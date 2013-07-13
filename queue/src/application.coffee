# express.js application configuration.


http = require 'http'
path = require 'path'

cors = require 'cors'
express = require 'express'
glob = require 'glob'

application = express()
appEnv = application.get 'env'
appRoot = path.dirname __dirname

# Settings.
application.enable 'trust proxy'
application.set 'port', process.env.PORT || 11000
application.set 'views', path.join(appRoot, 'views')
application.set 'view engine', 'ejs'
application.set 'view options', layout: false

# Locals in views.
application.locals.production = appEnv isnt 'development'

# Middlewares.
if appEnv is 'development'
  application.use express.logger()

application.use cors(
    methods: ['GET', 'PATCH', 'POST'], maxAge: 365 * 24 * 60 * 60,
    headers: ['Authorization', 'Content-Type'], credentials: false)
application.use express.static(path.join(appRoot, 'public'))
application.use express.json()
application.use express.urlencoded()
application.use application.router

if appEnv is 'development'
  application.use express.errorHandler()


# All done.
module.exports = application
