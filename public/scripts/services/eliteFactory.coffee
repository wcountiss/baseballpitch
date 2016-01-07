angular.module('motus').factory 'eliteFactory', [ '$http', '$q', ($http, $q) ->
  ef = this

  #get Elite metrics and filter down to categories of metrics
  ef.getEliteMetrics = () ->
    if ef.metrics
      return $q.when(ef.metrics)
    else
      defer = $q.defer();
      $http.get('elite')
      .success (response) ->
        ef.metrics = response
        _.each ef.metrics, (metric) -> 
          metric.eliteLow = Math.round(metric.avg-metric.stdev,0)
          metric.eliteHigh = Math.round(metric.avg+metric.stdev,0)
          metric.title = _.humanize(metric.metric)
          metric.description = 'description goes here..when added to the database this will no longer show'
        #Filter Metrics to categories
        ef.eliteMaxexcursion = _.filter(ef.metrics, (metric) -> metric.categoryCode == 'ME' )
        ef.eliteBallrelease = _.filter(ef.metrics, (metric) -> metric.categoryCode == 'BR' )
        ef.eliteKinetics = _.filter(ef.metrics, (metric) -> metric.categoryCode == 'K' )
        ef.eliteFootcontact = _.filter(ef.metrics, (metric) -> metric.categoryCode == 'FC' )
        defer.resolve(ef.metrics)
      return defer.promise
  
  # return the factory object
  return ef
]
