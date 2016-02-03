angular.module('motus').controller('playerController',

  ['$http', 'currentPlayerFactory','eliteFactory','$state', '$player','$stat','$q','$pitch', '$timeout', '$scope',
    ($http, currentPlayerFactory, eliteFactory, $state, $player, $stat, $q, $pitch, $timeout, $scope) ->

      pc = this
      pc.state = $state
      pc.filterType = '30'


      cpf = currentPlayerFactory
      ef = eliteFactory

      getPlayers = () ->
        return $player.getPlayers()
        .then (players) ->

          #Adding this in to make each player
          #in the roster the completed obj like pc.currentPlayer

          pc.playerRoster = players
          if (pc.playerRoster.length > 5)
            pc.overflowCheck = true;

      loadChart = (player) ->
         #Get pitches a year back
        $pitch.getPitches({ daysBack: 365 })
        .then (pitches) ->
          pitches = _.filter pitches, (pitch) -> pitch.athleteProfile.objectId == player.athleteProfile.objectId
          #group pitches by month
          pitches = _.groupBy pitches, (pitch) -> moment(pitch.pitchDate.iso).format('MM/01/YYYY')
          #run engine through all pitches per month
          statsPromises = []
          _.each _.keys(pitches), (key) -> statsPromises.push $stat.runStatsEngine(pitches[key])
          $q.all(statsPromises)
          .then (stats) ->
            #map overall score per month
            scores = _.map _.keys(pitches), (key, i) -> return { date: moment(key, "MM/DD/YYYY").startOf('month').format('MM/YYYY'), score: stats[i].overallScore.ratingScore, overall: stats[i].overallScore.rating}
            
            player.playerScores = scores



      loadNotes = (stats) ->
        pc.currentPlayer.notes = $stat.getLanguage(stats)


      #Select Current Player
      pc.selectedPlayer = (selected) ->
        cpf.currentPlayer = selected
        pc.currentPlayer = cpf.currentPlayer
        loadCurrentPlayer()
        myState = $state.current.name
        $state.reload(myState)

      color = {
        "Poor": '#f90b1c'
        "OK": '#ffaa22'
        "Good": '#00be76'
        "Exceed": '#00be76'
      }


      getPlayerStats = (player) ->
        return $stat.runStatsEngine(player.pitches)
        .then (stats) ->
          return if !stats

          joints = ['ELBOW', 'TRUNK', 'SHOULDER', 'HIP', 'FOOT']

          player.stats = _.extend(player.stats, stats)
          
          _.each joints, (joint) ->
            jointArray = []
            jointObjs = _.filter pc.eliteMetrics, (eliteMetric)-> eliteMetric.jointCode == joint                    
            _.each jointObjs, (jointObj)->
              jointObj.stats = stats.metricScores[jointObj.metric]
              jointObj.rating = jointObj.stats.rating
              jointObj.score = 100
              jointObj.ratingScore = jointObj.stats.ratingScore
              jointObj.opacity = 1
              jointObj.weight = 1
              jointObj.width = 1
              jointObj.order = 1
              jointObj.tooltip = jointObj.rating
              jointObj.playerscore = Math.round(jointObj.stats.score)
              jointObj.eliteval = jointObj.avg
              jointObj.unitmeasure = jointObj.units
              jointObj.label = jointObj.title
              jointObj.color = color[jointObj.rating]
              jointArray.push(jointObj)
            player[joint.toLowerCase()] = jointArray

          loadNotes(stats)

          return player


      loadCurrentPlayer = () ->
        getPlayerStats(pc.currentPlayer)
        .then (player) ->
          elbowObj = _.filter pc.eliteMetrics, (eliteMetric)-> eliteMetric.jointCode == "ELBOW"
          trunkObj = _.filter pc.eliteMetrics, (eliteMetric)-> eliteMetric.jointCode == "TRUNK"
          shoulderObj = _.filter pc.eliteMetrics, (eliteMetric)-> eliteMetric.jointCode == "SHOULDER"
          hipObj = _.filter pc.eliteMetrics, (eliteMetric)-> eliteMetric.jointCode == "HIP"
          footObj = _.filter pc.eliteMetrics, (eliteMetric)-> eliteMetric.jointCode == "FOOT"

          #The five status Icons code
          pc.hipIcon = Math.round(hipObj[9].stats.score)
          pc.hipIconStatus = hipObj[9].stats.rating
          #for the player comparison nightmare
          pc.currentPlayer.hipIcon = Math.round(hipObj[9].stats.score)
          pc.currentPlayer.hipIconStatus = hipObj[9].stats.rating

          pc.trunkIcon = Math.round(hipObj[1].stats.score)
          pc.trunkIconStatus = hipObj[1].stats.rating
          #for the player comparison nightmare
          pc.currentPlayer.trunkIcon = Math.round(hipObj[1].stats.score)
          pc.currentPlayer.trunkIconStatus = hipObj[1].stats.rating


          pc.strideIcon = Math.round(footObj[4].stats.score)
          pc.strideIconStatus = footObj[4].stats.rating
          #for the player comparison nightmare
          pc.currentPlayer.strideIcon = Math.round(footObj[4].stats.score)
          pc.currentPlayer.strideIconStatus = footObj[4].stats.rating

          pc.shldIcon = Math.round(shoulderObj[9].stats.score)
          pc.shldIconStatus = shoulderObj[9].stats.rating
          #for the player comparison nightmare
          pc.currentPlayer.shldIcon = Math.round(shoulderObj[9].stats.score)
          pc.currentPlayer.shldIconStatus = shoulderObj[9].stats.rating

          pc.shldRotIcon = Math.round(shoulderObj[8].stats.score)
          pc.shldRotIconStatus = shoulderObj[8].stats.rating
          #for the player comparison nightmare
          pc.currentPlayer.shldRotIcon = Math.round(shoulderObj[8].stats.score)
          pc.currentPlayer.shldRotIconStatus = shoulderObj[8].stats.rating

        loadChart(pc.currentPlayer)

      pc.setComparison = (player) ->
        getPlayerStats(player)
        .then (statPlayer) ->
          pc.comparedPlayer = statPlayer
          console.log pc.comparedPlayer, pc.currentPlayer
          loadChart(pc.comparedPlayer)
          myState = $state.current.name
          $state.reload(myState)

      #Page Load
      loadPromises = [ef.getEliteMetrics(), cpf.getCurrentPlayer(), getPlayers()]
      $q.all(loadPromises)
      .then (results) ->
        pc.eliteMetrics = results[0]
        pc.currentPlayer = results[1]
        loadCurrentPlayer()

      #From jointKineticsController
      #Trying to make this work here so we can use the drop down filter
      pc.filterLastThrowType = () ->
        console.log 'Player Comparison filter will trigger here. currently non-functional'

      return pc
  ])