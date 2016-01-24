angular.module('motus').controller 'kineticChainController', ['currentPlayerFactory','eliteFactory', (currentPlayerFactory, eliteFactory) ->
  chain = this
  
  chain.playerScores = [
    { key: "Hips", scores: [10, 12, 14] },
    { key: "Trunk", scores: [120, 3, 60] },
    { key: "Forearm", scores: [1, 34, 70] }
  ]

  return chain
]
