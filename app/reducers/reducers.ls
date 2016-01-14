require!{
	'prelude-ls': pl
	lodash: _
	'../constants/constants': {SPACE,K0,VF,W,NUM-CARS,RUSH-LENGTH,TRIP-LENGTH,ROAD-LENGTH,MEMORY-FREQ,MAX-MEMORY} 
	'./mfd-reducer': {reduce-mfd}
}

nexter = (i,list)->
	list[(i+1)%list.length]

reduce-time = (state)->
	{time,rates} = state
	time = time + 1
	{...state, time}

reduce-tick = ->
	a = if it.time%250==0 then reduce-mfd else (b)-> b
	it |> reduce-time |> reduce-signals |> reduce-cars |> reduce-memory 

differ = (a,b)->
	res = (b - a)%%ROAD-LENGTH

move-car = (car,next,xs)->
	{x} = car
	move = 0
	if next.id!=car.id
		move = differ(x,next.x-old) - SPACE |> pl.min _,VF |> pl.max _,0
	else 
		move = VF
	x-new = (x + move)%ROAD-LENGTH
	if x-new in xs
		move = 0
		x-new = x
	{...car,x:x-new,x-old: x, move,cum-move: car.cum-move+move}

reduce-cars = (state)->
	{traveling,waiting,signals,time,exited,queueing} = state

	reds-xs = signals
	|> pl.filter (.red)
	|> pl.map (.x)
	|> pl.sort-by -> it

	queued-xs = queueing |> pl.map (.x)

	xs = pl.concat reds-xs,queued-xs

	traveling = traveling 
	|> _.map _,(car,i,k)->
		next-car = nexter i,k
		move-car car,next-car,xs

	[new-queueing,waiting] = waiting
	|> pl.partition (d)-> 
		time-test = d.entry-time<=time

	queueing = pl.concat [queueing,new-queueing]

	traveling-xs = traveling |> pl.map (.x)
	[entering,queueing] = queueing 
		|> pl.partition (car)->
			if car.x in traveling-xs
				false
			else
				traveling-xs[*] = car.x
				true

	traveling = pl.concat [traveling,entering]
	|> pl.sort-by (.x)


	[traveling,exiting] = traveling 
	|> pl.partition -> it.cum-move<=it.trip-length

	exited = pl.concat [exited,exiting]

	{...state,traveling,waiting,exited,queueing} 

reduce-memory = (state)->
	{memory,q,n,time,history,EN,EX,traveling,arrivals,exited} = state
	q = q + pl.fold do
			(a,b)-> a+b.move
			0
			traveling

	n = n + traveling.length

	if time%25 is 0
		EN = traveling.length + exited.length
		EX = exited.length
		history = [...history,{time,cum-entries:EN,cum-exits:EX}]

	if (time%MEMORY-FREQ) == 0
		k = n/MEMORY-FREQ/ROAD-LENGTH
		q = q/MEMORY-FREQ/ROAD-LENGTH
		new-memory = {k,q,id: time}

		memory  = [...memory,new-memory]

		q = n = 0

		if memory.length> MAX-MEMORY then memory = pl.tail memory
			
	{...state,q,n,memory,history}

reduce-signals = (state)->
	{signals,time,green,cycle,num-signals,offset,traveling} = state
	signals = signals |> _.map _,(signal,i,k)->
		time-in-cycle = (time - i*offset)%cycle
		red = time-in-cycle>=green
		{...signal, red}

	{...state,signals}

export reduce-tick