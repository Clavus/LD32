
local lg = love.graphics

local Enemy = class("Enemy", Entity)
Enemy:include( PhysicsBody )
	
function Enemy:initialize( world )
	Entity.initialize(self)
	PhysicsBody.initialize(self, world )
	
	self._shield = {}
	local shields = math.random(1, 10)
	local abc = "abcdefghijklmnopqrstuvwxyz1234567890"
	
	while(shields > 0) do
		local pick = math.random(1, #abc)
		table.insert(self._shield, string.upper(string.sub(abc,pick,pick)))
		shields = shields - 1
	end
	
	self.radius = 40
	self:initBody()
end

function Enemy:initBody()
	
	self._body:setMass( 100 )
	self._body:setLinearDamping( 10 )
	
	local w, h = self.radius * 2, self.radius * 2
	self._shape = love.physics.newCircleShape( self.radius )
	self._fixture = love.physics.newFixture(self._body, self._shape)
	self._fixture:setUserData(self)
	self:setDrawBoundingBox( -w/2, -h/2, w/2, h/2 )
	
end

function Enemy:update( dt )
	
end

function Enemy:draw()
	
	local x, y = self:getPos()
	lg.setColor(255, 0, 0)
	lg.circle( "fill", x, y, self.radius, 32 )
	
	lg.setLineWidth(1)
	for k, v in pairs( self._shield ) do
		lg.circle( "line", x, y, self.radius + k * 4, 32 )
	end
	
	lg.setColor(255, 255, 255)
	
	
	
end

function Enemy:getDrawLayer()
	return "player_layer"
end

return Enemy