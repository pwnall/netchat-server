# Model for a chat room.
class ChatModel
  constructor: ->
    @users = {}
    @userCount = 0

    @events = {}
    @firstEventId = null
    @lastEventId = null

  addList: (roomList) ->
    @title = roomList.title
    @users = {}
    for userInfo in roomList.presence
      @users[userInfo.name] = userInfo

  addEvent: (event) ->
    @firstEventId = event.id if @firstEventId is null
    return false if @lastEventId is not null and event.id != @lastEventId + 1
    @events[event.id] = event
    @lastEventId = event.id

    # NOTE: the presence cache uses snake_case, because it follows the server
    #       data format
    switch event.type
      when 'join'
        unless event.session2
          @users[event.name] =
              name: event.name, name_color: event.name_color, av_nonce: null
      when 'part'
        unless event.session2
          delete @users[event.name]
      when 'av-invite'
        unless @users[event.name]
          @users[event.name] =
              name: event.name, name_color: event.name_color, av_nonce: null
        unless @users[event.name].av_nonce is event.av_nonce
          @users[event.name].av_nonce = event.av_nonce
      when 'av-accept'
        unless @users[event.name]
          @users[event.name] =
              name: event.name, name_color: event.name_color, av_nonce: null
        for own name, userInfo of @users
          if userInfo.av_nonce is event.av_nonce
            userInfo.av_nonce = null
      when 'av-close'
        unless @users[event.name]
          @users[event.name] =
              name: event.name, name_color: event.name_color, av_nonce: null
        if @users[event.name].av_nonce is event.av_nonce
          @users[event.name].av_nonce = null

    @userCount = 0
    for own name, user of @users
      @userCount += 1

    @

  getEvent: (eventId) -> @events[eventId]

  getAllEvents: ->
    return [] if @lastEventId is null
    @events[i] for i in[@firstEventId..@lastEventId]

  roomInfoVersion: -> @roomVersion

  getRoomInfo: ->
    users = []
    for own name, userInfo of @users
      users.push userInfo
    { title: @title, users: users }

window.ChatModel = ChatModel
