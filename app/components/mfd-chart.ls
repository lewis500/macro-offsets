react = require 'react'
d3 = require 'd3'
{Q0,KJ} = require '../constants/constants'
{svg,circle,path,rect,g,path} = react.DOM
require '../style/style-charts.scss'
{connect} = require 'react-redux'
{map} = require 'prelude-ls'
[width,height] = [250,250]
_ = require \lodash
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
	.x (.k)>>x
	.y (.q)>>y

y2 = d3.scale.linear()
	.domain [0,1]
	.range [height,0]

line2 = d3.svg.line()
	.x (.k)>>x
	.y (.v)>>y2

MFD-Chart = react.create-class do
	componentDidMount: ->
		d3.select @refs.xAxis	.call xAxis
		d3.select @refs.yAxis	.call yAxis
	render: ->
		{mfd,memory,formula-pred} = @props

		lines = memory[1 til ] |> _.map _,(b,i)->
			a = memory[i]
			path do
				d: line [a,b]
				className: 'portrait'
				key: 'line' ++ b.id

		circles = memory |> _.map _,(d,i)->
			[tx,ty] = [x(d.k), y(d.q)]
			circle do
				className: 'memory'
				key: d.id
				r: 3
				transform: "translate(#{tx},#{ty})"
				opacity: do ->
					2/(1+Math.exp 0.1*(memory.length - i))

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
				circles
				lines
				circle do
					className: 'memory formula'
					r: 3
					transform: @place-circle formula-pred
				g className:'y axis',ref: 'yAxis'
				g className:'x axis',ref: 'xAxis',transform: "translate(0,#{height})"

	place-circle: (d)->
		a
		[tx,ty] = [x(d.k), y(d.q)]
		"translate(#{tx},#{ty})"
|> connect -> it{mfd,memory,formula-pred}
|> react.create-factory

export MFD-Chart
