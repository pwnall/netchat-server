server = require('ws').Server
url = require('url')
http = require('http')

TIMEOUT = 60000
WEBSOCKET_PORT = process.env['PORT'] or 8443
HTTP_PORT = WEBSOCKET_PORT + 100

users = {}

### HTTP Server###
sendLeftQueue = (key) ->
  res_url = users[key]?.url
  if res_url?
    urlobj = url.parse(res_url)
    options =
      host: urlobj.hostname,
      port: urlobj.port,
      path: urlobj.path + "?LEFT_MK=#{users[key].match_key}"
      method: 'GET'
    http.request options, (res) ->
      return
    .end()

parsePacket = (packet) ->
  key = packet.key
  delete packet["key"]
  users[key] = packet

onRequest = (request, response) ->
  data = ''
  request.on 'data', (fragment) -> data += fragment
  request.on 'end', ->
    try
      # FIXME: need to validate the packet
      console.log data
      packet = JSON.parse(data)
      response.writeHead(204)
      response.end()
      parsePacket packet
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
    if !users[key]?
      connection.send "Invalid user"
      connection.close()
      return
    users[key].connection = connection
    connection.on 'message', (message) ->
      gotMessage connection, message
    setConnectionTimeout connection

    connection.on 'close', () ->
      sendLeftQueue key
  else
    connection.close()

wss = new server({port: WEBSOCKET_PORT})
wss.on 'connection', (connection) ->
  gotConnection connection

console.log "NetChat Queue Server listening on port #{WEBSOCKET_PORT}"
