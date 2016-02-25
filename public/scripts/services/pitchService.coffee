allCachedPitches = null
thisMonthsCachedPitches = null
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
    if !options?.noCache && allCachedPitches
      returnedPitches = _.filter allCachedPitches, (pitch) -> 
        moment(pitch.pitchDate.iso) >= moment().add(-options.daysBack, 'd')
      return $q.when(returnedPitches)
    else
      defer = $q.defer()
      
      #go to server and get pitches
      $http.post("pitch", {daysBack: 365})
      .then (result) ->
        pitches = transformPitches(result.data)

        #cache the pitches in the session
        allCachedPitches = pitches

        pitches = _.filter allCachedPitches, (pitch) -> 
          moment(pitch.pitchDate.iso) >= moment().add(-options.daysBack, 'd')
        defer.resolve(pitches)
    return defer.promise

  pitchService.findPitchTimingByAtheleteProfileId = (athleteProfileId, options={daysBack: 30}) ->
    cacheKey = "#{athleteProfileId}!#{options.daysBack.toString()}"
    if cachedAtheletePitches[cacheKey]
      return $q.when(cachedAtheletePitches[cacheKey])
    else
      defer = $q.defer()
      
      #get pitches for a particular player
      param = options
      param.athleteProfileId = athleteProfileId

      #go to server and get pitches
      $http.post("pitch/findPitchTimingByAtheleteProfileId", param)
      .then (result) ->
        pitches = transformPitches(result.data)

        #cache the pitches in the session
        cachedAtheletePitches[cacheKey] = pitches
        defer.resolve(pitches)

    return defer.promise


  pitchService.filterTag = (pitches, tag, subLevel=0) ->
    pitches = _.filter pitches, (pitch) -> 
      if tag == 'Untagged'
        return !pitch.tagString || !pitch.tagString.split(',')[subLevel]
      else
        return false if !pitch.tagString || !pitch.tagString.split(',')[subLevel]
        return pitch.tagString.split(',')[subLevel] == tag
      return pitches

  pitchService.uniquefilterTags = (pitches, subLevel=0) -> 
    hasUntagged = _.any(pitches, (pitch) -> !pitch.tagString || !pitch.tagString.split(',')[subLevel]);
    allTags = [] 
    _.each pitches, (pitch) -> 
      if pitch.tagString
        tag = pitch.tagString.split(',')[subLevel]
        if tag
          allTags.push tag.toString()

    allTags = _.uniq(allTags)
    if !subLevel && hasUntagged
      allTags.push 'Untagged'

    return _.sortBy allTags


  return pitchService      
])