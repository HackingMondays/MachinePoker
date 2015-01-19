express = require 'express'
bodyParser = require 'body-parser'
passport = require 'passport'
morgan = require 'morgan'
cookieParser = require 'cookie-parser'
session = require 'express-session'
PlayersController = require './controllers/PlayersController'

class Server
  constructor: () ->
    @app = express()
    @app.use morgan('dev')
    @app.use cookieParser()
    @app.use bodyParser.json()
    @app.use bodyParser.urlencoded(extended: true)
    @playersController = new PlayersController(@app)
    @app.listen 8080, () =>
      console.log 'started !!!'

new Server()
