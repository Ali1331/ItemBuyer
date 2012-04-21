local _, addonTable = ...
local CLASS = addonTable.CLASS
if not CLASS or not addonTable[CLASS] then return end

local ItemBuyer = CreateFrame("Frame")
local working = false
ItemBuyer:RegisterEvent("ADDON_LOADED")
ItemBuyer:RegisterEvent("MERCHANT_SHOW")
local Items = addonTable[CLASS].shoppingList
if addonTable[CLASS].events then
	for i=1, #addonTable[CLASS].events do
		ItemBuyer:RegisterEvent(addonTable[CLASS].events[i])
	end
end

function ItemBuyer:GetNumEmptySlots()
	local baglist = {}
	for i=1, NUM_BAG_SLOTS do
		local itemlink = GetInventoryItemLink("player",ContainerIDToInventoryID(i))
		if itemlink ~= nil then
			if select(7, GetItemInfo(itemlink)) == "Bag" then
				table.insert(baglist, i)
			end
		end
	end
	local freeslots = GetContainerNumFreeSlots(0)
	for i=1, #baglist do
		freeslots = freeslots+GetContainerNumFreeSlots(baglist[i])
	end
	return freeslots
end

function ItemBuyer:GetStackInfo(itemID)
	local tab = {}
	for i=0, 4 do
		for k=1, GetContainerNumSlots(i) do
			local link = GetContainerItemLink(i, k)
			if link and tonumber(string.match(link, "item:(%d+):")) == itemID then
				table.insert(tab, (select(2, GetContainerItemInfo(i, k))))
			end
		end
	end
	return tab
end

local cd = 0
function ItemBuyer:StartCD()
	if not working then return end
	cd = 0
	self:SetScript("OnUpdate", function(self, elapsed)
		cd = cd + elapsed
		if cd > 5 then
			cd = 0
			working = false
			self:SetScript("OnUpdate", nil)
		end
	end)
end

function ItemBuyer:PurchasableCount(vendorID, amount, buy)
	local cost = select(3, GetMerchantItemInfo(vendorID))
	local money = GetMoney()
	local count, missing = 0, 0
	if money < (amount*cost) then
		count = floor(money/cost)
		missing = ((amount-count)*cost)-money
	else
		count = amount
		missing = 0
	end
	if buy == 1 and count > 0 then
		BuyMerchantItem(vendorID, count)
	end
	return count, missing
end

