Meteor.methods
	setAvatarFromService: (dataURI, contentType, service) ->
		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "[methods] setAvatarFromService -> Invalid user")
			
		if dataURI.length > 15000
			throw new Meteor.Error('max-size-exceeded', "[methods] setAvatarFromService -> Too big")

		console.log '[methods] setAvatarFromService -> '.green, 'userId:', Meteor.userId(), 'contentType:', contentType, 'service:', service

		user = Meteor.user()

		if service is 'initials'
			Meteor.users.update {_id: user._id}, {$set: {avatarOrigin: service}}
			return

		{image, contentType} = RocketChatFile.dataURIParse dataURI

		rs = RocketChatFile.bufferToStream new Buffer(image, 'base64')
		ws = RocketChatFileAvatarInstance.createWriteStream "#{user.username}.jpg", contentType
		ws.on 'end', Meteor.bindEnvironment ->
			Meteor.users.update {_id: user._id}, {$set: {avatarOrigin: service}}

		rs.pipe(ws)
		return
