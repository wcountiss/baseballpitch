angular.module('motus').controller('playerController',

  ['$http', 'currentPlayerFactory','eliteFactory','$state', '$player','$stat','$q','$pitch', '$timeout', '$scope',
    ($http, currentPlayerFactory, eliteFactory, $state, $player, $stat, $q, $pitch, $timeout, $scope) ->

      pc = this
      pc.state = $state
      pc.filterType = '30'

      cpf = currentPlayerFactory
      ef = eliteFactory

      cpf.getPlayerRoster().then (results) ->
        pc.playerRoster = results

      cpf.getCurrentPlayer().then (results) ->
        pc.currentPlayer = results

      cpf.getComparedPlayer().then (results) ->
        pc.comparedPlayer = results
        console.log 'peaking at PC', pc

      #Select Current Player
      pc.selectedPlayer = (selected) ->
        console.log 'passed into selectedPlayer(): ', selected
        cpf.setCurrentPlayer(selected).then () ->
          cpf.getCurrentPlayer().then (results) ->
              pc.currentPlayer = results
              myState = $state.current.name
              $state.reload(myState)
              console.log 'pc: ',pc
              console.log 'cpf :', cpf



      pc.setComparison = (compared) ->
        console.log 'pc.setComparison passing in: ',compared
        cpf.setComparison(compared).then (results) ->
          pc.comparedPlayer = results
          myState = $state.current.name
          $state.reload(myState)
          console.log 'logging pc object, should have a current and comparedPlayer now: ', pc


      #From jointKineticsController
      #Trying to make this work here so we can use the drop down filter
      pc.filterLastThrowType = () ->
        console.log 'Filter Stuff, currently non-functional'



      return pc
  ])
