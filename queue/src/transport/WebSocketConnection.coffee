wss = require('ws').Server
util = require('util')
uuid = require('node-uuid').v4

safeStringify = (frame) ->
  return JSON.stringify(frame).replace (/[\uD800-\uDFFF]/g), (chr, pos, str) ->
    "\\u"+("0000"+chr.charCodeAt(0).toString(16)).slice(-4)

module.exports = class WebSocketConnection

  constructor: (socket) ->
    this._id = uuid()
    this._socket = socket
    this._connected = true
    this._transport = null
    this._verifyFn = null
    this._addListenersToSocket()

  setTransport: (transport) ->
    this._transport = transport
  
  SetVerifyFn: (verifyFn) ->
    this._verifyFn = verifyFn

  getId: () ->
    return this._id 

  disconnect: () ->
    this._socket.close()
    this._removeListenersFromSocket()

  send: (message) ->
    if this._connected == false
      return

    if typeof(message) != typeof('')
      message = safestringify message

    try
      this._socket send message, (err) ->
        if err?
          console.log "Error sending to websocket #{util.iinspect message} because #{err}"
          self.disconnect()
    catch err
      this.disconnect()

  _addListenersToSocket: () ->
    this._socket.on('message', this._onMessage)
    this._socket.on('error', this._onError)
    this._socket.on('close', this._onClose)

  _removeListenersFromSocket: () ->
    this._socket.removeListeners('message', this._onMessage)
    this._socket.removeListeners('error', this._onError)
    this._socket.removeListeners('close', this._onClose)

  _onMessage: (message) ->
    if typeof(message) == 'string'
      try
        packet = JSON.parse(message)
      catch err
        console.log "received invalid json #{util.inspect message}"
        this.disconnect()
        return
    else
      packet = message

    if Array.isArray(packet)
      messages = packet
    else
      messages = [packet]

    for message in messages
      if !this._verifyFn? || this._verifyFn(message) == true
        this.emit('message', message, this, this._transport)
      else
        this.disconnect()
        console.log ("Packet was incorrectly signed #{util.inspect message}")
        break
        
  _onError: (error) ->
    console.log error

  _onClose: () ->
    this._removeListenersFromSocket()
    this._onDisconnect()

  _onDisconnect: () ->
    this._connected = false
    this.emit('disconnect', this)
