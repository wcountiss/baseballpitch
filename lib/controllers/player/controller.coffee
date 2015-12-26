database = require '../../services/database'


module.exports.save = (req, res) ->
  #simple validation, replace with parseModel later
  if !req.body.playerName || !req.body.teamId
    res.sendStatus(500)

  #Saves a player for loading later
  database.save('player', { playerName: req.body.playerName, teamId: +req.body.teamId })
  .then (object) ->
    res.sendStatus(200)
  .error (error) ->
    console.log error
    res.sendStatus(500)

module.exports.find = (req, res) -> 
  #find players by keys.
  #Team Id should come from the session based on login and be secure. unless you are an admin
  database.find('player', { teamId: req.body.teamId })
  .then (results) ->
    res.send(results)
 