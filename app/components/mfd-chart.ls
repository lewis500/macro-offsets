react = require 'react'
d3 = require 'd3'
{Q0,KJ} = require '../constants/constants'
{svg,circle,path,rect,g} = react.DOM
require '../style/style-charts.scss'
{connect} = require 'react-redux'

[width,height] = [250,250]

m = 
	t: 20
	l: 50
	b: 30
	r: 10

x = d3.scale.linear()
	.domain [0,KJ]
	.range [0,width]

y = d3.scale.linear()
	.domain [0,Q0]
	.range [height,0]

xAxis = d3.svg.axis()
	.scale x

yAxis = d3.svg.axis()
	.scale y
	.orient 'left'

line = d3.svg.line()
	.x (d)-> x d.k
	.y (d)-> y d.q

y2 = d3.scale.linear()
	.domain [0,1]
	.range [height,0]

line2 = d3.svg.line()
	.x (d)-> x d.k
	.y (d)-> y2 d.v

MFD-Chart = react.create-class do
	componentDidMount: ->
		d3.select @refs.xAxis	.call xAxis
		d3.select @refs.yAxis	.call yAxis
	render: ->
		{mfd} = @props
		svg do
			do
				id: 'mfdChart'
				width: width+m.l+m.r
				height: height+m.t+m.b
			g do
				transform: "translate(#{m.l},#{m.t})"
				rect do
					do 
						width: width
						height: height
						className: \bg
				g className: 'g-paths'
					path d: line(mfd),className:'mfd'
					# path d: line2(mfd),className: 'vel'
				g className:'y axis',ref: 'yAxis'
				g className:'x axis',ref: 'xAxis',transform: "translate(0,#{height})"

	place_circle: (d)->
		[tx,ty] = [x(d.k), y(d.q)]
		"translate(#{tx},#{ty})"
|> connect -> it{mfd}
|> react.create-factory

export MFD-Chart
