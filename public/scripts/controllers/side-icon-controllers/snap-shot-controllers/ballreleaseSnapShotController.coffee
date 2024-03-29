angular.module('motus').controller 'ballreleaseSnapShotController', ['currentPlayerFactory','eliteFactory', '$stat', '$q',(currentPlayerFactory, eliteFactory, $stat, $q) ->
  ball = this
  cpf = currentPlayerFactory
  ef = eliteFactory

  ball.filterType = '30'

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
      _.each ball.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = ball.currentPlayer.stats.metricScores[eliteMetric.metric]
    else
      $stat.filterLastThrowType(ball.currentPlayer.pitches, ball.filterType)
      .then (stats) ->
        _.each ball.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = stats.metricScores[eliteMetric.metric]

  ball.setClickedRow = (eliteMetric, index) ->
    cpf.ballMetricsIndex = index
    ball.selectedMetric = eliteMetric
    ball.image = imageMap[ball.selectedMetric.metric]
    if ball.currentPlayer.stats?.metricScores
      ball.selectedPlayerMetric = ball.currentPlayer.stats.metricScores[ball.selectedMetric.metric].score

  loadPromises = [ef.getEliteMetrics(), cpf.getCurrentPlayer()]
  $q.all(loadPromises).then () ->
    ball.eliteMetrics = ef.eliteBallrelease
    ball.currentPlayer = cpf.currentPlayer
    _.each ball.eliteMetrics, (eliteMetric) -> 
      if ball.currentPlayer.stats?.metricScores?[eliteMetric.metric] 
        eliteMetric.pstats = ball.currentPlayer.stats.metricScores[eliteMetric.metric]
      else 
        eliteMetric.pstats = null
    ball.setClickedRow(ball.eliteMetrics[cpf.ballMetricsIndex], cpf.ballMetricsIndex)

  return ball

]
