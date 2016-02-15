angular.module('motus').service '$locHistory', [ '$location','$state', ($location, $state)->
  cu = this

  cu.lastLocation = () ->
     #GET CURRENT LOCATION
    url = $location.url()
    result = url.replace(/\//g,".")
    final = result.replace("."," ")
    trim = final.trim()
    $state.lastloc = trim
  #place to store the current User
  cu
]
