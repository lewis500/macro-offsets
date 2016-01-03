{map,each,even,max,min,is-type,sort-by,flatten,Obj} = require 'prelude-ls'
{SPACE,VF,NUM-CARS,RUSH-LENGTH,TRIP-LENGTH,ROAD-LENGTH,MEMORY-FREQ,MAX-MEMORY} = require '../constants/constants'
{filter,map,each,any,min,fold,max,find,partition,sort-by,concat,tail} = require 'prelude-ls'
{uniqueId} = require 'lodash'

reduce-tick = ({traveling,waiting,signals,time,q,k,green,offset,cycle,memory,EN,EX,memory-EN,memory-EX})->
	time = time + 1
	signals = reduce-signals {signals,time,green,cycle,offset}
	{traveling,waiting,k,q,EN,EX} = reduce-cars {traveling,waiting,signals,time,q,k,EN,EX}
	{memory,q,k,memory-EN,memory-EX,EN,EX} = reduce-memory {memory,time,q,k,EN,EX,memory-EN,memory-EX}
	{traveling,waiting,signals,time,q,k,memory,memory-EN,memory-EX}

move-car = (car,next-car,reds)->
	prev-loc = car.loc
	move = 0
	if next-car
		gap =( next-car.loc - prev-loc + 500)%%1000 - 500
		if gap>SPACE
			move = min(VF,gap)
			new-loc = prev-loc + move
		else 
			new-loc = prev-loc
	else
		move = VF
		new-loc = prev-loc + move

	next-red-loc = reds
	|> find (l)->	l>prev-loc

	if !(next-red-loc<new-loc)
		{...car,loc:new-loc%ROAD-LENGTH,move,cum-move: car.cum-move+move}
	else
		{...car,loc:prev-loc,move,cum-move: car.cum-move+move}

reduce-cars = ({traveling,waiting,signals,time,q,k,EN,EX})->
	reds = signals
	|> filter (.green)>>(not)
	|> map (.loc)
	|> sort-by -> it

	[arrivals,waiting] = waiting
	|> partition -> it.entry-time<=time
	
	EN = EN + arrivals.length

	traveling = concat [traveling,arrivals]
	|> sort-by (.loc)

	car-num = 0
	traveling = traveling 
	|> map (car)->
		next-car = traveling[(++car-num)%traveling.length]
		move-car car,next-car,reds

	before = traveling.length
	traveling = traveling |> filter -> it.cum-move<it.trip-length
	after = traveling.length

	EX = EX + before - after

	q = q + fold do
			(a,b)-> a+b.move
			0
			traveling

	k = k + traveling.length

	{traveling,waiting,k,q,EN,EX} 

reduce-memory = ({memory,q,k,time,EN,EX,memory-EN,memory-EX})->
	memory-EN = [...memory-EN,{time: time, EN}]
	memory-EX = [...memory-EX,{time: time, EX}]
	if (time%MEMORY-FREQ) == 0
		new-memory = 
			q: q/MEMORY-FREQ/ROAD-LENGTH
			k: k/MEMORY-FREQ/ROAD-LENGTH
			id: uniqueId()

		memory  = [new-memory] `concat` memory

		q = k = 0
		if memory.length> MAX-MEMORY then memory = tail memory
			
	{q,k,memory,memory-EN,memory-EX}

reduce-signals = ({signals,time,green,cycle,offset})->
	# i=0
	signals |> map (signal)->
		time-in-cycle = time%%cycle
		{...signal,green: time-in-cycle<=green}

export reduce-tick