@nextPhase = (rid) ->
	room = ChatRoom.findOne rid
	
	

@startGame = (rid, players) ->
	@Games[rid] = new Game(rid, players)

@endGame = (rid) ->
	room = ChatRoom.findOne rid
	unless room?
		return
	
	ChatRoom.update rid, $set:
		gs: "finished"
	
	Meteor.clearTimeout(MafiaTimeouts[rid])
	delete MafiaTimeouts[rid]