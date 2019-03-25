# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emittance::Sidekiq::EventFanoutJob do
  describe '#perform' do
    let(:serialized_event) { { "emitter" => nil, "timestamp" => Time.now.to_s, "payload" => { 'foo' => 'bar' } } }
    let(:deserialized_event) { double 'event', identifiers: ['identifier1'] }

    before do
      allow(Emittance::Sidekiq).to receive(:deserialize_event).and_return(deserialized_event)
      allow(Emittance::Sidekiq).to receive(:serialize_event).and_return(serialized_event)
    end

    it 'does not enqueue any jobs when there are no registrations' do
      allow(Emittance::Sidekiq::Dispatcher).to receive(:registrations_for).and_return([])

      Emittance::Sidekiq::EventFanoutJob.new.perform(serialized_event)

      expect(Emittance::Sidekiq::PROCESS_EVENT_JOB.jobs.size).to be_zero
    end

    it 'enqueues a job for a single registration' do
      allow(Emittance::Sidekiq::Dispatcher).to receive(:registrations_for).and_return([double('registration1', id: 'a')])

      Emittance::Sidekiq::EventFanoutJob.new.perform(serialized_event)

      expect(Emittance::Sidekiq::PROCESS_EVENT_JOB.jobs.size).to eq(1)
    end

    it 'enqueues a job for multiple registrations' do
      allow(Emittance::Sidekiq::Dispatcher).to(
        receive(:registrations_for).and_return([double('registration1', id: 'a'), double('registration2', id: 'b')])
      )

      Emittance::Sidekiq::EventFanoutJob.new.perform(serialized_event)

      expect(Emittance::Sidekiq::PROCESS_EVENT_JOB.jobs.size).to eq(2)
    end

    it 'serializes the event before enqueuing the process-event job' do
      allow(Emittance::Sidekiq::Dispatcher).to receive(:registrations_for).and_return([double('registration1', id: 'a')])

      Emittance::Sidekiq::EventFanoutJob.new.perform(serialized_event)

      expect(Emittance::Sidekiq::PROCESS_EVENT_JOB.jobs.first['args'][1]).to eq(serialized_event)
    end
  end

  describe 'interface contracts' do
    specify { expect(Emittance::Sidekiq::Dispatcher).to respond_to(:registrations_for).with(1).argument }
    specify { expect(Emittance::Sidekiq).to respond_to(:deserialize_event).with(1).argument }
    specify { expect(Emittance::Sidekiq).to respond_to(:serialize_event).with(1).argument }
  end
end
