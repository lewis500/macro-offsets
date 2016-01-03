{map,each,even,max,min,is-type,sort-by,flatten,Obj} = require 'prelude-ls'
{SPACE,VF,NUM-CARS,RUSH-LENGTH,TRIP-LENGTH,ROAD-LENGTH,MEMORY-FREQ,MAX-MEMORY} = require '../constants/constants'
{filter,map,each,any,min,fold,max,find,partition,sort-by,concat,tail} = require 'prelude-ls'
{uniqueId} = require 'lodash'

reduce-tick = ({traveling,waiting,signals,time,q,k,green,offset,cycle,memory})->
	time = time + 1
	signals = reduce-signals {signals,time,green,cycle,offset}
	{traveling,waiting,k,q} = reduce-cars {traveling,waiting,signals,time,q,k}
	{memory,q,k} = reduce-memory {memory,time,q,k}
	{traveling,waiting,signals,time,q,k,memory}

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

	next-red-loc = reds |> find (l)->
		l>prev-loc

	if !(next-red-loc<new-loc)
		{...car,loc:new-loc%ROAD-LENGTH,move}
	else
		{...car,loc:prev-loc,move}

reduce-cars = ({traveling,waiting,signals,time,q,k})->
	reds = signals
	|> filter (.green)>>(not)
	|> map (.loc)
	|> sort-by -> it

	[arrivals,waiting] = waiting
	|> partition (car)->
		car.entry-time<=time

	traveling = concat [traveling,arrivals]
	|> sort-by (.loc)

	car-num = 0
	traveling = traveling 
	|> map (car)->
		next-car = traveling[(++car-num)%traveling.length]
		move-car car,next-car,reds

	q = q + fold do
			(a,b)-> a+b.move
			0
			traveling

	k = k + (.length) traveling

	{traveling,waiting,k,q} 

reduce-memory = ({memory,q,k,time})->
	if (time%MEMORY-FREQ) == 0
		new-memory = 
			q: q/MEMORY-FREQ/ROAD-LENGTH
			k: k/MEMORY-FREQ/ROAD-LENGTH
			id: uniqueId()

		memory  = [new-memory] `concat` memory

		q = k = 0
		if memory.length> MAX-MEMORY then memory = tail memory
			
	{q,k,memory}

reduce-signals = ({signals,time,green,cycle,offset})->
	# i=0
	signals |> map (signal)->
		time-in-cycle = time%%cycle
		{...signal,green: time-in-cycle<=green}

export reduce-tick