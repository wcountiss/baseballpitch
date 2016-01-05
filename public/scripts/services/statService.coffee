angular.module('motus').service('$stat', ['$http','$q', 'eliteFactory', ($http, $q, eliteFactory) ->
  stat = this

  #temporary while I finish this
  randomBoolean = () ->
    !(Math.random()+.5|0)
  randomNumber = (min, max) ->
    Math.floor(Math.random() * max + min)

  scoreRatingMapping = ['Good', 'OK', 'Poor']

  #averages array of data
  AverageValues = (data) ->
  
  #Did the player complete the throw types in the last 30 days
  getThrowTypesInLast30Days = (players) ->

  #get scores for each individual metric
  getMetricsScore = (player, eliteMetrics) ->
    returnMetrics = {}
    _.each eliteMetrics, (eliteMetric) ->
      returnMetrics[eliteMetric.metric] = {score: randomNumber(1,100), rating: scoreRatingMapping[randomNumber(0,2)]}
    return returnMetrics

  #get scroes for each category of metrics
  getCategoryOverallScore = (player, eliteMetrics) ->
    returnMetrics = {}
    eliteCategories =  _.uniq(_.pluck(eliteMetrics, 'jointCode'))
    _.each eliteCategories, (eliteCategory) ->
      returnMetrics[eliteCategory] = scoreRatingMapping[randomNumber(0,2)]
    return returnMetrics

  #get score overall for the player
  getOverallScore = (player) ->
    return randomNumber(1,100)

  #stat engine
  runStatsEngine = (player, eliteMetrics) ->
    #get aggregate values
    player.stats.overallScore = getOverallScore(player, eliteMetrics)
    player.stats.metricScores = getMetricsScore(player, eliteMetrics)
    player.stats.categoryScores = getCategoryOverallScore(player, eliteMetrics)

  stat.getPlayersStats = (players) =>
    return $q.when(
      eliteFactory.getEliteMetrics()
      .then (eliteMetrics) ->
        _.each players, (player) -> 
          throwTypes = getThrowTypesInLast30Days()

          #get aggregate values
          player.stats = {
            longThrow: randomBoolean() #_.contains(throwTypes,'longThrow')
            bullPen:  randomBoolean() #_.contains(throwTypes,'bullPen')
            base: randomBoolean() # _.contains(throwTypes,'base')
          }
          runStatsEngine(player, eliteMetrics)
        return players
    )

  #give "awards" to players
  stat.getPlayerAwards = (players) ->
    awards = ['best', 'worst']
    players[randomNumber(0,players.length-1)].stats.award = awards[randomNumber(0,awards.length-1)]
    return players

  #filter data to a particular set of pitches
  stat.filterThrowType = (player, type) ->

  #filter data to a particular sessions
  stat.filterSession = (player, sessionDate) ->


  return stat
])