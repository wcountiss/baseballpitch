cachedPitches = {}

angular.module('motus').service('$pitch', ['$http', '$q', ($http, $q) ->
  pitchService = this

  #get pitches
  pitchService.getPitches = (options={daysBack: 30}) ->
    cacheKey = options.daysBack.toString()
    if cachedPitches[cacheKey]
      return $q.when(cachedPitches[cacheKey])
    else
      defer = $q.defer()
      $http.post("pitch", options)
      .success (pitches) ->
        cachedPitches[cacheKey] = pitches
        defer.resolve(pitches)
      return defer.promise

  return pitchService
])