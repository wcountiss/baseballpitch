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
        { order: 1, score: 100, weight: 1, label: "Movement" }
        { order: 1, score: 100, weight: 1, label: "Force" }
        { order: 1, score: 100, weight: 1, label: "Acceleration" }
        { order: 1, score: 100, weight: 1, label: "Timing" }
        { order: 1, score: 100, weight: 1, label: "Deceleration" }
        { order: 1, score: 100, weight: 1, label: "Velocity" }
        { order: 1, score: 100, weight: 1, label: "Momentum" }
        { order: 1, score: 100, weight: 1, label: "Distance" }
        { order: 1, score: 100, weight: 1, label: "Rate" }
      ]
      _.each scores, (score) -> 
        randomNum = randomNumber(0,3)
        score.color = colorOptions[randomNum]
        score.tooltip = toolTipOptions[randomNum]
      #random number of slices
      scores = _.slice(scores, 0, randomNumber(4,10))
      $scope[stat] = scores

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
