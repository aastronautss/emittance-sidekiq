# frozen_string_literal: true

require 'emittance/sidekiq/dispatcher'

module Emittance
  module Sidekiq
    ##
    # The Sidekiq broker for Emittance.
    #
    class Broker < Emittance::Broker
      class << self
        def process_event(event)
          dispatcher.process_event(event)
        end

        def dispatcher
          Emittance::Sidekiq::Dispatcher
        end
      end
    end
  end
end
