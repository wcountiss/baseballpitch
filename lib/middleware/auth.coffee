jwt = require 'jsonwebtoken'
login = require '../services/login'
invitationKeyService = require '../services/invitationKey'
database = require '../services/database'
encrypt = require '../services/encrypt'
NodeCache = require( "node-cache" );

cache = new NodeCache({ stdTTL: 60 * 60 * 24 * 90 });

#Ensures you are logged in and sets the data you have access to
module.exports = (req,res,next) ->
  if (req.signedCookies?.motus)
    decoded = jwt.verify(req.signedCookies.motus, process.env.JWT_PASS);
    decryptedUser = JSON.parse(encrypt.decrypt(decoded))
    login.getUser(decryptedUser.objectId)
    .then (user) ->

      #check once per session if your invitation key is still valid
      if !req.motusSession.invitationKeyChecked
        #check token if still valid
        invitationKeyService.checkKey(user)
        .then (invitationKeyError) ->
          #errors if invitation Key is not right
          if invitationKeyError
            #if invitation key expired, log you out
            res.clearCookie('motus')
            res.sendStatus(401)
          else
            #set the cookie so this session knows it is checked
            req.motusSession = { invitationKeyChecked: true }

      #try cache
      try
        results = cache.get("team#{user.id}", true)
        user.MTTeams = teams
        req.currentUser = user
        next()

      #If Coach, later check player or GM
      database.find('MTTeam', { equal: {'coach': user }}, {noParse: true})
      .then (teams) ->
        user.MTTeams = teams
        req.currentUser = user
        #cache
        cache.set( "team#{req.currentUser.id}", results)
        next()
    .catch (error) ->
      console.log error
      res.sendStatus(500)
  else
    res.sendStatus(401)
  


