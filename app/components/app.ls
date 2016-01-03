require!{
	'./ring-road':{Ring-Road}
	'./header':{Header}
	'./mfd-chart':{MFD-Chart}
	'./cum-chart':{Cum-Chart}
	react: {DOM:{div,p,button}}:react
	'react-redux': {connect}
	d3: {timer}
}

App = react.create-class do
	render: ->
		{paused, time, pause-play, tick, reset, traveling, signals} = @props
		# unless paused
		# 	requestAnimationFrame tick
		div do
			style: {flex-direction: \column}
			div do
				style: {display: \flex, flex-direction: \row}
				button do
					on-click: reset
					\reset
				button do
					on-click: @pause-play
					if paused then \play else \pause
			div do
				style: {display: \flex}
				Header {},null
			div do
				style: {display: \flex, flex-direction: \row}
				div do
					style: {display: \flex}
					Ring-Road {traveling,signals}
				div do
					style: {display: \flex, flex-direction: \column}
					div do
						style: {display: \flex}
						MFD-Chart {}
					div do
						style: {display: \flex}
						Cum-Chart {}

	pause-play: ->
		if @props.paused
			timer ~>
				@props.tick()
				@props.paused
		@props.pause-play()

|> connect do
	-> it{paused,time,traveling,signals}
	(dispatch) ->
		pause-play: -> dispatch type: 'PAUSE-PLAY'
		tick: -> dispatch type: \TICK
		reset: -> dispatch type: \RESET
|> react.create-factory

export App
	