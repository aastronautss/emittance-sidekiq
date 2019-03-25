# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emittance::Sidekiq::Serializers::JSON do
  subject { Emittance::Sidekiq::Serializers::JSON }

  describe '.dump' do
    let(:timestamp) { Time.now }
    let(:event) { Emittance::Event.new('the emitter', timestamp, { 'foobar' => 'foobaz' }) }

    before { allow(event).to receive(:identifiers).and_return(['some_event_identifier']) }

    context 'when event does not respond to #to_h' do
      before { allow(event).to receive(:respond_to?).with(:to_h).and_return(false) }

      it 'adds the identifier name key to the resulting hash' do
        expect(subject.dump(event)['_identifier']).to eq('some_event_identifier')
      end

      it 'adds the emitter to the resulting hash' do
        expect(subject.dump(event)['@emitter']).to eq('the emitter')
      end

      it 'adds the timestamp to the resulting hash' do
        expect(subject.dump(event)['@timestamp']).to eq(timestamp)
      end

      it 'adds the payload to the resulting hash' do
        expect(subject.dump(event)['@payload']).to eq('foobar' => 'foobaz')
      end

      it 'adds any additional instance variables to the resulting hash' do
        event.instance_variable_set('@some_ivar', 'hello world')

        expect(subject.dump(event)['@some_ivar']).to eq('hello world')
      end
    end

    context 'when the event does respond to #to_h' do
      before do
        allow(event).to receive(:respond_to?).with(:to_h).and_return(true)
        allow(event).to receive(:to_h).and_return(
          emitter: 'some other emitter', timestamp: timestamp, payload: { 'a' => 'b' }
          )
      end

      it 'adds the identifier name key to the resulting hash' do
        expect(subject.dump(event)['_identifier']).to eq('some_event_identifier')
      end

      it 'keeps the emitter, timestamp, and payload intact' do
        result = subject.dump(event)

        expect(result[:emitter]).to eq('some other emitter')
        expect(result[:timestamp]).to eq(timestamp)
        expect(result[:payload]).to eq('a' => 'b')
      end
    end
  end

  describe '.load' do
    it 'returns the default class when there is not event identifier specified' do
      input = {}

      expect(subject.load(input)).to be_a(Emittance::Event)
    end

    it 'returns the specified class when it is specified' do
      stub_const('MyEventKlassEvent', Class.new(Emittance::Event))
      input = { '_identifier' => 'my_event_klass' }

      expect(subject.load(input)).to be_a(MyEventKlassEvent)
    end

    context 'when the event class does not respond to #from_h' do
      before { allow(Emittance::Event).to receive(:respond_to?).with(:from_h).and_return(false) }

      it 'sets the appropriate instance variables from plain keys' do
        input = { 'emitter' => 'oh hey this worked', 'timestamp' => 12345, 'payload' => 'hello payload' }

        expect(subject.load(input).emitter).to eq('oh hey this worked')
        expect(subject.load(input).payload).to eq('hello payload')
      end

      it 'sets additional instance variables with plain keys' do
        input = { 'topic' => 'something.happened' }

        expect(subject.load(input).instance_variable_get('@topic')).to eq('something.happened')
      end
    end

    context 'when the event class responds to #from_h' do
      let(:output) { Emittance::Event.new(nil, nil, nil) }

      before do
        allow(Emittance::Event).to receive(:respond_to?).with(:from_h).and_return(true)
        allow(Emittance::Event).to receive(:from_h).and_return(output)
      end

      it 'calls #from_h' do
        expect(subject.load({})).to eq(output)
      end
    end
  end
end
