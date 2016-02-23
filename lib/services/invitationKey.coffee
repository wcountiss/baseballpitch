_ = require 'lodash'
Promise = require 'bluebird'
Parse = require('parse/node')
database = require './database'
moment = require 'moment'
NodeCache = require( "node-cache" );
cache = new NodeCache({ stdTTL: 60 * 60 * 24 * 90 });

module.exports.checkKey = (user) ->
  database.find('invitationKey', { equal: { userLink: user} }, { findOne: true })
  .then (invitationKey) ->
    #errors if invitation Key is not right
    return { error: 'missingInvitationKey' } if !invitationKey
    return { error: 'expiredInvitationKey', expirationDate: moment(invitationKey.expirationDate.iso).format('MM/DD/YYYY') } if moment() > moment(invitationKey.expirationDate.iso)
    return null

module.exports.checkUsersKey = (users) ->
  database.find('invitationKey', { equal: userLink: users })
    .then (invitationKeys) ->
      #add error if invitation Key is not right
      _.each users, (user) ->
        invitationKey = _.find invitationKeys, (invitationKey) -> 
          invitationKey.userLink.objectId == user.id
        
        if !invitationKey
          user.invitationKeyError = { error: 'missingInvitationKey' } 
        else if moment() > moment(invitationKey.expirationDate.iso)
          user.invitationKeyError = { error: 'expiredInvitationKey', expirationDate: moment(invitationKey.expirationDate.iso).format('MM/DD/YYYY') }

module.exports.assignInvitationKey = () ->
  return database.find('invitationKey', { equal: { invitationKey: req.body.invitationKey} })
    .then (invitationKey) ->
      #errors if invitation Key is not right
      return { error: 'invalidInvitationKey' } if !invitationKey
      return { error: 'inUseInvitationKey' } if invitationKey.athleteProfileLink
      return { error: 'expiredInvitationKey' } if moment() > moment(invitationKey.expirationDate.iso)

      #assign the invitation key to the user
      database.update('invitationKey', { objectId: invitationKey.objectId, athleteProfile: athleteProfile })
      .then (object) ->
        return null