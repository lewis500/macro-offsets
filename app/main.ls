# DEPENDENCIES
require!{
	'./components/app': {App}
	'react-dom'
	redux: {createStore,compose}
	'./reducers/root': {root,initial-state}
	'react-redux': {Provider}
	react
	react: {DOM:{div,p,button,h2}}:react
	'./components/devtools': {DevTools}
}

require './style/main.scss'

# final-create-store = compose( DevTools.instrument()) createStore

# store = final-create-store root,initial-state
store = createStore root,initial-state

	# createStore root
template = react.createElement do
	Provider
	{store}
	div do
		{}
		App {}
		# react.create-element DevTools, {}

# WIRE IT UP
el = document.getElementById 'app'
react-dom.render template,el
store.dispatch type: 'SET-NUM-SIGNALS',num-signals: 25
