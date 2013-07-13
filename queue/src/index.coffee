WebSocketTransport = require('./transport/WebSocketTransport')
#config = require('./config')

gotWebSocketMessage = (message, connection) ->
  console.log message

  

gotWebSocketConnection =  (connection) ->
  connection.on 'message', gotWebSocketMessage
  connection.on 'disconnect', () ->
    connection.removeAllListeners()

# set up websocket server
port = process.env['PORT'] or 8443
websocketTransport = new WebSocketTransport({host: "localhost", port: port})
console.log "NetChat Queue Server listening on port #{port}"
websocketTransport.on 'connection', gotWebSocketConnection
