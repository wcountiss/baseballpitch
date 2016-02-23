database = require '../../services/database'
invitationKeyService = require '../../services/invitationKey'
NodeCache = require( "node-cache" );
cache = new NodeCache({ stdTTL: 60 * 60 * 24 * 90 });
_ = require 'lodash'

module.exports.find = (req, res) -> 
  #try cache
  try
    results = cache.get("player#{req.currentUser.id}", true)
    res.send(results)
    return

  #find players by keys.
  #Team Id should come from the session based on login and be secure. unless you are an admin
  database.find('MTTeamMember', { equal: { team: req.currentUser.MTTeams}, include: ['athleteProfile']})
  .then (teamMembers) ->
    
    #get the user and check that against the invitation keys
    database.find('User', { equal: { objectId: _.pluck(teamMembers, 'athleteProfile.user.objectId') } }, { noParse: true })
    .then (athleteUsers) ->
      invitationKeyService.checkUsersKey(athleteUsers)
      .then (inviteKeyResults) ->
        _.each teamMembers, (teamMember) ->
          teamMember.invitationKeyError = _.find(inviteKeyResults, (inviteKeyResult) -> inviteKeyResult.id == teamMember.athleteProfile.user.objectId ).invitationKeyError

        #cache
        cache.set( "player#{req.currentUser.id}", teamMembers)

        res.send(teamMembers)
  .catch (error) ->
    console.log error
    res.sendStatus(500)

module.exports.assignInvitationKey = (req, res) -> 
  if !req.body.athleteProfile !req.body.invitationKey
    res.sendStatus(500)

  database.find('MTTeamMember', { equal: { team: req.currentUser.MTTeams}, include: ['athleteProfile', 'athleteProfile.user']}, { noParse: true })
  .then (teamMembers) ->
    athleteProfile = _.find teamMembers, (teamMember) -> teamMember.objectId == req.body.athleteProfile

    invitationKeyService.assignInvitationKey(user, req.body.invitationKey)
    .then (invitationKeyError) ->
      console.log invitationKeyError
      #errors if invitation Key is not right
      if invitationKeyError
        res.status(401).send(invitationKeyError)
        return 
        
      #clear cache
      cache.set( "player#{req.currentUser.id}", null)

      res.sendStatus(200)
    .catch (error) ->
      console.log error
      res.sendStatus(500)

 