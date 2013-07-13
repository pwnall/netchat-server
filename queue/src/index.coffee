server = require('ws').Server
url = require('url')
http = require('http')

TIMEOUT = 60000
WEBSOCKET_PORT = process.env['PORT'] or 8443
HTTP_PORT = WEBSOCKET_PORT + 100

connections = {}

### HTTP Server###
onRequest = (request, response) ->
  data = ''
  request.on 'data', (fragment) -> data += fragment
  request.on 'end', ->
    console.log data
    try
      packet = JSON.parse(data)
      response.writeHead(204)
      response.end()
    catch err
      response.writeHead(500)
      response.end()

http.createServer(onRequest).listen HTTP_PORT

### WEBSOCKET Server###
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

wss = new server({port: WEBSOCKET_PORT})
wss.on 'connection', (connection) ->
  gotConnection connection

console.log "NetChat Queue Server listening on port #{WEBSOCKET_PORT}"
