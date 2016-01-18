angular.module('motus').controller 'trendsController', ['$q','currentPlayerFactory','eliteFactory', '$stat',($q, currentPlayerFactory, eliteFactory, $stat) ->
  trends = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  
  loadPromises = [ef.getEliteMetrics(), cpf.getCurrentPlayer()]
  $q.all(loadPromises).then (results) ->
    trends.eliteMetrics = results[0]
    trends.currentPlayer = cpf.currentPlayer    
    trends.selectMetric(trends.eliteMetrics[0])


  getStats = (sessionPitches, metric) ->
    statsPromises = [
      $stat.filterLastThrowType(sessionPitches, 'Longtoss')
      $stat.filterLastThrowType(sessionPitches, 'Bullpen')
      $stat.filterLastThrowType(sessionPitches, 'Game')
      $stat.filterLastThrowType(sessionPitches, 'Untagged')
    ]
    $q.all(statsPromises)
    .then (stats) ->
      return { 
        longToss: stats[0]?.metricScores[metric.metric].score, 
        bullPen: stats[1]?.metricScores[metric.metric].score, 
        game: stats[2]?.metricScores[metric.metric].score, 
        untagged: stats[3]?.metricScores[metric.metric].score  
      }

  #select metric and map to the chart
  trends.selectMetric = (metric) ->
    #group the pitches into sessions and tags
    pitches = _.groupBy trends.currentPlayer.pitches, (pitch) -> moment(pitch.pitchDate.iso).format('MM/DD/YYYY')

    statsPromises = []
    groups = []
    _.each _.keys(pitches), (sessionKey) ->
      sessionPitches = pitches[sessionKey]
      statsPromises.push getStats(sessionPitches, metric).then (sessionStats) ->
        groupStats = _.extend({date: sessionKey}, sessionStats)
        groups.push groupStats

    $q.all(statsPromises)
    .then () ->
      groups = _.sortBy(groups, (group) -> moment(group.date))

      trends.playerScores = {
        heading: metric.label, units: metric.units, average: metric.avg
        keys: ['longToss', 'bullPen', 'game', 'untagged']
        groups: groups
      }


  return trends
]
