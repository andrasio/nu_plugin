require 'nu_plugin/packing'
require 'nu_plugin/command'
require 'nu_plugin/spec'

module NuPlugin
  class Error < StandardError; end

  class << self
    def log(data)
      #File.open('/Users/andrasMAMA/Desktop/nuplugin.log', 'a+') do |fd|
      #  fd.puts(data)
      #end
    end

    def commands
      @commands ||= []
    end

    def command(name)
      begin
        cmd = @commands.find {|c| c.instance_variable_get('@name')  == name}

        JsonEntryPoint.run cmd: cmd
       rescue 
         # ...
      end
    end

    def configuration
      @configuration ||= Class.new
    end

    def configure
      yield configuration
    end
  end

  class JsonEntryPoint
    require 'json'

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
      @io ||= [ARGF, STDOUT]
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

        if @input['params'] && !['quit', 'filter', 'sink', 'end_filter'].include?(@input['method'])
          plugin.send(@input['method'].to_sym, @input['params'])
        else
          plugin.send(@input['method'].to_sym)
        end
      end while !@done
    end

    def configuration_ready
      NuPlugin.log("Configuration ready.")
      r = { Ok: plugin.data }
      respond(r)
    end

    def filter_ready
      NuPlugin.log("filter start.")
      plugin.start_filter(@input['params'])
    end

    def sink_ready
      plugin.start_sink(*@input['params'])
    end

    def filter_done
      NuPlugin.log("filter done.")
      respond(@plugin.data)
    end

    def sink_done
      NuPlugin.log("sink done.")
      @done = true
    end

    def before_filter_ready
      NuPlugin.log("before filtering.")
      respond(@plugin.data)
    end

    def end_filter_ready
      NuPlugin.log("after filtering.")
      respond(@plugin.data)
    end

    def quit_ready
      # respond(plugin.data)
    end

    def respond(data)
      NuPlugin.log("writing out #{JSON.generate({
        jsonrpc: '2.0',
        method: 'response',
        params: data
      })}.")
      write.puts JSON.generate({
                                 jsonrpc: '2.0',
                                 method: 'response',
                                 params: data
                               })

      write.flush
    end
  end
end
