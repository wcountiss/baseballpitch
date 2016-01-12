angular.module('motus').controller('indexController',
['$state', '$http', '$cookies', '$currentUser', '$q',
  ($state, $http, $cookies, $currentUser, $q) ->
    index = this
    
    index.state = $state
    #if logged in set the current user
    index.loadUser = () ->
      stateDefer = $q.defer()
      if $cookies.get('motus')
        $http.get('/user')
        .success (user) ->
          $currentUser.user = user
          index.user = $currentUser.user
          stateDefer.resolve()
      else
        index.user = $currentUser.user
      return stateDefer.promise


    index.logOut = () ->
      $cookies.remove('motus')
      # $state.go('login')
      window.location = '?#/login'

    
    #########################################################
    # Main Navigation -team overview-player analysis states #
    #########################################################

    #Page Load
    index.loadUser().then () ->
      #Set Initial States of Header Nav
      uiState = $state.current.name
      playerUIs = ["player","player.home","player.kinetic-chain","player.foot-contact","player.ball-release","player.max-excursion","player.joint-kinetics","player.trends"]
      index.playerAnalysisActive = _.indexOf(playerUIs,uiState) > -1 
      index.teamOverviewActive = !_.indexOf(playerUIs,uiState) > -1 


    #Changes Which Header nav is Active
    index.headerActive = (activeHeader) ->
      index.teamOverviewActive = activeHeader == "team"
      index.playerAnalysisActive = activeHeader != "team"

    return index
])
