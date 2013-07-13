require 'eventmachine'
require 'evma_httpserver'
require 'English'
require 'json'

# :nodoc: namespace
module QueueSrv

class HttpServer
  def initialize(nexus)
    @nexus = nexus
    @log = nexus.log
  end

  def host
    @host ||= '0.0.0.0'
  end
  def ws_port
    @ws_port ||= (ENV['PORT'] ? ENV['PORT'].to_i : 8443)
  end
  def port
    @port ||= ws_port + 100
  end

  def run
    @log.info "HTTP Server PID #{$PID}, listening on #{host} port #{port}"

    HttpServerConnection.log = @log
    HttpServerConnection.nexus = @nexus
    EM.start_server host, port, HttpServerConnection
  end
end  # class QueueSrv::HttpServer


class HttpServerConnection < EM::Connection
  include EM::HttpServer

  class <<self
    attr_accessor :nexus
    attr_accessor :log
  end

  def post_init
    super
    no_environment_strings

    @nexus = self.class.nexus
    @log = self.class.log
  end

  def process_http_request
    begin
      @json_info = JSON.parse @http_post_content
      @log.debug { "HTTP: #{@http_path_info} - #{@json_info.inspect}" }

      if @http_path_info == '/user'
        # We received a user's profile.
        @nexus.user_profile @json_info do
          qs_respond_ok
        end
      elsif @http_path_info == '/user_left'
        # A user left.
        @nexus.user_left @json_info do
          qs_respond_ok
        end
      else
        # Unknown request.
        qs_respond_ok
      end
    rescue Exception => e
      qs_handle_exception e
    end
  end

  def qs_respond_ok
    response = EM::DelegatedHttpResponse.new self
    response.status = 204
    response.send_response
  end

  def qs_handle_exception(e)
    @log.warn "#{e.name}: #{e.message}\n#{e.backtrace.join("\n")}\n"

    response = EM::DelegatedHttpResponse.new self
    response.status = 500
    response.send_response
  end
end  # class QueueSrv::HttpServerConnection

end  # namespace QueueSrv
