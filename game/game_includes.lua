
require("game/game")

local toload = {
	{ Player = "game/classes/player" },
	{ Crosshair = "game/classes/crosshair" },
	{ LetterBullet = "game/classes/letterbullet" },
	{ Enemy = "game/classes/enemy" },
}
package.loadSwappable( toload )