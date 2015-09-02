Template.games.helpers
	tRoomMembers: ->
		return t('Members_placeholder')

	isActive: ->
		return 'active' if ChatSubscription.findOne({ t: { $in: ['g']}, f: { $ne: true }, open: true, rid: Session.get('openedRoom') }, { fields: { _id: 1 } })?

	rooms: ->
		return ChatRoom.find { t: 'g', gs: 'signups' }, { sort: 't': 1, 'name': 1 }

Template.games.events
	'click .add-room': (e, instance) ->
		SideNav.setFlex "createChannelFlex"
		SideNav.openFlex()

	'click .more-channels': ->
		SideNav.setFlex "listGamesFlex"
		SideNav.openFlex()
