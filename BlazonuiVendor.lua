local ADDON_NAME = ...

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("MERCHANT_SHOW")

local function Print(msg)
	print("|cff33ccffBlazonuiVendor|r: " .. msg)
end

local function InitDB()
	if type(BlazonuiVendorDB) ~= "table" then
		BlazonuiVendorDB = {}
	end
	if BlazonuiVendorDB.autoRepair == nil then
		BlazonuiVendorDB.autoRepair = true
	end
end

local function SellJunk()
	local totalCopper = 0
	local itemsSold = 0

	for bag = 0, NUM_BAG_SLOTS do
		local numSlots = C_Container.GetContainerNumSlots(bag)
		for slot = 1, numSlots do
			local info = C_Container.GetContainerItemInfo(bag, slot)
			if info and info.quality == Enum.ItemQuality.Poor and not info.hasNoValue then
				local _, _, _, _, _, _, _, _, _, _, itemPrice = GetItemInfo(info.itemID)
				if itemPrice and itemPrice > 0 then
					totalCopper = totalCopper + (itemPrice * info.stackCount)
					itemsSold = itemsSold + 1
				end
				C_Container.UseContainerItem(bag, slot)
			end
		end
	end

	if itemsSold > 0 then
		Print(("%d Ramsch-Gegenstände verkauft für %s."):format(itemsSold, GetCoinTextureString(totalCopper)))
	end
end

local function TryAutoRepair()
	if not BlazonuiVendorDB.autoRepair then
		return
	end
	if not CanMerchantRepair() then
		return
	end

	local repairCost, canRepair = GetRepairAllCost()
	if canRepair and repairCost > 0 then
		if GetMoney() >= repairCost then
			RepairAllItems(false)
			Print(("Ausrüstung repariert für %s."):format(GetCoinTextureString(repairCost)))
		else
			Print("Nicht genug Gold zum Reparieren.")
		end
	end
end

frame:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		local loadedAddon = ...
		if loadedAddon == ADDON_NAME then
			InitDB()
		end
	elseif event == "MERCHANT_SHOW" then
		TryAutoRepair()
		SellJunk()
	end
end)

SLASH_BLAZONUIVENDOR1 = "/bv"
SLASH_BLAZONUIVENDOR2 = "/blazonuivendor"
SlashCmdList["BLAZONUIVENDOR"] = function(msg)
	msg = (msg or ""):lower():trim()

	if msg == "repair" then
		BlazonuiVendorDB.autoRepair = not BlazonuiVendorDB.autoRepair
		Print("Auto-Reparieren ist jetzt " .. (BlazonuiVendorDB.autoRepair and "|cff33ff33aktiviert|r" or "|cffff3333deaktiviert|r") .. ".")
	else
		Print("Verkauft automatisch Ramsch beim Händler. Auto-Reparieren: " .. (BlazonuiVendorDB.autoRepair and "an" or "aus") .. ".")
		Print("Befehl: /bv repair — Auto-Reparieren an/aus schalten.")
	end
end
