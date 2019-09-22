module Nu
  module Plugin
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

        def flag(named_flag)
          @flags ||= [] << named_flag
        end
      end

      def configuration
        {
          name: self.class.instance_variable_get("@name"),
          named: self.class.instance_variable_get("@flags") || {},
          usage: "hola usage",
          positional: [],
          rest_positional: nil,
          is_filter: is_filter?
        }
      end

      private
      def is_filter?
        public_methods(false).include? :filter
      end
    end
  end
end
