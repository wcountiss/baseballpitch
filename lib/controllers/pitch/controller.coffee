database = require '../../services/database'
moment = require 'moment'
_ = require 'lodash'

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

module.exports.findByAthleteProfiles = (req, res) ->
  #Security, you only have access to your team's althletes
  database.find('TeamMember', {equal: { team: req.currentUser.MTTeams}})
  .then (teamMembers) ->
    athleteProfiles = _.pluck(teamMembers,'athleteProfile')
    athleteProfiles = _.filter(athleteProfiles, (athleteProfile) -> req.body.athleteProfileIds.indexOf(athleteProfile.objectId) > -1)
    #Go back 30 days by default but can override
    daysBack = req.body.daysBack || 30
    #Find by AthleteProfileIds
    console.log daysBack
    console.log moment().add(-daysBack,'d').toDate()
    database.find('Pitch', { equal: { 'athleteProfile': athleteProfiles}, greater: { 'createdAt': moment().add(-daysBack,'d').toDate() }})
    .then (results) ->
      res.send(results)
    .catch (error) ->
      console.log error
      res.sendStatus(500)
  .catch (error) ->
      console.log error
      res.sendStatus(500)

  

 