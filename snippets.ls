	# cars: _.fold do
	# 	-> L.push do
	# 		&0
	# 		* 
	# 			loc:&1 
	# 			id:id++
	# 			fill: sample colors
	# 	L.make-list()
	# 	[50 100 120]

# L = require './models/lane.ls'

# a = L.make-list()
# b = _.fold L.push,a,[\asdf,\fdsa,\fdfdca]
# 	|> L.unshift _,\mine
# 	|> L.remove _,\fdsa


# Lane = ->
# 	list = make-list()
# 	res = 
# 		push: (data)->
# 			list := push list,data
# 			this
# 		unshift: (data)->
# 			list := unshift list,data
# 			this
# 		remove: (data)->
# 			new_list = remove list data
# 			if new_list is not list
# 				list := new_list
# 			this
# 		start: -> list.start
# 		end: -> list.end
# 		list: -> list
# 		array: -> 
# 			array list