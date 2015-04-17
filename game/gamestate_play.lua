
local play = gamestate.new()
local gui, level, world, physics, input

function play:init()

	-- Create GUI
	gui = GUI()
	-- Create level with physics world
	level = Level(LevelData())
	world = level:getPhysicsWorld()
	--Get input controller
	input = getInput()
	
	-- Spawn objects part of the level data
	level:spawnObjects()
	
end

function play:enter()

end

function play:leave()

end

function play:update( dt )
	level:update( dt )
	gui:update( dt )
end

function play:draw()
	level:draw()
	gui:draw()
end

return play