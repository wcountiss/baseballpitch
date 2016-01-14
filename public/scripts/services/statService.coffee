angular.module('motus').service('$stat', ['$http','$q', 'eliteFactory', '$pitch', ($http, $q, eliteFactory, $pitch) ->
  stat = this

  #function to use based on eliteMetric ColorType (ex: higher than elite is good, bad or in-range) 
  limitNumbers = (score,min, max) ->
    return min if score < min
    return max if score > max
    return score

  scoreFunction = {
    # bad below
    1: (playerScore, eliteMetric) ->
       return (playerScore - (eliteMetric.avg-(2*eliteMetric.stdev)))/(4*eliteMetric.stdev)
    #in-range
    2: (playerScore, eliteMetric) ->
       return 1- (Math.abs((playerScore - eliteMetric.avg))/(2*eliteMetric.stdev))
    #bad above    
    3: (playerScore, eliteMetric) ->
       return  1 - ((playerScore - (eliteMetric.avg-(2*eliteMetric.stdev)))/(4*eliteMetric.stdev))
  }

  scoreRatingMapping = (score) -> 
    #if your score is above 2/3 you are Elite
    if score >= .66
      return 'Good' 
    #if your score is above 1/3 you are doing ok
    if score >= .33
      return 'OK'
    return 'Poor'

  #table to use for what function to use to rate a metric from 0-1
  rateScore = (playerScore, eliteMetric) ->
    #get the score
    score = scoreFunction[eliteMetric.colorType](playerScore, eliteMetric)
    #limit the output to min 0 max 1
    score = limitNumbers(score,0,1)

    #map to Rating and return
    return { ratingScore: score, rating: scoreRatingMapping(score)}

  #averages array of data
  average = (data) ->
    data = _.filter data, (d) -> d
    return data.reduce(((sum, a) ->
      sum + a
    ), 0) / (data.length or 1)

  #Did the player complete the throw pitch type
  didThrowType = (pitches, type) ->
    return _.any(pitches, (pitch) -> 
      if pitch.tagString 
        pitch.tagString.split(',')[0] == type 
    )

  #get scores for each individual metric
  getMetricsScore = (pitches, eliteMetrics) ->
    returnMetrics = {}
    #loop through the metrics
    _.each eliteMetrics, (eliteMetric) ->
      #get 0-1 score of that metric
      averageScore = average(_.pluck(pitches, eliteMetric.metric))
      #return that number and rate it
      returnMetrics[eliteMetric.metric] = _.extend({ ratingScore: averageScore }, rateScore(averageScore, eliteMetric))
    return returnMetrics

  overallScore = {}
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
      returnMetrics[jointMetric] = { ratingScore: averageScore, rating: scoreRatingMapping(averageScore) }
    )
    return returnMetrics

  #get score overall for the player
  getOverallScore = (metricScores) ->
    playersOverallScore = average(_.pluck(metricScores, 'ratingScore'))
    return { ratingScore: playersOverallScore*100, rating: scoreRatingMapping(playersOverallScore) }

  #stat engine
  stat.runStatsEngine = (pitches) ->
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
    statPromises = []
    _.each players, (player) ->
      if player.pitches.length
        statPromises.push stat.runStatsEngine(player.pitches)
      else
        statPromises.push $q.when(null)
    $q.all(statPromises)
    .then (playersStats) ->
      _.each playersStats, (playerStats, i) ->
        if playerStats
          players[i].stats = _.extend(players[i].stats, playerStats)
      defer.resolve(players)
    return defer.promise

  #give "awards" to players
  stat.getPlayerAwards = (players) ->
    defer = $q.defer()
    
    awards = []
    #Need at least 10 pitches to get awards
    awardedPlayers = _.filter players, (player) -> return player.pitches.length >= 10

    #Best Performer Award goes to:
    bestOverallScore = _.max(_.pluck(awardedPlayers, 'stats.overallScore.ratingScore'))
    player = _.find awardedPlayers, (player) -> player.stats.overallScore?.ratingScore == bestOverallScore
    awards.push({award: 'Best Performer', player})

    #Worst Performer Award goes to:
    worstOverallScore = _.min(_.pluck(awardedPlayers, 'stats.overallScore.ratingScore'))
    player = _.find awardedPlayers, (player) -> player.stats.overallScore?.ratingScore == worstOverallScore
    awards.push({award: 'Worst Performer', player})

    #Highest Elbow Torque
    BestElbowTorqueScore = _.max(_.pluck(awardedPlayers, 'stats.metricScores.peakElbowValgusTorque.ratingScore'))
    player = _.find awardedPlayers, (player) -> player.stats.metricScores.peakElbowValgusTorque.ratingScore == BestElbowTorqueScore
    awards.push({award: 'Highest Elbow Torque', player})

    #Lowest Elbow Torque
    worstElbowTorqueScore = _.min(_.pluck(awardedPlayers, 'stats.metricScores.peakElbowValgusTorque.ratingScore'))
    player = _.find awardedPlayers, (player) -> player.stats.metricScores.peakElbowValgusTorque.ratingScore == worstElbowTorqueScore
    awards.push({award: 'Lowest Elbow Torque', player})

    $pitch.getPitches({ daysBack: 60 })
    .then (pitches) ->
      #out of the 60 days, take off the first 30 since they are already on the player
      pitches = _.filter pitches, (pitch) -> moment(pitch.pitchDate.iso) < moment().add('d', -30);
      #group by player
      pitches = _.groupBy pitches, (pitch) -> pitch.athleteProfile.objectId

      #Most Improved/Regressed goes to
      statPromises = []
      _.each awardedPlayers, (player) -> 
        playerPitchesLastMonth = pitches[player.athleteProfile.objectId]
        statPromises.push(stat.runStatsEngine(playerPitchesLastMonth))
      $q.all(statPromises).then (lastMonthStats) ->
        mostImprovedIndex = null
        mostImprovedScore = null
        _.each awardedPlayers, (player, i) -> 
          if pitches[player.athleteProfile.objectId]
            if player.stats.overallScore.ratingScore > lastMonthStats[i].overallScore.ratingScore
              scoreDifference = player.stats.overallScore.ratingScore - lastMonthStats[i].overallScore.ratingScore
              if !mostImprovedScore || scoreDifference > mostImprovedScore
                mostImprovedScore = scoreDifference
                mostImprovedIndex = i
        if mostImprovedIndex
          player = players[mostImprovedIndex]
          awards.push({award: 'Most Improved', player})
        else
          awards.push({award: 'Most Improved', player: { athleteProfile: { firstName: 'NA' } }})


        mostRegressedIndex = null
        mostRegressedScore = null
        _.each awardedPlayers, (player, i) -> 
          if pitches[player.athleteProfile.objectId]
            if lastMonthStats[i].overallScore.ratingScore > player.stats.overallScore.ratingScore
              scoreDifference = lastMonthStats[i].overallScore.ratingScore - player.stats.overallScore.ratingScore
              if !mostRegressedScore ||  scoreDifference > mostRegressedScore
                mostRegressedScore = scoreDifference
                mostRegressedIndex = i
        if mostRegressedIndex
          player = players[mostRegressedIndex]
          awards.push({award: 'Most Regressed', player})
        else
          awards.push({award: 'Most Regressed', player: { athleteProfile: { firstName: 'NA' } }})

        defer.resolve(awards)
    return defer.promise


  stat.getLanguage = (player) ->
    debugger;
    #filter to only Ok and Poor
    listOfImprovementMetrics = _.filter(player.metricScores, (metricScore) -> metricScore.rating != 'Good')
    #sort by worst first
    listOfImprovementMetrics = _.limit(_.sortBy(listOfImprovementMetrics, 'ratingScore'),3,'desc')

    return _.map(listOfImprovementMetrics, (improvementMetric) -> return "Needs to improve #{_.humanize(improvementMetric.metric)}")

  #filter data to a particular set of pitches
  stat.filterLastThrowType = (pitches, type) ->
    defer = $q.defer()
    #if you did not have that throwtype, return empty array

    pitches = _.filter pitches, (pitch) -> 
      if type == 'Untagged'
        return !pitch.tagString
      else
        return false if !pitch.tagString
        return pitch.tagString.split(',')[0] == type

    #run through Player stats
    stat.runStatsEngine(pitches)
    .then (stats) ->
      defer.resolve(stats)
    return defer.promise

  return stat
])