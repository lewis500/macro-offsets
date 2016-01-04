{map,each,even,max,min,is-type,sort-by,flatten,Obj} = require 'prelude-ls'
{SPACE,VF,NUM-CARS,RUSH-LENGTH,TRIP-LENGTH,ROAD-LENGTH,MEMORY-FREQ,MAX-MEMORY} = require '../constants/constants'
{filter,map,each,any,minimum,fold,max,find,partition,sort-by,concat,tail} = require 'prelude-ls'
{uniqueId,find-last} = require 'lodash'

reduce-time = (state)->
	{time,rates} = state
	time = time+1
	formula-pred = find-last rates, -> it.time<=time

	{...state, time,formula-pred}

reduce-tick = ->
	it |> reduce-time << reduce-signals << reduce-cars << reduce-memory

move-car = (car,next-car,reds)->
	x-prev = car.x
	move = 0
	x-red = reds
	|> find (l)->	l>=x-prev
	gap-red = (x-red - x-prev + 500)%%1000 - 500

	if next-car
		gap-car = (next-car.x - x-prev + 500)%%1000 - 500
	else
		gap-car = Infinity
	move = max (minimum [VF,gap-car - SPACE,gap-red]),0
	x-new = (x-prev + move)%ROAD-LENGTH


	{...car,x:x-new,move,cum-move: car.cum-move+move}

reduce-cars = (state)->
	{traveling,waiting,signals,time,q,k,EN,EX} = state

	reds = signals
	|> filter (.green)>>(not)
	|> map (.x)
	|> sort-by -> it

	[arrivals,waiting] = waiting
	|> partition -> it.entry-time<=time
	
	EN = EN + arrivals.length

	traveling = concat [traveling,arrivals]
	|> sort-by (.x)

	car-num = 0
	traveling = traveling 
	|> map (car)->
		next-car = traveling[(++car-num)%traveling.length]
		move-car car,next-car,reds

	before = traveling.length
	traveling = traveling |> filter -> it.cum-move<it.trip-length
	after = traveling.length

	EX = EX + before - after

	{...state,traveling,waiting,k,q,EN,EX} 

reduce-memory = (state)->
	{memory,q,k,time,EN,EX,memory-EN,memory-EX,traveling} = state

	q = q + fold do
			(a,b)-> a+b.move
			0
			traveling
	k = k + traveling.length

	if time%10 is 0
		memory-EN = [...memory-EN,{time: time, val: EN}]
		memory-EX = [...memory-EX,{time: time, val: EX}]
	if (time%MEMORY-FREQ) == 0
		new-memory = 
			q: q/MEMORY-FREQ/ROAD-LENGTH
			k: k/MEMORY-FREQ/ROAD-LENGTH
			id: uniqueId()

		memory  = [...memory,new-memory]

		q = k = 0
		if memory.length> MAX-MEMORY then memory = tail memory
			
	{...state,q,k,memory,memory-EN,memory-EX}

reduce-signals = (state)->
	{signals,time,green,cycle,offset} = state
	# i=0
	signals = signals |> map (signal)->
		time-in-cycle = time%%cycle
		{...signal,green: time-in-cycle<=green}
	{...state,signals}

export reduce-tick