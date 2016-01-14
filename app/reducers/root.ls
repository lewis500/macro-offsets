{sample} = require 'lodash'
mc = require 'material-colors'
require! {
	'../actions/action-names': actions
	'./reducers':{reduce-tick}
	'./mfd-reducer': {reduce-mfd}
	'./prediction-reducer': {reduce-prediction}
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
	green: 50
	offset: 40
	num-signals: 25
	q: 0
	n: 0
	memory: []
	mfd:[]
	history: []
	prediction: []
	EN: 0
	EX: 0
	rates: []
	queueing: []
	mode: \fixed

reset = (state)->
		a =
			time: 0
			cars: cars
			paused: true
			lines: []
			traveling: []
			exited: []
			waiting: [...cars]
			signals: signals-create state
			n: 0
			memory: []
			history: []
			EN: 0
			EX: 0
			q: 0
			k:0
			rates: []
			queueing: []
		{...state,...a}

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

combined = reduce-mfd 
>> reduce-prediction

root = (state,action)->
	window.a = state
	switch action.type
	| actions.RESET
		state |> reset |> combined
	| actions.SET-MODE
		state = {...state, mode: action.mode}
		reduce-prediction state
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
		for i in [til 15]
			state = reduce-tick state
		state
	default state

export {root,initial-state}
