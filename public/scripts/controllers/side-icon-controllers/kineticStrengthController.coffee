angular.module('motus').controller 'kineticStrengthController', ['$q', 'currentPlayerFactory','eliteFactory', '$stat', ($q, currentPlayerFactory, eliteFactory, $stat) ->
  strength = this
  ef = eliteFactory
  cpf = currentPlayerFactory
  
  color = {
    "Poor": '#f90b1c'
    "OK": '#ffaa22'
    "Good": '#00be76'
    "Exceed": '#00be76'
  }

  loadPromises = [ef.getEliteMetrics(), cpf.getCurrentPlayer()]
  $q.all(loadPromises).then (results) ->
    strength.eliteMetrics = results[0]
    strength.currentPlayer = cpf.currentPlayer
    $stat.runStatsEngine(strength.currentPlayer.pitches)
    .then (stats) ->
      return if !stats
      
      strength.stats = stats
      strength.playerScores = [
        {bar: 'Hip Speed', value: strength.stats.metricScores.peakHipSpeed.score, color: color[strength.stats.metricScores.peakHipSpeed.rating], average: _.find(strength.eliteMetrics, (eliteMetric) -> eliteMetric.metric == 'peakHipSpeed').avg }
        {bar: 'Trunk Speed', value: strength.stats.metricScores.peakTrunkSpeed.score, color: color[strength.stats.metricScores.peakTrunkSpeed.rating], average: _.find(strength.eliteMetrics, (eliteMetric) -> eliteMetric.metric == 'peakTrunkSpeed').avg}
        {bar: 'Bicep Speed', value: strength.stats.metricScores.peakBicepSpeed.score, color: color[strength.stats.metricScores.peakBicepSpeed.rating], average: _.find(strength.eliteMetrics, (eliteMetric) -> eliteMetric.metric == 'peakBicepSpeed').avg}
        {bar: 'Arm Speed', value: strength.stats.metricScores.peakForearmSpeed.score, color: color[strength.stats.metricScores.peakForearmSpeed.rating], average: _.find(strength.eliteMetrics, (eliteMetric) -> eliteMetric.metric == 'peakForearmSpeed').avg}
      ]

  return strength
]
