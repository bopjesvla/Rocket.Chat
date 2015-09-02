Meteor.startup ->
	Meteor.defer ->
		# Insert server unique id if it doesn't exist
		if not Settings.findOne { _id: 'uniqueID' }
			Settings.insert
				_id: 'uniqueID'
				value: Random.id()

		if not ChatRoom.findOne('name': 'lobby')?
			ChatRoom.insert
				_id: 'lobby'
				default: true
				usernames: []
				ts: new Date()
				t: 'c'
				name: 'lobby'
				msgs: 0
		
		console.log(MafiaSetup)
		
		if not MafiaSetup.findOne('name': 'vengeful')?
			MafiaSetup.insert
				ts: new Date()
				u: 'Bob'
				name: 'vengeful'
				size: 5
				roles:
					t:
						_ven: 3
					m:
						gf: 1
						m: 1
		
		if process.env.ADMIN_EMAIL? and process.env.ADMIN_PASS? 
			re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i
			if re.test process.env.ADMIN_EMAIL
				if not Meteor.users.findOne({ admin: true })?
					if not Meteor.users.findOne({ "emails.address": process.env.ADMIN_EMAIL })
						console.log 'Inserting admin user'.red
						console.log "email: #{process.env.ADMIN_EMAIL} | password: #{process.env.ADMIN_PASS}".red

						id = Meteor.users.insert
							createdAt: new Date
							emails: [
								address: process.env.ADMIN_EMAIL
								verified: true
							],
							name: 'Admin'
							avatarOrigin: 'none'
							admin: true

						Accounts.setPassword id, process.env.ADMIN_PASS
					else
						console.log 'E-mail exists; ignoring environment variables ADMIN_EMAIL and ADMIN_PASS'.red
				else
					console.log 'Admin user exists; ignoring environment variables ADMIN_EMAIL and ADMIN_PASS'.red
			else
				console.log 'E-mail provided is invalid; ignoring environment variables ADMIN_EMAIL and ADMIN_PASS'.red

		# Set oldest user as admin, if none exists yet
		admin = Meteor.users.findOne { admin: true }, { fields: { _id: 1 } }
		unless admin
			# get oldest user
			oldestUser = Meteor.users.findOne({}, { fields: { username: 1 }, sort: {createdAt: 1}})
			if oldestUser
				Meteor.users.update {_id: oldestUser._id}, {$set: {admin: true}}
				console.log "No admins are found. Set #{oldestUser.username} as admin for being the oldest user"
