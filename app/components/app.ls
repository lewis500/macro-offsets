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
		{paused, queueing, time, traveling, signals} = @props
		div do
			style: {flex-direction: \column}
			Header do
				{style: {display: \flex}}
			div do
				style: {display: \flex, flex-direction: \row}
				div do
					style: {display: \flex, flex-basis: \45%}
					Ring-Road {traveling,signals,queueing}
				div do
					style: {display: \flex}
					MFD-Chart {}
				div do
					style: {display: \flex}
					Cum-Chart {}

|> connect do
	-> it{paused,time,traveling,signals,queueing}
|> react.create-factory

export App
	