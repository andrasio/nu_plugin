require "nu/plugin"

RSpec.configure do |c|
  c.include RequestHelpers
end

describe Nu::Plugin::Spec do

  let(:view) { double(:view).as_null_object }
  let(:packer) { double(:packer).as_null_object }
  let(:command) { double(:command).as_null_object }
 
  let(:plugin) { 
    spec = Nu::Plugin::Spec.new command: command, packer: packer
    spec.ready(view)
    spec
  }

  it "starts a plugin setup" do
    expect(view).to receive(:configuration_ready)
    plugin.config
  end

  it "gathers actions before filtering" do
    expect(view).to receive(:before_filter_ready)
    plugin.begin_filter
  end

  it "prepares filtering" do 
    expect(view).to receive(:filter_ready)
    plugin.filter
  end

  it "gathers actions after filtering" do  
    expect(view).to receive(:end_filter_ready)
    plugin.end_filter
  end

  it "quits the plugin" do
    expect(view).to receive(:quit_ready)
    plugin.quit
  end
end
