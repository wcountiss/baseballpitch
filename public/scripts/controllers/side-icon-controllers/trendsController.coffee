angular.module('motus').controller 'trendsController', ['currentPlayerFactory','eliteFactory',(currentPlayerFactory, eliteFactory) ->
  trends = this
  cpf = currentPlayerFactory
  ef = eliteFactory
  trends.currentPlayer = cpf.currentPlayer

  trends.playerScores = [
    {'State': 'State','Under 5 Years': 'Under 5 Years','5 to 13 Years':'5 to 13 Years','14 to 17 Years':'14 to 17 Years','18 to 24 Years':'18 to 24 Years','25 to 44 Years':'25 to 44 Years','45 to 64 Years':'45 to 64 Years','65 Years and Over':'65 Years and Over'}
    {'State': 'CA', 'Under 5 Years': 2704659, '5 to 13 Years': 4499890, '14 to 17 Years': 2159981, '18 to 24 Years': 3853788,'25 to 44 Years': 10604510, '45 to 64 Years':8819342,'65 Years and Over':4114496}
    {'State': 'TX', 'Under 5 Years': 2027307, '5 to 13 Years': 3277946, '14 to 17 Years': 1420518, '18 to 24 Years': 2454721,'25 to 44 Years': 7017731,'45 to 64 Years':5656528,'65 Years and Over':2472223}
  ]

  return trends
]
