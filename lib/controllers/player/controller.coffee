database = require '../../services/database'
NodeCache = require( "node-cache" );
cache = new NodeCache({ stdTTL: 60 * 60 * 24 * 90 });

module.exports.find = (req, res) -> 
  #try cache
  try
    results = cache.get("player#{req.currentUser.id}", true)
    res.send(results)
    return

  #find players by keys.
  #Team Id should come from the session based on login and be secure. unless you are an admin
  database.find('MTTeamMember', { equal: { team: req.currentUser.MTTeams}, include: ['athleteProfile']})
  .then (results) ->
    #cache
    cache.set( "player#{req.currentUser.id}", results)

    res.send(results)
  .catch (error) ->
    console.log error
    res.sendStatus(500)

 