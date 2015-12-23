angular.module('motus').controller('playerController',
['$scope', '$http'
  ($scope, $http) ->
    # Random number to generate boolean for Roster list icon colors
    randomBoolean = () ->
      !(Math.random()+.5|0)
    randomNumber = (min, max) ->
      Math.floor(Math.random() * max + min)

    colorOptions = [ '#e35746', '#ffe966', '#00a339' ]
    toolTipOptions = [ 'Bad', 'Ok', 'Good' ]

    #hardcoded change to by login later
    $scope.teamId = 1

    #random stats
    statNames = ['arm','shoulder','hip','leg','foot']
    _.each statNames, (stat) ->
      scores = [
        { order: 1, score: 100, weight: 1, label: "Rotation" }
        { order: 2, score: 100, weight: 1, label: "Movement" }
        { order: 3, score: 100, weight: 1, label: "Force" }
        { order: 4, score: 100, weight: 1, label: "Acceleration" }
        { order: 5, score: 100, weight: 1, label: "Timing" }
        { order: 6, score: 100, weight: 1, label: "Deceleration" }
      ]
      _.each scores, (score) -> 
        randomNum = randomNumber(0,3)
        score.color = colorOptions[randomNum]
        score.tooltip = toolTipOptions[randomNum]
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
