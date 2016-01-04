angular.module('motus').factory 'eliteFactory', [ '$http', ($http) ->
  ef = this

  $http.get('elite').success (response) ->
    console.log('response:',response)
    ef.metrics = response

    ef.eliteMaxexcursion = _.filter(ef.metrics, (metric) -> metric.categoryCode == 'ME' )
    ef.eliteBallrelease = _.filter(ef.metrics, (metric) -> metric.categoryCode == 'BR' )
    ef.eliteKinetics = _.filter(ef.metrics, (metric) -> metric.categoryCode == 'K' )
    ef.eliteFootcontact = _.filter(ef.metrics, (metric) -> metric.categoryCode == 'FC' )

    console.log ef.eliteMaxexcursion
  # return the factory object
  ef
]
