angular.module('motus').controller 'kineticChainController', ['currentPlayerFactory', '$pitch', '$stat' , (currentPlayerFactory, $pitch, $stat) ->
  chain = this
  cpf = currentPlayerFactory


  cpf.getCurrentPlayer()
  .then () ->
    $pitch.getPitchesByAtheleteId(cpf.currentPlayer.athleteProfile.objectId)
    .then (pitches) ->
      console.log 'running stats'
      stats = $stat.averageTimingData(pitches)
      console.log 'chart bind'
      chain.playerScores = [
        { key: "Hips", scores: stats.timeSeriesHipSpeed },
        { key: "Trunk", scores: stats.timeSeriesTrunkSpeed },
        { key: "Forearm", scores: stats.timeSeriesForearmSpeed }
      ]

  return chain
]
