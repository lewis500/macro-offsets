pl = require 'prelude-ls'
_ = require 'lodash'
{SPACE,K0,VF,W,NUM-CARS,RUSH-LENGTH,TRIP-LENGTH,ROAD-LENGTH,MEMORY-FREQ,MAX-MEMORY} = require '../constants/constants'
{reduce-mfd} = require './mfd-reducer'

reduce-time = (state)->
	{time,rates} = state
	time = time + 1
	formula-pred = _.find-last rates, -> it.time<=time
	{...state, time,formula-pred}

differ = (a,b)->
	(b - a + 500)%%1000 - 500

reduce-tick = ->
	a = if it.time%250==0 then reduce-mfd else (b)-> b
	it |> reduce-time |> reduce-signals |> reduce-cars |> reduce-memory 
		|> reduce-offset |> a

move-car = (car,next-car,reds)->
	x-prev = car.x
	move = 0
	x-red = reds
	|> pl.find (l)->	l>x-prev
	gap-red = differ x-prev,x-red
	gap-car = if (next-car and next-car!=car) then differ x-prev,next-car.x-old else Infinity
	move = pl.max 0,(pl.minimum [VF,gap-car - SPACE,gap-red - SPACE] )
	x-new = (x-prev + move)%ROAD-LENGTH

	{...car,x:x-new,x-old: x-prev, move,cum-move: car.cum-move+move}

reduce-offset = (state)->
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

	{...state,offset}

reduce-cars = (state)->
	{traveling,waiting,signals,time,exited} = state

	reds = signals
	|> pl.filter (.green)>>(not)
	|> pl.map (.x)
	|> pl.sort-by -> it

	[arrivals,waiting] = waiting
	|> pl.partition (d)-> 
		time-test = d.entry-time<=time
		if !time-test
			return false
		else
			if traveling.length is 0
				return true
			car1 = traveling 
				|> _.find-last _, (car)->
					car.x <= d.x
			if car1
				gap1 = differ( car1.x,d.x)
				if gap1<=SPACE
					return false
			car2 = traveling 
				|> _.find _, (car)->
					car.x >= d.x
			if car2
				gap2 = differ(d.x,car2.x)
				if gap2<=SPACE
					return false
			return true

	traveling = pl.concat [traveling,arrivals]
	|> pl.sort-by (.x)

	car-num = 0
	traveling = traveling 
	|> pl.map (car)->
		next-car = traveling[(++car-num)%traveling.length]
		move-car car,next-car,reds

	[traveling,exiting] = traveling 
	|> pl.partition -> it.cum-move<=it.trip-length

	exited = pl.concat [exited,exiting]

	{...state,traveling,waiting,exited} 

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
	{signals,time,green,cycle,offset,num-signals} = state
	i=0
	signals = signals 
	|> pl.map (signal)->
		O = if (i+1)<signals.length then i*offset else offset*i/2
		time-in-cycle = (time - O)%%cycle
		i++
		{...signal,green: time-in-cycle<=green}
	{...state,signals}

export reduce-tick