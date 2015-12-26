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
    $urlRouterProvider.otherwise("/login");

app.run ($rootScope, $state, $cookies) ->
  $rootScope.$on "$stateChangeStart", (event, toState, toParams, fromState, fromParams) ->
    if (toState.authenticate && !$cookies.get('motus'))
      #User isn’t authenticated
      $state.transitionTo("login")
      event.preventDefault()

require './controllers/indexController.coffee'    
require './controllers/playerController.coffee'
require './controllers/loginController.coffee'
require './controllers/adminController.coffee'
