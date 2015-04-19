
local playState = require("game/gamestate_play")
local input

function game.load()
	
	love.mouse.setVisible( false )
	love.mouse.setRelativeMode( true )
	
	words.load()
	
	input = getInput()
	
	signal.register( "SpawnLevelObject", function( level, object )
		-- spawn level objects
	end)

	signal.register( "Trigger", function( trigger, other, contact )
		-- handles triggers
	end)

	gamestate.switch( playState )
end

function game.update( dt )
	if (input:keyIsPressed("escape")) then 
		love.event.quit() 
		return 
	end
	if (input:keyIsPressed("r") and gamestate.canRestart()) then
		print("restarting")
		gamestate.switch( playState )
	end
	
	gamestate.update(dt)
end

function game.draw()
	love.graphics.setBackgroundColor( 30, 30, 40 )
	love.graphics.clear()
	gamestate.drawStack()
end

function game.mousemoved( x, y, dx, dy )
	gamestate.mousemoved(x, y, dx, dy)
end

function game.textinput( text )
	gamestate.textinput( text )
end

