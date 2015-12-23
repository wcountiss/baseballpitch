angular.module('motus').controller('playerController',
['$scope', '$http'
  ($scope, $http) ->
    # Random number to generate boolean for Roster list icon colors
    randomBoolean = () ->
      !(Math.random()+.5|0)
    randomNumber = (min, max) ->
      Math.floor(Math.random() * max + min)

    colorOptions = [ '#FF0000', '#F6FB5E', '#29CE18' ]

    #hardcoded change to by login later
    $scope.teamId = 1

    #random stats
    statNames = ['arm','shoulder','hip','leg','foot']
    _.each statNames, (stat) ->
      scores = [
        { order: 1, score: 100, weight: 1, label: "rotation" }
        { order: 2, score: 100, weight: 1, label: "movement" }
        { order: 3, score: 100, weight: 1, label: "force" }
        { order: 4, score: 100, weight: 1, label: "acceleration" }
        { order: 5, score: 100, weight: 1, label: "timing" }
        { order: 6, score: 100, weight: 1, label: "deceleration" }
      ]
      _.each scores, (score) -> score.color = colorOptions[randomNumber(0,3)]
      $scope[stat] = scores

    $scope.overview = [
      { date: '1-May-12', close: 100.13 }
      { date: '30-Apr-12', close: 150.98 }
      { date: '27-Apr-12', close: 130.00 }
      { date: '26-Apr-12', close: 140.70 }
      { date: '25-Apr-12', close: 180.00 }
      { date: '24-Apr-12', close: 75.28 }
    ]

    getPlayers = () ->
      $http.post("player/find",  { teamId: $scope.teamId })
      .success (players) ->
        #loop through team and add roster booleans
        _.each (players), (player) ->
          player.longThrow = randomBoolean()            
          player.bullPen = randomBoolean()            
          player.base = randomBoolean()
          
          #hardcoded stats, change to parse later
          player = _.extend(player, { playerAge: randomNumber(20,40), playerHeight: randomNumber(65,80), playerWeight: randomNumber(150,180), playerBirthPlace: "USA", position: 'right'})

          player                 
        $scope.playerRoster = players

    #Page Load
    getPlayers()


])
