require '../style/style-ring-road'

require!{
	'classNames'
	'../constants/constants': {ROAD-LENGTH}
	'prelude-ls': {map,at, Func: {memoize}}
	react: {DOM: {div,svg,g,rect,circle,path}}:react
	'react-redux': {connect}
}

RingRoad = ({traveling,signals,queueing})->
	svg do
		do
			id: 'vis'
			baseProfile: 'basic'
			x: 0
			y: 0
			viewBox: '0 0 110 110'
		g do
			transform: 'translate(55,55)'
			circle className: \roadout,r:52
			circle className: \road,r:50
			g do
				className: 'g-cars'
				traveling |> map (car)->
					rect do
						do
							className: 'car'
							key: car.id
							y: -0.35
							height: 0.7
							width: 0.3
							transform: do ->
								x = car.x/ROAD-LENGTH*360
								"rotate(#{x}) translate(0,50)"
							fill: car.fill
				queueing |> map (car)->
					rect do
						do
							className: 'car'
							key: car.id
							y: -0.35
							height: 0.7
							width: 0.3
							transform: do ->
								x = car.x/ROAD-LENGTH*360
								"rotate(#{x}) translate(0,53)"
							fill: car.fill
				signals |> map (signal)->
					rect do
						do
							key: signal.id
							className: classNames 'signal',{green: !signal.red,backwards: signal.backwards}
							width: 0.6
							height: 2
							y: -1
							transform: do ->
								x = signal.x/ROAD-LENGTH*360
								scale = if !signal.red then 1 else 1.2
								"rotate(#{x}) translate(0,50) scale(#{scale}) "

export RingRoad
