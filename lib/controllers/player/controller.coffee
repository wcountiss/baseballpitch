database = require '../../services/database'

module.exports.find = (req, res) -> 
  #find players by keys.
  #Team Id should come from the session based on login and be secure. unless you are an admin
  database.find('TeamMember', { equal: { team: req.currentUser.MTTeams}, include: ['athleteProfile']})
  .then (results) ->
    res.send(results)
  .catch (error) ->
    console.log error
    res.sendStatus(500)

 