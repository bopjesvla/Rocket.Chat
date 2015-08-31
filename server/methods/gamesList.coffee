Meteor.methods
	gamesList: ->
		return { channels: ChatRoom.find({ t: 'g' }, { sort: { msgs:-1 } }).fetch() }