# frozen_string_literal: true

module Emittance
  module Sidekiq
    ##
    # Looks up all watchers for a given event and enqueues jobs that will run their callbacks.
    #
    class EventFanoutJob
      DEFAULT_QUEUE = :default

      include ::Sidekiq::Worker
      sidekiq_options queue: DEFAULT_QUEUE

      def perform(event)
        event = ::Emittance::Sidekiq.deserialize_event(event)

        registrations(event).each { |registration| enqueue_perform_job(registration, event) }
      end

      private

      def registrations(event)
        collections = event.identifiers.map { |identifier| Dispatcher.registrations_for(identifier) }

        output = []
        collections.each { |collection| collection.each { |element| output << element } }

        output
      end

      def enqueue_perform_job(registration, event)
        event = ::Emittance::Sidekiq.serialize_event(event)

        PROCESS_EVENT_JOB.perform_async(registration.id, event)
      end
    end
  end
end
