react = require 'react'
d3 = require 'd3'
{Q0,KJ,NUM-CARS} = require '../constants/constants'
{svg,circle,path,rect,g,line} = react.DOM
require '../style/style-charts.scss'
{connect} = require 'react-redux'
{map} = require 'prelude-ls'
[width,height] = [300,300]

m = 
	t: 20
	l: 50
	b: 30
	r: 25

x = d3.scale
	.linear()
	.domain [0,5000]
	.range [0,width]

y = d3.scale
	.linear()
	.domain [0,NUM-CARS]
	.range [height,0]

xAxis = d3.svg
	.axis()
	.scale x
	.ticks 5

yAxis = d3.svg
	.axis()
	.scale y
	.orient 'left'

path-maker-exits = d3.svg.line()
	.x (.time)>>x
	.y (.cum-exits)>>y

path-maker-entries = d3.svg.line()
	.x (.time)>>x
	.y (.cum-entries)>>y

Cum-Chart = react.create-class do
	componentDidMount: ->
		d3.select @refs.xAxis	.call xAxis
		d3.select @refs.yAxis	.call yAxis
	render: ->
		{history,prediction} = @props
		svg do
			do
				id: 'mfdChart'
				width: width+m.l+m.r
				height: height+m.t+m.b
			g do
				transform: "translate(#{m.l},#{m.t})"
				path do
					className: 'en'
					d: path-maker-entries history
				path do
					className: 'en f'
					d: path-maker-entries prediction
				path do
					className: 'ex'
					d: path-maker-exits history
				path do
					className: 'ex f'
					d: path-maker-exits prediction
				g className:'y axis',ref: 'yAxis'
				g className:'x axis',ref: 'xAxis',transform: "translate(0,#{height})"

	place_circle: (d)->
		[tx,ty] = [x(d.k), y(d.q)]
		"translate(#{tx},#{ty})"
|> connect -> it{history,prediction}
|> react.create-factory

export Cum-Chart
