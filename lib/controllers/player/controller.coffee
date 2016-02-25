database = require '../../services/database'
athleteService = require '../../services/athlete'
invitationKeyService = require '../../services/invitationKey'
NodeCache = require( "node-cache" );
cache = new NodeCache({ stdTTL: 60 * 60 * 24 * 90 });
_ = require 'lodash'

#get players
module.exports.find = (req, res) -> 
  #find players by keys.
  athleteService.find(req.currentUser)
  .then (teamMembers) ->
    res.send(teamMembers)

  .catch (error) ->
    console.log error
    res.sendStatus(500)

#assign an invitation key to a player
module.exports.assignInvitationKey = (req, res) -> 
  if !req.body.athleteProfile || !req.body.invitationKey
    res.sendStatus(500)
    return

  athleteService.find(req.currentUser)
  .then (teamMembers) ->
    teamMember = _.find teamMembers, (teamMember) -> teamMember.athleteProfile.objectId == req.body.athleteProfile
    database.find('User', { equal: { objectId: teamMember.athleteProfile.user.objectId } }, { findOne: true, noParse: true })
    .then (athleteUsers) ->
      invitationKeyService.assignInvitationKey(athleteUsers, req.body.invitationKey)
      .then (invitationKeyError) ->
        #errors if invitation Key is not right
        if invitationKeyError
          res.status(401).send(invitationKeyError)
          return 
          
        #clear cache of players because now the key is valid
        cache.set( "athletes#{req.currentUser.id}", null)

        res.sendStatus(200)
    .catch (error) ->
      console.log error
      res.sendStatus(500)

 