names = require './action-names'
tick = ->
	type: names.TICK

pausePlay: ->
	type: names.PAUSE_PLAY

setNumSignals: (num_signals)->
	{type: names.SET_NUM_SIGNALS, num_signals}

setGreen: (green)->
	{type: names.SET_GREEN, green}

setOffset: (offset)->
	{type: names.SET_OFFSET, offset}

setCycle: (cycle)->
	{type: names.SET_CYCLE, cycle}

calcFormula: ->
	type: names.CALC_FORMULA
	
reset:->
	type:names.RESET


export {tick}