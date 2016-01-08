angular.module('motus').service('$stat', ['$http','$q', 'eliteFactory', ($http, $q, eliteFactory) ->
  stat = this

  #temporary while I finish this
  randomNumber = (min, max) ->
    Math.floor(Math.random() * max + min)

  scoreRatingMapping = ['Good', 'OK', 'Poor']
  rateScore = (score, eliteMetric) ->
    #get difference from average score and unsign score to get diff
    diffFromElite = Math.abs(eliteMetric.avg - score)
    NumberOfStdDeviations = Math.floor(diffFromElite/eliteMetric.stdev)

    #map to Rating
    if NumberOfStdDeviations > 2
      NumberOfStdDeviations = 2
    return { ratingScore: NumberOfStdDeviations, rating: scoreRatingMapping[NumberOfStdDeviations] }

  #averages array of data
  average = (data) ->
    data = _.filter data, (d) -> d
    return Math.round(data.reduce(((sum, a) ->
      sum + a
    ), 0) / (data.length or 1),0)

  #Did the player complete the throw pitch type
  didThrowType = (pitches, type) ->
    return _.any(pitches, (pitch) -> 
      if pitch.tagString 
        pitch.tagString.split(',')[0] == type 
    )

  #get scores for each individual metric
  getMetricsScore = (pitches, eliteMetrics) ->
    returnMetrics = {}
    _.each eliteMetrics, (eliteMetric) ->
      averageScore = average(_.pluck(pitches, eliteMetric.metric))
      returnMetrics[eliteMetric.metric] = _.extend({ score: averageScore }, rateScore(averageScore, eliteMetric))
    return returnMetrics

  #get scroes for each category of metrics
  getCategoryOverallScore = (metricScores, eliteMetrics) ->
    #build object with everything in it to group by categories
    allMetrics = _.map(_.keys(metricScores), (key) -> 
      eliteMetric = _.find(eliteMetrics, (eliteMetric) -> eliteMetric.metric == key)
      _.merge({"key": key}, metricScores[key], eliteMetric )
    )
    #group by the category
    jointMetrics = _.groupBy(allMetrics, (allMetric) -> allMetric.jointCode)
    #average the result to get a categoryScore
    returnMetrics = {}
    _.each(_.keys(jointMetrics), (jointMetric) ->       
      averageScore = average(_.pluck(jointMetrics[jointMetric], 'ratingScore'))
      returnMetrics[jointMetric] = { ratingScore: averageScore, rating: scoreRatingMapping[averageScore] }
    )
    return returnMetrics

  #get score overall for the player
  getOverallScore = (metricScores) ->
    eliteNumber = 85
    _.each metricScores, (metricScore) ->
      eliteNumber = eliteNumber-metricScore.ratingScore
    return eliteNumber

  #stat engine
  runStatsEngine = (pitches) ->
    return $q.when(
      eliteFactory.getEliteMetrics()
        .then (eliteMetrics) ->
          #get aggregate values
          stats = {}
          stats.metricScores = getMetricsScore(pitches, eliteMetrics)
          stats.categoryScores = getCategoryOverallScore(stats.metricScores, eliteMetrics)
          stats.overallScore = getOverallScore(stats.metricScores)
          return stats
    )

  stat.getPlayersStats = (players) =>
    defer = $q.defer()
    _.each players, (player) -> 
      #get aggregate values
      player.stats = {
        longToss: didThrowType(player.pitches, 'Longtoss')
        bullPen:  didThrowType(player.pitches, 'Bullpen')
        game: didThrowType(player.pitches, 'Game')
      }
    statPromises = _.map players, (player) ->
      if player.pitches.length
        runStatsEngine(player.pitches)
        .then (stats) ->
          player.stats = _.extend(player.stats, stats)
          return player
      else
        $q.when({})
    $q.all(statPromises)
    .then () ->
      defer.resolve(players)
    return defer.promise

  #give "awards" to players
  stat.getPlayerAwards = (players) ->
    defer = $q.defer()
    #Best Performer Award goes to:
    bestOverallScore = _.max(_.pluck(players, 'stats.overallScore'))
    player = _.find players, (player) -> player.stats.overallScore == bestOverallScore
    player.stats.award = 'Best Performer'

    #Worst Performer Award goes to:
    worstOverallScore = _.min(_.pluck(players, 'stats.overallScore'))
    player = _.find players, (player) -> player.stats.overallScore == worstOverallScore
    player.stats.award = 'Worst Performer'

    $http.post("pitch", { daysBack: 60 })
    .success (pitches) ->
      #out of the 60 days, take off the first 30 since they are already on the player
      pitches = _.filter pitches, (pitch) -> moment(pitch.pitchDate.iso) < moment().add('d', -30);
      #group by player
      pitches = _.groupBy pitches, (pitch) -> pitch.athleteProfile.objectId

      #Most Improved/Regressed goes to
      statPromises = []
      _.each players, (player) -> 
        playerPitchesLastMonth = pitches[player.athleteProfile.objectId]
        statPromises.push(runStatsEngine(playerPitchesLastMonth))
      $q.all(statPromises).then (lastMonthStats) ->
        mostImprovedIndex = null
        mostImprovedScore = 0
        _.each players, (player, i) -> 
          scoreDifference = player.stats.overallScore - lastMonthStats[i].overallScore
          if scoreDifference > mostImprovedScore
            mostImprovedScore = scoreDifference
            mostImprovedIndex = i
        if mostImprovedIndex
          player = players[mostImprovedIndex]
          player.stats.award = 'Most Improved' 

        mostRegressedIndex = null
        mostRegressedScore = 0
        _.each players, (player, i) -> 
          scoreDifference = lastMonthStats[i].overallScore - player.stats.overallScore
          if scoreDifference > mostRegressedScore
            mostRegressedScore = scoreDifference
            mostRegressedIndex = i
        if mostRegressedIndex
          player = players[mostRegressedIndex]
          player.stats.award = 'Most Regressed'
        defer.resolve()
    return defer.promise


  #filter data to a particular set of pitches
  stat.filterLastThrowType = (pitches, type) ->
    defer = $q.defer()
    # get last of throw type and all throwTypes on that day
    lastThrowType = _.find(pitches, (pitch) ->
      if pitch.tagString 
        pitch.tagString.split(',')[0] == type 
    )

    #if you did not have that throwtype, return empty array
    if lastThrowType
      allThrowsOfTypeOnSameDay = _.filter(pitches, (pitch) -> 
        if pitch.tagString 
          pitch.tagString.split(',')[0] == type && moment(pitch.pitchDate.iso).format('MM/DD/YYYY') == moment(lastThrowType.pitchDate.iso).format('MM/DD/YYYY')
      )

      #run through Player stats
      runStatsEngine(pitches)
      .then (stats) ->
        defer.resolve(stats)
    else
        defer.resolve({})
    return defer.promise

  return stat
])