require!{
	'../actions/action-creators': {set-num-signals,set-offset,set-green,set-cycle}
	'react-redux': {connect}
	'prelude-ls': {Func:{memoize,curry}}
	react: {DOM: {div}}:react
	'./slider': {Slider}
}

Header = ({num-signals,offset,cycle,green,dispatch,style})->
	actioner = (action,e)--> 
		+e.target.value|>action|>dispatch
	div do
		style
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
				step: 1
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
|> connect -> it{num-signals,offset,cycle,green}
|> react.create-factory
export Header