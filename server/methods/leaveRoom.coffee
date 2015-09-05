Meteor.methods
	leaveRoom: (rid) ->
		fromId = Meteor.userId()
		# console.log '[methods] leaveRoom -> '.green, 'fromId:', fromId, 'rid:', rid

		unless Meteor.userId()?
			throw new Meteor.Error 300, 'Usuário não logado'
		
		room = ChatRoom.findOne rid
		user = Meteor.user()
		
		unless room? and room.usernames.indexOf(user.username) isnt -1
			throw new Meteor.Error 300, "You aren't in this room"

		RocketChat.callbacks.run 'beforeLeaveRoom', user, room

		update =
			$pull:
				usernames: user.username

		ChatSubscription.update { rid: rid },
			$set:
				name: room.name
		,
			multi: true
		
		if room.gs is "filled"
			update.$set = {gs: "signups"}
		else if room.gs is "signups" and room.usernames.length is 1
			update.$set = {gs: "abandoned"}
		
		if room.t isnt 'c'
			removedUser = user

			ChatMessage.insert
				rid: rid
				ts: (new Date)
				t: 'ul'
				msg: removedUser.name
				u:
					_id: removedUser._id
					username: removedUser.username

		if room.u? and room.u._id is Meteor.userId()
			newOwner = _.without(room.usernames, user.username)[0]
			if newOwner?
				newOwner = Meteor.users.findOne username: newOwner

				if newOwner?
					if not update.$set?
						update.$set = {}

					update.$set['u._id'] = newOwner._id
					update.$set['u.username'] = newOwner.username

		ChatSubscription.remove { rid: rid, 'u._id': Meteor.userId() }

		ChatRoom.update rid, update
		
		if user.g is rid
			Meteor.users.update Meteor.userId(), {$unset: g: 1}

		Meteor.defer ->

			RocketChat.callbacks.run 'afterLeaveRoom', user, room
