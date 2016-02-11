angular.module('motus').controller 'ballreleaseSnapShotController', ['currentPlayerFactory','eliteFactory', '$pitch', '$stat', '$q',(currentPlayerFactory, eliteFactory, $pitch, $stat, $q) ->
  ball = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  ball.filterType = '30'
  ball.subFilters = {}

  imageMap = {
    "fingertipVelocityRelease": "images/legend/BR_FingertipSpeed.jpg",
    "forearmSlotRelease": "images/legend/BR_ForearmSlot.jpg",
    "elbowFlexionRelease": "images/legend/BR_ElbowFlexion.jpg",
    "shoulderRotationRelease": "images/legend/BR_ShoulderRotation.jpg",
    "shoulderAbductionRelease": "images/legend/BR_ShoulderAbduction.jpg",
    "trunkSideTiltRelease": "images/legend/BR_TrunkSideTilt.jpg",
    "trunkFlexionRelease": "images/legend/BR_TrunkFlexion.jpg",
    "trunkRotationRelease": "images/legend/BR_TrunkRotation.jpg",
    "pelvisSideTiltRelease": "images/legend/BR_PelvisSideTilt.jpg",
    "pelvisFlexionRelease": "images/legend/BR_PelvisFlexion.jpg",
    "pelvisRotationRelease": "images/legend/BR_PelvisRotation.jpg",
  }

  ball.filterSession = () ->
    if !ball.filteredPitches
      _.each ball.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = ball.stats.metricScores[eliteMetric.metric]
    else
      $stat.runStatsEngine(ball.filteredPitches)
      .then (stats) ->
        _.each ball.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = stats.metricScores[eliteMetric.metric]

    ball.subFilters.level1 = $pitch.uniquefilterTags(ball.filteredPitches, 1)    
    ball.subFilters.level2 = $pitch.uniquefilterTags(ball.filteredPitches, 2)

  ball.subFilterChange = (sub, level) ->
    #get pitches filtered by session or 30 days
    
    pitches = ball.filteredPitches || ball.currentPlayer.pitches
    if ball.subTag1
      pitches = $pitch.filterTag(pitches, ball.subTag1, 1)
      #update the subfilter level 2
      ball.subFilters.level2 = $pitch.uniquefilterTags(pitches, 2)
    if ball.subTag2
      pitches = $pitch.filterTag(pitches, ball.subTag2, 2)

    #run stats on filterd pitches
    $stat.runStatsEngine(pitches)
    .then (stats) ->
      ball.stats = stats
      _.each ball.eliteMetrics, (eliteMetric) -> 
        if ball.stats?.metricScores?[eliteMetric.metric] 
          eliteMetric.pstats = ball.stats.metricScores[eliteMetric.metric]
        else 
          eliteMetric.pstats = null


  ball.setClickedRow = (eliteMetric, index) ->
    cpf.ballMetricsIndex = index
    ball.selectedMetric = eliteMetric
    ball.image = imageMap[ball.selectedMetric.metric]
    if ball.stats?.metricScores
      ball.selectedPlayerMetric = eliteMetric.pstats.score

  ball.setfilterCount = (pitches, type) ->
    pitchesOfType = _.filter pitches, (pitch) -> 
      if type == 'Untagged'
        return !pitch.tagString
      else
        return false if !pitch.tagString
        return pitch.tagString.split(',')[0] == type
    ball["#{type}Count"] = pitchesOfType.length

  loadPromises = [ef.getEliteMetrics(), cpf.getCurrentPlayer(), $pitch.getPitches({ daysBack: 90 })]
  $q.all(loadPromises).then (results) ->
    ball.eliteMetrics = _.filter(results[0], (metric) -> metric.categoryCode == 'BR' )
    ball.currentPlayer = cpf.currentPlayer

    #group pitches into sessions
    pitches = _.filter results[2], (pitch) -> pitch.athleteProfile.objectId == cpf.currentPlayer.athleteProfile.objectId
    ball.sessions = _.groupBy pitches, (pitch) -> 
      topLevelTagString = if pitch.tagString then pitch.tagString.split(',')[0] else 'Untagged'
      return moment(pitch.pitchDate.iso).format('MM/DD/YYYY') + ':' + topLevelTagString

    #get 30 day average by default on the current player
    $stat.runStatsEngine(ball.currentPlayer.pitches)
    .then (stats) ->
      ball.stats = stats
      _.each ball.eliteMetrics, (eliteMetric) -> 
        if ball.stats?.metricScores?[eliteMetric.metric] 
          eliteMetric.pstats = ball.stats.metricScores[eliteMetric.metric]
        else 
          eliteMetric.pstats = null
      ball.setClickedRow(ball.eliteMetrics[cpf.ballMetricsIndex], cpf.ballMetricsIndex)

    #set subFilters
    ball.subFilters.level1 = $pitch.uniquefilterTags(pitches, 1)
    ball.subFilters.level2 = $pitch.uniquefilterTags(pitches, 2)


  return ball

]
