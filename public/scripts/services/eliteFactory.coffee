angular.module('motus').factory 'eliteFactory', [ '$http', '$q', ($http, $q) ->
  ef = this

  ef.getEliteMetrics = () ->
    if ef.metrics
      return $q.when(ef.metrics)
    else
      return $q.when(
        $http.get('elite')
        .success (response) ->
          ef.metrics = response
          ef.eliteMaxexcursion = _.filter(ef.metrics, (metric) -> metric.categoryCode == 'ME' )
          ef.eliteBallrelease = _.filter(ef.metrics, (metric) -> metric.categoryCode == 'BR' )
          ef.eliteKinetics = _.filter(ef.metrics, (metric) -> metric.categoryCode == 'K' )
          ef.eliteFootcontact = _.filter(ef.metrics, (metric) -> metric.categoryCode == 'FC' )
          return ef.metrics
      )
  
  # return the factory object
  return ef
]
