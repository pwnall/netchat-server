require 'em-websocket'
require 'English'
require 'json'

# :nodoc: namespace
module QueueSrv

class WebSocketServer
  def initialize(nexus)
    @nexus = nexus
    @log = nexus.log
  end

  def host
    @host ||= '0.0.0.0'
  end
  def port
    @port ||= (ENV['PORT'] ? ENV['PORT'].to_i : 8443)
  end
  def http_port
    @http_port ||= port + 100
  end

  def run
    @log.info "Server PID #{$PID}, listening on #{host} port #{port}"
    server_settings = { :host => host, :port => port }
    if ENV['RACK_ENV'] == 'production'
      server_settings[:secure] = true
      server_settings[:tls_options] = { :private_key_file => 'ssl/chatty.pem',
          :cert_chain_file => 'ssl/chatty.crt', :verify_peer => false }
    end

    EventMachine::WebSocket.start server_settings do |ws|
      session = Session.new ws, @nexus
      ws.onopen do |handshake|
        @log.debug { "WebSocket #{ws.inspect} opened: #{handshake.inspect}" }
        session.connected handshake.query
      end
      ws.onclose do
        @log.debug 'WebSocket closed'
        session.closed
      end
      ws.onmessage { |m| session.received m }
      ws.onping do |m|
        @log.debug "WebSocket ping"
      end
    end
  end
end  # class QueueSrv::WebSocketServer

end  # namespace QueueSrv
