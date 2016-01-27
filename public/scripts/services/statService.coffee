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

  scoreMetricRating = {
    # bad below
    1: (playerScore) ->
       return 'Poor' if playerScore == 0
       return 'OK' if playerScore <= .25
       return 'Exceed' if playerScore > .75
       return 'Good'
    #in-range
    2: (playerScore) ->
      return 'Poor' if playerScore == 0
      return 'OK' if playerScore <= .5
      return 'Good'
    #bad above
    3: (playerScore) ->
      return 'Poor' if playerScore == 0
      return 'OK' if playerScore <= .25
      return 'Exceed' if playerScore > .75
      return 'Good'

  }

  scoreOverallRating = (score) ->
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
    return { ratingScore: score, rating: scoreMetricRating[eliteMetric.colorType](score)}

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
      returnMetrics[eliteMetric.metric] = _.extend({ score: averageScore }, rateScore(averageScore, eliteMetric))
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
      returnMetrics[jointMetric] = { ratingScore: averageScore, rating: scoreOverallRating(averageScore) }
    )
    return returnMetrics

  #get score overall for the player
  getOverallScore = (metricScores) ->
    playersOverallScore = average(_.pluck(metricScores, 'ratingScore'))
    return { ratingScore: playersOverallScore*100, rating: scoreOverallRating(playersOverallScore) }

  #stat engine
  stat.runStatsEngine = (pitches) ->
    return $q.when(
      eliteFactory.getEliteMetrics()
        .then (eliteMetrics) ->
          return null if !pitches || !pitches.length

          #get aggregate values
          stats = {}
          stats.metricScores = getMetricsScore(pitches, eliteMetrics)
          stats.categoryScores = getCategoryOverallScore(stats.metricScores, eliteMetrics)
          stats.overallScore = getOverallScore(stats.metricScores)
          return stats
    )

  #get the player object back with the stats on it
  #best for binding the players to page
  stat.getPlayersStats = (players) =>
    statsPromises = []
    _.each players, (player) ->
      statsPromises.push stat.runStatsEngine(player.pitches)
    return $q.all(statsPromises)
    .then (stats) ->
      returnPlayers = _.clone players
      _.each returnPlayers, (returnPlayer,i) ->
        returnPlayer.stats = _.extend(returnPlayer.stats, stats[i])

  stat.getPlayersDidThrowType = (players) =>
    _.each players, (player) ->
      #get aggregate values
      player.stats = {
        longToss: didThrowType(player.pitches, 'Longtoss')
        bullPen:  didThrowType(player.pitches, 'Bullpen')
        game: didThrowType(player.pitches, 'Game')
        #added this line in to create an 'untagged' hope this works. sorry if it doesn't. 1-25-2016
        untagged: didThrowType(player.pitches, 'Untagged')
      }
    return players

  #give "awards" to players
  stat.getPlayerAwards = (players) ->
    defer = $q.defer()

    awards = []
    #Need at least 10 pitches to get awards
    awardedPlayers = _.filter players, (player) -> return player.pitches?.length >= 10

    #get stats on pitches player did
    statPromises = []
    _.each awardedPlayers, (player) ->
      statPromises.push(stat.runStatsEngine(player.pitches))
    $q.all(statPromises).then (thisMonthsStats) ->
      #Best Performer Award goes to:
      bestOverallScore = _.max(_.pluck(thisMonthsStats, 'overallScore.ratingScore'))
      awardIndex = _.findIndex thisMonthsStats, (thisMonthsStat) -> thisMonthsStat.overallScore?.ratingScore == bestOverallScore
      awards.push({award: 'Best Performer', player: awardedPlayers[awardIndex]})

      #Worst Performer Award goes to:
      worstOverallScore = _.min(_.pluck(thisMonthsStats, 'overallScore.ratingScore'))
      awardIndex = _.findIndex thisMonthsStats, (thisMonthsStat) -> thisMonthsStat.overallScore?.ratingScore == worstOverallScore
      awards.push({award: 'Worst Performer', player: awardedPlayers[awardIndex]})

      #Highest Elbow Torque
      BestElbowTorqueScore = _.max(_.pluck(thisMonthsStats, 'metricScores.peakElbowValgusTorque.ratingScore'))
      awardIndex = _.findIndex thisMonthsStats, (thisMonthsStat) -> thisMonthsStat.metricScores.peakElbowValgusTorque.ratingScore == BestElbowTorqueScore
      awards.push({award: 'Highest Elbow Torque', player: awardedPlayers[awardIndex]})

      #Lowest Elbow Torque
      worstElbowTorqueScore = _.min(_.pluck(thisMonthsStats, 'metricScores.peakElbowValgusTorque.ratingScore'))
      awardIndex = _.findIndex thisMonthsStats, (thisMonthsStat) -> thisMonthsStat.metricScores.peakElbowValgusTorque.ratingScore == worstElbowTorqueScore
      awards.push({award: 'Lowest Elbow Torque', player: awardedPlayers[awardIndex]})

      $pitch.getPitches({ daysBack: 60 })
      .then (pitches) ->
        #already have 30 days for filter them out
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
          _.each thisMonthsStats, (thisMonthsStat, i) ->
            if lastMonthStats[i]
              if thisMonthsStat.overallScore.ratingScore > lastMonthStats[i].overallScore.ratingScore
                scoreDifference = thisMonthsStat.overallScore.ratingScore - lastMonthStats[i].overallScore.ratingScore
                if !mostImprovedScore || scoreDifference > mostImprovedScore
                  mostImprovedScore = scoreDifference
                  mostImprovedIndex = i
          if mostImprovedIndex != null
            awards.push({award: 'Most Improved', player: awardedPlayers[mostImprovedIndex]})
          else
            awards.push({award: 'Most Improved', player: { athleteProfile: { firstName: 'NA' } }})


          mostRegressedIndex = null
          mostRegressedScore = null
          _.each thisMonthsStats, (thisMonthsStat, i) ->
            if lastMonthStats[i]
              if lastMonthStats[i].overallScore.ratingScore > thisMonthsStat.overallScore.ratingScore
                scoreDifference = lastMonthStats[i].overallScore.ratingScore - thisMonthsStat.overallScore.ratingScore
                if !mostRegressedScore ||  scoreDifference > mostRegressedScore
                  mostRegressedScore = scoreDifference
                  mostRegressedIndex = i
          if mostRegressedIndex != null
            awards.push({award: 'Most Regressed', player: awardedPlayers[mostRegressedIndex]})
          else
            awards.push({award: 'Most Regressed', player: { athleteProfile: { firstName: 'NA' } }})

          defer.resolve(awards)
    return defer.promise


  stat.getLanguage = (stats) ->
    #turn stats into array
    metricScores = _.map _.keys(stats.metricScores), (statKey) -> { metric: statKey, scores: stats.metricScores[statKey] }

    #filter to only Ok and Poor
    listOfImprovementMetrics = _.filter(metricScores, (metricScore) -> metricScore.scores.rating != 'Good')

    #sort by worst first
    listOfImprovementMetrics = _.slice(_.sortBy(listOfImprovementMetrics, 'scores.ratingScore'),0,3)

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

    defer.resolve(null) if !pitches.length

    #run through Player stats
    stat.runStatsEngine(pitches)
    .then (stats) ->
      defer.resolve(stats)
    return defer.promise

  stat.averageTimingData = (pitches) ->
    keys = ['timeSeriesForearmSpeed', 'timeSeriesHipSpeed', 'timeSeriesTrunkSpeed']
    statResult = {}
    #Loop over the properties
    _.each keys, (key) ->
      #pluck out the array
      keyPitchTimings = _.pluck(pitches, key)
      #average each index of the plucked arary
      averagedTimings = []
      arrayToAverage = []
      for index in [0..keyPitchTimings[0].length]
        #show stat for every 10
        if index%10 == 0
          _.each keyPitchTimings, (keyPitchTiming) ->
            arrayToAverage.push keyPitchTiming[index]
          averagedTimings.push average(arrayToAverage)
      statResult[key] = averagedTimings
    #timing averaged
    statResult.keyframeFirstMovement = average(_.pluck(pitches, 'keyframeFirstMovement'))
    statResult.keyframeFootContact  = average(_.pluck(pitches, 'keyframeFootContact'))
    statResult.keyframeHipSpeed = average(_.pluck(pitches, 'keyframeHipSpeed'))
    statResult.keyframeLegKick = average(_.pluck(pitches, 'keyframeLegKick'))
    statResult.keyframeTimeWarp = average(_.pluck(pitches, 'keyframeTimeWarp'))
    statResult.keyframeTrunkSpeed = average(_.pluck(pitches, 'keyframeTrunkSpeed'))
    return statResult



  return stat
])
