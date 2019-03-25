# frozen_string_literal: true

module Emittance
  module Sidekiq
    ##
    # Looks up a registration by a specific key and processes it
    #
    class ProcessEventJob
      DEFAULT_QUEUE = :default

      include ::Sidekiq::Worker
      sidekiq_options queue: DEFAULT_QUEUE

      def perform(callback_id, event)
        event = ::Emittance::Sidekiq.deserialize_event(event)
        event = defined?(::Emittance::Middleware) ? ::Emittance::Middleware.down(event) : event

        callback_for_id(callback_id).(event)
      end

      private

      def callback_for_id(callback_id)
        ::Emittance::Sidekiq.callback_repository[callback_id.to_sym]
      end
    end
  end
end
