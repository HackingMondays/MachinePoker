express = require 'express'
bodyParser = require 'body-parser'
passport = require 'passport'
morgan = require 'morgan'
cookieParser = require 'cookie-parser'
session = require 'express-session'
socketio = require 'socket.io'
open = require 'open'

PlayersController = require './controllers/PlayersController'
TablesController = require './controllers/TablesController'

port = 8080;
openBrowser = process.argv.map((s) -> s == "--open").filter((x)->x).length>0;

class Server
  constructor: (callback) ->
    @app = express()
    @server = require('http').Server(@app)
    @socket = socketio @server
    @app.use morgan('dev')
    @app.use cookieParser()
    @app.use bodyParser.json()
    @app.use bodyParser.urlencoded(extended: true)
    @playersController = new PlayersController(@app)
    @tablesController = new TablesController(@app, @socket)
    @app.use "/", express.static("#{__dirname}/public/")
    @server.listen port, () =>
      console.log 'Ready. Listening on port ' + port
      if typeof callback == "function"
        callback()

    @socket.on 'connection',  (socket) =>
      socket.emit 'news',
        hello: 'world'
      socket.on 'my other event', (data) ->
          console.log data

new Server () -> 
  if openBrowser
    open("http://localhost:" + port + "/")
