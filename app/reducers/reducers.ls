{map,each,even,max,min,is-type,sort-by,flatten,Obj} = require 'prelude-ls'
{SPACE,VF,NUM-CARS,RUSH-LENGTH,TRIP-LENGTH,ROAD-LENGTH,MEMORY-FREQ,MAX-MEMORY} = require '../constants/constants'
{filter,map,each,any,min,max,find,partition,concat,tail} = require 'prelude-ls'
{uniqueId} = require 'lodash'
# mod = (a, n) -> a - Math.floor(a/n) * n

differ = (a,b)->
	(b - a + 500)%%1000 - 500

reduce-cars = ({traveling,waiting,signals,time,q,k})->
	reds = signals 
	|> filter (sig)->	!sig.green
	|> map (.loc)

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

			stopped-light = reds |> any (l)->
				prev-loc < l < new-loc

			# stopped-light = reds |> find (signal-loc)->
			# 	below = differ prev-loc,signal-loc
			# 	above = differ signal-loc,new-loc
			# 	above>0 and below>0

			if !stopped-light
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

export {reduce-signals,reduce-cars,reduce-memory}