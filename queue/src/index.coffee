server = require('ws').Server
url = require('url')

TIMEOUT = 60000

connections = {}

setConnectionTimeout = (connection) ->
  if connection._timeout?
    clearTimeout connection._timeout
  connection._timeout = setTimeout connection.close, TIMEOUT

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
    connection.send JSON.stringify packet
    setConnectionTimeout connection

gotConnection = (connection) ->
  urlobj = url.parse(connection.upgradeReq.url)
  if urlobj.pathname is "/queue" and urlobj.query.slice(0, 3) is "key"
    key = urlobj.query.slice(4)
    connections[key] = connection
    connection.on 'message', (message) ->
      gotMessage connection, message
    setConnectionTimeout connection
  else
    connection.close()

wss = new server({port: 9000})
wss.on 'connection', (connection) ->
  gotConnection connection
