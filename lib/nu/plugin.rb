require "nu/plugin/version"
require "nu/plugin/data"
require "nu/plugin/command"
require "nu/plugin/spec"

module Nu
  module Plugin
    class Error < StandardError; end
    
    class JsonEntryPoint
      require "json"

      attr_accessor :plugin, :io

      def self.run(args)
        packer = Packing.new
        command = args.fetch(:cmd).new
        plugin = Spec.new command: command, packer: packer
        ui = JsonEntryPoint.new plugin: plugin
        ui.main
      end

      def initialize(opts = {})
        @plugin = opts.fetch(:plugin)
      end 

      def io
        @io ||= [STDIN, STDOUT]
      end

      def read
        io[0]
      end

      def write
        io[1]
      end

      def parse!
        line = read.gets

        if !line
          @done = true
          return
        end 

        @input = JSON.parse(line)
      end

      def main
        plugin.ready(self)

        begin
          parse!
          plugin.send(@input["method"].to_sym)
        end while !@done
      end

      def configuration_ready
        r = {Ok: plugin.data}
        respond(r)
      end

      def filter_ready
        plugin.start_filter(@input["params"])
      end

      def filter_done
        r = {Ok: [{ Ok: {Value: @plugin.data} }]}
        respond(r)
      end

      def before_filter_ready
        r = {Ok: @plugin.data}
        respond(r)
      end

      def end_filter_ready
        r = {Ok: [{ Ok: {Value: @plugin.data} }]}
        respond(r)
      end

      def quit_ready
        #respond(plugin.data)
      end

      def respond(data)
        write.puts JSON.generate({
          jsonrpc: "2.0", 
          method: "response", 
          params: data
        })

        write.flush
      end
    end
  end
end
