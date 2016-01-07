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
    return $q.when(
      _.each players, (player) -> 
        #get aggregate values
        player.stats = {
          longThrow: didThrowType(player.pitches, 'Longtoss')
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
        return players
    )

  #give "awards" to players
  stat.getPlayerAwards = (players) ->
    # FAKE
    #Most improved/regressed get 60 days of pitches?
    awards = ['best', 'worst']
    players[randomNumber(0,players.length-1)].stats.award = awards[randomNumber(0,awards.length-1)]
    return players

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
          pitch.tagString.split(',')[0] == type && moment(pitch.pitchDate).format('MM/DD/YYYY') == moment(lastThrowType.pitchDate).format('MM/DD/YYYY')
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