ItemBuyer:SetScript("OnEvent", function(self, event, ...)
	if event == "MERCHANT_SHOW" and working == false then
		working = true
		local emptySlots = ItemBuyer:GetNumEmptySlots()
		local total = 0
		local notBought = 0
		local moneyMissing = {}
		local thisIndex = false
		for i=1, GetMerchantNumItems() do	
			local itemLink = GetMerchantItemLink(i)
			local itemID = itemLink and tonumber(string.match(itemLink, "item:(%d+):"))
			if itemID then
				local index = nil
				for k, l in pairs(Items) do
 					if l.id == itemID then
						index = k
						break
					end
				end
				if index then
					local reqLvl = Items[index].merchantSize and ItemBuyerDB[CLASS][index]-ceil(GetItemCount(itemID)/Items[index].merchantSize) or ItemBuyerDB[CLASS][index]-GetItemCount(itemID)
					local invStacks = ItemBuyer:GetStackInfo(itemID)
					if Items[index].merchantSize then
						for i, j in pairs(invStacks) do
							invStacks[i] = ceil(j/Items[index].merchantSize)
						end
					end
					local bought, missing
					moneyMissing = 0
					thisIndex = false
					if reqLvl > 0 then
						for j=1, #invStacks do
							local spare = (Items[index].stack-invStacks[j])
							if reqLvl >= spare then
								if spare ~= 0 then
									bought, missing = ItemBuyer:PurchasableCount(i, spare, 1)
									reqLvl = reqLvl - bought
									total = total + bought
									notBought = notBought + (spare-bought)
									if missing > 0 then 
										thisIndex = true 
									end
									moneyMissing = moneyMissing + missing
								end
							else
								bought, missing = ItemBuyer:PurchasableCount(i, reqLvl, 1)
								reqLvl = reqLvl - bought
								total = total + bought
								notBought = notBought + (reqLvl-bought)
								if missing > 0 then 
									thisIndex = true 
								end								
								moneyMissing = moneyMissing + missing
							end
						end
						if reqLvl > 0 and thisIndex == false then
							while reqLvl >= Items[index].stack do
								if emptySlots > 0 then
									bought, missing = ItemBuyer:PurchasableCount(i, Items[index].stack, 1)
									total = total + bought
									reqLvl = reqLvl - bought
									notBought = notBought + (Items[index].stack-bought)
									if missing > 0 then 
										thisIndex = true 
									end									
									moneyMissing = moneyMissing + missing
									if bought ~= 0 then
										emptySlots = emptySlots - 1
									end
								else
									break
								end
							end
							if reqLvl > 0 and thisIndex == false then
								if emptySlots > 0 then
									bought, missing = ItemBuyer:PurchasableCount(i, reqLvl, 1)
									total = total + bought
									reqLvl = reqLvl - bought
									notBought = notBought + (reqLvl-bought)
									moneyMissing = moneyMissing + missing
									if bought ~= 0 then
										emptySlots = emptySlots - 1
									end
								else
									bought, missing  = ItemBuyer:PurchasableCount(i, reqLvl, 0)
									moneyMissing = moneyMissing + missing
									notBought = notBought + reqLvl
								end
							end
						end
					end
				end
			end
		end
		local line = ""
		if total > 0 then
			line = line..total.." item(s) bought."
		end
		if notBought > 0 then
			line = line.." "..notBought.." item(s) were not bought. The purchase(s) required "
			if emptySlots == 0 then
				line = line.."additional inventory space(s)."
			else
				line = line..GoldFormat(moneyMissing).." more."
			end
		end
		ItemBuyer:Msg(line)
		ItemBuyer:StartCD()
	elseif event == "ADDON_LOADED" then
		if arg1 == "ItemBuyer" then
			ItemBuyerDB = ItemBuyerDB or {}
			if not ItemBuyerDB[CLASS] then
				ItemBuyerDB[CLASS] = {}
			end
			for i, j in pairs(Items) do
				if not ItemBuyerDB[CLASS][i] then
					ItemBuyerDB[CLASS][i] = j.stack
				end
			end
			ItemBuyer:UnregisterEvent("ADDON_LOADED")
		end
	else
		addonTable[CLASS].update(self, event, ...)
	end 
end)

function ItemBuyer:Msg(text) 
	if text:len() ~= 0 then 
		DEFAULT_CHAT_FRAME:AddMessage("ItemBuyer: "..text, RAID_CLASS_COLORS[CLASS].r, RAID_CLASS_COLORS[CLASS].g, RAID_CLASS_COLORS[CLASS].b) 
	end 
end
 
SLASH_ITEMBUYER1 = "/itembuyer"
SLASH_ITEMBUYER2 = "/ib"
SlashCmdList["ITEMBUYER"] = function(cmd)
	if string.len(cmd) == 0 then
		ItemBuyer:Msg("No item name given")
		ItemBuyer:Msg("Usage /item or /itembuyer <Item Name> <Buy level>")
	else
		cmd = strrev(cmd)
		local level, name = strsplit(" ", cmd, 2)
		if not name or not level then
			ItemBuyer:Msg("Usage /item or /itembuyer <Item Name> <Buy level>")
			return
		end
		name = strupper(strrev(name))
		level = tonumber(strrev(level))
		if not name or not level then
			ItemBuyer:Msg("Usage /item or /itembuyer <Item Name> <Buy level>")
			return
		end
		if level < 0 then
			ItemBuyer:Msg("Buy level must be zero or above")
			return
		end
		for i, k in pairs(Items) do
			if name == i then
				ItemBuyerDB[CLASS][i] = level
				ItemBuyer:Msg("|cff3FFF00"..i.."|r buy level set to |cff3FFF00"..level.."|r")
				return 
			end
		end
		ItemBuyer:Msg("Incorrect item name given")
	end
end
