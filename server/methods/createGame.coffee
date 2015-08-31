Meteor.methods
	createGame: (name, setup) ->
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', "[methods] createGame -> Invalid user"

		if not /^[0-9a-z-_]+$/i.test name
			throw new Meteor.Error 'name-invalid'

		console.log '[methods] createGame -> '.green, 'userId:', Meteor.userId(), 'arguments:', arguments

		now = new Date()
		user = Meteor.user()
		username = user.username
		u =
			_id: Meteor.userId()
			username: username

		# avoid duplicate names
		if ChatRoom.findOne({name:name})
			throw new Meteor.Error 'duplicate-name'

		# name = s.slugify name

		room =
			usernames: [username]
			ts: now
			t: 'g'
			name: name
			msgs: 0
			u: u
			phase: "signups"

		RocketChat.callbacks.run 'beforeCreateChannel', user, room

		# create new room
		rid = ChatRoom.insert room
		
		sub =
			rid: rid
			ts: now
			name: name
			t: 'g'
			unread: 0
			u: u

		if username is user.username
			sub.ls = now
			sub.open = true

		ChatSubscription.insert sub

		Meteor.defer ->

			RocketChat.callbacks.run 'afterCreateChannel', user, room

		return {
			rid: rid
		}
