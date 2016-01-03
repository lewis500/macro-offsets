{sample} = require 'lodash'
mc = require 'material-colors'
require! {
	'../actions/action-names': actions
	'./reducers':{reduce-cars,reduce-signals,reduce-memory}
	'../constants/constants': {ROAD-LENGTH,COLORS,NUM-CARS,RUSH-LENGTH,TRIP-LENGTH}
	'prelude-ls':{map,flatten,each,even}
	lodash: {random}
}

# INITIALIZE WAITING CARS
cars = [til NUM-CARS]
	|> map (n) -> 
		entry-loc = (random 0,ROAD-LENGTH*1000)/1000
		res = 
			loc: entry-loc
			id: n
			fill: sample COLORS
			trip-length: TRIP-LENGTH
			exited: false
			travel: TRIP-LENGTH
			entry-time: RUSH-LENGTH*n/NUM-CARS
			exit-loc: (entry-loc + TRIP-LENGTH)%ROAD-LENGTH

initial-state = 
	time: 0
	paused: true
	signals: []
	traveling: []
	waiting: [...cars]
	cycle: 100
	green: 50
	offset: 0
	num_signals: 5
	q: 0
	k: 0
	memory: []

root = (state,action)->
	window.a = state
	switch action.type
	case actions.RESET
		waiting = [...cars]
		time = 0
		paused = true
		traveling = []
		{...state,waiting,time,paused,traveling}

	case actions.SET-CYCLE
		cycle = action.cycle
		{...state,cycle}

	case actions.SET-OFFSET
		offset = action.offset
		{...state,offset}

	case actions.SET-GREEN
		green = action.green
		{...state,green}

	case actions.SET-NUM-SIGNALS
		n = num-signals = action.num-signals
		offset = 1/n * Math.round offset*n
		signals = [til num-signals] |> map (i)->
			res =
				loc: Math.floor i/num-signals*ROAD-LENGTH
				id: i
				green: true
		{...state,signals,num-signals}

	case actions.PAUSE-PLAY
		paused = !state.paused
		{...state, paused}

	case actions.TICK
		time = state.time + 1
		signals = reduce-signals state
		{traveling,waiting,q,k} = reduce-cars {...state,signals,time}
		{memory,q,k} = reduce-memory {...state,time,q,k}
		{...state,traveling,waiting,time,signals,memory,q,k}

	default state

export {root,initial-state}
