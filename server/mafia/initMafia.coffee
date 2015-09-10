@MafiaTimeouts = {}
@Games = {}

class @Role

class @Game
	constructor: (@rid, @players) ->
		if @players?
			@start @players
	start: (@players) ->
		g = ChatRoom.findAndModify
			query: _id: @rid
			update: $set:
				gs: "ongoing"
				players: @players
				# alive: Meteor.users.find({username: $in: players}, {fields:
				# 	username: 1
				# 	_id: 1}).fetch()
				# dead: []
		{sid} = g
		console.log(g)
		
		Meteor.users.update {g: @rid}, {$set: ingame: true}
		
		@setup = MafiaSetups.find sid
		@modes = setup.m
		@roll(); @nextPhase() unless @roles
	roll: ->
		@roles = {}
		i = 0
		shuffled = _.shuffle(@players)
		for r in setup.s
			rolecount = r.c or 1
			role = @constructRole(r)
			
			for c in [0...rolecount]
				@roles[@players[i++]] = role
	reactions: {}
	hooks: []
	constructRole: (r) ->
		r.r ?= []
		r.a ?= 't'
		parts = (MafiaRoles.findOne({n:n}) for n in r.r)
		iNotFound = parts.indexOf(undefined)
		
		@end "Role #{r.r[iNotFound]} not found" unless iNotFound isnt -1
		@end "Team #{r.a} not found" unless TeamConfig[r.a]
		
		role =
			parts: parts
			team: r.a
		
		actions = []
		reactions = []
		name = if _.last(parts).mod then TeamConfig[r.a]["b"] or "" else ""
		
		for p in parts by -1
			actions.push p.act if p.act
			reactions.push p.re if p.re
			name = "#{p.name} #{name}" if p.name
			
		role.actions = [].concat.apply([], actions)
		role.reactions = [].concat.apply([], reactions)
		role.name = name.trim()
		
		console.log(role)
	end: (err, res) ->
		room = ChatRoom.findOne @rid
		unless room?
			return
		
		ChatRoom.update rid, $set:
			gs: "finished"
		
		Meteor.clearTimeout(MafiaTimeouts[rid])
		delete MafiaTimeouts[rid]
		delete Games[rid]
	nextPhase: ->
		
	on: (user, event, fn) ->
		

@PhaseDefaults =
	d:
		actions: ["lynch"]
		delay: 10
		length: 600
		act:
			instant: true
	n:
		length: 180
	t:
		length: 60

@TeamConfig =
	t:
		n: "Town"
		b: "Townie"
		w: (game, me) ->
			for player in game.alive
				a = player.alignment
				unless a is 't' or TeamConfig[a].neutral
					return false
			
			return true
	m:
		n: "Mafia"
		b: "Mafioso"
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
	
	Meteor.runAsUser(Meteor.findOne({username: "Bob"})) ->
		testrid = Meteor.call("createGame", {name: "1v1"})
	
	Meteor.runAsUser(Meteor.findOne({username: "Bob2"})) ->
		Meteor.call("joinRoom", testrid)