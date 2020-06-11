module RequestHelpers
  require 'json'

  def stub_config_request
    io = StringIO.new
    io.write JSON.generate(config_request)
    io.rewind
    io
  end

  def config_request
    { jsonrpc: '2.0', method: 'config', params: [] }
  end

  def begin_filter_request
    { jsonrpc: '2.0', method: 'begin_filter', params: [] }
  end
end
