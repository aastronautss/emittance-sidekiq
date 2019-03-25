# frozen_string_literal: true

RSpec.describe Emittance::Sidekiq::Callback do
  describe '.for_proc' do
    it 'takes a callable runner and a hash with an :on key' do
      expect(Emittance::Sidekiq::Callback.for_proc(-> {}, on: :id1)).to be_a(Emittance::Sidekiq::Callback)
    end

    it 'transforms the :on options key to an ID' do
      callback = Emittance::Sidekiq::Callback.for_proc(-> {}, on: :id2)

      expect(callback.id).to eq(:id2)
    end

    it 'runs the passed-in runner when the return value is called' do
      receiver = spy('call me')
      the_lambda = ->(event) { event.called! }
      callback = Emittance::Sidekiq::Callback.for_proc(the_lambda, on: :id3)

      callback.call(receiver)

      expect(receiver).to have_received(:called!)
    end

    it 'throws when the passed-in runner is not callable' do
      expect { Emittance::Sidekiq::Callback.for_proc('this should blow up', on: :id4) }.to raise_error(ArgumentError)
    end
  end

  describe '.for_method_call' do
    it 'runs the method call when the return value is called' do
      receiver = spy('receiver')
      callback = Emittance::Sidekiq::Callback.for_method_call(receiver, :method1, {})
      event = :the_event

      callback.call(event)

      expect(receiver).to have_received(:method1).with(event)
    end

    it 'generates an ID from the object and the method by default' do
      receiver = double('receiver', to_s: 'receiver')
      callback = Emittance::Sidekiq::Callback.for_method_call(receiver, :method2, {})

      expect(callback.id).to eq(:'receiver.method2')
    end

    it 'uses the ID from the :on key if given' do
      callback = Emittance::Sidekiq::Callback.for_method_call('some obj', :method3, on: :id5)

      expect(callback.id).to eq(:id5)
    end
  end

  describe '#initialize' do
    it 'rejects a non-symbolizable ID' do
      expect { Emittance::Sidekiq::Callback.new(double('not symbolizable'), -> {}) }.to raise_error(ArgumentError)
    end
  end
end
