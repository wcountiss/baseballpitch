jwt = require 'jsonwebtoken'
login = require '../services/login'
database = require '../services/database'
encrypt = require '../services/encrypt'

#Ensures you are logged in and sets the data you have access to
module.exports = (req,res,next) ->
  if (req.signedCookies?.motus)
    decoded = jwt.verify(req.signedCookies.motus, process.env.JWT_PASS);
    decryptedUser = JSON.parse(encrypt.decrypt(decoded))
    login.getUser(decryptedUser.objectId)
    .then (user) ->
      #If Coach, later check player or GM
      database.find('MTTeam', { equal: {'coach': user }}, {noParse: true})
      .then (teams) ->
        user.MTTeams = teams
        req.currentUser = user
        next()
    .catch (error) ->
      console.log error
      res.sendStatus(500)
  else
    res.sendStatus(401)
  


