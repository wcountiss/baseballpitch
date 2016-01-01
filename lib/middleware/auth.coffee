jwt = require 'jsonwebtoken'
login = require '../services/login'
database = require '../services/database'


module.exports = (req,res,next) ->
  if (req.signedCookies?.motus)
    decoded = jwt.verify(req.signedCookies.motus, process.env.JWT_PASS);
    login.getUser(decoded.objectId)
    .then (user) ->
      #If Coach, later check player or GM
      database.find('MTTeam', {'coach': user }, {noParse: true})
      .then (teams) ->
        user.MTTeams = teams
        req.currentUser = user
        next()
    .catch (error) ->
      console.log error
      res.sendStatus(500)
  else
    res.sendStatus(401)
  


