angular.module('motus').service('$stat', ['$http','$q', 'eliteFactory', ($http, $q, eliteFactory) ->
  stat = this

  #averages array of data
  AverageValues = (data) ->
  
  #Did the player complete the throw types in the last 30 days
  getThrowTypesInLast30Days = (players) ->

  #get scores for each individual metric
  getMetricsScore = (player) ->

  #get scroes for each category of metrics
  getCategoryOverallScore = (player) ->

  #get score overall for the player
  getOverallScore = (player) ->
  
  #give "awards" to players
  getPlayerAwards = (players) ->


  #stat engine
  runStatsEngine = (player) ->
    #get aggregate values
    player.stats.overallScore = getOverallScore(player)
    player.stats.metricScores = getMetricsScore(player)
    player.stats.categoryScores = getCategoryOverallScore(player)

  stat.getPlayersStats = (players) =>
    return $q.when(
      eliteFactory.getEliteMetrics()
      .then (eliteMetrics) ->
        _.each players, (player) -> 
          throwTypes = getThrowTypesInLast30Days()

          #get aggregate values
          player.stats = {
            longThrow: _.contains(throwTypes,'longThrow')
            bullPen:_.contains(throwTypes,'bullPen')
            longThrow: _.contains(throwTypes,'game')
          }
          runStatsEngine(player)
        getPlayerAwards(players)

        return players
    )

  #filter data to a particular set of pitches
  stat.filterThrowType = (player, type) ->

  #filter data to a particular sessions
  stat.filterSession = (player, sessionDate) ->


  return stat
])