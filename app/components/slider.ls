react = require 'react'
{div,input,p} = react.DOM
PureRenderMixin = require 'react-addons-pure-render-mixin'

Slider = ({value,label,on-change,max,min,step})->
		props = 
			className: 'mdl-slider mdl-js-slider'
			tabIndex:0
			type: 'range'
		div do
			style: {display: \flex, flex-direction: \column,   align-items: \center}
			div do
				className: 'slider-label',style: {display: \flex, horizontal-align: 'center'}
				"#{label}: #{Math.floor(value)}"
			div do
				style: {display: \flex}
				input do
					{value,label,on-change,max,min,step,...props}

Slider = Slider|> react.create-factory

export Slider