{map,each,even,max,min,is-type,sort-by,flatten,Obj} = require 'prelude-ls'
{SPACE,VF,NUM-CARS,RUSH-LENGTH,TRIP-LENGTH,ROAD-LENGTH,MEMORY-FREQ,MAX-MEMORY} = require '../constants/constants'
{filter,map,each,any,min,max,find,partition,concat,tail} = require 'prelude-ls'
{uniqueId} = require 'lodash'
mod = (a, n) -> a - Math.floor(a/n) * n

differ = (a,b)->
		dx = b - a
		mod(dx + ROAD-LENGTH/2,ROAD-LENGTH) - ROAD-LENGTH/2

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

			stopped-light = reds |> find (signal-loc)->
				below = differ prev-loc,signal-loc
				above = differ signal-loc,new-loc
				above>0 and below>0

			if typeof stopped-light == \undefined
				{...car,loc:new-loc%ROAD-LENGTH}
			else
				q+=move
				{...car,loc:prev-loc}

	k+= (.length) traveling

	{traveling,waiting,k,q} 

reduce-memory = ({memory,q,k,time})->
	if (time%MEMORY-FREQ) == 0
		new-memory = 
			q: q/MEMORY-FREQ/ROAD-LENGTH
			k: k/MEMORY-FREQ
			id: uniqueId()

		memory  = [...memory, new-memory]

		q = k = 0
		# make sure it's not too long
		if memory.length> MAX-MEMORY then memory = tail memory
			
	{q,k,memory}


reduce-signals = ({signals,time,green,cycle,offset})->
	# i=0
	signals |> map (signal)->
		time-in-cycle = time%%cycle
		{...signal,green: time-in-cycle<=green}

export {reduce-signals,reduce-cars,reduce-memory}