require!{
	react
	'redux-devtools': {createDevTools}
	react: {DOM:{div,p,button,h2}}:react

	# 'redux-devtools-dock-monitor': {DockMonitor}
	# 'redux-devtools-log-monitor': {LogMonitor}
	# 'redux-'
}
# <SliderMonitor keyboardEnabled />
SliderMonitor = require 'redux-slider-monitor'
DockMonitor = require 'redux-devtools-dock-monitor'
LogMonitor = require 'redux-devtools-log-monitor'
props =
			toggleVisibilityKey: 'ctrl-h'
			changePositionKey:'ctrl-q'
			# defaultPosition: 'bottom'
			# defaultSize: 0.15

DM = 	react.create-element do
	DockMonitor.default
	props
	# do ->
	react.create-element do 
		SliderMonitor
		{keyboardEnabled: true}
		null
	# react.create-element do
	# 	LogMonitor.default
	# 	{theme: 'tomorrow'}
	# 	null


DevTools = createDevTools DM

export DevTools