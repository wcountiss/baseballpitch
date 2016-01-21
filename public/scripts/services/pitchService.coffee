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
      #get pitches from the server
      $http.post("pitch", options)
      .success (pitches) ->
        #filter out the pitches of unknown tags since Catch and BallWeight should not show
        pitches = _.filter pitches, (pitch) -> 
          return true if !pitch.tagString
          tag = pitch.tagString.split(',')[0]
          return _.contains(['Longtoss','Bullpen','Game'], tag)

        #cache the pitches in the session
        cachedPitches[cacheKey] = pitches
        defer.resolve(pitches)
      return defer.promise

  pitchService.filterTag = (pitches, tag) ->
    pitches = _.filter pitches, (pitch) -> 
      if tag == 'Untagged'
        return !pitch.tagString
      else
        return false if !pitch.tagString
        return pitch.tagString.split(',')[0] == tag
      return pitches

  return pitchService
])