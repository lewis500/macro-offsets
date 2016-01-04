require '../style/style-ring-road'

require!{
	'classNames'
	'../constants/constants': {ROAD-LENGTH}
	'prelude-ls': {map,at, Func: {memoize}}
	react: {DOM: {div,svg,g,rect,circle,path}}:react
	'react-redux': {connect}
}

path-string = "M3.5-46.3l3.1,22.4c0.4,2.7,3.5,3.9,5.6,2.3l18-13.6	c3.3-2.5,7.4,1.7,4.9,4.9l-13.6,18C20-10.1,21.3-7,23.9-6.6l22.4,3.1c4,0.6,4,6.4,0,7L23.9,6.6c-2.7,0.4-3.9,3.5-2.3,5.6l13.6,18	c2.5,3.3-1.7,7.4-4.9,4.9l-18-13.6C10.1,20,7,21.3,6.6,23.9L3.5,46.3c-0.6,4-6.4,4-7,0l-3.1-22.4c-0.4-2.7-3.5-3.9-5.6-2.3l-18,13.6	c-3.3,2.5-7.4-1.7-4.9-4.9l13.6-18c1.6-2.1,0.3-5.2-2.3-5.6l-22.4-3.1c-4-0.6-4-6.4,0-7l22.4-3.1c2.7-0.4,3.9-3.5,2.3-5.6l-13.6-18	c-2.5-3.3,1.7-7.4,4.9-4.9l18,13.6c2.1,1.6,5.2,0.3,5.6-2.3l3.1-22.4C-2.9-50.3,2.9-50.3,3.5-46.3z"

make-signals = (signals,placer)->
			g do
				className: 'g-signals'
				signals |> map (signal)~>
					rect do
						do
							key: signal.id
							className: classNames 'signal',{green: signal.green}
							width: 0.6
							height: 2
							y: -1
							transform: placer signal.x

# RingRoad = react.create-class do
# 	component-did-mount: ->
# 		road = @refs.road
# 		l = road.getTotalLength()
# 		scale = [til ROAD-LENGTH]|>map (x)->
# 					p =  x/ROAD-LENGTH*l |> road.getPointAtLength 
# 					p1 = (x+0.1)/ROAD-LENGTH*l |> road.getPointAtLength 
# 					theta = 180/ Math.PI * Math.atan (p1.y - p.y)/(p1.x - p.x)
# 					{x: p.x, y: p.y, theta}
# 		@set-state {scale: scale, done: true}

# 	get-initial-state: ->
# 		scale: d3.scale.linear()
# 		done: false

# 	placer: (x)->
# 		a =@state.scale[Math.floor x]
# 		"translate(#{a.x},#{a.y}) rotate(#{a.theta})"

# 	render:->
# 		{traveling,signals} = @props
# 		g-cars 
# 		g-signals
# 		if @state.done>0
# 			g-cars = g do
# 				className: 'g-cars'
# 				traveling |> map (car)~>
# 					rect do
# 						do
# 							className: 'car'
# 							key: car.id
# 							y: -0.15
# 							height: 0.3
# 							width: 0.4
# 							transform: @placer car.x
# 							fill: car.fill
# 			g-signals = make-signals signals,@placer
# 		svg do
# 			do
# 				id: 'vis'
# 				baseProfile: 'basic'
# 				x: 0
# 				y: 0
# 				viewBox: '0 0 110 110'
# 			g do
# 				transform: 'translate(55,55)'
# 				# circle className: \road,r:50
# 				path do
# 					# stroke-miterlimit: 10
# 					className: \road
# 					# stroke-width: \2px
# 					fill: 'none'
# 					ref: \road
# 					d: path-string
# 				g-cars
# 				g-signals

# |> react.create-factory

RingRoad = ({traveling,signals})->
	svg do
		do
			id: 'vis'
			baseProfile: 'basic'
			x: 0
			y: 0
			viewBox: '0 0 110 110'
		g do
			transform: 'translate(55,55)'
			circle className: \road,r:50
			g do
				className: 'g-cars'
				traveling |> map (car)->
					rect do
						do
							className: 'car'
							key: car.id
							y: -0.15
							height: 0.3
							width: 0.4
							transform: do ->
								x = car.x/ROAD-LENGTH*360
								"rotate(#{x}) translate(0,50)"
							fill: car.fill
				signals |> map (signal)->
					rect do
						do
							key: signal.id
							className: classNames 'signal',{green: signal.green}
							width: 0.6
							height: 2
							y: -1
							transform: do ->
								x = signal.x/ROAD-LENGTH*360
								scale = if signal.green then 1 else 1.2
								"rotate(#{x}) translate(0,50) scale(#{scale}) "

export RingRoad
