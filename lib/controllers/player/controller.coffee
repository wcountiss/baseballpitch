parse = require '../../services/parse'

module.exports.save = (req, res) ->
  parse().save('player', { playerName: req.query.playerName })
  .then (object) ->
    res.sendStatus(200)

module.exports.find = (req, res) -> 
  #list players
  parse().find('player', {})
  .then (results) ->
    res.send(results)
 