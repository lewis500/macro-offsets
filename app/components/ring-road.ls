require '../style/style-ring-road'

require!{
	'classNames'
	'../constants/constants': {ROAD-LENGTH}
	'prelude-ls': {map}
	react: {DOM: {div,svg,g,rect,circle}}:react
	'react-redux': {connect}
}

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
								"rotate(#{x}) translate(0,50)"

export RingRoad
