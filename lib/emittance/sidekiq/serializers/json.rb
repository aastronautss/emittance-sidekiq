# frozen_string_literal: true

module Emittance
  module Sidekiq
    module Serializers
      ##
      # The standard JSON serializer for an event. Later versions of Emittance provide the +#to_h+ and +.from_h+ methods
      # for ease of serialization, but this serializer is backwards compatible with version of Emittance that do not
      # provide those interfaces.
      #
      module JSON
        class << self
          IDENTIFIER_KEY_NAME = '_identifier'

          def dump(event_obj)
            base =
              if event_obj.respond_to?(:to_h)
                event_obj.to_h
              else
                event_obj.instance_variables.map do |var|
                  [var.to_s, event_obj.instance_variable_get(var)]
                end.to_h
              end

            base.merge(IDENTIFIER_KEY_NAME => event_obj.identifiers.first)
          end

          def load(event_hsh)
            identifier = event_hsh.delete(IDENTIFIER_KEY_NAME)
            event_klass = Emittance::Event.event_klass_for(identifier)

            if event_klass.respond_to?(:from_h)
              event_klass.from_h(event_hsh)
            else
              event_klass.new(nil, nil, nil).tap do |event|
                event_hsh.each do |var, value|
                  ivar = var.start_with?('@') ? var : "@#{var}"
                  event.instance_variable_set(ivar, value)
                end
              end
            end
          end
        end
      end
    end
  end
end
