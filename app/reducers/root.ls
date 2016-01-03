{sample} = require 'lodash'
mc = require 'material-colors'
require! {
	'../actions/action-names': actions
	'./reducers':{reduce-cars,reduce-signals}
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

root = (state,action)->
	window.a = state
	switch action.type
	case actions.RESET
		waiting = [...cars]
		time = 0
		paused = true
		{...state,waiting,time,paused}
	case actions.SET-CYCLE
		cycle = action.cycle
		{...state,cycle}
	case actions.SET-OFFSET
		offset = action.offset
		# offset = 1/state.num-signals * Math.round action.offset*num-signals
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
		{signals,time,traveling,waiting} = state
		time = time+1
		signals = reduce-signals state
		{traveling,waiting} = reduce-cars state
		{...state,traveling,waiting,time,signals}

	default state

export {root,initial-state}
