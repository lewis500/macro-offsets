require!{
	'../actions/action-creators': {set-num-signals,set-offset,set-green,set-cycle}
	'react-redux': {connect}
	'prelude-ls': {Func:{memoize,curry}}
	react: {DOM: {div,button,label,input,span}}:react
	'./slider': {Slider}
	'd3': {timer}
}
require '../style/main.scss'
classes = 'mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect'

Header = react.create-class do
	pause-play: ->
		if @props.paused
			timer ~>
				@props.tick()
				@props.paused
		@props.pause-play()
	render: ->
		{num-signals,offset,cycle,green,dispatch,style,paused,tick,mode,reset,change-mode} = @props 
		actioner = (action,e)--> 
			+e.target.value|>action|>dispatch

		radio-classes = "mdl-radio mdl-js-radio mdl-js-ripple-effect"

		div do
			style: {... style, justify-content: 'space around'}
			button do
				do
					className: classes
					on-click: reset
				\reset

			button do
				do
					className: classes
					on-click: @pause-play
				if paused then \play else \pause

			label do
				do
					className: radio-classes
					htmlFor: 'option-2'
				input do
					do
						className: 'mdl-radio__button'
						name: \options
						id: 'option-2' 
						type: \radio
						on-change: change-mode \fixed
						checked: mode=='fixed'
				span do
					do 
						className: 'mdl-radio__label'
					\fixed

			label do
				do
					className: radio-classes
					htmlFor: 'option-3'
				input do
					do
						className: 'mdl-radio__button'
						name: \options
						id: 'option-3' 
						type: \radio
						on-change: change-mode 'time-path'
						checked: mode=='time-path'
				span do
					do 
						className: 'mdl-radio__label'
					'time-path'

			Slider do
				do
					value: num-signals
					max: 40
					min: 0
					step: 1
					on-change: actioner set-num-signals
					label: 'number signals'
			Slider do
				do
					value: offset
					max: 100
					min: -100
					step: 2.5
					on-change: actioner set-offset
					label: 'offset'
			Slider do
				do
					value: green
					max: 100
					min: 0
					step: 5
					on-change: actioner set-green
					label: 'green'
			Slider do
				do
					value: cycle
					max: 200
					min: 0
					step: 5
					on-change: actioner set-cycle
					label: 'cycle'

Header = Header
|> connect do
	-> it{num-signals,offset,cycle,green,paused,mode}
	(dispatch) ->
		dispatch: dispatch
		pause-play: -> dispatch type: 'PAUSE-PLAY'
		tick: -> dispatch type: \TICK
		reset: -> dispatch type: \RESET
		change-mode: (mode)->
			->
				dispatch {type: 'SET-MODE', mode}
|> react.create-factory
export Header