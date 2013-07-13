server = require('ws').Server
url = require('url')
http = require('http')
querystring = require('querystring')
matching = require('./matching')

TIMEOUT = 60000
WEBSOCKET_PORT = process.env['PORT'] or 8443
HTTP_PORT = WEBSOCKET_PORT + 100

users = {}

### HTTP Server###
sendRequest = (urlobj, params, callback) ->
  options =
    host: urlobj.hostname,
    port: urlobj.port,
    path: "#{urlobj.path}?#{querystring.stringify(params)}"
    method: 'GET'
  http.request options, (res) ->
    if callback?
      callback()
  .end()

sendLeftQueue = (key) ->
  if users[key]?
    res_url = users[key]?.url
    if res_url?
      urlobj = url.parse(res_url)
      params = {LEFT_MK: users[key].match_key}
      callback = () ->
        delete users[key]
      sendRequest urlobj, params, callback

onRequest = (request, response) ->
  data = ''
  request.on 'data', (fragment) -> data += fragment
  request.on 'end', ->
    try
      # FIXME: need to validate the packet
      console.log data
      packet = JSON.parse(data)      
      users[packet.key] = packet
      
      response.writeHead(204)
      response.end()
      parsePacket packet
    catch err
      response.writeHead(500)
      response.end()

http.createServer(onRequest).listen HTTP_PORT

### WEBSOCKET Server###
notifyUser = (key, matched_key) ->
  # if the user hasn't left
  if users[key]?
    response =
      method: "matched"
    users[key].connection.send JSON.stringify response

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
    console.log users
    if !users[key]?
      connection.send "Invalid user"
      connection.close()
      return

    user = users[key]
    user.connection = connection
    matching.match user, (err, result) ->
      urlobj = url.parse(user.url)
      params = {MK1: user.match_key, MK2: result.match_key}
      sendRequest urlobj, params, () ->
        notifyUser key, result.key
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
