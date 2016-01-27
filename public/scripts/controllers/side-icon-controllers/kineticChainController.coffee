angular.module('motus').controller 'kineticChainController', ['currentPlayerFactory', '$pitch', '$stat' , (currentPlayerFactory, $pitch, $stat) ->
  chain = this
  cpf = currentPlayerFactory


  cpf.getCurrentPlayer()
  .then () ->
    $pitch.getPitchesByAtheleteId(cpf.currentPlayer.athleteProfile.objectId)
    .then (pitches) ->
      stats = $stat.averageTimingData(pitches)
      chain.playerScores = {
        timings: {
          keyframeFirstMovement: stats.keyframeFirstMovement,
          keyframeFootContact: stats.keyframeFootContact,
          keyframeHipSpeed: stats.keyframeHipSpeed,
          keyframeLegKick: stats.keyframeLegKick,
          keyframeTimeWarp: stats.keyframeTimeWarp,
          keyframeTrunkSpeed: stats.keyframeTrunkSpeed
        },
        speeds: [
          { key: "Hips", scores: stats.timeSeriesHipSpeed },
          { key: "Trunk", scores: stats.timeSeriesTrunkSpeed },
          { key: "Forearm", scores: stats.timeSeriesForearmSpeed }
        ]
      }

  return chain
]
