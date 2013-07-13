# Detects network timeout issues.
class PingController
  constructor: (@chatController) ->
    @pingTimerHandler = => @onPingTimer()
    @pingTimer = null

    @pongTimerHandler = => @onPongTimer()
    @pongTimer = null
    @pongNonce = null

    @pingInterval = 30
    @roundTrip = 20.0

  resetTimer: ->
    @disableTimer()
    @pingTimer = window.setTimeout @pingTimerHandler, @pingInterval * 1000

  disableTimer: ->
    if @pongTimer isnt null
      window.clearTimeout @pongTimer
      @pongTimer = null
      @pongNonce = null
    if @pingTimer isnt null
      window.clearTimeout @pingTimer
      @pingTimer = null

  onPong: (data) ->
    if @pongNonce is data.nonce and data.client_ts
      roundTrip = Date.now() / 1000 - data.client_ts
      @roundTrip = @roundTrip * 0.2 + roundTrip * 0.8

  onPingTimer: ->
    return if @pingTimer is null
    @pingTimer = null
    # No need to send a ping if we already have one on the way.
    return if @pongTimer isnt null

    @pongNonce = @chatController.nonce()
    @chatController.socketSend(
        type: 'ping', nonce: @pongNonce, client_ts: Date.now() / 1000)
    @pongTimer = window.setTimeout @pongTimerHandler, @roundTrip + 5000

  onPongTimer: ->
    return if @pongTimer is null
    @pongTimer = null

    @disableTimer()
    @chatController.onPingTimeout()

# Interfaces with the WS chat server.
class ChatController
  constructor: (options) ->
    @backendUrl = options.backend
    @closedUrl = options.closedUrl
    @joinKey = options.key
    @name = options.name

    @model = new ChatModel
    @chatView = new ChatView
    @chatView.onMessageSubmission = (text) => @submitMessage text

    @setupSocket()

  setupSocket: ->
    @wsUri = @backendUrl + "/chat?key=" + encodeURIComponent(@joinKey)
    @ws = null
    @pingController = new PingController @
    @rtcController = new RtcController @
    @connect()

  connect: ->
    @disconnect()
    @ws = new WebSocket(@wsUri)
    @ws.onclose = => @onSocketClose()
    @ws.onerror = (event) => @onSocketError 'Unspecified Error'
    @ws.onopen = => @onSocketOpen()
    @ws.onmessage = (event) => @onMessage JSON.parse(event.data)

    console.log 'Connecting'
    @pingController.resetTimer()

  disconnect: ->
    @pingController.disableTimer()
    return if @ws is null

    @ws.close()
    # Disconnect the event handlers so we don't get spurious events.
    @ws.onmessage = null
    @ws.onerror = null
    @ws.onclose = null
    @ws = null

  onSocketOpen: ->
    return unless @ws
    @sendListQuery()
    @chatView.enableComposer()
    console.log 'Connected'

  onSocketClose: ->
    wasConnected = !!@ws
    @disconnect()
    @chatView.disableComposer()
    if wasConnected
      console.log 'Server Disconnected'
      setTimeout (=> @connect()), 5000

  onSocketError: (errorMessage) ->
    @disconnect()
    @chatView.disableComposer()
    console.log "Socket error: #{errorMessage}"
    setTimeout (=> @connect()), 5000

  onPingTimeout: ->
    @onSocketError 'Network issues'

  onMessage: (data) ->
    if data.events
      for event in data.events
        @model.addEvent event
        @rtcController.onAvEvent(event) if event.av_nonce
      @chatView.update @model
    if data.list
      @model.addList data.list
      @chatView.update @model
    if data.pong
      @pingController.onPong data.pong
    if data.relays
      for relay in data.relays
        @rtcController.onAvRelay(relay) if relay.body?.av_nonce
    @pingController.resetTimer()

  submitMessage: (text) ->
    @submitEvent type: 'text', text: text

  submitEvent: (event) ->
    event.nonce = @nonce()
    event.client_ts = Date.now() / 1000
    @socketSend event

  sendRelay: (receiverName, body) ->
    @socketSend(
        type: 'relay', to: receiverName, body: body, nonce: @nonce(),
        client_ts: Date.now() / 1000)

  sendListQuery: ->
    @socketSend type: 'list', nonce: @nonce(), client_ts: Date.now() / 1000

  socketSend: (data) ->
    @ws.send JSON.stringify(data)

  nonce: ->
    timestamp = (new Date()).getTime().toString 36
    random = Math.floor(Math.random() * 0x7fffffff).toString 36
    [random, timestamp].join '.'

window.ChatController = ChatController
