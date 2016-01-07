pl = require 'prelude-ls'
_ = require 'lodash'
{SPACE,K0,VF,W,NUM-CARS,RUSH-LENGTH,TRIP-LENGTH,ROAD-LENGTH,MEMORY-FREQ,MAX-MEMORY} = require '../constants/constants'
{reduce-mfd} = require './mfd-reducer'

nexter = (i,list)->
	list[(i+1)%list.length]

reduce-time = (state)->
	{time,rates} = state
	time = time + 1
	formula-pred = _.find-last rates, -> it.time<=time
	{...state, time,formula-pred}

reduce-tick = ->
	a = if it.time%250==0 then reduce-mfd else (b)-> b
	it |> reduce-time |> reduce-signals |> reduce-cars |> reduce-memory 


differ = (a,b)->
	res = (b - a)%%ROAD-LENGTH

move-car = (car,next,xs)->
	{x} = car
	move = 0
	if next.id!=car.id
		move = differ(x,next.x-old) - SPACE |> pl.min _,VF |> pl.max _,0
	else 
		move = VF
	x-new = (x + move)%ROAD-LENGTH
	if x-new in xs
		move = 0
		x-new = x
	{...car,x:x-new,x-old: x, move,cum-move: car.cum-move+move}

reduce-cars = (state)->
	{traveling,waiting,signals,time,exited,queueing} = state

	reds-xs = signals
	|> pl.filter (.green)>>(not)
	|> pl.map (.x)
	|> pl.sort-by -> it

	queued-xs = queueing |> pl.map (.x)

	xs = pl.concat reds-xs,queued-xs

	traveling = traveling 
	|> _.map _,(car,i,k)->
		next-car = nexter i,k
		move-car car,next-car,xs

	[new-queueing,waiting] = waiting
	|> pl.partition (d)-> 
		time-test = d.entry-time<=time

	queueing = pl.concat [queueing,new-queueing]

	traveling-xs = traveling |> pl.map (.x)
	[entering,queueing] = queueing 
		|> pl.partition (car)->
			if car.x in traveling-xs
				false
			else
				traveling-xs[*] = car.x
				true

	traveling = pl.concat [traveling,entering]
	|> pl.sort-by (.x)


	[traveling,exiting] = traveling 
	|> pl.partition -> it.cum-move<=it.trip-length

	exited = pl.concat [exited,exiting]

	{...state,traveling,waiting,exited,queueing} 

reduce-memory = (state)->
	{memory,q,n,time,memory-EN,memory-EX,EN,EX,traveling,arrivals,exited} = state
	q = q + pl.fold do
			(a,b)-> a+b.move
			0
			traveling

	n = n + traveling.length

	if time%25 is 0
		EN = traveling.length + exited.length
		EX = exited.length
		memory-EN = [...memory-EN,{time: time, val: EN}]
		memory-EX = [...memory-EX,{time: time, val: EX}]

	if (time%MEMORY-FREQ) == 0
		k = n/MEMORY-FREQ/ROAD-LENGTH
		q = q/MEMORY-FREQ/ROAD-LENGTH
		new-memory = {k,q,id: time}

		memory  = [...memory,new-memory]

		q = n = 0

		if memory.length> MAX-MEMORY then memory = pl.tail memory
			
	{...state,q,n,memory,memory-EN,memory-EX}

reduce-signals = (state)->
	{signals,time,green,cycle,num-signals,traveling} = state
	d = ROAD-LENGTH/num-signals
	signals = signals |> _.map _,(signal,i,k)->
		{next-green,next-red} = signal
		if time >= next-green
			offset-a = 0
			if (next-signal = k[i+1])
				offset-r = d/VF
				next-green = next-signal.next-green - offset-r
				while next-green<time
					next-green+=cycle
				next-red = next-signal.next-red - offset-r
				while next-red<time
					next-red+=cycle
			else 
				next-green = time + cycle
				next-red = time + green
			{...signal,green: true, next-green,next-red}
		else if time >= next-red
			{...signal,green:false}
		else 
			signal
		# {...signal,green: time-in-cycle<=green,offset-a}
	# d = ROAD-LENGTH / num-signals
	# traveling-grouped = traveling |> pl.group-by (car)->
	# 	Math.floor car.x/d
	# signals = signals|> _.map _,(signal,i,k)->
	# 	next-a = nexter i,k .offset-a
	# 	# if traveling-grouped[i]?.length/d >= K0
	# 	offset-a = d/W + next-a
	# 	# else
	# 		# offset-a = -d/VF + next-a
	# 	# offset-a = 0
	# 	time-in-cycle = (time + offset-a)%%cycle
	# 	{...signal,green: time-in-cycle<=green, offset-a}
	{...state,signals}

export reduce-tick