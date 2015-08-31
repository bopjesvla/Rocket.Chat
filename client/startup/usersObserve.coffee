Meteor.startup ->
	Meteor.users.find({}, { fields: { username: 1, statusConnection: 1, utcOffset: 1 } }).observe
		added: (user) ->
			Session.set('user_' + user.username + '_status', user.statusConnection)
			RoomManager.updateUserStatus user, user.statusConnection, user.utcOffset
		changed: (user) ->
			Session.set('user_' + user.username + '_status', user.statusConnection)
			RoomManager.updateUserStatus user, user.statusConnection, user.utcOffset
		removed: (user) ->
			Session.set('user_' + user.username + '_status', null)
			RoomManager.updateUserStatus user, 'offline', null
