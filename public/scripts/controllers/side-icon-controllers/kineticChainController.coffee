angular.module('motus').controller 'kineticChainController', ['$q', 'currentPlayerFactory', 'eliteFactory', '$pitch', '$stat' , ($q, currentPlayerFactory, eliteFactory, $pitch, $stat) ->
  chain = this
  cpf = currentPlayerFactory
  ef = eliteFactory

  color = {
    "Poor": '#f90b1c'
    "OK": '#ffaa22'
    "Good": '#00be76'
    "Exceed": '#00be76'
  }

  loadPromises = [ef.getEliteMetrics(), cpf.getCurrentPlayer()]
  $q.all(loadPromises)
  .then (results) ->
    chain.eliteMetrics = results[0]

    $pitch.findPitchTimingByAtheleteProfileId(cpf.currentPlayer.athleteProfile.objectId)
    .then (pitches) ->
      if !pitches.length
        chain.loaded = true
        return
        
      stats = $stat.averageTimingData(pitches, chain.eliteMetrics)
      chain.playerScores = {
        timings: {
          keyframeFootContact: stats.keyframeFootContact,
          keyframeLegKick: stats.keyframeLegKick
        },
        timeWarp: stats.keyframeTimeWarp,        
        averages: {
          peakHipSpeedTime: _.find chain.eliteMetrics, (metric) -> metric.metric == 'peakHipSpeedTime'
          peakTrunkSpeedTime: _.find chain.eliteMetrics, (metric) -> metric.metric == 'peakTrunkSpeedTime'
          # peakForearmSpeedTime: _.find chain.eliteMetrics, (metric) -> metric.metric == 'peakForearmSpeedTime'
        }
        peakSpeeds: {
          Hip: { score: stats.metricScores.peakHipSpeedTime.score, color: color[stats.metricScores.peakHipSpeedTime.rating] }
          Trunk: { score: stats.metricScores.peakTrunkSpeedTime.score, color: color[stats.metricScores.peakTrunkSpeedTime.rating] }
          Forearm: { score: stats.metricScores.peakForearmSpeedTime.score, color: color[stats.metricScores.peakForearmSpeedTime.rating] }
        }
        speeds: [
          { key: "Hip", scores: stats.timeSeriesHipSpeed },
          { key: "Trunk", scores: stats.timeSeriesTrunkSpeed },
          { key: "Forearm", scores: stats.timeSeriesForearmSpeed }
        ]
      }
      chain.loaded = true

  return chain
]
