angular.module('motus').controller 'kineticChainController', ['$q', 'currentPlayerFactory', 'eliteFactory', '$pitch', '$stat' , ($q, currentPlayerFactory, eliteFactory, $pitch, $stat) ->
  chain = this
  cpf = currentPlayerFactory
  ef = eliteFactory

  return
  loadPromises = [ef.getEliteMetrics(), cpf.getCurrentPlayer()]
  $q.all(loadPromises)
  .then (results) ->
    chain.eliteMetrics = results[0]

    $pitch.getPitchesByAtheleteId(cpf.currentPlayer.athleteProfile.objectId)
    .then (pitches) ->
      stats = $stat.averageTimingData(pitches)
      chain.playerScores = {
        timings: {
          keyframeFirstMovement: stats.keyframeFirstMovement,
          keyframeFootContact: stats.keyframeFootContact,
          keyframeHipSpeed: stats.keyframeHipSpeed,
          keyframeLegKick: stats.keyframeLegKick,
          # keyframeTimeWarp: stats.keyframeTimeWarp,
          keyframeTrunkSpeed: stats.keyframeTrunkSpeed
        },
        averages: {
          footContactTime: _.find chain.eliteMetrics, (metric) -> metric.metric == 'footContactTime'
          maxFootHeightTime: _.find chain.eliteMetrics, (metric) -> metric.metric == 'maxFootHeightTime'
          peakBicepSpeedTime: _.find chain.eliteMetrics, (metric) -> metric.metric == 'peakBicepSpeedTime'
          peakForearmSpeedTime: _.find chain.eliteMetrics, (metric) -> metric.metric == 'peakForearmSpeedTime'
          peakHipSpeedTime: _.find chain.eliteMetrics, (metric) -> metric.metric == 'peakHipSpeedTime'
          peakTrunkSpeedTime: _.find chain.eliteMetrics, (metric) -> metric.metric == 'peakTrunkSpeedTime'
        }
        speeds: [
          { key: "Hips", scores: stats.timeSeriesHipSpeed },
          { key: "Trunk", scores: stats.timeSeriesTrunkSpeed },
          { key: "Forearm", scores: stats.timeSeriesForearmSpeed }
        ]
      }

  return chain
]
