angular.module('motus').controller 'kineticStrengthController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  strength = this

  strength.playerScores = [
    {bar: 'test', value: 100}
    {bar: 'other', value: 300}
    {bar: 'another', value: 400}
    {bar: 'oneMore', value: 50}
  ]

  return strength
]
