app = angular.module 'motus', ['ui.router','ngCookies','d3', 'ngAnimate'],
  ($stateProvider, $urlRouterProvider, $sceDelegateProvider) ->
    $sceDelegateProvider.resourceUrlWhitelist(["self"])
    
    #For demo just go to a player details for now
    $stateProvider
    .state('login', {
      url: "/login",
      templateUrl: "views/login.html",
      controller: 'loginController'
      authenticate: false
    })
    .state('player', {
      url: "/player",
      templateUrl: "views/player.html",
      controller: 'playerController'
      authenticate: true
    })
    .state('admin', {
      url: "/admin",
      templateUrl: "views/admin.html",
      controller: 'adminController'
      authenticate: true
    })
    #starting page
    $urlRouterProvider.otherwise("/player");

app.run ($rootScope, $state, $cookies) ->
  $rootScope.$on "$stateChangeStart", (event, toState, toParams, fromState, fromParams) ->
    #if not logged in, go to login screen
    if (toState.authenticate && !$cookies.get('motus'))
      #User isn’t authenticated, not sure why I have to do this
      window.location = '?#/login'
      # $state.go("login")

require './controllers/indexController.coffee'    
require './controllers/playerController.coffee'
require './controllers/loginController.coffee'
require './controllers/adminController.coffee'
