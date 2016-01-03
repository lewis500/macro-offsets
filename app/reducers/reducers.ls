{map,each,even,max,min,is-type,sort-by,flatten,Obj} = require 'prelude-ls'
{SPACE,VF,NUM-CARS,RUSH-LENGTH,TRIP-LENGTH,ROAD-LENGTH} = require '../constants/constants'
{filter,map,each,any,min,max,find,partition,concat} = require 'prelude-ls'

mod = (a, n) -> a - Math.floor(a/n) * n

differ = (a,b)->
		dx = b - a
		mod((dx + 500),1000) - 500

reduce-cars = ({traveling,waiting,signals,time})->
	# reds = signals 
	# |> filter (sig)->	!sig.green
	# |> map (.loc)
	# arrivals = []
	# waiting |> each (car)->
	# 	if car.entry-time<=time
	# 		if traveling.length is 0
	# 			arrivals.push car
	# 		else
	# 			if 


	# 	waiting |> filter (car)->

	# # console.log arrivals
	# waiting = 

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
					new-loc = prev-loc + min(VF,gap)
				else 
					new-loc = prev-loc
			else
				console.log 'asdf'
				new-loc = prev-loc + VF

			# stopped-light = reds |> find (signal-loc)->
			# 	below = differ prev-loc,signal-loc
			# 	above = differ signal-loc,new-loc
			# 	above>0 and below<0

			# if stopped-light `is-type` \undefined
			# 	{...car,loc:prev-loc}
			# else
			{...car,loc:new-loc%ROAD-LENGTH}

	{traveling,waiting} 

reduce-signals = ({signals,time,green,cycle,offset})->
	i=0
	signals |> map (signal)->
		time-in-cycle = (time - (++i)*offset)%%cycle
		green = time-in-cycle<=green
		{...signal,green}

export {reduce-signals,reduce-cars}