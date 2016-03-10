angular.module('motus').controller 'kineticChainController', ['$q', 'currentPlayerFactory', 'eliteFactory', '$pitch', '$stat', '$locHistory',($q, currentPlayerFactory, eliteFactory, $pitch, $stat, $locHistory) ->
  chain = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  $locHistory.lastLocation()

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

    $pitch.findPitchTimingByAtheleteProfileId(cpf.currentPlayer.objectId)
    .then (pitches) ->
      if !pitches.length
        chain.loaded = true
        return
        
      stats = $stat.averageTimingData(pitches, chain.eliteMetrics)
      chain.playerScores = {
        timings: {
          FootContact: { keyframe: stats.keyframeFootContact, timing: stats.footContactTime },
          LegKick: { keyframe: stats.keyframeLegKick, timing: stats.maxFootHeightTime }
        },
        timeWarp: stats.keyframeTimeWarp,        
        averages: {
          keyframeHipSpeed: _.find chain.eliteMetrics, (metric) -> metric.metric == 'keyframeHipSpeed'
          keyframeTrunkSpeed: _.find chain.eliteMetrics, (metric) -> metric.metric == 'keyframeTrunkSpeed'
        }
        peakSpeeds: {
          Hip: { score: stats.metricScores.peakHipSpeedTime.score, color: color[stats.metricScores.peakHipSpeedTime.rating], rating: stats.metricScores.peakHipSpeedTime.rating, eliteavg: _.find chain.eliteMetrics, (metric) -> metric.metric == 'peakHipSpeedTime' }
          Trunk: { score: stats.metricScores.peakTrunkSpeedTime.score, color: color[stats.metricScores.peakTrunkSpeedTime.rating], rating: stats.metricScores.peakHipSpeedTime.rating, eliteavg: _.find chain.eliteMetrics, (metric) -> metric.metric == 'peakTrunkSpeedTime' }
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
