react = require 'react'
{div,input} = react.DOM
PureRenderMixin = require 'react-addons-pure-render-mixin'

Slider = ({value,label,on-change,max,min-step})->
		div {},
			input do
				{value,label,on-change,max,min-step,type:'range'}
			"#{label}: #{value}"

Slider = Slider|> react.create-factory

export Slider