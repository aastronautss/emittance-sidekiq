# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emittance::Sidekiq::Dispatcher do
  let(:event) { double 'event', identifiers: ['something_happened'] }

  subject { Emittance::Sidekiq::Dispatcher }

  describe '.process_event' do
    it 'enqueues the fanout job' do
      subject.process_event(event)

      expect(Emittance::Sidekiq::FANOUT_JOB.jobs.size).to eq(1)
    end
  end

  describe '.register' do
    let(:callback) { double 'callback', id: 'id1' }
    let(:callback_klass) { double 'callback_klass', for_proc: callback }
    let(:block) { ->(event) { 'do stuff' } }

    it 'adds a registration' do
      subject.register('identifier1', callback_klass: callback_klass, &block)

      expect(subject.registrations_for('identifier1')).to include(callback)
    end

    it 'adds the callback to the repository' do
      expect(Emittance::Sidekiq.callback_repository['id1']).to be_nil # sanity check
      subject.register('identifier2', callback_klass: callback_klass, &block)

      expect(Emittance::Sidekiq.callback_repository['id1']).to eq(callback)
    end

    it 'pulls the callback from the callback_klass' do
      expect(callback_klass).to receive(:for_proc).and_return(callback)

      subject.register('identifier3', callback_klass: callback_klass, &block)
    end
  end

  describe '.register_method_call' do
    let(:callback) { double 'callback', id: 'id1' }
    let(:callback_klass) { double 'callback_klass', for_method_call: callback }

    it 'rejects a non-module object' do
      expect do
        subject.register_method_call('identifier4', 'not a module', :foobar, callback_klass: callback_klass)
      end.to raise_error(Emittance::Sidekiq::InvalidCallbackError)
    end

    it 'registers the wrapped callback' do
      subject.register_method_call('identifier5', Class.new, :a_method, callback_klass: callback_klass)

      expect(subject.registrations_for('identifier5')).to include(callback)
    end

    it 'adds the callback to the repository' do
      expect(Emittance::Sidekiq.callback_repository['id1']).to be_nil # sanity check
      subject.register_method_call('identifier6', Class.new, :a_method, callback_klass: callback_klass)

      expect(Emittance::Sidekiq.callback_repository['id1']).to eq(callback)
    end

    it 'pulls the callback from the callback_klass' do
      identifier = 'identifier7'
      klass = Class.new
      method = :a_method

      expect(callback_klass).to receive(:for_method_call).with(klass, method, kind_of(Hash)).and_return(callback)

      subject.register_method_call(identifier, klass, method, callback_klass: callback_klass)
    end
  end

  describe 'interface contracts' do
    specify { expect(Emittance::Sidekiq::Callback).to respond_to(:for_proc).with(2).arguments }
    specify { expect(Emittance::Sidekiq::Callback).to respond_to(:for_method_call).with(3).arguments }

    specify { expect(Emittance::Sidekiq::Callback.new('id1', -> {})).to respond_to(:id) }
    specify { expect(Emittance::Sidekiq::Callback.new('id1', -> {})).to respond_to(:runner) }
  end
end
