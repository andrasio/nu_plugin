module Runner
  FIXTURES = File.join(File.dirname(__FILE__), '../fixtures/')

  attr_accessor :command

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def for(binary)
      runner = new
      runner.for(binary)
      runner.run!
    end
  end

  def plugin
    File.join(FIXTURES, @binary_path)
  end

  def run!
    with_plugin_paths do
      IO.popen([nu!, '-c', command], err: %i[child out]) do |out|
        self.out(out.read)
      end
    end
  end

  def out(data)
    data
  end

  def with_plugin_paths(&block)
    original_plugin_paths = []
    IO.popen([nu!, '-c', "config get plugin_dirs | to csv"], err: %i[child out]) do |out|
      original_plugin_paths = out.read.split(',')
    end
    IO.popen([nu!, '-c', "config set plugin_dirs [#{plugin}]"], err: %i[child out]) { |_| }
    block.call
  ensure
    IO.popen([nu!, '-c', "config set plugin_dirs [#{original_plugin_paths.join(' ')}]"], err: %i[child out]) { |_| }
  end

  private
  def nu!(program = 'nu')
    extensions = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']

    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      extensions.each do |extension|
        binary = File.join(path, "#{program}#{extension}")
        return binary if File.executable?(binary) && !File.directory?(binary)
      end
    end

    "#{ENV['NU_PATH']}/#{program}"
  end
end
