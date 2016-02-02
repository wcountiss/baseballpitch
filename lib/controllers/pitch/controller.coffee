database = require '../../services/database'
moment = require 'moment'
_ = require 'lodash'
Promise = require 'bluebird'
NodeCache = require( "node-cache" );
extendedCache = new NodeCache({ stdTTL: 60 * 60 * 24 * 90 }); #90 day cache
cache = new NodeCache({ stdTTL: 60 * 60 * 24 * 1 }); #1 day cache

# module.exports.save = (req, res) ->
#   #simple validation, replace with parseModel later
#   if !req.body.playerName || !req.body.teamId
#     res.sendStatus(500)

#   #Saves a player for loading later
#   database.save('player', { playerName: req.body.playerName, teamId: +req.body.teamId })
#   .then (object) ->
#     res.sendStatus(200)
#   .catch (error) ->
#     console.log error
#     res.sendStatus(500)


getTeamMembers = (currentUser) ->
  #cached from player controller
  try
    teamMembers = cache.get("player#{currentUser.id}", true)
    return new Promise(teamMembers)

  #Security, you only have access to your team's althletes
  return database.find('TeamMember', {equal: { team: currentUser.MTTeams}})  


module.exports.find = (req, res) ->
  daysBack = req.body.daysBack || 30
  cachedResults = null
  pitchGotFullSet = false

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
      res.send(cachedResults)
      return
      
  getTeamMembers(req.currentUser)
  .then (teamMembers) ->
    athleteProfiles = _.pluck(teamMembers, 'athleteProfile')
    
    #Go back 30 days by default but can override
    getNumberofPages = 1
    if daysBack > 60
        getNumberofPages = 2
    if daysBack >= 365
        getNumberofPages = 8

    #get pitches by player asynch
    pitchPromises = []
    _.each athleteProfiles, (athleteProfile) ->
        _.times getNumberofPages, (pageNum) ->
            #Find by AthleteProfileIds
            pitchPromises.push database.find('Pitch', { 
              equal: { 'athleteProfile': athleteProfile}, 
              greater: { 'pitchDate': moment().add(-daysBack,'d').toDate() },
              page: pageNum,
              #unneeded byte type columns removed
              select: [
                "armSlot",
                "armSpeed",
                "athleteProfile",
                "createdAt",
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
                "objectId",
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
                "pelvisFlexionFootContact",
                "pelvisFlexionRelease",
                "pelvisRotationFootContact",
                "pelvisRotationRelease",
                "pelvisSideTiltFootContact",
                "pelvisSideTiltRelease",
                "pitchDate",
                "pitchTime",
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
                "trunkSideTiltRelease",
                "updatedAt"
              ]  
            })
    Promise.all(pitchPromises)
    .then (pitchGroups) ->
      results = _.flatten pitchGroups

      #if cached results combine
      if cachedResults
        results = results.concat cachedResults
        results = _.sortBy results, (result) -> moment(result.pitchDate.iso)
      else
        #save 365 was gotten so you don't have to get again for 24 hours
        cache.set( "pitchGotFullSet", true)

      #cache
      extendedCache.set( "pitch#{req.currentUser.id}", results)

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
  getTeamMembers(req.currentUser)
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
        pitchPromises.push database.find('Pitch', { 
          equal: { 'athleteProfile': athleteProfile}, 
          greater: { 'pitchDate': moment().add(-daysBack,'d').toDate() },
          page: pageNum,
          #unneeded byte type columns removed
          select: [
            "athleteProfile",
            "footContactTime",
            "keyframeFirstMovement",
            "keyframeFootContact",
            "keyframeHipSpeed",
            "keyframeLegKick",
            "keyframeTimeWarp",
            "keyframeTrunkSpeed",
            "maxFootHeightTime",
            "objectId",
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
            #show stat for every 10
            if index%10 == 0
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



