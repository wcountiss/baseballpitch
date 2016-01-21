angular.module('motus').controller 'trendsController', ['$scope', '$q','currentPlayerFactory','eliteFactory', '$pitch', '$stat',($scope, $q, currentPlayerFactory, eliteFactory, $pitch, $stat) ->

  trends = this
  cpf = currentPlayerFactory
  ef = eliteFactory

  #Accordion State open or closed
  trends.isOpen = { foot: false, hip: false, trunk: false, shoulder: false, elbow: false }

  loadPromises = [ef.getEliteMetrics(), cpf.getCurrentPlayer()]
  $q.all(loadPromises).then (results) ->
    trends.eliteMetrics = results[0]
    trends.currentPlayer = cpf.currentPlayer
    trends.selectMetric(trends.eliteMetrics[0])

    #Create footJoint array for the accordion
    trends.footJoint = _.filter trends.eliteMetrics, (obj) ->
      if obj.jointCode == 'FOOT'
        return obj

    #Create hipJoint array for the accordion
    trends.hipJoint = _.filter trends.eliteMetrics, (obj) ->
      if obj.jointCode == 'HIP'
        return obj

    #Create trunkJoint array for the accordion
    trends.trunkJoint = _.filter trends.eliteMetrics, (obj) ->
      if obj.jointCode == 'TRUNK'
        return obj

    #Create shoulderJoint array for the accordion
    trends.shoulderJoint = _.filter trends.eliteMetrics, (obj) ->
      if obj.jointCode == 'SHOULDER'
        return obj

    #Create elbowJoint array for the accordion
    trends.elbowJoint = _.filter trends.eliteMetrics, (obj) ->
      if obj.jointCode == 'ELBOW'
        return obj

  trends.groupClick = (element) ->
    #group the pitches into sessions and tags
    pitches = _.groupBy trends.currentPlayer.pitches, (pitch) -> moment(pitch.pitchDate.iso).format('MM/DD/YYYY')
    pitches = pitches[element.group]
    pitches = $pitch.filterTag(pitches, element.name)
    pitches = _.sortBy pitches, (pitch) -> moment(pitch.pitchDate.iso)

    scores = _.map pitches, (pitch, i) -> { index: i+1, score: pitch[trends.selectedMetric.metric]}

    #filter the trend chart down to the clicked element and rebind to detail chart
    trends.playerDetailScores = {
      average: trends.playerScores.average,
      scores: scores
    }

    $scope.$apply()
    return

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
        Longtoss: stats[0]?.metricScores[metric.metric].score,
        Bullpen: stats[1]?.metricScores[metric.metric].score,
        Game: stats[2]?.metricScores[metric.metric].score,
        Untagged: stats[3]?.metricScores[metric.metric].score
      }

  #select metric and map to the chart
  trends.selectMetric = (metric) ->
    #blank out detail chart
    trends.playerDetailScores = null

    #Grab the current metric.label and place it into trends.accordionSelected
    #This will add the propper CSS to the selected metric
    trends.accordionSelected = metric.label
    trends.selectedMetric = metric

    #group the pitches into sessions and tags
    pitches = _.groupBy trends.currentPlayer.pitches, (pitch) -> moment(pitch.pitchDate.iso).format('MM/DD/YYYY')

    groups = []
    statsPromises = []
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
        keys: ['Longtoss', 'Bullpen', 'Game', 'Untagged']
        groups: groups
      }


  return trends
]
