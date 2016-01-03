require!{
	'./ring-road':{Ring-Road}
	'./header':{Header}
	react: {DOM:{div,p,button}}:react
	'react-redux': {connect}
}

App = ({paused, time, pause-play, tick, reset, traveling, signals})->
		unless paused 
			requestAnimationFrame tick
		div do
			style: {flex-direction: \column}
			div do
				style: {display: \flex, flex-direction: \row}
				button do
					on-click: reset
					\reset
				button do
					on-click: pause-play
					if paused then \play else \pause
			div do
				style: {display: \flex}
				Header {},null
			div do
				style: {display: \flex}
				Ring-Road {traveling,signals}
			# ADD OTHER CHARTS AND SUCH LATER ON.
|> connect do
	-> it{paused,time,traveling,signals}
	(dispatch) ->
		pause-play: -> dispatch type: 'PAUSE-PLAY'
		tick: -> dispatch type: \TICK
		reset: -> dispatch type: \RESET
|> react.create-factory

export App
	