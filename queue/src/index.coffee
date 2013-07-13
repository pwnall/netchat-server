server = require('ws').Server

gotMessage = (connection, message) ->
  if typeof(message) == 'string'
    try
      packet = JSON.parse(message)
    catch err
      connection.close()
      console.log "invalid json package: #{message}"
      return

  if packet.method == "ping"
    packet.method = "pong"
    console.log packet
    connection.send JSON.stringify packet

gotConnection = (connection) ->
  connection.on 'message', (message) ->
    gotMessage connection, message
    

wss = new server({port: 9000})
wss.on 'connection', (connection) ->
  gotConnection connection
