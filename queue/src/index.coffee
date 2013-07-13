WebSocketTransport = require('./transport/WebSocketTransport').WebSocketTransport
config = require('./config')

gotWebSocketMessage = (message, connection) ->
  console.log message

  

gotWebSocketConnection =  (connection) ->
  connection.on 'message', gotWebSocketMessage
  connection.on 'disconnect', () ->
    connection.removeAllListeners()

# set up websocket server
websocketTransport = new WebSocketTransport config.websocket
console.log "WebSocket server started"
websocketTransport.on 'connection', gotWebSocketConnection
