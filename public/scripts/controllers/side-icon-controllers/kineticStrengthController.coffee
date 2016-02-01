angular.module('motus').controller 'kineticStrengthController', ['$q', 'currentPlayerFactory','eliteFactory', '$stat', ($q, currentPlayerFactory, eliteFactory, $stat) ->
  strength = this
  ef = eliteFactory
  cpf = currentPlayerFactory

  loadPromises = [ef.getEliteMetrics(), cpf.getCurrentPlayer()]
  $q.all(loadPromises).then (results) ->
    strength.eliteMetrics = results[0]
    strength.currentPlayer = cpf.currentPlayer
    $stat.runStatsEngine(strength.currentPlayer.pitches)
    .then (stats) ->
      strength.stats = stats
      strength.playerScores = [
        {bar: 'Hip Speed', value: strength.stats.metricScores.peakHipSpeed.score, average: _.find(strength.eliteMetrics, (eliteMetric) -> eliteMetric.metric == 'peakHipSpeed').avg }
        {bar: 'Trunk Speed', value: strength.stats.metricScores.peakTrunkSpeed.score, average: _.find(strength.eliteMetrics, (eliteMetric) -> eliteMetric.metric == 'peakTrunkSpeed').avg}
        {bar: 'Arm Speed', value: strength.stats.metricScores.peakForearmSpeed.score, average: _.find(strength.eliteMetrics, (eliteMetric) -> eliteMetric.metric == 'peakForearmSpeed').avg}
        {bar: 'Bicep Speed', value: strength.stats.metricScores.peakBicepSpeed.score, average: _.find(strength.eliteMetrics, (eliteMetric) -> eliteMetric.metric == 'peakBicepSpeed').avg}
      ]

  return strength
]
