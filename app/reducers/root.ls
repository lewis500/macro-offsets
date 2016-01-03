{sample} = require 'lodash'
mc = require 'material-colors'
require! {
	'../actions/action-names': actions
	'./reducers':{reduce-cars,reduce-signals,reduce-memory}
	'./mfd-reducer': {reduce-mfd}
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
	mfd:[]

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
		mfd = reduce-mfd {...state,cycle}
		{...state,cycle,mfd}

	case actions.SET-OFFSET
		offset = action.offset
		mfd = reduce-mfd {...state,offset}
		{...state,mfd,offset}

	case actions.SET-GREEN
		green = action.green
		mfd = reduce-mfd {...state,green}
		{...state,green,mfd}

	case actions.SET-NUM-SIGNALS
		n = num-signals = action.num-signals
		offset = 1/n * Math.round offset*n
		signals = [til num-signals] 
		|> map (i)->
			loc: Math.floor(i/num-signals*ROAD-LENGTH - 2)%%ROAD-LENGTH
			id: i
			green: true
		mfd = reduce-mfd {...state,num-signals}
		{...state,signals,num-signals,mfd}

	case actions.PAUSE-PLAY
		paused = !state.paused
		{...state, paused}

	case actions.TICK
		{time,signals,q,k,memory,traveling,waiting,green,cycle,offset} = state
		for i in [til 20]
			time = time + 1
			signals = reduce-signals {signals,time,green,cycle,offset}
			{traveling,waiting,q,k} = reduce-cars {traveling,waiting,q,k,signals,time}
			{memory,q,k} = reduce-memory {memory,time,q,k}
		{...state,traveling,waiting,time,signals,memory,q,k}

	default state

export {root,initial-state}
