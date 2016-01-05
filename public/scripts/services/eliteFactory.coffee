angular.module('motus').factory 'eliteFactory', [ '$http', '$q', ($http, $q) ->
  ef = this

  #get Elite metrics and filter down to categories of metrics
  ef.getEliteMetrics = () ->
    if ef.metrics
      return $q.when(ef.metrics)
    else
      return $http.get('elite')
      .success (response) ->
        ef.metrics = response
        #Filter Metrics to categories
        ef.eliteMaxexcursion = _.filter(ef.metrics, (metric) -> metric.categoryCode == 'ME' )
        ef.eliteBallrelease = _.filter(ef.metrics, (metric) -> metric.categoryCode == 'BR' )
        ef.eliteKinetics = _.filter(ef.metrics, (metric) -> metric.categoryCode == 'K' )
        ef.eliteFootcontact = _.filter(ef.metrics, (metric) -> metric.categoryCode == 'FC' )
        return ef.metrics
  
  # return the factory object
  return ef
]
