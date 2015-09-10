Meteor.methods
	addUserToRoom: (data) ->
		fromId = Meteor.userId()
		# console.log '[methods] addUserToRoom -> '.green, 'fromId:', fromId, 'data:', data

		room = ChatRoom.findOne data.rid

		# if room.username isnt Meteor.user().username and room.t is 'c'
		unless fromId? and room? and !Meteor.findOne(fromId, fields: ingame: 1).ingame and
		(room.t is 'p' or room.t is 'c' and room.u?.username is Meteor.user().username)
			throw new Meteor.Error 403, '[methods] addUserToRoom -> Not allowed'

		# verify if user is already in room
		if room.usernames.indexOf(data.username) isnt -1
			return

		now = new Date()

		update =
			$addToSet:
				usernames: data.username

		newUser = Meteor.users.findOne username: data.username
		
		throw new Meteor.Error 403, '[methods] addUserToRoom -> User does not exist' unless newUser?

		ChatRoom.update data.rid, update

		ChatSubscription.insert
			rid: data.rid
			ts: now
			name: room.name
			t: room.t
			open: true
			alert: true
			unread: 1
			u:
				_id: newUser._id
				username: data.username

		ChatMessage.insert
			rid: data.rid
			ts: now
			t: 'au'
			msg: newUser.name
			u:
				_id: fromId
				username: Meteor.user().username

		return true
