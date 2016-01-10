angular.module('motus').controller('indexController',
['$scope', '$state', '$http', '$cookies', '$currentUser', '$q',
  ($scope, $state, $http, $cookies, $currentUser, $q) ->
    $scope.state = $state
    #if logged in set the current user
    $scope.loadUser = () ->
      stateDefer = $q.defer()
      if $cookies.get('motus')
        $http.get('/user')
        .success (user) ->
          $currentUser.user = user
          $scope.user = $currentUser.user
          stateDefer.resolve()
      else
        $scope.user = $currentUser.user
      return stateDefer.promise


    $scope.logOut = () ->
      $cookies.remove('motus')
      # $state.go('login')
      window.location = '?#/login'

    
    #########################################################
    # Main Navigation -team overview-player analysis states #
    #########################################################

    #Page Load
    $scope.loadUser().then () ->
      #Set Initial States of Header Nav
      uiState = $state.current.name
      if uiState == "player" || uiState == "player.home" || uiState == "player.kinetic-chain" || uiState == "player.foot-contact" || uiState == "player.ball-release" || uiState == "player.max-excursion" || uiState == "player.joint-kinetics" || uiState == "player.trends"
        $scope.playerAnalysisActive = true
        $scope.teamOverviewActive = false
      else
        $scope.playerAnalysisActive = false
        $scope.teamOverviewActive = true


    #Changes Which Header nav is Active
    $scope.headerActive = (activeHeader) ->
      if activeHeader == "team"
        $scope.teamOverviewActive = true
        $scope.playerAnalysisActive = false
      else
        $scope.teamOverviewActive = false
        $scope.playerAnalysisActive = true
])
