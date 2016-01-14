require!{
	'prelude-ls': pl
	lodash: _
	d3
	'../constants/constants': {VF,W,ROAD-LENGTH,K0}
	'./mfd-reducer': {reduce-mfd}
}

reduce-prediction = (state)->
	{cars,mfd,green,cycle,num-signals,mode} = state
	V = d3.scale.linear()
		.domain( mfd |> pl.map (.k))
		.range( mfd |> pl.map (.v))

	waiting = [...cars]
	traveling = []
	prediction = []
	cum-move = cum-entries = cum-exits = time = 0

	places = [til ROAD-LENGTH] |> pl.map -> -1
	offset = 0
	step = 10
	total-exits = []

	while (waiting.length>0 or traveling.length>0) and time<5000
		n0 = traveling.length

		if mode is 'time-path'
			k = traveling.length/ROAD-LENGTH
			r = k/K0
			p = switch
				| r<green/cycle
					1/VF
				| green/cycle<=r< 1+(VF/W)*(1 - green/cycle)
					1/ VF * (1 - r) / (1 - green/cycle)
				default
					-1/W
			offset = p * ROAD-LENGTH/num-signals
			{mfd} = reduce-mfd {...state,offset}
			V = d3.scale.linear()
				.domain( mfd |> pl.map (.k))
				.range( mfd |> pl.map (.v))

		v = V n0/ROAD-LENGTH
		move = v*step
		cum-move+=move

		[traveling,exits] = traveling 
		|> pl.map (car)->
			{...car,cum-move: car.cum-move+move}
		|> pl.partition (car)->
			car.cum-move<=car.trip-length

		exits |> pl.each (car)->
			car.t-e = time
			places[car.place] = -1

		total-exits = pl.concat [total-exits,exits]

		[arrivals,waiting] = waiting
		|> pl.partition -> it.entry-time<=time

		arrivals |> pl.each (car)->
			car.t-a = time
			my-place = car.place = places 
			|> _.find-index _,(d)-> d == -1
			places[my-place] = car.id

		q = v*n0/ROAD-LENGTH
		k = n0/ROAD-LENGTH
		num-exits = n0 - traveling.length
		num-entries = arrivals.length
		cum-exits+=num-exits
		cum-entries+=num-entries

		traveling = pl.concat [traveling,arrivals]
		prediction.push {time,q,k,traveling,cum-entries,cum-exits,offset,mfd}
		time+=step

	window.cum-delay = total-exits |> _.reduce do
			_
			, (a,b)->
				a+(b.t-e - b.t-a)
			, 0


	{...state,prediction}

export reduce-prediction