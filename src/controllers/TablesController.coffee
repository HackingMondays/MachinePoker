MachinePocker = require "../index"
LocalSeat = MachinePocker.seats.JsLocal
module.exports = class TablesController
  tables: []
  constructor: (@app, @socket)->
    @app.route('/tables')
      .get (request, response) =>
        response.json @tables
      .post (request, response) =>
        bots =  @createBotFromKey(key) for key,value of request.body when value?
        table =
          id: @tables.length
          bots: bots
          games: []
          state: 'Running'
        @tables.push table
        @launchGame table
        response.status(201).location("#{request.originalUrl}/#{table.id}").json(table)
    @app.route('/tables/:id')
      .get (request, response) =>
        table = @tables[request.params.id]
        if table?
          response.json table
        else
          response.status(404).end()
  launchGame: (table) ->
    realTable = MachinePocker.create
      maxRounds: 1000
    realTable.addPlayer table.bots
    realTable.addObserver
      complete: (gameObject) =>
        table.game.push gameObject
        @socket.emit "game-complete-#{table.id}", gameObject
    realTable.on 'tournamentClosed', () =>
      table.state = 'Terminated'
      @socket.emit "game-complete-#{table.id}", "Terminated"
  createBotFromKey: (key) ->
    LocalSeat.create(require("../../examples/bots/#{key}"))
