module.exports = class TablesController
  tables: []
  constructor: (@app)->
    @app.route('/tables')
      .get (request, response) =>
        response.json @tables
      .post (request, reponse) =>
        table =
          id: tables.length
          bots: request.body.bots
          state: 'Running'
        tables.push table
        @launchGame table
        response.status(201).location("#{request.originalUrl}/#{table.id}").end()
    @app.route('/tables/:id')
      .get (request, response) =>
        table = @tables[request.params.id]
        if table?
          response.json table
        else
          response.status(404).end()
  launchGame: (table) ->
    # Start a game
