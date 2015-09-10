Tracker.autorun ->
	user = Meteor.user()
	utcOffset = moment().utcOffset() / 60
	if user?.utcOffset isnt utcOffset
		Meteor.call 'updateUserUtcOffset', utcOffset