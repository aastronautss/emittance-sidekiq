# frozen_string_literal: true

require 'emittance/sidekiq/callback'

module Emittance
  module Sidekiq
    ##
    # The Sidekiq dispatcher for Emittance.
    #
    # == Closures
    #
    # The Sidekiq adapter supports closures, with one caveat. Since the event fanout logic needs to know which callback
    # to fan out to, an additional key must be provided by the watcher.
    #
    #   something.watch('orders.create', on: :order_create_cool_stuff) { |event| do_some_cool_stuff_with(event) }
    #
    # This key must be unique.
    #
    class Dispatcher < Emittance::Dispatcher
      class << self
        private

        # Primary implementations

        def _process_event(event)
          event = serialize_event(event)

          FANOUT_JOB.perform_async(event)
        end

        def _register(identifier, callback_klass: Callback, **params, &callback)
          registration = callback_klass.for_proc(callback, params)

          save_registration(identifier, registration)
        end

        def _register_method_call(identifier, object, method_name, callback_klass: Callback, **params)
          validate_method_call(object, method_name)
          registration = callback_klass.for_method_call(object, method_name, params)

          save_registration(identifier, registration)
        end

        # Aux

        def serialize_event(event)
          Emittance::Sidekiq.serialize_event(event)
        end

        def save_registration(identifier, registration)
          registrations_for(identifier) << registration
          callbacks[registration.id] = registration
        end

        def callbacks
          @callbacks ||= ::Emittance::Sidekiq.callback_repository
        end

        def validate_method_call(object, _method_name)
          error_msg = 'Emittance::Sidekiq can only call methods on classes and modules'
          raise InvalidCallbackError, error_msg unless object.is_a?(Module)
        end
      end
    end
  end
end
