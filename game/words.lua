
local words = {}
local abc = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

function words.load()
	
	words = {}
	for k, char in chars(abc) do
		words[char] = string.split(require("game/words/"..char.." Words"), '\n')
		print(char.." size: "..#words[char])
	end	
	
end

function words.getRandom( minlength, maxlength )
	
	local char = table.random(table.getKeys(words))
	local chosen = ""
	local iter = 0
	local l = -1
	
	while(chosen == "" or l < minlength or l > maxlength) do
		chosen = table.random(words[char])
		l = string.len(chosen)
		iter = iter + 1
		if (iter > 1000) then return "LUDUM" end
	end
	
	return chosen
	
end

return words