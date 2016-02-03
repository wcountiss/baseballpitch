angular.module('motus').controller 'kineticChainController', ['$q', 'currentPlayerFactory', 'eliteFactory', '$pitch', '$stat' , ($q, currentPlayerFactory, eliteFactory, $pitch, $stat) ->
  chain = this
  cpf = currentPlayerFactory
  ef = eliteFactory

  loadPromises = [ef.getEliteMetrics(), cpf.getCurrentPlayer()]
  $q.all(loadPromises)
  .then (results) ->
    chain.eliteMetrics = results[0]

    $pitch.findPitchTimingByAtheleteProfileId(cpf.currentPlayer.athleteProfile.objectId)
    .then (pitches) ->
      stats = $stat.averageTimingData(pitches)
      chain.playerScores = {
        timings: {
          keyframeFootContact: stats.keyframeFootContact,
          keyframeHipSpeed: stats.keyframeHipSpeed,
          keyframeLegKick: stats.keyframeLegKick,
          keyframeTrunkSpeed: stats.keyframeTrunkSpeed
          # keyframeTimeWarp: stats.keyframeTimeWarp,
        },
        averages: {
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
