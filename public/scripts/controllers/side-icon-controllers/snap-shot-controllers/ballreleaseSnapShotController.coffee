angular.module('motus').controller 'ballreleaseSnapShotController', ['currentPlayerFactory','eliteFactory', '$q',(currentPlayerFactory, eliteFactory, $q) ->
  ball = this
  cpf = currentPlayerFactory
  ef = eliteFactory

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

  ball.setClickedRow = (eliteMetric) ->
    ball.selectedMetric = eliteMetric
    ball.image = imageMap[ball.selectedMetric.metric]
    ball.selectedPlayerMetric = ball.currentPlayer.stats.metricScores[ball.selectedMetric.metric].score

  loadPromises = [ef.getEliteMetrics(), cpf.getCurrentPlayer()]  
  $q.all(loadPromises).then () ->
    ball.eliteMetrics = ef.eliteBallrelease
    ball.currentPlayer = cpf.currentPlayer
    _.each ball.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = ball.currentPlayer.stats.metricScores[eliteMetric.metric]
    ball.setClickedRow(ball.eliteMetrics[0])
    console.log 'ball.eliteMetrics: ',ball.eliteMetrics

  console.log 'ball.currentPlayer: ',ball.currentPlayer

  # ball.currentPlayer = cpf.currentPlayer
  # console.log 'ball.currentPlayer: ',ball.currentPlayer
]
