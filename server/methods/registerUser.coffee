Meteor.methods
	registerUser: (formData) ->
		throw new Meteor.Error 'empty-field' unless formData? and formData.username
		
		if not /^[a-z0-9]\w{1,8}[a-z0-9]$/i.test formData.username
			throw new Meteor.Error 'username-invalid'

		if not RocketChat.checkUsernameAvailability formData.username
			throw new Meteor.Error 'username-unavailable', "#{formData.username} is already taken."
		
		userData =
			email: formData.email
			password: formData.pass

		userId = Accounts.createUser userData

		Meteor.users.update userId,
			$set:
				name: formData.name
				username: formData.username

		if userData.email
			Accounts.sendVerificationEmail(userId, userData.email);
