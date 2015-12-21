app = angular.module 'motus', ['ui.router','ngCookies','d3', 'ngAnimate'],
  ($stateProvider, $urlRouterProvider, $sceDelegateProvider) ->
    $sceDelegateProvider.resourceUrlWhitelist(["self"])
    
    #For demo just go to a player details for now
    $urlRouterProvider.otherwise("/player");

    $stateProvider
    .state('player', {
      url: "/player",
      templateUrl: "views/player.html",
      controller: 'playerController'
    })
    .state('admin', {
      url: "/admin",
      templateUrl: "views/admin.html",
      controller: 'adminController'
    })

require './controllers/indexController.coffee'    
require './controllers/playerController.coffee'
require './controllers/adminController.coffee'
