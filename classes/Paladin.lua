local _, addonTable = ...
if not addonTable.CLASS then addonTable.CLASS = select(2, UnitClass("player")) end
if addonTable.CLASS ~= "PALADIN" then return end
addonTable[addonTable.CLASS] = 
{
	items = {
				{name = "SYMBOL OF DIVINITY", level=30, stack=5, id=17033},
				{name = "SYMBOL OF KINGS", level=52, merchantSize = 20, stack=5, id=21177}
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