
local Crosshair = class("Crosshair", Entity)
Crosshair:include( Rotatable )
Crosshair:include( Scalable )

function Crosshair:initialize()
	
	Entity.initialize( self )
	Rotatable.initialize( self )
	Scalable.initialize( self )
	
	self._sprite = Sprite({
		image = resource.getImage(FOLDER.ASSETS.."crosshair.png"),
		origin_relative = Vector(0.5, 0.5)
	})
	
	-- scale bounciness
	timer.addPeriodic(0.6, function()
		timer.tween(0.3, self._scale, { x = 0.7, y = 0.7 }, 'in-out-quad')
	end)
	timer.add(0.6, function()
		timer.addPeriodic(0.6, function()
			timer.tween(0.2, self._scale, { x = 1, y = 1 }, 'in-out-quad')
		end)
	end)

end

function Crosshair:update()
	
end

function Crosshair:getDrawLayer()
	return "crosshair_layer"
end

function Crosshair:draw()
	
	local x, y = self:getPos()
	local r = self:getAngle()
	local sx, sy = self:getScale()
	self._sprite:draw( x, y, r, sx, sy )
	
end

return Crosshair