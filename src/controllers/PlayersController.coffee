module.exports = class PlayersController
  players: {}
  constructor: (@app) ->
    @app.route('/players')
      .get (request, response) =>
        response.json @players
      .post (request, response) =>
        name = request.body.name
        if !@players[name]?
          @players[name] =
            name: name
            bots: {}
          response.status(201).location("#{request.originalUrl}/#{name}").end()
        else
          response.status(409).end()
    @app.route('/players/:name')
      .get (request, response) =>
        response.json @players[request.params.name]
    @app.route('/players/:name/bots')
      .get (request, response) =>
        if @players[request.params.name]?
          response.json(@players[request.params.name].bots)
        else
          response.status(404).end()
      .post (request, response) =>
        player = @players[request.params.name]
        if player?
          botName = request.body.name
          player.bots[botName] =
            url : request.body.url
            name: botName
            owner: player.name
          response.status(201).location("#{request.originalUrl}/#{botName}").end()
        else
          repsonse.status(404).end()
    @app.route('/players/:playerName/bots/:botName')
      .get (request, response) =>
        bot = @players[request.params.playerName]?.bots[request.params.botName]
        if bot?
          response.json(bot)
        else
          response.status(404).end()
