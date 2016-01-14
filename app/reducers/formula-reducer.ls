require!{
	'prelude-ls': pl
	d3
	'../constants/constants': {VF,W,ROAD-LENGTH,K0}
}

calc-offset = (state)->
	{traveling,mfd,cycle,green,num-signals,time} = state
	k = traveling.length/ROAD-LENGTH
	[a,b] = [green/cycle, 1+(VF/W)*(1 - green/cycle)]
	r = k/K0
	p = switch 
		case r<a
			1/VF
		case a<=r< b
			1/ VF * (1 - r) / (1 - green/cycle)
		default
			-1/W
	offset = p * ROAD-LENGTH/num-signals

reduce-history = (state)->
	{cars,mfd,green,cycle,num-signals} = state
	V = d3.scale.linear()
		.domain( mfd |> pl.map (.k))
		.range( mfd |> pl.map (.v))

	waiting = [...cars]
	traveling = []
	history = {}
	time = 0
	cum-move = 0
	lines = [{time,cum-move}]
	places = [til ROAD-LENGTH] |> pl.map -> -1
	offset = 0

	while (waiting.length>0 or traveling.length>0) and time<3000
		n0 = traveling.length

		v = V n0/ROAD-LENGTH
		move = v
		cum-move+=move

		[traveling,exits] = traveling 
		|> pl.map (car)->
			{...car,cum-move: car.cum-move+move}
		|> pl.partition (car)->
			car.cum-move<=car.trip-length

		exits |> pl.each (car)->
			car.t-e = time
			places[car.place] = -1

		[arrivals,waiting] = waiting
		|> pl.partition -> it.entry-time<=time

		arrivals |> pl.each (car)->
			car.t-a = time
			my-place = car.place = places 
			|> _.find-index _,(d)-> d == -1
			places[my-place] = car.id

		q = v*n0/ROAD-LENGTH
		k = n0/ROAD-LENGTH

		[a,b] = [green/cycle, 1+(VF/W)*(1 - green/cycle)]
		r = k/K0
		p = switch 
			| r<a
				1/VF
			| a<=r< b
				1/ VF * (1 - r) / (1 - green/cycle)
			default
				-1/W

		offset = p * ROAD-LENGTH/num-signals

		traveling = pl.concat [traveling,arrivals]
		history[time] = {time,q,k,traveling}
		time++
	{...state,history}

export reduce-history