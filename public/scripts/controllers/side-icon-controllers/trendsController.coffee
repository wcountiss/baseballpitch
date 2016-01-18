angular.module('motus').controller 'trendsController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  trends = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  
  trends.playerScores = {
    heading: 'peak Something', units: 'Newtons', average: 12
    keys: ['longToss', 'bullPen', 'game']
    groups: [
      {date: '1/1/2016', longToss: 5, bullPen: 11, game: 14 } 
      {date: '1/3/2016', longToss: 10, bullPen: 23, game: 14 } 
      {date: '1/15/2016', longToss: 10, bullPen: 11, game: 50 } 
    ]
  }


  return trends
]
