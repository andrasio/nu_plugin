module NuPlugin
  class Command
    class << self
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

      def flag(named_flag)
        @flags ||= [] << named_flag
      end
    end

    def configuration
      cmd_name = self.class.instance_variable_get('@name')

      {
        name: cmd_name,
        named: self.class.instance_variable_get('@flags') || {},
        usage: self.class.instance_variable_get('@usage') || cmd_name,
        positional: [],
        rest_positional: nil,
        is_filter: filter?
      }
    end

    private

    def filter?
      public_methods(false).include? :filter
    end
  end
end
