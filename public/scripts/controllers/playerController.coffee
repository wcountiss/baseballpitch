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
          if (pc.playerRoster.length > 7)
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
              jointArray.push({
                  stats: stats.metricScores[jointObj.metric]
                  rating: stats.metricScores[jointObj.metric].rating
                  score: 100
                  ratingScore: stats.metricScores[jointObj.metric].ratingScore
                  filler: false
                  weight: 1
                  width: 1
                  order: 1
                  tooltip: stats.metricScores[jointObj.metric].rating
                  playerscore: Math.round(stats.metricScores[jointObj.metric].score)
                  eliteval: jointObj.avg
                  unitmeasure: jointObj.units
                  label: jointObj.title
                  eliteHigh: jointObj.eliteHigh
                  units: jointObj.units
                  color: color[stats.metricScores[jointObj.metric].rating]
                })
            player[joint.toLowerCase()] = jointArray

          loadNotes(stats)

          return player


      loadCurrentPlayer = () ->
        getPlayerStats(pc.currentPlayer)
        .then (stats) ->
          return if !stats

          elbowObj = _.filter pc.eliteMetrics, (eliteMetric)-> eliteMetric.jointCode == "ELBOW"
          trunkObj = _.filter pc.eliteMetrics, (eliteMetric)-> eliteMetric.jointCode == "TRUNK"
          shoulderObj = _.filter pc.eliteMetrics, (eliteMetric)-> eliteMetric.jointCode == "SHOULDER"
          hipObj = _.filter pc.eliteMetrics, (eliteMetric)-> eliteMetric.jointCode == "HIP"
          footObj = _.filter pc.eliteMetrics, (eliteMetric)-> eliteMetric.jointCode == "FOOT"
          pc.currentPlayer.hipIcon = Math.round(stats.hip[7].stats.score)
          pc.currentPlayer.hipIconStatus = stats.hip[7].rating

          pc.currentPlayer.trunkIcon = Math.round(stats.trunk[8].stats.score)
          pc.currentPlayer.trunkIconStatus = stats.trunk[8].stats.rating

          pc.currentPlayer.strideIcon = Math.round(stats.foot[4].stats.score)
          pc.currentPlayer.strideIconStatus = stats.foot[4].rating

          pc.currentPlayer.shldIcon = Math.round(stats.shoulder[9].stats.score)
          pc.currentPlayer.shldIconStatus = stats.shoulder[9].rating

          pc.currentPlayer.shldRotIcon = Math.round(stats.shoulder[8].stats.score)
          pc.currentPlayer.shldRotIconStatus = stats.shoulder[8].rating

          if $state.current.name == 'player.home.trends'
            loadChart(pc.currentPlayer)


      pc.playerHomeTrendsClick = () ->
        loadChart(pc.currentPlayer)
        $state.go('player.home.trends')

      pc.playerComparisonToggle = () ->
        if ($state.current.name != 'player.comparison.overview')
          loadChart(pc.currentPlayer)
          $state.go('player.comparison.overview')
        else
          $state.go('player.home.overview')

      pc.setComparison = (player) ->
        getPlayerStats(player)
        .then (statPlayer) ->
          pc.comparedPlayer = statPlayer
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
        $scope.index.loaded = true

      #From jointKineticsController
      #Trying to make this work here so we can use the drop down filter
      pc.filterLastThrowType = () ->
        console.log 'Player Comparison filter will trigger here. currently non-functional'

      return pc
  ])