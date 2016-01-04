{map,partition,filter,each,concat,fold,scan} = require 'prelude-ls'
d3 = require 'd3'
{ROAD-LENGTH} = require '../constants/constants'
_ = require 'lodash'

reduce-formula = (state)->
	{cars,mfd} = state
	V = d3.scale.linear()
		.domain( mfd |> map (.k))
		.range( mfd |> map (.v))

	waiting = [...cars]
	traveling = []
	rates = []
	res = []
	time = 0
	while (waiting.length>0 or traveling.length>0) and time<5000
		n0 = traveling.length
		v = V n0/ROAD-LENGTH
		d = v

		traveling = traveling 
		|> map (car)->
			{...car,cum-move: car.cum-move+d}
		|> filter (car)->
			car.cum-move<=car.trip-length

		[arrivals,waiting] = waiting
		|> partition -> it.entry-time<=time

		num-exits = n0 - traveling.length
		num-entries = arrivals.length
		q = v*n0/ROAD-LENGTH
		k = n0/ROAD-LENGTH

		res.push {time,num-entries,num-exits}
		if time%10 is 0
			rates.push {time,q,k}
		traveling = concat [traveling,arrivals]
		time++

	cum-entries = [{time: -1, val: 0}]
	cum-exits = [{time: -1, val:0}]
	for e in res
		cum-entries.push do
			val: cum-entries[* - 1]?.val + e.num-entries
			time: e.time 
		cum-exits.push do
			val: cum-exits[* - 1]?.val + e.num-exits
			time: e.time
	console.log cum-entries

	{...state,formula-EN: cum-entries, formula-EX: cum-exits, rates}

export reduce-formula