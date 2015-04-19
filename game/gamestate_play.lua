
local play = gamestate.new()
local gui, level, world, physics, input, player, crosshair
local ammo_pool = {}
local snd_type

function play:init()

	-- Create GUI
	gui = GUI()
	-- Create level with physics world
	local ldata = LevelData()
	ldata.layers = { { name = "player_layer", type = LAYER_TYPE.BATCH, batches = {} }, { name = "crosshair_layer", type = LAYER_TYPE.BATCH, batches = {} },  }
	
	level = Level(ldata)
	world = level:getPhysicsWorld()
	--Get input controller
	input = getInput()
	
	crosshair = level:createEntity("Crosshair")
	player = level:createEntity("Player", level, crosshair)
	player:setPos(0, 0)
	
	level:createEntity("Enemy", world):setPos( -200, -200 )
	level:createEntity("Enemy", world):setPos( 300, 150 )
	level:createEntity("Enemy", world):setPos( 400, -200 )
	level:createEntity("Enemy", world):setPos( -250, 250 )
	
	-- Spawn objects part of the level data
	level:spawnObjects()
	
	snd_type = resource.getSound(FOLDER.ASSETS.."type.wav", "static")
	snd_type:setVolume( 0.5 )
	
	gui:addDynamicElement( "ammo", 0, 0, 0, function()
		local ammostr = ""
		for k, v in pairs( ammo_pool ) do
			ammostr = ammostr..v.."  "
		end
		love.graphics.print(ammostr, 10, 10)
	end)
	
end

function play:enter()

end

function play:leave()

end

function play:update( dt )
	level:update( dt )
	gui:update( dt )
	
	if (input:mouseIsDown("r")) then
		player:goForward()
	end
	
	if (input:mouseIsDown("l") and delay("fire", 0.08)) then
		self:fireLetter()
	end
	
end

function play:draw()
	--debug.drawPhysicsWorld( world )
	level:draw()
	gui:draw()
end

function play:fireLetter()
	local letter = ammo_pool[1]
	if (letter == nil) then return end
	
	player:fireLetter(letter)
	table.remove(ammo_pool, 1)	
end

function play:mousemoved(x, y, dx, dy)
	crosshair:move(dx, dy)
end

function play:textinput( text )
	if (text:match("%w")) then -- only alphanumeric
		snd_type:stop()
		snd_type:setPitch( 0.8 + (0.4 * math.random()) )
		snd_type:play()
		table.insert( ammo_pool, string.upper(text) )
	end
end

return play