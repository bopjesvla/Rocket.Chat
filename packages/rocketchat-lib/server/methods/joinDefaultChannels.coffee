Meteor.methods
	joinDefaultChannels: ->
		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "[methods] setUsername -> Invalid user")

		console.log '[methods] joinDefaultChannels -> '.green, 'userId:', Meteor.userId(), 'arguments:', arguments

		user = Meteor.user()

		RocketChat.callbacks.run 'beforeJoinDefaultChannels', user

		ChatRoom.find({default: true, t: {$in: ['c', 'p']}}).forEach (room) ->
			Meteor.call("joinRoom", room.rid)
