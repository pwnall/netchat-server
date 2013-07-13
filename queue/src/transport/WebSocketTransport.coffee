wss = require('ws').Server
EventEmitter = require('events').EventEmitter
WebSocketConnection = require('./WebSocketConnection')


module.exports = class WebSocketTransport extends EventEmitter
  constructor: ({host, port}) ->
    self._socket = new wss({host, port})
    self._socket.on 'connection', (socket) ->
      console.log "Got WebSocketConnection"
      self._connection new WebSocketConnection(socket)

  _connection: (connection) ->
    connection.setTransport(this)
    this.emit('connection', connection, this)

  disconnect: () ->
    if this._socket?._server?
      this._socket.close()
    this.emit('disconnect', 'this)
