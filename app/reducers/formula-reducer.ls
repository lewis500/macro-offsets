{map,partition,filter,each,concat,fold,scan} = require 'prelude-ls'
d3 = require 'd3'
{ROAD-LENGTH} = require '../constants/constants'

reduce-formula = (state)->
	{cars,mfd} = state
	V = d3.scale.linear()
		.domain( mfd |> map (.k))
		.range( mfd |> map (.v))

	waiting = [...cars]
	traveling = []
	rates = []
	time = 0
	step = 10 
	while (waiting.length>0 or traveling.length>0) and time<5000
		n0 = traveling.length
		v = V n0/ROAD-LENGTH
		d = v*step

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

		rates.push {time,q,k,num-entries,num-exits}
		traveling = concat [traveling,arrivals]
		time+=step

	cum-entries = scan do
		(a,b)->
			val: a.val + b.num-entries
			time: b.time
		time: -1, val: 0
		rates
	cum-exits = scan do
		(a,b)->
			val: a.val + b.num-exits
			time: b.time
		time:-1,val:0
		rates

	{...state,formula-EN: cum-entries, formula-EX: cum-exits, rates}

export reduce-formula