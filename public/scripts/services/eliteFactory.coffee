cachedMetrics = null

angular.module('motus').factory 'eliteFactory', [ '$http', '$q', ($http, $q) ->
  ef = this

  #get Elite metrics and filter down to categories of metrics
  ef.getEliteMetrics = () ->
    if cachedMetrics
      return $q.when(cachedMetrics)
    else
      defer = $q.defer();
      $http.get('elite')
      .success (response) ->
        ef.metrics = response
        _.each ef.metrics, (metric) -> 
          metric.eliteLow = Math.round(metric.avg-metric.stdev,0)
          metric.eliteHigh = Math.round(metric.avg+metric.stdev,0)
          metric.title = _.humanize(metric.metric)
        cachedMetrics = ef.metrics
        defer.resolve(ef.metrics)
      return defer.promise
  
  # return the factory object
  return ef
]
