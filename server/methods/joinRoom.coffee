Meteor.methods
	joinRoom: (rid) ->

		room = ChatRoom.findOne rid
		user = Meteor.user()

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
			update.$set =
				gs: "filled"
				to: (Meteor.setTimeout (() -> startGame(rid)), 0)
		
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
