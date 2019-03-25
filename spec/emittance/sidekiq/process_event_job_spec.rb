# frozen_string_literal: true

RSpec.describe Emittance::Sidekiq::ProcessEventJob do
  describe '#perform' do
    let(:callback) { double 'callback', call: nil }
    let(:event) { {} }
    before { allow(::Emittance::Sidekiq.callback_repository).to receive(:[]).and_return(callback) }

    it 'looks up the callback by symbolized ID' do
      Emittance::Sidekiq::ProcessEventJob.new.perform('a', event)

      expect(::Emittance::Sidekiq.callback_repository).to have_received(:[]).with(:a)
    end

    it 'calls the callback' do
      Emittance::Sidekiq::ProcessEventJob.new.perform('b', event)

      expect(callback).to have_received(:call).with(kind_of(Emittance::Event))
    end
  end

  describe 'interface contracts' do
    specify { expect(::Emittance::Sidekiq.callback_repository).to respond_to(:[]).with(1).argument }
  end
end
