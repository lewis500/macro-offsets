require!{
	'../actions/action-creators': actions
	'react-redux': {connect}
	'prelude-ls': {Func:{memoize}}
	react: {DOM: {div}}:react
	'../actions/action-creators': actions
	'./slider': {Slider}
}

actioner = (action,e)--> 
	actions[action] +e.target.value

Header = ({num-signals,offset,cycle,green})->
	div do
		id: 'trb-header'
		Slider do
			do
				value: num-signals
				max: 40
				min: 0
				step: 1
				on-change: actioner actions.set-num-signals
				label: 'number signals'
		Slider do
			do
				value: offset
				max: 30
				min: 0
				step: 1
				on-change: actioner actions.set-offset
				label: 'offset'
		Slider do
			do
				value: green
				max: 200
				min: 0
				step: 5
				on-change: actioner actions.set-green
				label: 'green'
		Slider do
			do
				value: cycle
				max: 200
				min: 0
				step: 5
				on-change: actioner actions.set-cycle
				label: 'cycle'

Header = Header
|> connect -> it{num-signals,offset,cycle,green}
|> react.create-factory
export Header