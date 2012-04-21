local _, addonTable = ...
if not addonTable.CLASS then addonTable.CLASS = select(2, UnitClass("player")) end
if addonTable.CLASS ~= "ROGUE" then return end
addonTable[addonTable.CLASS] = 
{
	items = {
				{name = "CRIPPLING", level=20, id=3775},
				{name = "DEADLY", level=30, id=2892},
				{name = "INSTANT", level=10, id=6947},
				{name = "MIND-NUMBING", level=24, id=5237},
				{name = "WOUND", level=78, level=32, id=10918}
			},
	shoppingList = {},
	events = {
				"PLAYER_LEVEL_UP"
			},
	update = function(self, event, ...)
				local lev = arg1 or UnitLevel("player")
				for i, j in ipairs(addonTable[addonTable.CLASS].items) do
					if j ~= true then
						--[[for k, l in ipairs(j.items) do
							if lev >= l.level then
								addonTable[addonTable.CLASS].shoppingList[j.name] = l
								addonTable[addonTable.CLASS].shoppingList[j.name].stack = 20
								if k == 1 then
									addonTable[addonTable.CLASS].items[i] = true
								end
								break
							end
						end]]
						
						if addonTable[addonTable.CLASS].shoppingList[j.name] == nil then
							if lev >= j.level then
								addonTable[addonTable.CLASS].shoppingList[j.name] = j
								addonTable[addonTable.CLASS].shoppingList[j.name].stack = 20
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