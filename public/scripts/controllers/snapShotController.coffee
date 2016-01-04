angular.module('motus').controller 'snapShotController', ['currentPlayerFactory','$http','$location',(currentPlayerFactory, $http, $location) ->
  sc = this
  cpf = currentPlayerFactory
  sc.greeting = 'hello from snapShotController'
  sc.currentPlayer = cpf.currentPlayer

  $http.get('elite').then (response) ->
    sc.metrics = response.data
    # sc.kinetics = _.pluck(_.filter(sc.metrics, { 'categoryCode': 'K' }), 'metric')
    sc.ballrelease = _.pluck(_.filter(sc.metrics, { 'categoryCode': 'BR' }), 'metric')
    sc.footcontact = _.pluck(_.filter(sc.metrics, { 'categoryCode': 'FC' }), 'metric')
    sc.maxexcursion = _.pluck(_.filter(sc.metrics, { 'categoryCode': 'ME' }), 'metric')
    console.log($location.path())

  if $location.path() == "/player/foot-contact" 
      console.log('FOOTCONTACT!')
      sc.currentpage = "foot-contact"
  else if $location.path() == "/player/ball-release"
      console.log('BALLRELEASE!')
      sc.currentpage = "ball-release"
  else if $location.path() == "/player/max-excursion"
      console.log('MAXEXCURSION!')
      sc.currentpage = "max-excursion"
  return

 
]
