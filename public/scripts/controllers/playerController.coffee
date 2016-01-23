angular.module('motus').controller('playerController',

  ['$http', 'currentPlayerFactory','eliteFactory','$state', '$player','$stat','$q','$pitch', '$timeout'
    ($http, currentPlayerFactory, eliteFactory, $state, $player, $stat, $q, $pitch, $timeout) ->

      pc = this
      pc.state = $state

      #Grab data from the factory service
      cpf = currentPlayerFactory
      ef = eliteFactory

      getPlayers = () ->
        return $player.getPlayers()
        .then (players) ->
          pc.playerRoster = players
         
      loadChart = () ->
         #Get pitches a year back
        $pitch.getPitches({ daysBack: 365 })
        .then (pitches) ->
          pitches = _.filter pitches, (pitch) -> pitch.athleteProfile.objectId == pc.currentPlayer.athleteProfile.objectId
          #group pitches by month
          pitches = _.groupBy pitches, (pitch) -> moment(pitch.pitchDate.iso).format('MM/01/YYYY')
          #run engine through all pitches per month
          statsPromises = []
          _.each _.keys(pitches), (key) -> statsPromises.push $stat.runStatsEngine(pitches[key])
          $q.all(statsPromises)
          .then (stats) ->
            #map overall score per month
            scores = _.map _.keys(pitches), (key, i) -> return { date: moment(key, "MM/DD/YYYY").startOf('month').format('MM/YYYY'), score: stats[i].overallScore.ratingScore}
            pc.playerScores = scores

      loadNotes = (stats) ->
        pc.notes = $stat.getLanguage(stats)

      #Select Current Player
      pc.selectedPlayer = (selected) ->
        cpf.currentPlayer = selected
        pc.currentPlayer = cpf.currentPlayer
        loadCurrentPlayer()
        myState = $state.current.name
        $state.reload(myState)
        # pc.hip = pc.hipObj

      color = {
        "Poor": '#f90b1c'
        "OK": '#ffaa22'
        "Good": '#00be76'
        "Exceed": '#00be76'
      }

    

      loadCurrentPlayer = () ->
        #reset
        pc.notes = []

        loadPromises = [ef.getEliteMetrics(), cpf.getCurrentPlayer()]
        $q.all(loadPromises).then (results) ->
          pc.currentPlayer = results[1]
          pc.eliteMetrics = results[0]
          
          elbowObj = _.filter pc.eliteMetrics, (eliteMetric)-> eliteMetric.jointCode == "ELBOW"
          trunkObj = _.filter pc.eliteMetrics, (eliteMetric)-> eliteMetric.jointCode == "TRUNK"
          shoulderObj = _.filter pc.eliteMetrics, (eliteMetric)-> eliteMetric.jointCode == "SHOULDER"
          hipObj = _.filter pc.eliteMetrics, (eliteMetric)-> eliteMetric.jointCode == "HIP"
          footObj = _.filter pc.eliteMetrics, (eliteMetric)-> eliteMetric.jointCode == "FOOT"

          elbArray = []
          trunkArray = []
          shoulderArray = []
          hipArray = []
          footArray = []
          

          $stat.runStatsEngine(pc.currentPlayer.pitches)
          .then (stats) ->
            return if !stats

            _.each elbowObj, (elb)->

              elb.stats = stats.metricScores[elb.metric]
              elb.rating = elb.stats.rating
              elb.score = 100
              elb.ratingScore = elb.stats.ratingScore
              elb.opacity = 1
              elb.weight = 1
              elb.width = 1
              elb.order = 1
              elb.tooltip = elb.rating
              elb.playerscore = Math.round(elb.stats.score)
              elb.eliteval = elb.avg
              elb.unitmeasure = elb.units
              elb.label = elb.title
              elb.color = color[elb.rating]
              elbArray.push(elb)
            pc.elbow = elbArray


            _.each trunkObj, (tru)->

              tru.stats = stats.metricScores[tru.metric]
              tru.rating = tru.stats.rating
              tru.score = 100
              tru.ratingScore = tru.stats.ratingScore
              tru.opacity = 1
              tru.weight = 1
              tru.width = 1
              tru.order = 1
              tru.tooltip = tru.rating
              tru.playerscore = Math.round(tru.stats.score)
              tru.eliteval = tru.avg
              tru.unitmeasure = tru.units
              tru.label = tru.title
              tru.color = color[tru.rating]
              trunkArray.push(tru)
            pc.trunk = trunkArray

            _.each shoulderObj, (sho)->

              sho.stats = stats.metricScores[sho.metric]
              sho.rating = sho.stats.rating
              sho.score = 100
              sho.ratingScore = sho.stats.ratingScore
              sho.opacity = 1
              sho.weight = 1
              sho.width = 1
              sho.order = 1
              sho.tooltip = sho.rating
              sho.playerscore = Math.round(sho.stats.score)
              sho.eliteval = sho.avg
              sho.unitmeasure = sho.units
              sho.label = sho.title
              sho.color = color[sho.rating]
              shoulderArray.push(sho)
            pc.shoulder = shoulderArray

            _.each hipObj, (hip)->

              hip.stats = stats.metricScores[hip.metric]
              hip.rating = hip.stats.rating
              hip.score = 100
              hip.ratingScore = hip.stats.ratingScore
              hip.opacity = 1
              hip.weight = 1
              hip.width = 1
              hip.order = 1
              hip.tooltip = hip.rating
              hip.playerscore = Math.round(hip.stats.score)
              hip.eliteval = hip.avg
              hip.unitmeasure = hip.units
              hip.label = hip.title
              hip.color = color[hip.rating]
              hipArray.push(hip)
            pc.hip = hipArray


            _.each footObj, (foo)->

              foo.stats = stats.metricScores[foo.metric]
              foo.rating = foo.stats.rating
              foo.score = 100
              foo.ratingScore = foo.stats.ratingScore
              foo.opacity = 1
              foo.weight = 1
              foo.width = 1
              foo.order = 1
              foo.tooltip = foo.rating
              foo.playerscore = Math.round(foo.stats.score)
              foo.eliteval = foo.avg
              foo.unitmeasure = foo.units
              foo.label = foo.title
              foo.color = color[foo.rating]
              footArray.push(foo)
            pc.foot = footArray

            #The five status Icons code
            pc.hipIcon = Math.round(hipObj[9].stats.score)
            pc.hipIconStatus = hipObj[9].stats.rating

            pc.trunkIcon = Math.round(hipObj[1].stats.score)
            pc.trunkIconStatus = hipObj[1].stats.rating

            pc.strideIcon = Math.round(footObj[4].stats.score)
            pc.strideIconStatus = footObj[4].stats.rating

            pc.shldIcon = Math.round(shoulderObj[9].stats.score)
            pc.shldIconStatus = shoulderObj[9].stats.rating

            pc.shldRotIcon = Math.round(shoulderObj[8].stats.score)
            pc.shldRotIconStatus = shoulderObj[8].stats.rating
            
            loadNotes(stats)

          loadChart()
        


      #Page Load
      getPlayers()
      .then () ->
        loadCurrentPlayer()   


      return pc
  ])
