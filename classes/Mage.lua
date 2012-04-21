local _, addonTable = ...
if not addonTable.CLASS then addonTable.CLASS = select(2, UnitClass("player")) end
if addonTable.CLASS ~= "MAGE" then return end
addonTable[addonTable.CLASS] = 
{
	items = {
				{name = "RUNE OF TELEPORTATION", level=20, stack=20, id=17031},
				{name = "RUNE OF PORTALS", level=35, stack=20, id=17032},
				{name = "ARCANE POWDER", level=56, stack=100, id=17020}
			},
	shoppingList = {},
	events = {
				"PLAYER_LEVEL_UP"
			},
	update = function(self, event, ...)
				local lev = arg1 or UnitLevel("player")
				for i, j in ipairs(addonTable[addonTable.CLASS].items) do
					if j ~= true then
						if addonTable[addonTable.CLASS].shoppingList[j.name] == nil then
							if lev >= j.level then
								addonTable[addonTable.CLASS].shoppingList[j.name] = j
								addonTable[addonTable.CLASS].shoppingList[j.name].name = nil
								addonTable[addonTable.CLASS].items[i] = true
							else
								break
							end
						end
					end
				end
			end
}
addonTable[addonTable.CLASS].update()