
local deltaTime = deltaTime

local Player = class("Player", Entity)
Player:include( PhysicsBody )

function Player:initialize(level, crosshair, input)
	
	self._level = level
	self._world = level:getPhysicsWorld()
	
	Entity.initialize(self)
	PhysicsBody.initialize(self, self._world)
	
	self._speed = 0
	self._moved = false
	
	self._sprite = Sprite({
		image = resource.getImage(FOLDER.ASSETS.."player_ship.png"),
		origin_relative = Vector(0.5, 0.5)
	})
	self._shootsound = resource.getSound(FOLDER.ASSETS.."shoot.wav", "static")
	
	self._crosshair = crosshair
	self:initBody()
	
end

function Player:initBody()
	
	local w, h = 60, 60
	local x, y = self:getPos()
	self._shape = love.physics.newRectangleShape(0, 0, w, h)
	self._fixture = love.physics.newFixture(self._body, self._shape)
	self._fixture:setUserData(self)
	self:setDrawBoundingBox( -w/2, -h/2, w/2, h/2 )
	
end

function Player:update( dt )
	
	local cx, cy = self._crosshair:getPos()
	local x, y = self:getPos()
	self:setAngle( angle.rotateTo( self:getAngle(), vector2d.angle(cx - x, cy - y), math.pi ) )
	self:moveForward(self._speed * dt)
	if not (self._moved) then
		self._speed = math.approach( self._speed, 0, dt * 3600 )
	end
	self._moved = false
	
end

function Player:fireLetter( letter )
	
	self._shootsound:stop()
	self._shootsound:setPitch( 0.8 + (0.4 * math.random()) )
	self._shootsound:play()
	
	local x, y = self:getPos()
	local r = self:getAngle()
	local rx, ry = angle.forward( r )
	local bullet = self._level:createEntity("LetterBullet", self._world, letter )
	bullet:setAngle( math.random() * (2 * math.pi) )
	bullet:setPos( x + rx * 60, y + ry * 60 )
	bullet:launch( rx * 300, ry * 300 )
	
end

function Player:goForward()
	self._speed = math.approach( self._speed, 600, deltaTime() * 2400 )
	self._moved = true
end

function Player:getDrawLayer()
	return "player_layer"
end

function Player:draw()
	
	local x, y = self:getPos()
	local r = self:getAngle()
	self._sprite:draw(x, y, r, 0.5)
	
end

return Player