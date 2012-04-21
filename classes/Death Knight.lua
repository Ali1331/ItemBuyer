local _, addonTable = ...
if not addonTable.CLASS then addonTable.CLASS = select(2, UnitClass("player")) end
if addonTable.CLASS ~= "DEATHKNIGHT" then return end
addonTable[addonTable.CLASS] = 
{
	--[[items = {
				["CORPSE DUST"] = {level=56, stack=20, id=37201}
			},]]
	shoppingList = {},
	events = {
				"PLAYER_LEVEL_UP"
			},
	update = function(self, event, ...)
				local lev = arg1 or UnitLevel("player")
				if lev >= 56 then
					addonTable[addonTable.CLASS].shoppingList["CORPSE DUST"] = {level=56, stack=20, id=37201}
					if self then self:UnregisterEvent("PLAYER_LEVEL_UP") end
				end
				--[[
				for i=1, 5, 2 do
					local link = GetGlyphLink(i)
					local id = tonumber(link:find("Raise Dead"))
					if id then
						addonTable[addonTable.CLASS].shoppingList["CORPSE DUST"] = nil
						break
					end
				end
				]]
			end
}
addonTable[addonTable.CLASS].update()