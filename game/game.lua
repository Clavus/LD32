
local playState = require("game/gamestate_play")
local input

function game.load()
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
	
	gamestate.update(dt)
end

function game.draw()
	love.graphics.setBackgroundColor( 30, 30, 40 )
	love.graphics.clear()
	gamestate.drawStack()
end
