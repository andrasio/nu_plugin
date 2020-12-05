module NuPlugin
  class Command
    class << self
      def inherited(klass)
        NuPlugin.commands << klass
      end

      def silent(action)
        @silent = action
      end

      def before_action(action)
        @before = action
      end

      def after_action(action)
        @after = action
      end

      def name(command_name)
        @name = command_name
      end

      def usage(desc)
        @usage = desc
      end

      def switch(name, rest = {}, &spec)
        begin
          captures = instance_eval(&spec)

          (@captures ||= []) << {name.to_sym => captures} if captures.is_a?(Proc)
        end if block_given?

        flag name.to_sym => SwitchFlag.build(rest, &spec)
      end

      class SwitchFlag
        attr_reader :c, :usage

        class << self
          def build(properties = {}, &spec)
            new(properties, &spec).nuvalize
          end  
        end

        def initialize(properties = {}, &spec)
          @c = properties[:short]
          @usage = properties[:desc]

          instance_eval(&spec) if block_given?
        end

        def nuvalize
          [{Switch: @c}, @usage || ""]
        end

        def type(klass)
          # no-op..
          self
        end

        def short(character)
          @c = character
          self
        end

        def desc(usage_text)
          @usage = usage_text
          self
        end

        def present(&block)
          # no-op..
        end
      end

      def optional(name, rest = {}, &spec)
        begin
          captures = instance_eval(&spec)

          (@captures ||= []) << {name.to_sym => captures} if captures.is_a?(Proc)
        end if block_given?

        flag name.to_sym => OptionalFlag.build(rest, &spec)
      end

      def method_missing(name, *args, &block)
        return block if name == :present
        []
      end

      private
      def flag(named_flag)
        (@flags ||= []) << named_flag
      end
    end

    class OptionalFlag
      attr_reader :ty, :c, :usage

      class << self
        def build(properties = {}, &spec)
          new(properties, &spec).nuvalize
        end  
      end

      def initialize(properties = {}, &spec)
        @ty = properties[:type]
        @c = properties[:short]
        @usage = properties[:desc]

        instance_eval(&spec) if block_given?
      end

      def nuvalize
        [{Optional: [@c, @ty]}, @usage || ""]
      end

      def type(klass)
        @ty = "String" if klass == String
        @ty = "Any" if klass == Array || klass == Object
        @ty = "Int" if klass == Integer
        self
      end

      def short(character)
        @c = character
        self
      end

      def desc(usage_text)
        @usage = usage_text
        self
      end

      def present(&block)
        # no-op..
      end
    end

    def args
      @args
    end

    def configuration
      cmd_name = self.class.instance_variable_get('@name')

      {
        name: cmd_name,
        named: (self.class.instance_variable_get('@flags') || []).reduce({}) {|flags, f| flags.merge(f)},
        usage: self.class.instance_variable_get('@usage') || cmd_name,
        positional: [],
        rest_positional: nil,
        yields: nil,
        input: nil, 
        is_filter: filter?
      }
    end

    private
    def filter?
      public_methods(false).include? :filter
    end
  end
end
