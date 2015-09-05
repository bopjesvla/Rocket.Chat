@MafiaTimeouts = {}

@MafiaAlignments =
	t:
		n: "Town"
		b: "Townie"
		w: (game, me) ->
			for player in game.alive
				a = player.alignment
				unless a is 't' or MafiaAlignments[a].neutral
					return false
			
			return true
	m:
		n: "Mafia"
		b: "Mafia Goon"
		w: (game, me) ->
			n = 0
			for player in game.alive
				if player.alignment isnt 'm' and ++n > game.alive.length / 2
					return false
			
			return true

Meteor.startup ->
	Meteor.defer ->
		if not MafiaRoles.findOne('n': '_ven')?
			MafiaRoles.insert
				ts: new Date()
				u: 'Bob'
				n: '_ven'
				name: 'Vengeful #NAME'
				triggers:
					onvoted: "addaction vengekill"