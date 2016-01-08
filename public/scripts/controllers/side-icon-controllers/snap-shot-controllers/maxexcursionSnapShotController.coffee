angular.module('motus').controller 'maxexcursionSnapShotController', ['currentPlayerFactory','eliteFactory','$stat', '$q',(currentPlayerFactory, eliteFactory, $stat, $q) ->
  max = this
  cpf = currentPlayerFactory
  ef = eliteFactory

  max.filterType = '30'

  imageMap = {
    "maxElbowFlexion": "images/legend/MAX_ElbowFLexion.jpg",
    "maxShoulderRotation": "images/legend/MAX_ShoulderRotation.jpg",
    "maxTrunkSeparation": "images/legend/MAX_TrunkRotation.jpg",
    "maxFootHeight": "images/legend/MAX_FootHeight.jpg",
  }

  max.filterLastThrowType = () ->
    if max.filterType == '30'
      _.each max.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = max.currentPlayer.stats.metricScores[eliteMetric.metric]
    else
      $stat.filterLastThrowType(max.currentPlayer.pitches, max.filterType)
      .then (stats) ->
        _.each max.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = stats.metricScores[eliteMetric.metric]
  
  max.setClickedRow = (eliteMetric, index) ->
    cpf.maxMetricsIndex = index
    max.selectedMetric = eliteMetric
    max.image = imageMap[max.selectedMetric.metric]
    if max.currentPlayer.stats?.metricScores
      max.selectedPlayerMetric = max.currentPlayer.stats.metricScores[max.selectedMetric.metric].score

  loadPromises = [ef.getEliteMetrics(), cpf.getCurrentPlayer()]
  $q.all(loadPromises).then () ->
    max.eliteMetrics = ef.eliteMaxexcursion
    max.currentPlayer = cpf.currentPlayer
    _.each max.eliteMetrics, (eliteMetric) -> 
      if max.currentPlayer.stats?.metricScores?[eliteMetric.metric] 
        eliteMetric.pstats = max.currentPlayer.stats.metricScores[eliteMetric.metric]
      else 
        eliteMetric.pstats = null
    max.setClickedRow(max.eliteMetrics[cpf.maxMetricsIndex], cpf.maxMetricsIndex)

  return max
]
