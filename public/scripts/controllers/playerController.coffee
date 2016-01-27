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








      pc.hello = (whodis) ->
        cpf.comparisonObj.player2 = whodis
        console.log pc.comparisonObj
        myState = $state.current.name
        $state.reload(myState)

      #From jointKineticsController
      #Trying to make this work here so we can use the drop down filter
      pc.filterLastThrowType = () ->
        console.log 'Player Comparison filter will trigger here. currently non-functional'

      return pc
  ])
