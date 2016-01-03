{map,partition,filter,each,concat} = require 'prelude-ls'
d3 = require 'd3'
{ROAD-LENGTH} = require '../constants/constants'

reduce-formula = (state)->
	{cars,mfd} = state
	V = d3.scale.linear()
		.domain( mfd |> map (.k))
		.range( mfd |> map (.v))

	waiting = [...cars]
	res = []
	traveling = []
	rates = []
	time = 0
	while (waiting.length>0 or traveling.length>0) and time<6000
		v = V n0/ROAD-LENGTH
		d = v
		n0 = traveling.length

		traveling = traveling 
		|> map (car)->
			{...car,cum-moved: car.cum-moved+d}
		|> filter (car)->
			car.cum-moved<=car.trip-length

		[arrivals,waiting] = waiting
		|> partition -> it.entry-time<=time

		num-exits = n0 - traveling.length
		num-entries = arrivals.length
		q = v*n0/ROAD-LENGTH
		k = n0/ROAD-LENGTH

		if time%10==0
			rates.push {time,q,k}
			res.push {time, num-entries, num-exits}
			
		traveling = concat [traveling,arrivals]

		time++

	cum-entries = [{val: 0, time:-1}]
	cum-exits = [{val: 0,time: -1}]
	res |> each (e)->
		cum-entries.push do
			val: cum-entries[cum-entries.length-1].val + e.num-entries
			time: e.time 
		cum-exits.push do
			val: cum-exits[cum-exits.length-1].val + e.num-exits
			time: e.time

	{...state,formula-EN: cum-entries, formula-EX: cum-exits, rates}

export reduce-formula