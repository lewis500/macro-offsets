{sample} = require 'lodash'
mc = require 'material-colors'
require! {
	'../actions/action-names': actions
	'./reducers':{reduce-tick}
	'./mfd-reducer': {reduce-mfd}
	'./formula-reducer': {reduce-formula}
	'../constants/constants': {ROAD-LENGTH,COLORS,VF,NUM-CARS,RUSH-LENGTH,TRIP-LENGTH}
	'prelude-ls':{map,flatten,each,even}
	lodash: {random,assign}
}

cars = [til NUM-CARS]
	|> map (i) -> 
		entry-loc = random(0,ROAD-LENGTH)
		res = 
			x: entry-loc
			x-old: entry-loc
			id: i
			fill: sample COLORS
			trip-length: TRIP-LENGTH
			exited: false
			move: 0
			cum-move: 0
			entry-time: RUSH-LENGTH*i/NUM-CARS

initial-state = 
	time: 0
	cars: cars
	paused: true
	lines: []
	signals: []
	traveling: []
	exited: []
	waiting: [...cars]
	cycle: 100
	green: 40
	offset: 0
	num-signals: 25
	q: 0
	n: 0
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
	queueing: []

reset = (state)->
		waiting = [...cars]
		time = 0
		paused = true
		EN = EX = k = q = 0
		memory = []; memory-EN = []; memory-EX = []; exited = []; traveling = [];traveling = []; queueing=[];
		signals = signals-create state
		{...state,waiting,time,paused,traveling,memory-EX,memory-EN,EN,EX,memory,traveling,exited,k,q,queueing,signals}

signals-create = (state)->	
		{green,num-signals,cycle} = state
		d  =  ROAD-LENGTH/num-signals
		signals = [til num-signals] 
		|> map (i)->
			signal = 
				x: Math.floor(i/num-signals*ROAD-LENGTH - 2)%%ROAD-LENGTH
				id: i
				red: false
				backwards: false
		signals

combined = reduce-mfd >> reduce-formula

root = (state,action)->
	window.a = state
	switch action.type
	| actions.RESET
		reset state
	| actions.CHANGE-MODE
		{...state, mode: action.mode}
	| actions.SET-CYCLE
		combined {...state,cycle: action.cycle}
	| actions.SET-OFFSET
		combined {...state,offset: action.offset}
	| actions.SET-GREEN
		combined {...state,green: action.green}
	| actions.SET-NUM-SIGNALS
		num-signals = action.num-signals
		signals = signals-create state 
		combined {...state,num-signals,signals}
	| actions.PAUSE-PLAY
		paused = !state.paused
		{...state, paused}
	| actions.TICK
		for i in [til 2]
			state = reduce-tick state
		state
	default state

export {root,initial-state}
