names = require './action-names'

export 
	tick: ->
		type: names.TICK
	pause-play: ->
		type: names.PAUSE-PLAY
	set-num-signals: (num-signals)->
		{type: names.SET-NUM-SIGNALS, num-signals}
	set-green: (green)->
		{type: names.SET-GREEN, green}
	set-offset: (offset)->
		{type: names.SET-OFFSET, offset}
	set-cycle: (cycle)->
		{type: names.SET-CYCLE, cycle}
	calc-formula: ->
		type: names.CALC-FORMULA
	reset:->
		type:names.RESET