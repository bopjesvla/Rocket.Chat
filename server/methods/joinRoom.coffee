Meteor.methods
	joinRoom: (rid) ->
		user = Meteor.user()
		
		if user.g?
			throw new Meteor.Error 'already-in-game', 'Cannot join rooms while in a game'
		
		room = ChatRoom.findOne rid
		
		unless room?.t is 'c' or room.t is 'g' and room.gs not in ["ongoing", "filled"]
			throw new Meteor.Error 403, '[methods] joinRoom -> Not allowed'
				
		unless room.usernames.indexOf(user.username) is -1
			throw new Meteor.Error 300, "You're already in this room"

		# verify if user is already in room
		# if room.usernames.indexOf(user.username) is -1
		console.log '[methods] joinRoom -> '.green, 'userId:', Meteor.userId(), 'arguments:', arguments

		now = new Date()

		RocketChat.callbacks.run 'beforeJoinRoom', user, room

		update =
			$addToSet:
				usernames: user.username
		
		if room.gs is "signups" and room.usernames.length is room.size - 1
			MafiaTimeouts[rid] = Meteor.setTimeout (() -> startGame(rid)), 10000
			update.$set =
				gs: "filled"
				dl: new Date(MafiaTimeouts[rid]._idleStart)
		
		ChatRoom.update rid, update
		
		ChatSubscription.insert
			rid: rid
			ts: now
			name: room.name
			t: room.t
			open: true
			alert: true
			unread: 1
			u:
				_id: user._id
				username: user.username
		
		if room.gs is "signups"
			Meteor.users.update Meteor.userId(), {$set: {g: rid}}
		
		ChatMessage.insert
			rid: rid
			ts: now
			t: 'uj'
			msg: user.name
			u:
				_id: user._id
				username: user.username

		Meteor.defer ->

			RocketChat.callbacks.run 'afterJoinRoom', user, room

		return true
