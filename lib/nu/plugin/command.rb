module Nu
  module Plugin
    class Command
      class << self
        def before_action(action)
          @before = action
        end

        def after_action(action)
          @after = action
        end

        def name(command_name)
          @name = command_name
        end

        def flag(named_flag)
          @flags ||= [] << named_flag
        end
      end

      def configuration
        config = {
          name: self.class.instance_variable_get("@name"),
          named: self.class.instance_variable_get("@flags") || {},
          usage: "hola usage",
          positional: []
        }

        command_type = type

        config.merge! Hash[command_type.to_sym, true] if command_type
        config
      end

      private
      def type
        return "is_filter" if public_methods(false).include? :filter
        return "is_sink" if public_methods(false).include? :sink
      end
    end
  end
end
