angular.module('motus').controller 'ballreleaseSnapShotController', ['currentPlayerFactory','eliteFactory', '$pitch', '$stat', '$q','$locHistory',(currentPlayerFactory, eliteFactory, $pitch, $stat, $q, $locHistory) ->
  ball = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  ball.filterType = '30'
  ball.subFilters = {}
  ball.subFilterHeading = 'Pitch Type'
  
  #GET CURRENT LOCATION
  $locHistory.lastLocation()

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
    pitches = ball.sessions[ball.filteredPitchKey] || ball.currentPlayer.pitches
    ball.subTag1 = null
    ball.subTag2 = null
    if !ball.filteredPitchKey
      _.each ball.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = ball.stats.metricScores[eliteMetric.metric]
      ball.subFilterHeading = 'Pitch Type'
    else
      $stat.runStatsEngine(pitches)
      .then (stats) ->
        _.each ball.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = stats.metricScores[eliteMetric.metric]

      #if longtoss the filter is by distance
      ball.subFilterHeading =  if ball.filteredPitchKey.split(':')[1] == 'Longtoss' then 'Distance' else 'Pitch Type'

    ball.subFilters.level1 = $pitch.uniquefilterTags(pitches, 1)    
    ball.subFilters.level2 = $pitch.uniquefilterTags(pitches, 2)

  ball.subFilterChange = (sub, level) ->
    #get pitches filtered by session or 30 days
    pitches = ball.sessions[ball.filteredPitchKey] || ball.currentPlayer.pitches
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
