module NuPlugin
  class Spec
    attr_accessor :binary
    attr_reader :data

    def initialize(opts)
      @binary = opts[:command]
      @view = opts[:view]
      @packer = opts[:packer]
    end

    def ready(view)
      @view = view
    end

    def config(args=nil)
      @data = @binary.configuration
      @view.configuration_ready
    end

    def format_stream!
      @data = Ok do
        [].tap do |values|
          @output.flatten.map do |value|
            values << Ok do
              Hash[:Value, @packer.nuvalize(value)]
            end
          end
        end
      end
    end

    def begin_filter(call_info)
      klass = @binary.class
      before_method = klass.instance_variable_get('@before')
      captures = klass.instance_variable_get('@captures') || []

      switches = @binary.configuration[:named].select {|flag, spec| spec.first.has_key?(:Switch)}.keys.map(&:to_sym)
      optionals = @binary.configuration[:named].select {|flag, spec| spec.first.has_key?(:Optional)}.keys.map(&:to_sym)

      args_passed = (call_info["args"]["named"] || []).reduce({}) do |args, (name, value)|
        converted = @packer.rubytize(value)

        @binary.instance_variable_set("@#{name}", converted)
        args.merge(name.to_sym => converted)
      end
      
      args_passed.each do |(name, value)|
        capture = captures.find {|action| action[name]}
        @binary.instance_exec(value, &capture.values.first) if capture
      end

      (switches - args_passed.keys).each do |no_switch_passed|
        args_passed.merge!(no_switch_passed => false)
        @binary.instance_variable_set("@#{no_switch_passed}", false)
      end

      (optionals - args_passed.keys).each do |none|
        args_passed.merge!(none => nil)
        # check again (sometimes we want to set instance var in class directly instead of relying on nil if not passed from Nu
        #@binary.instance_variable_set("@#{none}", nil)
      end

      @binary.instance_variable_set('@args', Named.new(args_passed))
      @binary.send(before_method) if before_method
      @output = []
      format_stream!
      @view.before_filter_ready
    end

    class Named
      def initialize(arguments)
        @arguments = arguments
      end

      def method_missing(name, *args, &block)
        begin
          argument = name[...-1].to_sym
          exists = @arguments.has_key?(argument)

          value = @arguments[argument]

          return value if [TrueClass, FalseClass].include?(value.class)
          return false if value.nil?
          return exists
        end if name.end_with?('?')

        return @arguments.fetch(name) if @arguments.has_key? name
        super.method_missing name, *args, &block
      end
    end

    def end_filter
      klass = @binary.class
      end_method = klass.instance_variable_get('@after')
      @output = begin
        if end_method
          [@binary.send(end_method)]
        else
          @binary.respond_to?(:end_filter) ? [@binary.end_filter] : []
        end
      end
      format_stream!
      @view.end_filter_ready
    end

    def start_filter(input)
      klass = @binary.class
      NuPlugin.log("filtering input #{input}")
      output = @binary.filter(@packer.rubytize(input))

      @output = begin
        if klass.instance_variable_get('@silent') == :filter
          []
        else
          output ? [output] : []
        end
      end

      format_stream!
      @view.filter_done
    end

    def Ok(&block)
      { Ok: block.call }
    end

    def filter
      @view.filter_ready
    end

    def sink
      @view.sink_ready
    end

    def start_sink(call_info, *inputs)
      klass = @binary.class
      captures = klass.instance_variable_get('@captures') || []

      switches = @binary.configuration[:named].select {|flag, spec| spec.first.has_key?(:Switch)}.keys.map(&:to_sym)
      optionals = @binary.configuration[:named].select {|flag, spec| spec.first.has_key?(:Optional)}.keys.map(&:to_sym)

      args_passed = (call_info["args"]["named"] || []).reduce({}) do |args, (name, value)|
        converted = @packer.rubytize(value)

        @binary.instance_variable_set("@#{name}", converted) if converted
        args.merge(name.to_sym => converted)
      end
      
      args_passed.each do |(name, value)|
        capture = captures.find {|action| action[name]}
        @binary.instance_exec(value, &capture.values.first) if capture
      end

      (switches - args_passed.keys).each do |no_switch_passed|
        args_passed.merge!(no_switch_passed => false)
        @binary.instance_variable_set("@#{no_switch_passed}", false)
      end

      (optionals - args_passed.keys).each do |none|
        args_passed.merge!(none => nil)
        # check again (sometimes we want to set instance var in class directly instead of relying on nil if not passed from Nu
        #@binary.instance_variable_set("@#{none}", nil)
      end

      @binary.instance_variable_set('@args', Named.new(args_passed))

      input = inputs.flatten.map { |value| @packer.rubytize(value) }

      @data = (input.empty? || input.first.nil?) ? @binary.sink : @binary.sink(input)
      @view.sink_done
    end

    def quit
      @view.quit_ready
      @data = []
    end
  end
end
