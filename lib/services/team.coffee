_ = require 'lodash'
Promise = require 'bluebird'
database = require './database'
NodeCache = require( "node-cache" );
cache = new NodeCache({ stdTTL: 60 * 60 * 24 * 90 });

module.exports.find = (currentUser) ->
  try
    teamMembers = cache.get("team#{currentUser.id}", true)
    return new Promise(teamMembers)

  return new Promise (resolve, reject) ->
    #Team Id should come from the session based on login and be secure. unless you are an admin
    database.find('MTTeamMember', { equal: { team: currentUser.MTTeams}})
    .then (teamMembers) ->
      #cache
      cache.set("team#{currentUser.id}", teamMembers)

      resolve(teamMembers)




