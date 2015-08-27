Meteor.startup ->
	Migrations.add
		version: 11
		up: ->
			###
			# Set GENERAL room to be default
			###

			ChatRoom.update({_id: 'lobby'}, {$set: {default: true}})
			console.log "Set #lobby to be default"