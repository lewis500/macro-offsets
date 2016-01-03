d3 = require 'd3'
_ = require 'lodash'
{VF,Q0,KJ,W,ROAD-LENGTH} = require '../constants/constants'
{map,concat-map} = require 'prelude-ls'

loop-over-entries = ({d,cycle,green,offset,direction})->
	[g0,g,i,res] = [1000,999,0,[]]
	while g>0 and Math.abs(i)<100
		entry = get-entry i,d,cycle,green,offset
		g=entry.g
		res.push entry
		if direction is 'forward' then i++ else i--
	res

get-entry = (i,d,cycle,green,offset)->
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

make-table =({d,cycle,green,offset}) ->
	['forward','backward'] |> concat-map (direction)->
		loop-over-entries {d,cycle,green,offset,direction}

find-min = (k,table)->
	costs = table |> map (e)->
		(e.c + e.x*k)/e.t 
	q = _.min [...costs,VF*k,W*(KJ - k)]
	v = if k>0 then q/k else 0
	{k,q,v}

find-mfd = (table)->
	range  = _.range 0.01,1.01,0.01
	range |> map find-min _,table

reduce-mfd = ({mfd,num-signals,cycle,green,offset})->
	d = ROAD-LENGTH/num-signals
	find-mfd make-table {d,cycle,green,offset}

export reduce-mfd