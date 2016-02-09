angular.module('motus').controller 'kineticChainTableController', ['currentPlayerFactory','eliteFactory','$stat','$q',(currentPlayerFactory, eliteFactory, $stat, $q) ->
  # self reference
  table = this
  # grab factory data
  cpf = currentPlayerFactory
  ef = eliteFactory
  table.filterType = '30'


  imageMap = {
    "peakHipSpeed": "images/legend/T_HipSpeed.jpg",
    "peakTrunkSpeed": "images/legend/T_TrunkSpeed.jpg",
    "peakBicepSpeed": "images/legend/T_BicepSpeed.jpg",
    "peakForearmSpeed": "images/legend/BR_ForearmSlot.jpg",
    "peakHipSpeedTime": "images/legend/T_HipSpeed.jpg",
    "peakTrunkSpeedTime": "images/legend/T_TrunkSpeed.jpg",
    "peakBicepSpeedTime": "images/legend/T_BicepSpeed.jpg",
    "peakForearmSpeedTime": "images/legend/BR_ForearmSlot.jpg",
    "footContactTime": "images/legend/T_FootContact.jpg",
    "pitchTime": "images/legend/T_PitchTime.jpg",
  }

  table.filterLastThrowType = () ->
    if table.filterType == '30'
      _.each table.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = table.stats.metricScores[eliteMetric.metric]
    else
      $stat.filterLastThrowType(table.currentPlayer.pitches, table.filterType)
      .then (stats) ->
        _.each table.eliteMetrics, (eliteMetric) -> eliteMetric.pstats = stats.metricScores[eliteMetric.metric]
  
  table.setClickedRow = (eliteMetric, index) ->
    cpf.tableMetricsIndex = index
    table.selectedMetric = eliteMetric
    table.selectedMetric.avg = Math.round(table.selectedMetric.avg)
    table.image = imageMap[table.selectedMetric.metric]
    if table.stats?.metricScores
      table.selectedPlayerMetric = Math.round(eliteMetric.pstats.score)

  table.setfilterCount = (pitches, type) ->
    pitchesOfType = _.filter pitches, (pitch) -> 
      if type == 'Untagged'
        return !pitch.tagString
      else
        return false if !pitch.tagString
        return pitch.tagString.split(',')[0] == type
    table["#{type}Count"] = pitchesOfType.length


  loadPromises = [ef.getEliteMetrics(), cpf.getCurrentPlayer()]
  $q.all(loadPromises).then (results) ->
    table.eliteMetrics = _.filter(results[0], (metric) -> metric.metric == 'peakHipSpeed' || metric.metric == 'peakTrunkSpeed' || metric.metric == 'peakBicepSpeed' || metric.metric == 'peakForearmSpeed' || metric.metric == 'peakHipSpeedTime' || metric.metric == 'peakTrunkSpeedTime' || metric.metric == 'peakBicepSpeedTime' || metric.metric == 'peakForearmSpeedTime'|| metric.metric == 'footContactTime' || metric.metric == 'pitchTime' )
    console.log("ELITEMETRICTABLE: ",table.eliteMetrics)
    table.currentPlayer = cpf.currentPlayer 
    $stat.runStatsEngine(table.currentPlayer.pitches).then (stats) ->
      table.stats = stats
      _.each table.eliteMetrics, (eliteMetric) -> 
        if table.stats?.metricScores?[eliteMetric.metric] 
          eliteMetric.pstats = table.stats.metricScores[eliteMetric.metric]
        else 
          eliteMetric.pstats = null
      table.setClickedRow(table.eliteMetrics[cpf.maxMetricsIndex], cpf.maxMetricsIndex)
      table.setfilterCount(table.currentPlayer.pitches, 'Longtoss')
      table.setfilterCount(table.currentPlayer.pitches, 'Bullpen')
      table.setfilterCount(table.currentPlayer.pitches, 'Game')
      table.setfilterCount(table.currentPlayer.pitches, 'Untagged')

  return table
]
