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
		div do
			style: {flex-direction: \column}
			div do
				style:
					display: \flex
					flex-direction: \row
					width: '300px'
					justify-content: 'space-around'
				button do
					do
						className: 'mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect'
						on-click: reset
						style: {display: \flex}
					\reset
				button do
					do
						className: 'mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect'
						on-click: @pause-play
						style: {display: \flex}
					if paused then \play else \pause
			Header {display: \flex}
			div do
				style: {display: \flex, flex-direction: \row}
				div do
					style: {display: \flex, flex-basis: '35%'}
					Ring-Road {traveling,signals}
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
	