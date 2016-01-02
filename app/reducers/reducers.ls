{map,each,even,max,min,is-type,sort-by,flatten,Obj} = require 'prelude-ls'
{SPACE,VF,NUM-CARS,RUSH-LENGTH,TRIP-LENGTH,ROAD-LENGTH} = require '../constants/constants'
{filter,map,each,any,min,find,partition} = require 'prelude-ls'

mod = (a, n) -> a - Math.floor(a/n) * n

differ = (a,b)->
		dx = b - a
		mod((dx + 180),360) - 180

reduce-cars = (traveling,waiting,signals)->
	reds = signals 
	|> filter (sig)->
			!sig.green
	|> map (.loc)

	[arrivals,waiting] = waiting
	|> partition (car)->
		car.entry-time<=time

	traveling = concat traveling,arrivals
	|> sort-by (.loc)

	car-num = 0
	traveling = traveling |> map (car)->
			prev-loc = new-loc = car.loc
			next-car = cars[++car-num]
			if next-car
				new-loc = min(prev-loc + VF,next-car.loc - SPACE)%ROAD-LENGTH
			else
				new-loc = (prev-loc + VF)%ROAD-LENGTH

			stopped-light = reds |> find (signal-loc)->
				below = differ prev-loc,signal-loc
				above = differ signal-loc,new-loc
				above>0 and below<0

			if stopped-light `is-type` \undefined
				{...car,loc:prev-loc}
			else
				{...car,loc:new-loc}

	{traveling,waiting} 

reduce-signals = (signals,time,green,cycle,offset)->
	signals |> map (signal)->
		time-in-cycle = (time - i*offset)%%cycle
		green = time-in-cycle<=green
		{...signal,green}

export {reduce-signals,reduce-cars}