d3 = require 'd3'
_ = require 'lodash'
{VF,Q0,KJ,W,ROAD-LENGTH} = require '../constants/constants'
{map,concat-map,concat} = require 'prelude-ls'
{reduce-formula} = require './formula-reducer'

loop-over-entries = (it)->
	[g0,g,i,res] = [1000,999,0,[]]
	while g>0 and Math.abs(i)<100
		entry = get-entry {i,...it}
		g=entry.g
		res.push entry
		if it.direction is 'forward' then i++ else i--
	res

get-entry = ({i,d,cycle,green,offset})->
	v = if i<0 then -W else VF
	x = d*i
	tt = x/v
	e = tt - i*offset
	g = green - e
	green = Math.max g,0
	tr = Math.max( cycle - e,0)
	t = tt + cycle - e
	c = Q0*green + Math.max 0,-x*KJ
	{t,c,x,g}

find-min = (k,table)->
	costs = table |> map (e)->
		(e.c + e.x*k)/e.t 
		# |> concat _
	q = _.min [...costs,VF*k,W*(KJ - k)]
	v = if k>0 then q/k else 0
	{k,q,v}

reduce-mfd = (state)->
	{num-signals,cycle,green,offset} = state
	d = ROAD-LENGTH/num-signals
	table = ['forward','backward'] |> concat-map (direction)->
		loop-over-entries {d,cycle,green,offset,direction}
	mfd = _.range 0.01,1.01,0.01 |> map find-min _,table
	{...state,mfd} |> reduce-formula

export reduce-mfd