database = require '../../services/database'
athleteService = require '../../services/athlete'
teamService = require '../../services/team'
moment = require 'moment'
_ = require 'lodash'
Promise = require 'bluebird'
NodeCache = require( "node-cache" );
extendedCache = new NodeCache({ stdTTL: 60 * 60 * 24 * 90 }); #90 day cache
cache = new NodeCache({ stdTTL: 5 * 60 }); #5 min cache

# console.log extendedCache.getStats();

filterInvitationKeyErroredPitches = (athletes, pitches) ->
  #filter out pitches made by players with invalid keys
  _.each athletes, (athlete) ->
    if athlete.invitationKeyError
      #if there is an invitatinoKeyError, remove that player's pitches
      pitches = _.filter pitches, (pitch) -> pitch.athleteProfile.objectId != athlete.objectId
  return pitches

#gets the pitches for all the players at once
module.exports.find = (req, res) ->
  daysBack = req.body.daysBack || 30
  cachedResults = null
  pitchGotFullSet = false

  athleteService.find(req.currentUser)
  .then (athletes) ->
    #if cache, get recent days and combine with the cache to reduce calls but stay current 
    try
      cachedResults = extendedCache.get("pitch#{req.currentUser.id}", true)

      cachedResults = _.sortBy cachedResults, (cachedResult) -> moment(cachedResult.pitchDate.iso)
      #filter down to 365 days ago
      cachedResults = _.filter cachedResults, (cachedResult) -> moment(cachedResult.pitchDate.iso) >= moment().add(-365,'d')
      #go until the last load back for real data
      daysBack = moment().diff(moment(cachedResults[cachedResults.length-1].pitchDate.iso), 'days')

      #if you recently loaded everything, you do not need to get it until 24 hours later
      pitchGotFullSet = cache.get("pitchGotFullSet", true)
      if pitchGotFullSet
        cachedResults = filterInvitationKeyErroredPitches(athletes, cachedResults)
        res.send(cachedResults)
        return
      
    teamService.find(req.currentUser)
    .then (teamMembers) ->
      athleteProfiles = _.pluck(teamMembers, 'athleteProfile')

      #Go back 30 days by default but can override
      getNumberofPages = 1
      if daysBack >= 60
          getNumberofPages = 2
      if daysBack >= 90
          getNumberofPages = 3
      if daysBack >= 365
          getNumberofPages = 8

      #get pitches by player asynch
      pitchPromises = []
      _.each athleteProfiles, (athleteProfile) ->
          _.times getNumberofPages, (pageNum) ->
              #Find by AthleteProfileIds
              pitchPromises.push database.find('MPPitch', { 
                equal: { 'athleteProfile': athleteProfile}, 
                greater: { 'pitchDate': moment().add(-daysBack,'d').toDate() },
                page: pageNum,
                #unneeded byte type columns removed
                select: [
                  "armSlot",
                  "armSpeed",
                  "athleteProfile",
                  "elbowFlexionFootContact",
                  "elbowFlexionRelease",
                  "elbowHeight",
                  "fingertipVelocityRelease",
                  "footAngle",
                  "footContactTime",
                  "forearmSlotRelease",
                  "maxElbowFlexion",
                  "maxFootHeight",
                  "maxFootHeightTime",
                  "maxShoulderRotation",
                  "maxTrunkSeparation",
                  "pelvisFlexionFootContact",
                  "pelvisFlexionRelease",
                  "pelvisRotationFootContact",
                  "pelvisRotationRelease",
                  "pelvisSideTiltFootContact",
                  "pelvisSideTiltRelease",
                  "pitchDate",
                  "pitchTime",
                  "peakBicepSpeed",
                  "peakBicepSpeedTime",
                  "peakElbowCompressiveForce",
                  "peakElbowValgusTorque",
                  "peakForearmSpeed",
                  "peakForearmSpeedTime",
                  "peakHipSpeed",
                  "peakHipSpeedTime",
                  "peakShoulderAnteriorForce",
                  "peakShoulderCompressiveForce",
                  "peakShoulderRotationTorque",
                  "peakTrunkSpeed",
                  "peakTrunkSpeedTime",
                  "releasePoint",
                  "shoulderAbductionFootContact",
                  "shoulderAbductionRelease",
                  "shoulderRotation",
                  "shoulderRotationFootContact",
                  "shoulderRotationRelease",
                  "strideLength",
                  "tagString",
                  "torque",
                  "trunkFlexionFootContact",
                  "trunkFlexionRelease",
                  "trunkRotationFootContact",
                  "trunkRotationRelease",
                  "trunkSideTiltFootContact",
                  "trunkSideTiltRelease"
                ]  
              })
      Promise.all(pitchPromises)
      .then (pitchGroups) ->
        results = _.flatten pitchGroups

        #remove unused data for speed
        _.each results, (result) ->
          delete result.objectId
          delete result.updatedAt
          delete result.createdAt

        #if cached results combine
        if cachedResults
          results = results.concat cachedResults
          results = _.sortBy results, (result) -> moment(result.pitchDate.iso)
        else
          #save 365 was gotten so you don't have to get again for 24 hours
          cache.set( "pitchGotFullSet", true)

        #cache
        extendedCache.set( "pitch#{req.currentUser.id}", results)

        results = filterInvitationKeyErroredPitches(athletes, results)

        res.send(results)
      .catch (error) ->
        console.log error
        res.sendStatus(500)
  .catch (error) ->
    console.log error
    res.sendStatus(500)


