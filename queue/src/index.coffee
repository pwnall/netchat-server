server = require('ws').Server
url = require('url')

gotMessage = (connection, message) ->
  if typeof(message) == 'string'
    try
      packet = JSON.parse(message)
    catch err
      connection.close()
      console.log "invalid json package: #{message}"
      return

  if packet.method is "ping"
    packet.method = "pong"
    console.log packet
    connection.send JSON.stringify packet

gotConnection = (connection) ->
  urlobj = url.parse(connection.upgradeReq.url)
  if urlobj.pathname is "/queue" and urlobj.query.slice(0, 3) is "key"
    key = urlobj.query.slice(4)
    console.log key
    connection.on 'message', (message) ->
      gotMessage connection, message
  else
    connection.close()

wss = new server({port: 9000})
wss.on 'connection', (connection) ->
  gotConnection connection
