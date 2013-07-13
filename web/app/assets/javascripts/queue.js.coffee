# Detects network timeout issues.
class PingController
  constructor: (@queueController) ->
    @pingTimerHandler = => @onPingTimer()
    @pingTimer = null

    @pongTimerHandler = => @onPongTimer()
    @pongTimer = null
    @pongNonce = null

    @pingInterval = 15
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

    @pongNonce = @nonce()
    @queueController.sendPing(
        method: 'ping', client_ts: Date.now() / 1000, nonce: @pongNonce)
    @pongTimer = window.setTimeout @pongTimerHandler, @roundTrip + 5000

  onPongTimer: ->
    return if @pongTimer is null
    @pongTimer = null

    @disableTimer()
    @queueController.onPingTimeout()

  nonce: ->
    timestamp = (new Date()).getTime().toString 36
    random = Math.floor(Math.random() * 0x7fffffff).toString 36
    [random, timestamp].join '.'


# Drives the queue view.
class QueueController
  # @param {Object} options
  # @option options {String} backend the URL of the queueing server
  # @option options {String} key the join key for the current user
  # @option options {Number} enteredAt the time the user joined the queue
  constructor: (options) ->
    @enteredAt = options.enteredAt or (Date.now() / 1000.0)
    @backendUrl = options.backend
    @joinKey = options.key

    @setupTimers()
    @setupSocket()

  # Sets up the WebSocket talking to the queue server.
  setupSocket: ->
    # NOTE: the joinKey could be embedded here
    @wsUri = @backendUrl + "/chat?key=" + encodeURIComponent(@joinKey)
    @pingController = new PingController @
    @connect()

  # Connects to the queue backend.
  connect: ->
    @ws = new WebSocket @wsUri
    @ws.onclose = => @onSocketClose()
    @ws.onerror = (event) => @onSocketError 'Unspecified Error'
    @ws.onopen = => @onSocketOpen()
    @ws.onmessage = (event) => @onSocketMessage JSON.parse(event.data)

    console.log 'Connecting to queue server'

  # Disconnects from the queue backend.
  disconnect: ->
    @pingController.disableTimer()
    return if @ws is null

    @ws.close()
    # Disconnect the event handlers so we don't get spurious events.
    @ws.onmessage = null
    @ws.onerror = null
    @ws.onclose = null
    @ws = null
  
  # Called when we're connected to the queue server.
  onSocketOpen: ->
    return unless @ws
    @pingController.resetTimer()
    console.log 'Connected to queue server'

  # Called when we're disconnected from the queue server.
  onSocketClose: ->
    wasConnected = !!@ws
    @disconnect()
    if wasConnected
      console.log 'Server Disconnected'
      setTimeout (=> @connect()), 5000

  # Called when something went wrong.
  onSocketError: (errorMessage) ->
    @disconnect()
    console.log "Socket error: #{errorMessage}"
    setTimeout (=> @connect()), 5000

  # Called when a pong wasn't received early enough.
  onPingTimeout: ->
    @onSocketError 'Ping Timeout'

  # Called when we receive a message from the queue server.
  onSocketMessage: (data) ->
    switch data.method
      when 'pong'
        @pingController.onPong data
      when 'match'
        # TODO(pwnall): matched
        console.log 'Matched'
    @pingController.resetTimer()

  # Sends a ping message to the queue server.
  sendPing: (data) ->
    return unless @ws
    @ws.send JSON.stringify(data)

  # Sets up the queue-related timer displays.
  setupTimers: ->
    @$elapsed = $ '#queue-elapsed-time'
    @$waiting = $ '#queue-waiting-time'
    @updateElapsedTime()
    window.setInterval @updateElapsedTime.bind(@), 500

  # Updates the timer showing how much since the user entered the queue.
  updateElapsedTime: ->
    totalSeconds = Date.now() / 1000.0 - @enteredAt

    minutes = Math.floor(totalSeconds / 60)
    seconds = Math.floor(totalSeconds % 60)
    s1 = Math.floor seconds / 10
    s2 = seconds % 10

    @$elapsed.text "#{minutes}:#{s1}#{s2}"


window.QueueController = QueueController
