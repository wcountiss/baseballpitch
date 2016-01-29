database = require '../../services/database'
moment = require 'moment'
_ = require 'lodash'
Promise = require 'bluebird'

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

module.exports.find = (req, res) ->
  #Security, you only have access to your team's althletes
  database.find('TeamMember', {equal: { team: req.currentUser.MTTeams}})
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
    _.each athleteProfiles, (athleteProfile) ->
        _.times getNumberofPages, (pageNum) ->
            #Find by AthleteProfileIds
            pitchPromises.push database.find('Pitch', { 
              equal: { 'athleteProfile': athleteProfile}, 
              greater: { 'pitchDate': moment().add(-daysBack,'d').toDate() },
              page: pageNum,
              #unneeded byte type columns removed
              select: ["armSlot",
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
      res.send(results)
    .catch (error) ->
      console.log error
      res.sendStatus(500)
  .catch (error) ->
    console.log error
    res.sendStatus(500)


module.exports.findByAtheleteProfileId = (req, res) ->
  #required params
  if !req.body.athleteProfileId
    res.status(400).send({ error: 'No AthleteProfileId'})

  #Security, you only have access to your team's althletes
  database.find('TeamMember', {equal: { team: req.currentUser.MTTeams}})
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
          select: ["armSlot",
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
            "keyframeFirstMovement",
            "keyframeFootContact",
            "keyframeHipSpeed",
            "keyframeLegKick",
            "keyframeTimeWarp",
            "keyframeTrunkSpeed",
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
            "timeSeriesForearmSpeed",
            "timeSeriesHipSpeed",
            "timeSeriesTrunkSpeed",
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
      res.send(results)
    .catch (error) ->
      console.log error
      res.sendStatus(500)
  .catch (error) ->
    console.log error
    res.sendStatus(500)



