angular.module('motus').factory 'currentPlayerFactory', [ '$player', '$q','eliteFactory', '$stat', '$pitch', ($player, $q, eliteFactory, $stat, $pitch)  ->
  cpf = this
  ef = eliteFactory

  cpf.footMetricsIndex = 0
  cpf.ballMetricsIndex = 0
  cpf.maxMetricsIndex = 0
  cpf.jointMetricsIndex = 0

  color = {
    "Poor": '#f90b1c'
    "OK": '#ffaa22'
    "Good": '#00be76'
    "Exceed": '#00be76'
  }

  #Setter for currentPlayer
  cpf.setCurrentPlayer = (xx) ->
    cpf.currentPlayer = xx
    cpf.comparisonObj.player1 = xx
    console.log 'cpf.currentPlayer is now: ',cpf.currentPlayer
    return $q.when(cpf.currentPlayer)

  #Getter for currentPlayer
  cpf.getCurrentPlayer = () ->

    if cpf.currentPlayer
      return $q.when(cpf.currentPlayer)
    else
      return getPlayers().then (results) ->
        cpf.currentPlayer = results[0]


  #Get playerRoster
  cpf.getPlayerRoster = () ->

    if cpf.playerRoster
      return $q.when(cpf.playerRoster)
    else
      return getPlayers()



  cpf.comparisonObj = {
    player1: {},
    player2: null
  }

  getPlayers = () ->
    return $player.getPlayers().then (players) ->
      ef.getEliteMetrics()
      .then (eliteStuff) ->

        #Adding this in to make each player
        #in the roster the completed obj like pc.currentPlayer

        cpf.playerRoster = _.each players, (daPlaya) ->

          elbowObj = _.filter eliteStuff, (eliteMetric)-> eliteMetric.jointCode == "ELBOW"
          trunkObj = _.filter eliteStuff, (eliteMetric)-> eliteMetric.jointCode == "TRUNK"
          shoulderObj = _.filter eliteStuff, (eliteMetric)-> eliteMetric.jointCode == "SHOULDER"
          hipObj = _.filter eliteStuff, (eliteMetric)-> eliteMetric.jointCode == "HIP"
          footObj = _.filter eliteStuff, (eliteMetric)-> eliteMetric.jointCode == "FOOT"

          elbArray = []
          trunkArray = []
          shoulderArray = []
          hipArray = []
          footArray = []


          $stat.runStatsEngine(daPlaya.pitches)
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

            daPlaya.elbow = elbArray


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

            daPlaya.trunk = trunkArray

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

            daPlaya.shoulder = shoulderArray

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

            daPlaya.hip = hipArray


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

            daPlaya.foot = footArray

            #The five status Icons code

            daPlaya.hipIcon = Math.round(hipObj[9].stats.score)
            daPlaya.hipIconStatus = hipObj[9].stats.rating


            daPlaya.trunkIcon = Math.round(hipObj[1].stats.score)
            daPlaya.trunkIconStatus = hipObj[1].stats.rating

            #for the player comparison nightmare
            daPlaya.strideIcon = Math.round(footObj[4].stats.score)
            daPlaya.strideIconStatus = footObj[4].stats.rating

            daPlaya.shldIcon = Math.round(shoulderObj[9].stats.score)
            daPlaya.shldIconStatus = shoulderObj[9].stats.rating

            daPlaya.shldRotIcon = Math.round(shoulderObj[8].stats.score)
            daPlaya.shldRotIconStatus = shoulderObj[8].stats.rating

            loadNotes(daPlaya,stats)
            loadChart(daPlaya)


  loadChart = (object) ->
    #Get pitches a year back
    $pitch.getPitches({ daysBack: 365 })
    .then (pitches) ->
      pitches = _.filter pitches, (pitch) -> pitch.athleteProfile.objectId == object.athleteProfile.objectId
      #group pitches by month
      pitches = _.groupBy pitches, (pitch) -> moment(pitch.pitchDate.iso).format('MM/01/YYYY')
      #run engine through all pitches per month
      statsPromises = []
      _.each _.keys(pitches), (key) -> statsPromises.push $stat.runStatsEngine(pitches[key])
      $q.all(statsPromises)
      .then (stats) ->
        #map overall score per month
        scores = _.map _.keys(pitches), (key, i) -> return { date: moment(key, "MM/DD/YYYY").startOf('month').format('MM/YYYY'), score: stats[i].overallScore.ratingScore, overall: stats[i].overallScore.rating}

        object.playerScores = scores



  loadNotes = (object,stats) ->
    object.notes = $stat.getLanguage(stats)


  # return the factory object
  return cpf
]
