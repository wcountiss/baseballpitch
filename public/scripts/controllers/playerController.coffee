angular.module('motus').controller('playerController',

  ['$http', 'currentPlayerFactory','eliteFactory','$state', '$player','$stat','$q','$pitch', '$timeout'
    ($http, currentPlayerFactory, eliteFactory, $state, $player, $stat, $q, $pitch, $timeout) ->

      pc = this
      pc.state = $state

      color = {
            "Poor": '#f90b1c'
            "OK": '#ffaa22'
            "Good": '#00be76'
      }


      $timeout (()->

        console.log('BOOM')
      ), 3000
      
      #Grab data from the factory service
      cpf = currentPlayerFactory
      ef = eliteFactory
      
      console.log("PC OBJ:", pc)


      loadPromises = [ef.getEliteMetrics(), cpf.getCurrentPlayer()]
      $q.all(loadPromises).then (results) ->
        pc.currentPlayer = results[1]
        pc.eliteMetrics = results[0]
        # console.log('THIS IS ELITEMETRICS', pc.eliteMetrics)

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


        $stat.runStatsEngine(pc.currentPlayer.pitches).then (stats) ->
           
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
            foo.label = foo.title
            foo.color = color[foo.rating]
            footArray.push(foo)
            pc.foot = footArray


        


            
            
          # pc.stats = stats
      
      

      
      

      # pc.scores = [
      #   {
      #   joint: 'foot'
      #   order: 1
      #   score: 100
      #   weight: 1
      #   label: "peakVulgusTorque"
      #   color: color['OK']
      #   tooltip: "OK"
      #   opacity: 1
      #   weight: 1
      #   width: 1
      #   },

      #   {
      #   joint: 'foot'
      #   order: 1
      #   score: 100
      #   weight: 1
      #   label: "peakVulgusTorque"
      #   color: color['Poor']
      #   tooltip: "OK"
      #   opacity: 1
      #   weight: 1
      #   width: 1
      #   }
      # ] 


      
  

     
      







      # statNames = ['elbow','shoulder','trunk','hip','foot']
      # statSlices = [10,10,9,8,7]
      # _.each statNames, (stat, i) ->
      #   scores = [
      #     { order: 1, score: 100, weight: 1, label: "Rotation" }
      #     { order: 1, score: 100, weight: 1, label: "Movement" }
      #     { order: 1, score: 100, weight: 1, label: "Force" }
      #     { order: 1, score: 100, weight: 1, label: "Acceleration" }
      #     { order: 1, score: 100, weight: 1, label: "Timing" }
      #     { order: 1, score: 100, weight: 1, label: "Deceleration" }
      #     { order: 1, score: 100, weight: 1, label: "Velocity" }
      #     { order: 1, score: 100, weight: 1, label: "", opacity: 0, color }
      #     { order: 1, score: 100, weight: 1, label: "", opacity: 0 }
      #     { order: 1, score: 100, weight: 1, label: "", opacity: 0 }
      #   ]
      #   _.each scores, (score) ->
      #     randomNum = randomNumber(0,3)
      #     score.color = "#ffaa22"
      #     score.tooltip = toolTipOptions[randomNum]
      #   #Number of slices
      #   score = _.slice(scores, 1, statSlices[i])
        # pc.hip = score
        # pc.trunk = score
        # pc.elbow = score

      getPlayers = () ->
        return $player.getPlayers()
        .then (players) ->
          position = ['starter', 'relief', 'closer']

          #loop through team and add roster booleans
          _.each (players), (player) ->
            #hardcoded stats, change to parse later
            player = _.extend(player, { age: _.random(20,40), height: _.random(65,80), weight: _.random(150,180), birthPlace: "USA", position: position[_.random(2)], level: 'mlb', imgUrl: '../images/matt-harvey.png', alt: 'Matt Harvey'})
            player
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

      #Page Load
      getPlayers()
      .then () ->
        loadChart()


      #Select Current Player
      pc.selectedPlayer = (selected) ->
        cpf.currentPlayer = selected
        pc.currentPlayer = cpf.currentPlayer
        loadChart()
        myState = $state.current.name
        $state.reload(myState)
        pc.hip = pc.hipObj

      return pc
  ])
