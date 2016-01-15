angular.module('motus').controller 'ballreleaseSnapShotController', ['currentPlayerFactory','eliteFactory', '$stat', '$q',(currentPlayerFactory, eliteFactory, $stat, $q) ->
  ball = this
  cpf = currentPlayerFactory
  ef = eliteFactory

  ball.filterType = '30'
  cpf.getCurrentPlayer()

  imageMap = {
    "fingerTipVelocityRelease": "images/legend/BR_FingertipSpeed.jpg",
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

  ball.filterLastThrowType = () ->
    if ball.filterType == '30'
      _.each ball.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = ball.stats.metricScores[eliteMetric.metric]
    else
      $stat.filterLastThrowType(ball.currentPlayer.pitches, ball.filterType)
      .then (stats) ->
        _.each ball.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = stats.metricScores[eliteMetric.metric]

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

  loadPromises = [ef.getEliteMetrics(), cpf.getCurrentPlayer()]
  $q.all(loadPromises).then (results) ->
    ball.eliteMetrics = _.filter(results[0], (metric) -> metric.categoryCode == 'BR' )
    ball.currentPlayer = cpf.currentPlayer
    $stat.runStatsEngine(ball.currentPlayer.pitches).then (stats) ->
      ball.stats = stats
      _.each ball.eliteMetrics, (eliteMetric) -> 
        if ball.stats?.metricScores?[eliteMetric.metric] 
          eliteMetric.pstats = ball.stats.metricScores[eliteMetric.metric]
        else 
          eliteMetric.pstats = null
      ball.setClickedRow(ball.eliteMetrics[cpf.ballMetricsIndex], cpf.ballMetricsIndex)
      ball.setfilterCount(ball.currentPlayer.pitches, 'Longtoss')
      ball.setfilterCount(ball.currentPlayer.pitches, 'Bullpen')
      ball.setfilterCount(ball.currentPlayer.pitches, 'Game')
      ball.setfilterCount(ball.currentPlayer.pitches, 'Untagged')


  return ball

]
