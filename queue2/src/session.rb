require 'json'

# :nodoc: namespace
module QueueSrv

# A user's browser session.
class Session
  attr_reader :user

  def initialize(web_socket, nexus)
    @ws = web_socket
    @nexus = nexus
    @user = nil
    @nonces = Set.new
  end

  # Called after the WebSocket handshake completes.
  def connected(query)
    join_key = query['key']
    if join_key
      @nexus.user_by_key join_key do |user|
        if user
          @user = user
          # Close old sessions. These are other tabs, and we shouldn't have
          # multiple tabs go into the chat window.
          @user.sessions.each do |old_session|
            old_session.respond method: 'old'
          end
          @user.add_session self
          respond method: 'hi'
        else
          @ws.close_websocket
        end
      end
    else
      @ws.close_websocket
    end
  end

  # Called when the client closes the WebSocket.
  def closed
    if @user
      @user.remove_session self
    end
  end

  # Called when the client sends some data.
  def received(message)
    if message.respond_to?(:encoding) && message.encoding != 'UTF-8'
      message.force_encoding 'UTF-8'
    end
    data = JSON.parse message, :symbolize_names => true

    case data[:method]
    when 'ping'
      data[:method] = 'pong'
      respond data
    end
  end

  # Tell the client we found a match
  def send_matched
    respond method: 'matched'
  end

  # Returns data to the client.
  def respond(data)
    @ws.send JSON.unparse(data)
  end
end  # class QueueSrv::Session

end  # namespace QueueSrv
