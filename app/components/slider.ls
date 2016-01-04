react = require 'react'
{div,input,p} = react.DOM
PureRenderMixin = require 'react-addons-pure-render-mixin'

Slider = ({value,label,on-change,max,min,step})->
		props = 
			className: 'mdl-slider mdl-js-slider'
			tabIndex:0
			type: 'range'
		div do
			style: {display: \flex, flex-direction: 'row'}
			div do
				style: {flex-basis: '300px'}
				input do
					{value,label,on-change,max,min,step,...props}
			div do
				style: {display: \flex}
				"#{label}: #{value}"

Slider = Slider|> react.create-factory

export Slider