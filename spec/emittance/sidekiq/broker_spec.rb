# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emittance::Sidekiq::Broker do
  describe '.process_event' do
    let(:event) { double 'event' }

    it 'delegates to the dispatcher' do
      expect(Emittance::Sidekiq::Dispatcher).to receive(:process_event).with(event)

      Emittance::Sidekiq::Broker.process_event(event)
    end
  end
end
