database = require '../../services/database'


module.exports.save = (req, res) ->
  #simple validation, replace with parseModel later
  if !req.body.playerName || !req.body.teamId
    res.sendStatus(500)

  #Saves a player for loading later
  database.save('player', { playerName: req.body.playerName, teamId: +req.body.teamId })
  .then (object) ->
    res.sendStatus(200)
  .catch (error) ->
    console.log error
    res.sendStatus(500)

module.exports.find = (req, res) -> 
  #find players by keys.
  #Team Id should come from the session based on login and be secure. unless you are an admin
  database.find('TeamMember', { team: req.currentUser.MTTeams[0]}, { include: ['athleteProfile']})
  .then (results) ->
    console.log results
    res.send(results)
  .catch (error) ->
    console.log error
    res.sendStatus(500)


 