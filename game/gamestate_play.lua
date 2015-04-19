
local play = gamestate.new()
local gui, level, world, physics, input, player, crosshair
local lg = love.graphics
local ammo_pool = {}
local snd_type, snd_explo
local lost = false
local score = 0
local letters_typed = 0
local start_time = 0
local final_font
local score_font
local instruct_font
local psystem

function play:init()

	final_font = love.graphics.newFont( 72 )
	score_font = love.graphics.newFont( 24 )
	instruct_font = love.graphics.newFont( 12 )
		
	snd_type = resource.getSound(FOLDER.ASSETS.."type.wav", "static")
	snd_type:setVolume( 0.3 )
	
	snd_explo = resource.getSound(FOLDER.ASSETS.."explosion.wav", "static")
	snd_explo:setVolume( 0.5 )

	snd_score = resource.getSound(FOLDER.ASSETS.."score.wav", "static")
	snd_score:setVolume( 0.5 )
	
end

function play:enter()
	
	-- Create GUI
	gui = GUI()
	-- Create level with physics world
	local ldata = LevelData()
	ldata.layers = { { name = "bullet_layer", type = LAYER_TYPE.BATCH, batches = {} }, 
		{ name = "player_layer", type = LAYER_TYPE.BATCH, batches = {} }, 
		{ name = "crosshair_layer", type = LAYER_TYPE.BATCH, batches = {} },  
	}
	
	level = Level(ldata)
	world = level:getPhysicsWorld()
	--Get input controller
	input = getInput()
	
	crosshair = level:createEntity("Crosshair")
	player = level:createEntity("Player", level, crosshair)
	player:setPos(-400, 0)
	
	gui:addDynamicElement( "ammo", 0, 0, 0, function()
		local ammostr = ""
		for k, v in pairs( ammo_pool ) do
			ammostr = ammostr..v.."  "
		end
		love.graphics.print(ammostr, 10, 10)
	end)
	
	gui:addDynamicElement( "instructions", 0, 0, 0, function()
		local oldfont = lg.getFont()
		lg.setFont(instruct_font)
		lg.print("Type letters to load into your weapon. Left click to fire. Hold right mouse to move. Don't get hit by enemies. Destroy enemies by hitting them with the right letters.", 10, screen.getRenderHeight() - 22)
		lg.setFont(oldfont)
	end)
	
	local spawns = 0
	local diff = 2
	timer.clear()
	timer.addPeriodic(4, function()
		if not Entity.isValid(player) then return end
		spawns = spawns + 1
		if (spawns > 3) then 
			diff = diff + 1
			spawns = 0
		end
		level:createEntity("Enemy", world, player, diff):setPos( 700, -300 + math.random() * 600 )
	end)
	
	-- Spawn objects part of the level data
	level:spawnObjects()
	
	score = 0
	letters_typed = 0
	start_time = currentTime()
	ammo_pool = {}
	lost = false
	
	signal.clear("lose")
	signal.clear("score")
	
	local cam = level:getCamera()
	
	signal.register("lose", function()
		local secs = math.round(currentTime() - start_time, 2)
		snd_explo:play()
		lost = true
		-- screenshake
		timer.doFor(0.3, function()
			cam:setPos(-6+math.random()*12,-6+math.random()*12)
		end, function()
			cam:setPos(0,0)
		end)
		gui:addDynamicElement( "game_over", 0, 0, 0, function()
			local oldfont = lg.getFont()
			lg.setFont(final_font)
			lg.printf("YOU DIED HORRIBLY", screen.getRenderWidth() / 2 - 400, screen.getRenderHeight() / 2 - 100, 800, "center")
			lg.setFont(score_font)
			lg.printf("Score: "..score.." enemies beaten. Survived "..secs.." seconds", screen.getRenderWidth() / 2 - 400, screen.getRenderHeight() / 2 , 800, "center")
			lg.printf("Letters typed: "..letters_typed, screen.getRenderWidth() / 2 - 400, screen.getRenderHeight() / 2 + 40, 800, "center")
			lg.printf("Press R to restart", screen.getRenderWidth() / 2 - 400, screen.getRenderHeight() / 2 + 80, 800, "center")
			lg.setFont(oldfont)
		end)
	end)

	signal.register("score", function()
		-- screenshake
		timer.doFor(0.2, function()
			cam:setPos(-4+math.random()*8,-4+math.random()*8)
		end, function()
			cam:setPos(0,0)
		end)
		snd_score:play()
		score = score + 1
	end)
	
	psystem = lg.newParticleSystem(resource.getImage(FOLDER.ASSETS.."dot.png"), 1000)
	psystem:setSpeed( 5, 20 )
	psystem:setSpread( math.pi * 2 )
	psystem:setParticleLifetime(1, 2)
	psystem:setColors(255, 255, 255, 255, 255, 255, 255, 0)
	signal.register("enemy_death", function(x, y, rad)
		psystem:setAreaSpread( "normal", rad/2, rad/2 )
		psystem:setPosition(x, y)
		psystem:emit(200)
	end)
	
end

function play:leave()

end

function play:update( dt )
	level:update( dt )
	gui:update( dt )
	
	psystem:update(dt)
	
	if not lost then
		if (input:mouseIsDown("r")) then
			player:goForward()
		end
		
		if (input:mouseIsDown("l") and delay("fire", 0.08)) then
			self:fireLetter()
		end
	end

end

function play:draw()
	--debug.drawPhysicsWorld( world )
	level:getCamera():draw(function() lg.draw(psystem) end)
	level:draw()
	gui:draw()
end

function play:fireLetter()
	local letter = ammo_pool[1]
	if (letter == nil) then return end
	
	local cam = level:getCamera()
	-- screenshake
	timer.doFor(0.1, function()
		cam:setPos(-1+math.random()*2,-1+math.random()*2)
	end, function()
		cam:setPos(0,0)
	end)
	
	player:fireLetter(letter)
	table.remove(ammo_pool, 1)	
end

function play:canRestart()
	return lost
end

function play:mousemoved(x, y, dx, dy)
	crosshair:move(dx, dy)
end

function play:textinput( text )
	if (not lost and text:match("%w")) then -- only alphanumeric
		snd_type:stop()
		snd_type:setPitch( 0.8 + (0.4 * math.random()) )
		snd_type:play()
		letters_typed = letters_typed + 1
		table.insert( ammo_pool, string.upper(text) )
	end
end

return play