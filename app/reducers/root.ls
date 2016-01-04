{sample} = require 'lodash'
mc = require 'material-colors'
require! {
	'../actions/action-names': actions
	'./reducers':{reduce-tick}
	'./mfd-reducer': {reduce-mfd}
	# './formula-reducer': {reduce-formula}
	'../constants/constants': {ROAD-LENGTH,COLORS,NUM-CARS,RUSH-LENGTH,TRIP-LENGTH}
	'prelude-ls':{map,flatten,each,even}
	lodash: {random,assign}
}

# INITIALIZE WAITING CARS
cars = [til NUM-CARS]
	|> map (n) -> 
		entry-loc = (random 0,ROAD-LENGTH*1000)/1000
		res = 
			x: entry-loc
			id: n
			fill: sample COLORS
			trip-length: TRIP-LENGTH
			exited: false
			move: 0
			cum-move: 0
			entry-time: RUSH-LENGTH*n/NUM-CARS

initial-state = 
	time: 0
	cars: cars
	paused: true
	signals: []
	traveling: []
	exited: []
	waiting: [...cars]
	cycle: 100
	green: 50
	offset: 0
	num-signals: 30
	q: 0
	k: 0
	memory: []
	mfd:[]
	EN: 0
	EX: 0
	memory-EN: []
	memory-EX: []
	formula-EN: []
	formula-EX: []
	rates: []
	formula-pred: {q:0,k:0,v:0}

reset = (state)->
		waiting = [...cars]
		time = 0
		paused = true
		EN = EX = k = q = 0
		memory = []; memory-EN = []; memory-EX = []; exited = []; traveling = [];traveling = [];
		{...state,waiting,time,paused,traveling,memory-EX,memory-EN,EN,EX,memory,traveling,exited,k,q}

signals-create = (num-signals)->	
		signals = [til num-signals] 
		|> map (i)->
			x: Math.floor(i/num-signals*ROAD-LENGTH - 2)%%ROAD-LENGTH
			id: i
			green: true

root = (state,action)->
	window.a = state
	switch action.type
	case actions.RESET
		reset state
	case actions.SET-CYCLE
		reduce-mfd {...state,cycle: action.cycle}
	case actions.SET-OFFSET
		reduce-mfd {...state,offset: action.offset}
	case actions.SET-GREEN
		reduce-mfd {...state,green: action.green}
	case actions.SET-NUM-SIGNALS
		num-signals = action.num-signals
		signals = signals-create num-signals 
		reduce-mfd {...state,num-signals,signals}
	case actions.PAUSE-PLAY
		paused = !state.paused
		{...state, paused}
	case actions.TICK
		for i in [til 5]
			state = reduce-tick state
		state
	default state

export {root,initial-state}
