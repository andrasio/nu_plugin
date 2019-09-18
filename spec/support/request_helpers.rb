module RequestHelpers
  require "json"

  def stub_config_request
    io = StringIO.new
    io.write JSON.generate(config_sample)
    io.rewind
    io
  end

  def config_sample
    {jsonrpc:"2.0", method:"config", params:[]}
  end
end
