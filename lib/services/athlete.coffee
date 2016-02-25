_ = require 'lodash'
Promise = require 'bluebird'
database = require './database'
NodeCache = require( "node-cache" );
cache = new NodeCache({ stdTTL: 60 * 60 * 24 * 90 });
teamService = require './team'
invitationKeyService = require './invitationKey'


module.exports.find = (currentUser) ->
  try
    athletes = cache.get("athletes#{currentUser.id}", true)
    return new Promise(athletes)

  return new Promise (resolve, reject) ->
    #Team Id should come from the session based on login and be secure. unless you are an admin
    teamService.find(currentUser)
    .then (teamMembers) ->
      database.find('AthleteProfile', { equal: { objectId: _.pluck(teamMembers, 'athleteProfile.objectId') } } )
      .then (athletes) ->
        #get the user and check that against the invitation keys
        database.find('User', { equal: { objectId: _.pluck(athletes, 'user.objectId') } }, { noParse: true })
        .then (athleteUsers) ->
          invitationKeyService.checkUsersKey(athleteUsers)
          .then (inviteKeyResults) ->
            _.each athletes, (athlete) ->
              athlete.invitationKeyError = _.find(inviteKeyResults, (inviteKeyResult) ->  
                inviteKeyResult.id == athlete.user.objectId).invitationKeyError

            #cache
            cache.set("athletes#{currentUser.id}", athletes)

            resolve(athletes)




