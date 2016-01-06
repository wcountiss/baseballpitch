angular.module('motus').service('$stat', ['$http','$q', 'eliteFactory', ($http, $q, eliteFactory) ->
  stat = this

  #temporary while I finish this
  randomBoolean = () ->
    !(Math.random()+.5|0)
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
    return scoreRatingMapping[NumberOfStdDeviations]

  #averages array of data
  average = (data) ->
    return data.reduce(((sum, a) ->
      sum + a
    ), 0) / (data.length or 1)

  #Did the player complete the throw types in the last 30 days
  didThrowTypeInLast30Days = (pitches, type) ->
    return _.any(pitches, (pitch) -> 
      if pitch.tagString 
        pitch.tagString.split(',')[0] == type 
    )

  #get scores for each individual metric
  getMetricsScore = (pitches, eliteMetrics) ->
    returnMetrics = {}
    _.each eliteMetrics, (eliteMetric) ->
      averageScore = average(_.pluck(pitches, eliteMetric.metric))
      returnMetrics[eliteMetric.metric] = { score: averageScore, rating: rateScore(averageScore, eliteMetric)}
    return returnMetrics

  #get scroes for each category of metrics
  getCategoryOverallScore = (player, eliteMetrics) ->
    # FAKE
    returnMetrics = {}
    eliteCategories =  _.uniq(_.pluck(eliteMetrics, 'jointCode'))
    _.each eliteCategories, (eliteCategory) ->
      returnMetrics[eliteCategory] = scoreRatingMapping[randomNumber(0,2)]
    return returnMetrics

  #get score overall for the player
  getOverallScore = (pitches) ->
    # FAKE
    return randomNumber(1,100)

  #stat engine
  runStatsEngine = (player, pitches, eliteMetrics) ->
    #get aggregate values
    player.stats.overallScore = getOverallScore(pitches, eliteMetrics)
    player.stats.metricScores = getMetricsScore(pitches, eliteMetrics)
    player.stats.categoryScores = getCategoryOverallScore(player, eliteMetrics)

  stat.getPlayersStats = (players) =>
    return $q.when(
      eliteFactory.getEliteMetrics()
      .then (eliteMetrics) ->
        _.each players, (player) -> 
          #get aggregate values
          player.stats = {
            longThrow: didThrowTypeInLast30Days(player.pitches, 'Longtoss')
            bullPen:  didThrowTypeInLast30Days(player.pitches, 'Bullpen')
            game: didThrowTypeInLast30Days(player.pitches, 'Game')
          }
          if player.pitches.length
            runStatsEngine(player, player.pitches, eliteMetrics)
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
  stat.filterThrowType = (player, type) ->

  #filter data to a particular sessions
  stat.filterSession = (player, sessionDate) ->


  return stat
])