module.exports.findPitchTimingByAtheleteProfileId = (req, res) ->
  #required params
  if !req.body.athleteProfileId
    res.status(400).send({ error: 'No AthleteProfileId'})

  #if cache, get recent days and combine with the cache to reduce calls but stay current 
  #try cache
  try
    results = cache.get("pitchTiming#{req.body.athleteProfileId}", true)
    res.send(results)
    return

  #Security, you only have access to your team's althletes
  teamService.find(req.currentUser)
  .then (teamMembers) ->
    athleteProfiles = _.pluck(teamMembers, 'athleteProfile')
    #Go back 30 days by default but can override
    daysBack = req.body.daysBack || 30

    getNumberofPages = 1
    if daysBack > 60
        getNumberofPages = 2
    if daysBack >= 365
        getNumberofPages = 4

    #get pitches by player asynch
    pitchPromises = []
    athleteProfile = _.find athleteProfiles, (ap) -> ap.objectId == req.body.athleteProfileId
    _.times getNumberofPages, (pageNum) ->
        #Find by AthleteProfileIds
        pitchPromises.push database.find('MPPitch', { 
          equal: { 'athleteProfile': athleteProfile}, 
          greater: { 'pitchDate': moment().add(-daysBack,'d').toDate() },
          page: pageNum,
          #unneeded byte type columns removed
          select: [
            "athleteProfile",
            "footContactTime",
            "keyframeFirstMovement",
            "keyframeFootContact",
            "keyframeLegKick",
            "keyframeTimeWarp",
            "objectId",
            "maxFootHeightTime",
            "peakBicepSpeedTime",
            "peakForearmSpeedTime",
            "peakHipSpeedTime",
            "peakTrunkSpeedTime",
            "pitchDate",
            "pitchTime",
            "tagString",
            "timeSeriesForearmSpeed",
            "timeSeriesHipSpeed",
            "timeSeriesTrunkSpeed"
          ]  
        })
    Promise.all(pitchPromises)
    .then (pitchGroups) ->
      results = _.flatten pitchGroups

      keys = ['timeSeriesForearmSpeed', 'timeSeriesHipSpeed', 'timeSeriesTrunkSpeed']
      _.each results, (result) ->
        _.each keys, (key) ->
          shrunkTiming = []
          for index in [0..result[key].length]
            #show stat for every 5
            if index%5 == 0
              shrunkTiming.push result[key][index]
          result[key] = shrunkTiming

      #cache
      cache.set("pitchTiming#{req.body.athleteProfileId}", results)

      res.send(results)
    .catch (error) ->
      console.log error
      res.sendStatus(500)
  .catch (error) ->
    console.log error
    res.sendStatus(500)



