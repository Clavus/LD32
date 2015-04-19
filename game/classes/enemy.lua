
local lg = love.graphics

local Enemy = class("Enemy", Entity)
Enemy:include( PhysicsBody )
Enemy:include( CollisionResolver )
	
function Enemy:initialize( world, target, difficulty )
	Entity.initialize(self)
	PhysicsBody.initialize(self, world )
	
	self._font = lg.newFont( 24 )
	
	self._force = 2000 + 500 * difficulty
	self._target = target
	self._shield = {}
	local word = string.upper(words.getRandom(math.min(3,difficulty/2), math.max(3,math.random(difficulty/1.5, difficulty+1))))
	
	for i, char in chars(word) do
		table.insert(self._shield, char)
	end
	self:updateShieldString()
	
	self.radius = 40
	self:initBody()
end

function Enemy:initBody()
	
	self._body:setMass( 100 )
	self._body:setLinearDamping( 5 )
	
	local w, h = self.radius * 2, self.radius * 2
	self._shape = love.physics.newCircleShape( self.radius )
	self._fixture = love.physics.newFixture(self._body, self._shape)
	self._fixture:setUserData(self)
	self:setDrawBoundingBox( -w/2, -h/2, w/2, h/2 )
	
end

function Enemy:update( dt )
	
	if (Entity.isValid(self._target)) then
		local tx, ty = self._target:getPos()
		local x, y = self:getPos()
		if (vector2d.distance(x,y,tx,ty) > 400) then
			self:getBody():applyForce((tx-x)/math.abs(tx-x) * self._force,0) 
		else
			local dir = Vector(tx-x, ty-y):normalize() * self._force
			self:getBody():applyForce(dir.x, dir.y)
		end
	end

end

function Enemy:draw()
	
	local x, y = self:getPos()
	lg.setColor(255, 0, 0)
	lg.circle( "fill", x, y, self.radius, 32 )
	
	lg.setLineWidth(1)
	for k, v in pairs( self._shield ) do
		lg.circle( "line", x, y, self.radius + k * 4, 32 )
	end
	
	local fw, fh = self._font:getWidth(self._shieldstr), self._font:getHeight(self._shieldstr)
	lg.setColor(255, 200, 200)
	lg.print(self._shieldstr, x - fw/4, y - fh/4)
	
	lg.setColor(255, 255, 255)
	
end

function Enemy:getDrawLayer()
	return "player_layer"
end

function Enemy:updateShieldString()
	self._shieldstr = ""
	local prefix = ""
	
	for k, v in pairs(self._shield) do
		self._shieldstr = self._shieldstr..prefix..v
		prefix = " "
	end
end

function Enemy:die()
	local x, y = self:getPos()
	signal.emit("enemy_death", x, y, self.radius)
	self:remove()
end

function Enemy:beginContactWith( other, contact, myFixture, otherFixture, selfIsFirst )
	
	if (other:isInstanceOf(LetterBullet)) then
		if (other:getLetter() == self._shield[1]) then
			table.remove(self._shield, 1)
			self:updateShieldString()
			other:remove()
			if (#self._shield == 0) then
				signal.emit("score")
				self:die()
			end
		end
	end
	
end

return Enemy