require './spec/support/runner'

class ConfigStagePluginTest
  include Runner

  def initialize(binary_path)
    @binary_path  = binary_path
  end

  def command
    @command ||= "help commands | where name == \"#{@binary_path.split('/').first}\" | count"
  end
end

class FilterStagePluginTest
  include Runner

  attr_reader :command

  def initialize(binary_path)
    @binary_path  = binary_path
    @command = "echo 'andres' | #{@binary_path.split('/').first}"
  end
end

class SinkStagePluginTest
  include Runner

  attr_reader :command

  def initialize(binary_path)
    @binary_path  = binary_path
    @command = "#{@binary_path.split('/').first}"
  end
end

describe 'Nu plugin lifecycle hooks' do
  context 'Configuration stage' do
    it 'registers correctly' do
      actual = ConfigStagePluginTest.new('len-ruby-test/bin').run!
      expect(actual).to eql('1')
    end

    it 'registers named flags' do
      binary = ConfigStagePluginTest.new('arguments/bin')
      require File.join(binary.plugin, '../', 'cases.rb')

      binary.command = ArgumentTests.named(arg1: "value")
      actual = binary.run!
      expect(actual).to eql('arg1=value|arg2=')

      binary.command = ArgumentTests.named(arg1: "\"another value\"")
      actual = binary.run!
      expect(actual).to eql("arg1=another value|arg2=")

      binary.command = ArgumentTests.named(arg1: "value", arg2: "\"another value\"")
      actual = binary.run!
      expect(actual).to eql("arg1=value|arg2=another value")
    end

    it 'registers switch flags' do
      binary = ConfigStagePluginTest.new('arguments/bin')
      require File.join(binary.plugin, '../', 'cases.rb')

      binary.command = ArgumentTests.switch(:arg1)
      actual = binary.run!
      expect(actual).to eql('arg1=true|active=true|arg2=false')

      binary.command = ArgumentTests.switch(:arg1, :arg2)
      actual = binary.run!
      expect(actual).to eql('arg1=true|active=true|arg2=true')
    end
  end

  context 'Filtering stage' do
    it 'filters the values' do
      actual = FilterStagePluginTest.new('len-ruby-test/bin').run!
      expect(actual.to_i).to be('andres'.size)
    end
  end

  context 'Sink stage' do
    it "sinks" do
      actual = SinkStagePluginTest.new('hello-plain-test/bin').run!
      expect(actual).to eq('Andrés')
    end
  end
end
