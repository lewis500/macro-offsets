{map,each,even,max,min,is-type,sort-by,flatten,Obj} = require 'prelude-ls'
{SPACE,VF,NUM-CARS,RUSH-LENGTH,TRIP-LENGTH,ROAD-LENGTH,MEMORY-FREQ,MAX-MEMORY} = require '../constants/constants'
{filter,map,each,any,min,max,find,partition,sort-by,concat,tail} = require 'prelude-ls'
{uniqueId} = require 'lodash'

reduce-tick = ({traveling,waiting,signals,time,q,k,green,offset,cycle,memory})->
	time = time+1
	signals = reduce-signals {signals,time,green,cycle,offset}
	{traveling,waiting,k,q} = reduce-cars {traveling,waiting,signals,time,q,k}
	{memory,q,k} = reduce-memory {memory,time,q,k}
	{traveling,waiting,signals,time,q,k,memory}

reduce-cars = ({traveling,waiting,signals,time,q,k})->

	differ = (a,b)->
		(b - a + 500)%%1000 - 500
		
	reds = signals 
	|> filter (sig)->	!sig.green
	|> map (.loc)
	|> sort-by -> it

	[arrivals,waiting] = waiting
	|> partition (car)->
		car.entry-time<=time

	traveling = concat [traveling,arrivals]
	|> sort-by (.loc)

	car-num = 0
	traveling = traveling |> map (car)->
			prev-loc = car.loc
			next-car = traveling[(++car-num)%traveling.length]
			move = 0
			if next-car
				gap = differ prev-loc,next-car.loc
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
				q+=move
				{...car,loc:new-loc%ROAD-LENGTH}
			else
				{...car,loc:prev-loc}

	k+= (.length) traveling

	{traveling,waiting,k,q} 

reduce-memory = ({memory,q,k,time})->
	if (time%MEMORY-FREQ) == 0
		new-memory = 
			q: q/MEMORY-FREQ/ROAD-LENGTH
			k: k/MEMORY-FREQ/ROAD-LENGTH
			id: uniqueId()

		memory  = [...memory, new-memory]

		q = k = 0
		if memory.length> MAX-MEMORY then memory = tail memory
			
	{q,k,memory}

reduce-signals = ({signals,time,green,cycle,offset})->
	# i=0
	signals |> map (signal)->
		time-in-cycle = time%%cycle
		{...signal,green: time-in-cycle<=green}

export {reduce-tick}