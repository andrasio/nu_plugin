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

      def format_stream!
        @data = Ok do
          [].tap do |values|
            @output.flatten.map do |value|
              values << Ok do
                Hash[ :Value, @packer.nuvalize(value) ]
              end
            end
          end
        end
      end

      def begin_filter
        klass = @binary.class
        before_method = klass.instance_variable_get("@before")
        @output = (before_method ? [@binary.send(before_method)] : [])
        format_stream!
        @view.before_filter_ready
      end

      def end_filter
        klass = @binary.class
        end_method = klass.instance_variable_get("@after")
        @output = (end_method ? [@binary.send(end_method)] : [])
        format_stream!
        @view.end_filter_ready
      end

      def start_filter input
        input = @packer.rubytize(input)
        output = @binary.filter(input)
        @output = output ? [output] : []
        format_stream!
        @view.filter_done
      end

      def Ok &block
        {Ok: block.call}
      end

      def Err &block
        {ShellError: block.call}
      end

      def filter
        @view.filter_ready
      end

      def sink
        @view.sink_ready
      end

      def start_sink input
        input = input.map {|value| @packer.rubytize(value)}
        @data = @binary.sink(input)
        @view.sink_done
      end

      def quit
        @view.quit_ready
        @data = []
      end
    end
  end
end
