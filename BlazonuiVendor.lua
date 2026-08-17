local ADDON_NAME = ...

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("MERCHANT_SHOW")

local sessionRepairedCopper = 0
local sessionSoldCopper = 0

local gui

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
	if BlazonuiVendorDB.autoSellJunk == nil then
		BlazonuiVendorDB.autoSellJunk = true
	end
	if BlazonuiVendorDB.minimapAngle == nil then
		BlazonuiVendorDB.minimapAngle = 225
	end
end

local function RefreshGUI()
	if not gui then
		return
	end
	gui.repairCheckbox:SetChecked(BlazonuiVendorDB.autoRepair)
	gui.sellCheckbox:SetChecked(BlazonuiVendorDB.autoSellJunk)
	gui.statsText:SetText(("Diese Session repariert: %s\nRamsch verkauft: %s"):format(
		GetCoinTextureString(sessionRepairedCopper),
		GetCoinTextureString(sessionSoldCopper)
	))
end

local function SellJunk()
	if not BlazonuiVendorDB.autoSellJunk then
		return
	end

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
		sessionSoldCopper = sessionSoldCopper + totalCopper
		RefreshGUI()
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
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			sessionRepairedCopper = sessionRepairedCopper + repairCost
			RefreshGUI()
			Print(("Ausrüstung repariert für %s."):format(GetCoinTextureString(repairCost)))
		else
			Print("Nicht genug Gold zum Reparieren.")
		end
	end
end

local function CreateSettings()
	local category = Settings.RegisterVerticalLayoutCategory("BlazonuiVendor")

	local repairSetting = Settings.RegisterAddOnSetting(category, "BlazonuiVendorAutoRepair", "autoRepair", BlazonuiVendorDB, Settings.VarType.Boolean, "Auto-Reparieren", true)
	Settings.CreateCheckbox(category, repairSetting, "Repariert deine Ausrüstung automatisch beim Händler (nur mit eigenem Gold, nie über die Gildenbank).")

	local sellSetting = Settings.RegisterAddOnSetting(category, "BlazonuiVendorAutoSellJunk", "autoSellJunk", BlazonuiVendorDB, Settings.VarType.Boolean, "Ramsch automatisch verkaufen", true)
	Settings.CreateCheckbox(category, sellSetting, "Verkauft graue (minderwertige) Gegenstände automatisch beim Händler.")

	Settings.RegisterAddOnCategory(category)
end

local function CreateCheckboxRow(parent, label, yOffset, onClick)
	local checkbox = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
	checkbox:SetPoint("TOPLEFT", 16, yOffset)
	checkbox:SetScript("OnClick", function(self)
		onClick(self:GetChecked())
	end)

	local text = checkbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	text:SetPoint("LEFT", checkbox, "RIGHT", 4, 0)
	text:SetText(label)

	return checkbox
end

local function CreateGUI()
	local f = CreateFrame("Frame", "BlazonuiVendorFrame", UIParent, "BackdropTemplate")
	f:SetSize(260, 190)
	f:SetPoint("CENTER")
	f:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	f:SetBackdropColor(0, 0, 0, 0.9)
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	f:SetClampedToScreen(true)
	f:Hide()
	tinsert(UISpecialFrames, "BlazonuiVendorFrame")

	local title = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOP", 0, -14)
	title:SetText("|cff33ccffBlazonuiVendor|r")

	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -4)

	f.repairCheckbox = CreateCheckboxRow(f, "Auto-Reparieren", -50, function(checked)
		BlazonuiVendorDB.autoRepair = checked
	end)

	f.sellCheckbox = CreateCheckboxRow(f, "Ramsch automatisch verkaufen", -80, function(checked)
		BlazonuiVendorDB.autoSellJunk = checked
	end)

	local statsHeader = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	statsHeader:SetPoint("TOPLEFT", 16, -115)
	statsHeader:SetText("|cffffd100Statistik|r")

	f.statsText = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	f.statsText:SetPoint("TOPLEFT", 16, -132)
	f.statsText:SetJustifyH("LEFT")

	return f
end

local function ToggleGUI()
	if not gui then
		gui = CreateGUI()
	end
	if gui:IsShown() then
		gui:Hide()
	else
		RefreshGUI()
		gui:Show()
	end
end

local function UpdateMinimapButtonPosition(button)
	local angle = math.rad(BlazonuiVendorDB.minimapAngle)
	local radius = 80
	button:ClearAllPoints()
	button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

local function CreateMinimapButton()
	local button = CreateFrame("Button", "BlazonuiVendorMinimapButton", Minimap)
	button:SetSize(31, 31)
	button:SetFrameStrata("MEDIUM")
	button:SetFrameLevel(8)
	button:RegisterForClicks("LeftButtonUp")
	button:RegisterForDrag("LeftButton")

	local icon = button:CreateTexture(nil, "BACKGROUND")
	icon:SetTexture("Interface/Icons/INV_Misc_Coin_02")
	icon:SetSize(20, 20)
	icon:SetPoint("CENTER", 0, 0)

	local border = button:CreateTexture(nil, "OVERLAY")
	border:SetTexture("Interface/Minimap/MiniMap-TrackingBorder")
	border:SetSize(54, 54)
	border:SetPoint("TOPLEFT")

	button:SetScript("OnDragStart", function(self)
		self:SetScript("OnUpdate", function()
			local mx, my = Minimap:GetCenter()
			local cx, cy = GetCursorPosition()
			local scale = Minimap:GetEffectiveScale()
			cx, cy = cx / scale, cy / scale
			BlazonuiVendorDB.minimapAngle = math.deg(math.atan2(cy - my, cx - mx))
			UpdateMinimapButtonPosition(self)
		end)
	end)
	button:SetScript("OnDragStop", function(self)
		self:SetScript("OnUpdate", nil)
	end)

	button:SetScript("OnClick", ToggleGUI)
	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText("BlazonuiVendor")
		GameTooltip:AddLine("Klicken zum Öffnen der Einstellungen.", 1, 1, 1)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", GameTooltip_Hide)

	UpdateMinimapButtonPosition(button)
end

frame:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		local loadedAddon = ...
		if loadedAddon == ADDON_NAME then
			InitDB()
			CreateSettings()
			CreateMinimapButton()
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
		RefreshGUI()
		Print("Auto-Reparieren ist jetzt " .. (BlazonuiVendorDB.autoRepair and "|cff33ff33aktiviert|r" or "|cffff3333deaktiviert|r") .. ".")
	elseif msg == "sell" then
		BlazonuiVendorDB.autoSellJunk = not BlazonuiVendorDB.autoSellJunk
		RefreshGUI()
		Print("Ramsch-Verkauf ist jetzt " .. (BlazonuiVendorDB.autoSellJunk and "|cff33ff33aktiviert|r" or "|cffff3333deaktiviert|r") .. ".")
	else
		ToggleGUI()
	end
end
