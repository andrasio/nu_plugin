require './spec/support/runner'

class ConfigStagePluginTest
  include Runner

  def initialize(binary)
    @plugin  = binary
    @command = "help commands | where name == #{binary.split('/').first} | count | echo $it"
  end
end

class FilterStagePluginTest
  include Runner

  def initialize(binary)
    @plugin  = binary
    @command = "echo 'andres' | #{binary.split('/').first} | echo $it"
  end
end

describe 'Nu plugin lifecycle hooks' do
  context 'Configuration stage' do
    it 'registers correctly' do
      actual = ConfigStagePluginTest.new('len-ruby/bin').run!
      expect(actual).to eql('1')
    end
  end

  context 'Filtering stage' do
    it 'filters the values' do
      actual = FilterStagePluginTest.new('len-ruby/bin').run!
      expect(actual.to_i).to be('andres'.size)
    end
  end
end
