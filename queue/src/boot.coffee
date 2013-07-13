require('source-map-support').install()

application = require './application'

port = application.get 'port'
application.listen port, ->
  console.log "NetChat Queue Server listening on port #{port}"

# Start connecting to the database early, don't wait for a request to come in.
#require './database'

require './index'
