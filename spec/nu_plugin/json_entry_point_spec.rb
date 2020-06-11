require 'nu_plugin'

require './spec/support/request_helpers'

RSpec.configure do |c|
  c.include RequestHelpers
end

describe NuPlugin::JsonEntryPoint do
  let(:plugin) { double(:plugin).as_null_object }
  let(:ui) { NuPlugin::JsonEntryPoint.new(plugin) }

  it 'can be started' do
    expect(ui.plugin).to be(plugin)
  end

  context 'Plugin setup' do
    it 'starts a plugin setup' do
      ui.io = [stub_config_request, StringIO.new]

      expect(plugin).to receive(:config)
      ui.main
    end
  end
end
