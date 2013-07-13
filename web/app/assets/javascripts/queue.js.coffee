class QueueController
  # @param {Object} options
  # @option options {String} backend the URL of the queueing server
  # @option options {String} key the join key for the current user
  # @option options {Number} enteredAt the time the user joined the queue
  constructor: (options) ->
    
