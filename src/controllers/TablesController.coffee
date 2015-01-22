MachinePocker = require "../index"
LocalSeat = MachinePocker.seats.JsLocal
RemoteSeat = MachinePocker.seats.Remote
async = require "async"

localBots =
  'bot-randBot': '../../examples/bots/randBot.js'
  'bot-callBot': '../../examples/bots/callBot.js'
  'bot-foldBot': '../../examples/bots/foldBot.js'

url_re = /^https?:\/\/.+/

module.exports = class TablesController
  tables: []
  constructor: (@app, @socket)->
    @app.route('/tables')
      .get (request, response) =>
        response.json @tables
      .post (request, response) =>
        bots = [];
        self = this
        initBotTasks = Object.keys(request.body).map (key) =>
          (callback) => @createBot key, request.body[key], (err, createdBot) ->
            if !err && createdBot
              bots = bots.concat(createdBot);
            callback null
        async.series initBotTasks, (err) =>
          if !err
            table =
              id: @tables.length
              bots: bots
              games: []
              state: 'Running'
            @tables.push table
            @launchGame table, parseInt(request.body.rounds)
            response.status(201).location("#{request.originalUrl}/#{table.id}").json(table)
          else
            response.status(501)

    @app.route('/tables/:id')
      .get (request, response) =>
        table = @tables[request.params.id]
        if table?
          response.json table
        else
          response.status(404).end()
    @app.route('/table/current')
      .get (request, response) =>
        response.json(@table.length - 1)
    @app.route('/table/:id/:number')
      .get (request, response) =>
        response.json(@tables[request.params.id]?.games[request.params.number])
  launchGame: (table, roundCount) ->
    realTable = MachinePocker.create
      maxRounds: roundCount || 1000
    console.log JSON.stringify(table, undefined, 2)
    realTable.addPlayers(table.bots)
    realTable.addObserver
      complete: (gameObject) =>
        table.games.push gameObject
        console.log "sending event game-complete-#{table.id}"
        @socket.emit "game-complete-#{table.id}", gameObject
    realTable.on 'tournamentClosed', () =>
      table.state = 'Terminated'
      @socket.emit "game-complete-#{table.id}", "Terminated"
    realTable.start()
  createBot: (key, value, callback) ->
    console.log "creating bot", key, value
    if (localBots[key])
      callback(null, LocalSeat.create(require(localBots[key])));
    else if key == 'botlist'
      remoteBotCreator = (x,callback) -> RemoteSeat.create x,undefined, (err, bot) -> callback err, bot
      async.map (value.split '\n').filter((el) -> url_re.test(el)), remoteBotCreator, callback
    else
      callback new Error("Invalid bot reference " + key + "/" + value + " (ignoring)")
