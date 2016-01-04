require '../style/style-ring-road'

require!{
	'classNames'
	'../constants/constants': {ROAD-LENGTH}
	'prelude-ls': {map}
	react: {DOM: {div,svg,g,rect,circle,path}}:react
	'react-redux': {connect}
	d3
}

path-string = "M4-46.8L12.7-27c0.8,1.7,2.6,2.8,4.4,2.6l21.4-2.3	c3.7-0.4,6.2,3.8,4,6.9L29.7-2.6c-1.1,1.5-1.1,3.6,0,5.1l12.7,17.4c2.2,3-0.2,7.3-4,6.9l-21.4-2.3c-1.9-0.2-3.7,0.8-4.4,2.6L4,46.8	c-1.5,3.4-6.4,3.4-7.9,0L-12.7,27c-0.8-1.7-2.6-2.8-4.4-2.6l-21.4,2.3c-3.7,0.4-6.2-3.8-4-6.9l12.7-17.4c1.1-1.5,1.1-3.6,0-5.1l-12.7-17.4c-2.2-3,0.2-7.3,4-6.9l21.4,2.3c1.9,0.2,3.7-0.8,4.4-2.6L-4-46.8C-2.4-50.2,2.4-50.2,4-46.8z"

RingRoad = react.create-class do
	component-did-mount: ->
		road = @refs.road
		l = road.getTotalLength()
		scale = d3.scale.linear()
			.domain [til ROAD-LENGTH]
			.range do ->
				[til ROAD-LENGTH]|>map (x)->
					p =  x/ROAD-LENGTH*l |> road.getPointAtLength 
					p1 = (x+0.1)/ROAD-LENGTH*l |> road.getPointAtLength 
					theta = 180/ Math.PI * Math.atan (p1.y - p.y)/(p1.x - p.x)
					{x: p.x, y: p.y, theta}
		@set-state {scale: scale, done: true}

	get-initial-state: ->
		scale: d3.scale.linear()
		done: false

	placer: (x)->
		# p =  x/ROAD-LENGTH*@state.road-length |> @refs.road.getPointAtLength 
		# p1 = (x+0.1)/ROAD-LENGTH*@state.road-length |> @refs.road.getPointAtLength 
		# theta = 180/ Math.PI * Math.atan (p1.y - p.y)/(p1.x - p.x)
		a = @state.scale x
		"translate(#{a.x},#{a.y}) rotate(#{a.theta})"

	render:->
		{traveling,signals} = @props
		g-cars 
		g-signals
		if @state.done>0
			g-cars = g do
				className: 'g-cars'
				traveling |> map (car)~>
					rect do
						do
							className: 'car'
							key: car.id
							y: -0.15
							height: 0.3
							width: 0.4
							transform: @placer car.x
							fill: car.fill
			g-signals = g do
				className: 'g-signals'
				signals |> map (signal)~>
					rect do
						do
							key: signal.id
							className: classNames 'signal',{green: signal.green}
							width: 0.6
							height: 2
							y: -1
							transform: @placer signal.x
		svg do
			do
				id: 'vis'
				baseProfile: 'basic'
				x: 0
				y: 0
				viewBox: '0 0 110 110'
			g do
				transform: 'translate(55,55)'
				# circle className: \road,r:50
				path do
					# stroke-miterlimit: 10
					className: \road
					# stroke-width: \2px
					fill: 'none'
					ref: \road
					d: path-string
				g-cars
				g-signals

|> react.create-factory

# RingRoad = ({traveling,signals})->
# 	svg do
# 		do
# 			id: 'vis'
# 			baseProfile: 'basic'
# 			x: 0
# 			y: 0
# 			viewBox: '0 0 110 110'
# 		g do
# 			transform: 'translate(55,55)'
# 			circle className: \road,r:50
# 			g do
# 				className: 'g-cars'
# 				traveling |> map (car)->
# 					rect do
# 						do
# 							className: 'car'
# 							key: car.id
# 							y: -0.15
# 							height: 0.3
# 							width: 0.4
# 							transform: do ->
# 								x = car.x/ROAD-LENGTH*360
# 								"rotate(#{x}) translate(0,50)"
# 							fill: car.fill
# 				signals |> map (signal)->
# 					rect do
# 						do
# 							key: signal.id
# 							className: classNames 'signal',{green: signal.green}
# 							width: 0.6
# 							height: 2
# 							y: -1
# 							transform: do ->
# 								x = signal.x/ROAD-LENGTH*360
# 								scale = if signal.green then 1 else 1.2
# 								"rotate(#{x}) translate(0,50) scale(#{scale}) "

export RingRoad
