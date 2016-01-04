react = require 'react'
d3 = require 'd3'
{Q0,KJ} = require '../constants/constants'
{svg,circle,path,rect,g} = react.DOM
require '../style/style-charts.scss'
{connect} = require 'react-redux'
{map} = require 'prelude-ls'
[width,height] = [250,250]

m = 
	t: 20
	l: 50
	b: 30
	r: 10

x = d3.scale
	.linear()
	.domain [0,7000]
	.range [0,width]

y = d3.scale
	.linear()
	.domain [0,2000]
	.range [height,0]

xAxis = d3.svg
	.axis()
	.scale x

yAxis = d3.svg
	.axis()
	.scale y
	.orient 'left'

line = d3.svg
	.line()
	.x (.time)>>x
	.y (.val)>>y

Cum-Chart = react.create-class do
	componentDidMount: ->
		d3.select @refs.xAxis	.call xAxis
		d3.select @refs.yAxis	.call yAxis
	render: ->
		{memory-EN,memory-EX,formula-EX,formula-EN} = @props
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
					path do
						className: 'en'
						d: line memory-EN
				g className: 'g-paths'
					path do
						className: 'en f'
						d: line formula-EN
				g className: 'g-paths'
					path do
						className: 'ex'
						d: line memory-EX
				g className: 'g-paths'
					path do
						className: 'ex f'
						d: line formula-EX
				g className:'y axis',ref: 'yAxis'
				g className:'x axis',ref: 'xAxis',transform: "translate(0,#{height})"

	place_circle: (d)->
		[tx,ty] = [x(d.k), y(d.q)]
		"translate(#{tx},#{ty})"
|> connect -> it{memory-EN,memory-EX,formula-EX,formula-EN}
|> react.create-factory

export Cum-Chart
