# frozen_string_literal: true

module Emittance
  module Sidekiq
    ##
    # @private
    #
    class Callback
      attr_reader :id, :runner, :queue

      class << self
        def for_proc(the_proc, opts)
          id = opts[:on]
          queue = opts[:queue] || ProcessEventJob::DEFAULT_QUEUE

          new(id, the_proc, queue)
        end

        def for_method_call(object, method_name, opts)
          new(id_for_method_call(object, method_name, opts), proc_for_method_call(object, method_name))
        end

        private

        def id_for_method_call(object, method_name, opts)
          opts[:on] || "#{object}.#{method_name}"
        end

        def proc_for_method_call(object, method_name)
          ->(event) { object.send(method_name, event) }
        end
      end

      def initialize(id, runner, queue = ProcessEventJob::DEFAULT_QUEUE)
        raise ArgumentError, 'A symbolizable ID must be provided' unless id.respond_to?(:to_sym)
        raise ArgumentError, 'A callable runner must be provided' unless runner.respond_to?(:call)

        @id = id.to_sym
        @runner = runner
        @queue = queue
      end

      def call(event)
        runner.(event)
      end
    end
  end
end
