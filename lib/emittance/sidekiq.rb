# frozen_string_literal: true

require 'sidekiq'
require 'emittance'

require 'emittance/sidekiq/version'
require 'emittance/sidekiq/errors'

require 'emittance/sidekiq/broker'

require 'emittance/sidekiq/event_fanout_job'
require 'emittance/sidekiq/process_event_job'

require 'emittance/sidekiq/serializers/json'

module Emittance
  ##
  # Top-level namespace for the Sidekiq broker for Emittance.
  #
  module Sidekiq
    FANOUT_JOB = Emittance::Sidekiq::EventFanoutJob
    PROCESS_EVENT_JOB = Emittance::Sidekiq::ProcessEventJob

    class << self
      # @private
      attr_accessor :event_serializer

      def fanout_queue=(queue)
        FANOUT_JOB.sidekiq_options queue: queue
      end

      def default_process_event_queue=(queue)
        PROCESS_EVENT_JOB.sidekiq_options queue: queue
      end

      # @private
      def callback_repository
        @callback_repository ||= {}
      end

      # @private
      def serialize_event(event)
        event_serializer.dump(event)
      end

      # @private
      def deserialize_event(event_hsh)
        event_serializer.load(event_hsh)
      end
    end
  end
end

# :nocov:
Emittance::Brokerage.register_broker Emittance::Sidekiq::Broker, :sidekiq
Emittance::Sidekiq.event_serializer = Emittance::Sidekiq::Serializers::JSON
# :nocov:
