module Nu
  module Plugin
    class Spec
      attr_accessor :binary
      attr_reader :data

      def initialize opts
        @binary = opts[:command]
        @view = opts[:view]
        @packer = opts[:packer]
      end

      def ready(view)
        @view = view
      end

      def config
        @data = @binary.configuration
        @view.configuration_ready
      end

      def begin_filter
        klass = @binary.class
        before_method = klass.instance_variable_get("@before")
        output = (before_method ? @binary.send(before_method) : [])
        @data = (output.empty? ? [] : @packer.nuvalize(output))
        @view.before_filter_ready
      end

      def filter
        @view.filter_ready
      end

      def start_filter input
        input = @packer.rubytize(input)
        output = @binary.filter(input)
        @data = @packer.nuvalize(output)
        @view.filter_done
      end

      def end_filter
        klass = @binary.class
        end_method = klass.instance_variable_get("@after")
        output = (end_method ? @binary.send(end_method) : [])
        @data = (output.empty? ? [] : @packer.nuvalize(output))
        @view.end_filter_ready
      end

      def quit
        @view.quit_ready
        @data = []
      end
    end
  end
end
