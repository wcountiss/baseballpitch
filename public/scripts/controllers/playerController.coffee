angular.module('motus').controller('playerController',

  ['$http', 'currentPlayerFactory','eliteFactory','$state',
    ($http, currentPlayerFactory, eliteFactory, $state) ->

      pc = this
      pc.state = $state
      pc.filterType = '30'

      cpf = currentPlayerFactory
      ef = eliteFactory

      cpf.getPlayerRoster()
      .then () ->
        pc.playerRoster = cpf.playerRoster
        if (pc.playerRoster.length > 5)
          pc.overflowCheck = true;


      cpf.getCurrentPlayer().then (results) ->
        pc.currentPlayer = results

      cpf.getComparedPlayer().then (results) ->
        pc.comparedPlayer = results


      #Select Current Player
      pc.selectedPlayer = (selected) ->
        cpf.setCurrentPlayer(selected).then () ->
          cpf.getCurrentPlayer().then (results) ->
              pc.currentPlayer = results
              console.log pc
              myState = $state.current.name
              $state.reload(myState)




      pc.setComparison = (compared) ->

        cpf.setComparison(compared).then (results) ->
          pc.comparedPlayer = results
          myState = $state.current.name
          $state.reload(myState)



      #From jointKineticsController
      #Trying to make this work here so we can use the drop down filter
      pc.filterLastThrowType = () ->




      return pc
  ])
