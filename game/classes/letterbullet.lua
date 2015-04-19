
local lg = love.graphics

local LetterBullet = class("LetterBullet", Entity)
LetterBullet:include( PhysicsBody )

function LetterBullet:initialize( world, letter )
	Entity.initialize( self )
	PhysicsBody.initialize( self, world )
	self._letter = letter
	self._font = lg.newFont( 24 )
	self.w = self._font:getWidth(self._letter)
	self.h = self._font:getHeight()
	print(self.h)
	self:initBody()
	
	self._lifestart = currentTime()
end

function LetterBullet:initBody()
	
	local w, h = 10, 10
	self._shape = love.physics.newCircleShape( 10 )
	self._fixture = love.physics.newFixture(self._body, self._shape)
	self._fixture:setUserData(self)
	self:setDrawBoundingBox( -w/2, -h/2, w/2, h/2 )
	
end

function LetterBullet:launch( dx, dy )
	self._body:applyLinearImpulse( dx, dy )
end

function LetterBullet:update( dt )
	if (self._lifestart + 5 < currentTime()) then
		self:remove()
	end
end

function LetterBullet:draw()
	local x, y = self:getPos()
	local r = self:getAngle()
	local fx, fy = angle.forward( r )
	local rx, ry = angle.forward( r + math.pi / 2 )
	
	local oldfont = lg.getFont()
	lg.setFont(self._font)
	--lg.setColor( Color.getRGB( "Red" ) )
	--lg.line(x + fx * 5, y + fy * 5, x, y, x + rx * 5, y + ry * 5)
	lg.setColor( Color.getRGB( "White" ) )
	lg.printf(self._letter, x - (fx * self.w / 2), y - (ry * self.h / 2), 100, "left", r)
	lg.setFont(oldfont)
	
end

return LetterBullet