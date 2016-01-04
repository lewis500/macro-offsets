{map,each,even,max,min,is-type,sort-by,flatten,Obj} = require 'prelude-ls'
{SPACE,VF,NUM-CARS,RUSH-LENGTH,TRIP-LENGTH,ROAD-LENGTH,MEMORY-FREQ,MAX-MEMORY} = require '../constants/constants'
{filter,map,each,any,minimum,fold,max,find,partition,sort-by,concat,tail} = require 'prelude-ls'
{uniqueId,find-last} = require 'lodash'

reduce-time = (state)->
	{time,rates} = state
	time = time+1
	formula-pred = find-last rates, -> it.time<=time

	{...state, time,formula-pred}

differ = (a,b)->
	(b - a + 500)%%1000 - 500

reduce-tick = ->
	it |> reduce-time << reduce-signals << reduce-cars << reduce-memory

move-car = (car,next-car,reds)->
	x-prev = car.x
	move = 0
	x-red = reds
	|> find (l)->	l>=x-prev
	gap-red = differ x-prev,x-red
	gap-car = if next-car then differ x-prev,next-car.x-old else Infinity
	move = minimum [VF,gap-car - SPACE,gap-red] |> max _,0
	x-new = (x-prev + move)%ROAD-LENGTH
	#SHOULD I DO GAP-RED - SPACE?

	{...car,x:x-new,x-old: x-prev, move,cum-move: car.cum-move+move}

reduce-cars = (state)->
	{traveling,waiting,signals,time,q,k,exited} = state

	reds = signals
	|> filter (.green)>>(not)
	|> map (.x)
	|> sort-by -> it

	[arrivals,waiting] = waiting
	|> partition -> it.entry-time<=time
	
	traveling = concat [traveling,arrivals]
	|> sort-by (.x)

	car-num = 0
	traveling = traveling 
	|> map (car)->
		next-car = traveling[(++car-num)%traveling.length]
		move-car car,next-car,reds

	[traveling,exiting] = traveling 
	|> partition -> it.cum-move<=it.trip-length

	exited = concat [exited,exiting]

	{...state,traveling,waiting,exited} 

reduce-memory = (state)->
	{memory,q,k,time,memory-EN,memory-EX,EN,EX,traveling,arrivals,exited} = state
	q = q + fold do
			(a,b)-> a+b.move
			0
			traveling
	k = k + traveling.length

	if time%MEMORY-FREQ is 0
		EN = traveling.length + exited.length
		EX = exited.length
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
	{signals,time,green,cycle,offset,num-signals} = state
	i=0
	signals = signals |> map (signal)->
		O = if (i+1)<signals.length then i*offset else offset*i/2
		time-in-cycle = (time - O)%%cycle
		i++
		{...signal,green: time-in-cycle<=green}
	{...state,signals}

export reduce-tick