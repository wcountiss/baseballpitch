cachedPitches = {}
cachedAtheletePitches = {}


angular.module('motus').service('$pitch', ['$http', '$q', ($http, $q) ->
  pitchService = this

  transformPitches = (pitches) ->
    #filter out the pitches of unknown tags since Catch and BallWeight should not show
    pitches = _.filter pitches, (pitch) -> 
      return true if !pitch.tagString
      tag = pitch.tagString.split(',')[0]
      return _.contains(['Longtoss','Bullpen','Game'], tag)

  #get pitches
  pitchService.getPitches = (options={daysBack: 30}) ->
    cacheKey = options.daysBack.toString()
    if cachedPitches[cacheKey]
      return $q.when(cachedPitches[cacheKey])
    else
      defer = $q.defer()
      
      #go to server and get pitches
      $http.post("pitch", options)
      .then (result) ->
        pitches = transformPitches(result.data)

        #cache the pitches in the session
        cachedPitches[cacheKey] = pitches
        defer.resolve(pitches)
    return defer.promise

  pitchService.getPitchesByAtheleteId = (athleteProfileId, options={daysBack: 30}) ->
    cacheKey = "#{athleteProfileId}!#{options.daysBack.toString()}"
    if cachedAtheletePitches[cacheKey]
      return $q.when(cachedAtheletePitches[cacheKey])
    else
      defer = $q.defer()
      
      #get pitches for a particular player
      param = options
      param.athleteProfileId = athleteProfileId

      #go to server and get pitches
      $http.post("pitch/findByAtheleteProfileId", param)
      .then (result) ->
        console.log result.data
        pitches = transformPitches(result.data)

        #cache the pitches in the session
        cachedAtheletePitches[cacheKey] = pitches
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