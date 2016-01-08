angular.module('motus').controller('indexController',
['$scope', '$state', '$http', '$cookies', '$currentUser'
  ($scope, $state, $http, $cookies, $currentUser) ->
    $scope.state = $state
    console.log 'State:::', $scope.state
    #if logged in set the current user
    $scope.loadUser = () ->
      if $cookies.get('motus')
        $http.get('/user')
        .success (user) ->
          $currentUser.user = user
          $scope.user = $currentUser.user
      else
        $scope.user = $currentUser.user

    $scope.logOut = () ->
      $cookies.remove('motus')
      # $state.go('login')
      window.location = '?#/login'

    #Page Load
    $scope.loadUser().then () ->
      #Set Initial States of Header Nav
      uiState = $state.current.name
      console.log 'uiState:', $state.current.name
      if uiState == "player" || uiState == "player.home" || uiState == "player.kinetic-chain" || uiState == "player.foot-contact" || uiState == "player.ball-release" || uiState == "player.max-excursion" || uiState == "player.joint-kinetics" || uiState == "player.trends"
        $scope.playerAnalysisActive = true
        $scope.teamOverviewActive = false
      else
        $scope.playerAnalysisActive = false
        $scope.teamOverviewActive = true

    #########################################################
    # Main Navigation                                       #
    #########################################################

    #Changes Which Header nav is Active
    $scope.headerActive = (activeHeader) ->
      console.log 'headerActive clicked: ',activeHeader
      if activeHeader == "team"
        $scope.teamOverviewActive = true
        $scope.playerAnalysisActive = false
        console.log 'teamOverviewActive:', $scope.teamOverviewActive
      else
        $scope.teamOverviewActive = false
        $scope.playerAnalysisActive = true
        console.log 'teamOverviewActive:', $scope.teamOverviewActive
])
