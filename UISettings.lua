--========================
-- FillRaidBots Settings
--========================

local settingsLoaded = false

--========================
-- Event Handling
--========================
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" then
        FillRaidBots_LoadSettings()
    elseif event == "PLAYER_LOGOUT" then
        FillRaidBots_SaveSettings()
    end
end)



--========================
-- Save Settings
--========================
function FillRaidBots_SaveSettings()
    local checkboxes = {
        {frame = ToggleCheckAndRemoveCheckButton, key = "isCheckAndRemoveEnabled"},
        {frame = BotMessagesCheckButton, key = "isBotMessagesEnabled"},
        {frame = DebugMessagesCheckButton, key = "debugMessagesEnabled"},
        {frame = moveButtonsCheckButton, key = "moveButtonsEnabled"},
        {frame = RefillButtonCheckButton, key = "isRefillEnabled"},
        {frame = SmallButtonCheckButton, key = "isSmallEnabled"},
        {frame = AutoFFACheckButton, key = "isFFAEnabled"},
        {frame = AutoGroupLootCheckButton, key = "isGroupLootEnabled"},
        {frame = AutoMasterLootCheckButton, key = "isMasterLootEnabled"},
        {frame = ClickToFillCheckButton, key = "isClickToFillEnabled"},
        {frame = AutoRepairCheckButton, key = "isAutoRepairEnabled"},
        {frame = AutoJoinGuildCheckButton, key = "isAutoJoinGuildEnabled"},
        {frame = AutoMuteSoundCheckButton, key = "isAutoMuteSoundEnabled"},
		{frame = DailyTipCheckButton, key = "isDailyTipEnabled"},
    }
    for _, cb in ipairs(checkboxes) do
        if cb.frame then
            FillRaidBotsSavedSettings[cb.key] = cb.frame:GetChecked() and true or false
        end
    end
end

--========================
-- UI Helpers
--========================
local function CreateUISectionHeader(parentFrame, anchorTo, label, offsetX, offsetY)
    local header = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetPoint("TOPLEFT", anchorTo, "TOPLEFT", offsetX or 0, offsetY or -20)
    header:SetText(label)

    local separator = parentFrame:CreateTexture(nil, "ARTWORK")
    separator:SetHeight(2)
    separator:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -2)
    separator:SetPoint("TOPRIGHT", parentFrame, "TOPRIGHT", -10, 0)
    separator:SetTexture("Interface\\Buttons\\WHITE8x8")
    separator:SetVertexColor(1, 1, 1, 0.8)

    return header, separator
end

local function CreateCheckButton(parent, name, anchor, xOffset, yOffset, label, tooltipText, initialValue, onClickFunc)
    local checkButton = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
    checkButton:SetHeight(20)
	checkButton:SetWidth(20)
    checkButton:SetPoint("TOPLEFT", anchor, "TOPLEFT", xOffset or 0, yOffset or -20)

    checkButton.text = checkButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    checkButton.text:SetPoint("LEFT", checkButton, "RIGHT", 5, 0)
    checkButton.text:SetText(label)

    checkButton:SetChecked(initialValue)
    checkButton:SetScript("OnClick", function(self)
        local isChecked = this:GetChecked()
        onClickFunc(isChecked)
        local status = isChecked and "|cFF00FF00enabled|r" or "|cFFFF0000disabled|r"
        DEFAULT_CHAT_FRAME:AddMessage(label .. ": " .. status)
    end)

    checkButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(checkButton, "ANCHOR_RIGHT")
        GameTooltip:SetText(tooltipText)
        GameTooltip:Show()
    end)
    checkButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return checkButton
end

--========================
-- Loot Helper
--========================
local function SetLootOption(ffa, group, master)
    AutoFFACheckButton:SetChecked(ffa)
    AutoGroupLootCheckButton:SetChecked(group)
    AutoMasterLootCheckButton:SetChecked(master)
end

--========================
-- Create Settings UI
--========================
function CreateToggleCheckButton()
    local yOffset = -20 -- start Y offset

    -- ========================
    -- Main Section
    -- ========================
    local mainHeader, mainSeparator = CreateUISectionHeader(UISettingsFrame, UISettingsFrame, "Main", 10, yOffset)

    ToggleCheckAndRemoveCheckButton = CreateCheckButton(
        UISettingsFrame, "ToggleCheckAndRemoveCheckButton", mainSeparator, 0, -10,
        "Auto Remove Dead Bots",
        "Automatically removes dead bots from raid/party.",
        FillRaidBotsSavedSettings.isCheckAndRemoveEnabled,
        function(isChecked) FillRaidBotsSavedSettings.isCheckAndRemoveEnabled = isChecked end
    )

    BotMessagesCheckButton = CreateCheckButton(
        UISettingsFrame, "BotMessagesCheckButton", ToggleCheckAndRemoveCheckButton, 0, -20,
        "Suppress Messages",
        "Suppress bot messages.",
        FillRaidBotsSavedSettings.isBotMessagesEnabled,
        function(isChecked)
            FillRaidBotsSavedSettings.isBotMessagesEnabled = isChecked
            if isChecked then SuppressEditorButton:Enable() else SuppressEditorButton:Disable() end
        end
    )

    -- Suppress Editor Button
    SuppressEditorButton = CreateFrame("Button", nil, UISettingsFrame, "GameMenuButtonTemplate")
    SuppressEditorButton:SetWidth(80)
    SuppressEditorButton:SetHeight(20)
    SuppressEditorButton:SetPoint("TOPLEFT", BotMessagesCheckButton, "TOPLEFT", 0, -20)
    SuppressEditorButton:SetText("Suppress")
    SuppressEditorButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(SuppressEditorButton, "ANCHOR_RIGHT")
        GameTooltip:SetText("Add/Edit Messages to be Suppressed")
        GameTooltip:Show()
    end)
    SuppressEditorButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
    SuppressEditorButton:SetScript("OnClick", function()
        if SuppressEditor:IsShown() then SuppressEditor:Hide() else RefreshSuppressList() SuppressEditor:Show() end
    end)
    if FillRaidBotsSavedSettings.isBotMessagesEnabled then
        SuppressEditorButton:Enable() else SuppressEditorButton:Disable()
    end

    -- ========================
    -- Function Section
    -- ========================
    ClickToFillCheckButton = CreateCheckButton(
        UISettingsFrame, "ClickToFillCheckButton", SuppressEditorButton, 0, -20,
        "Click-To-Fill",
        "Hold ctrl+alt+click boss to fill raid.",
        FillRaidBotsSavedSettings.isClickToFillEnabled,
        function(isChecked) ToggleClickToFill(isChecked) end
    )

    AutoRepairCheckButton = CreateCheckButton(
        UISettingsFrame, "AutoRepairCheckButton", ClickToFillCheckButton, 0, -20,
        "Auto Repair",
        "Automatically repair after resurrection. VIP only.",
        FillRaidBotsSavedSettings.isAutoRepairEnabled,
        function(isChecked) ToggleAutoRepair(isChecked) end
    )

    AutoJoinGuildCheckButton = CreateCheckButton(
        UISettingsFrame, "AutoJoinGuildCheckButton", AutoRepairCheckButton, 0, -20,
        "Auto Join Guild",
        "Automatically join the SoloCraft guild.",
        FillRaidBotsSavedSettings.isAutoJoinGuildEnabled,
        function(isChecked) ToggleAutoJoinGuild(isChecked) end
    )

    AutoMuteSoundCheckButton = CreateCheckButton(
        UISettingsFrame, "AutoMuteSoundCheckButton", AutoJoinGuildCheckButton, 0, -20,
        "Auto Mute Sound",
        "Automatically lower sound while filling raid.",
        FillRaidBotsSavedSettings.isAutoMuteSoundEnabled,
        function(isChecked) ToggleAutoMuteSound(isChecked) end
    )
    DailyTipCheckButton = CreateCheckButton(
        UISettingsFrame, "DailyTipCheckButton", AutoMuteSoundCheckButton, 0, -20,
        "Daily tip",
        "Shows a daily tip.",
        FillRaidBotsSavedSettings.isDailyTipEnabled,
        function(isChecked) ToggleDailyTip(isChecked) end
    )
    -- ========================
    -- Buttons Section
    -- ========================
    local ButtonsHeader = CreateUISectionHeader(UISettingsFrame, DailyTipCheckButton, "Buttons", 0, -25)

    moveButtonsCheckButton = CreateCheckButton(
        UISettingsFrame, "moveButtonsCheckButton", ButtonsHeader, 0, -20,
        "Enable moving buttons",
        "Enable moving of fillraid and kick all buttons.",
        FillRaidBotsSavedSettings.moveButtonsEnabled,
        function(isChecked) ToggleButtonMovement(OpenFillRaidButton) end
    )

    RefillButtonCheckButton = CreateCheckButton(
        UISettingsFrame, "RefillButtonCheckButton", moveButtonsCheckButton, 0, -20,
        "Enable Refill Button",
        "The Refill Button will be available.",
        FillRaidBotsSavedSettings.isRefillEnabled,
        function(isChecked) UpdateReFillButtonVisibility() end
    )

    SmallButtonCheckButton = CreateCheckButton(
        UISettingsFrame, "SmallButtonCheckButton", RefillButtonCheckButton, 0, -20,
        "Enable Small Button",
        "The buttons will be small.",
        FillRaidBotsSavedSettings.isSmallEnabled,
        function(isChecked) ToggleSmallbuttonCheck(isChecked) end
    )


    -- ========================
    -- Loot Section
    -- ========================
    local LootHeader = CreateUISectionHeader(UISettingsFrame, SmallButtonCheckButton, "Loot Type", 0, -20)

	-- Start X-offset för första checkboxen
	local startX = 10
	local spacingX = 50 -- hur långt mellan varje checkbox

	AutoFFACheckButton = CreateCheckButton(
		UISettingsFrame, "AutoFFACheckButton", LootHeader, startX, -25,
		"FFA",
		"Puts FFA automatically on raid creation",
		FillRaidBotsSavedSettings.isFFAEnabled,
		function() SetLootOption(true, false, false) DEFAULT_CHAT_FRAME:AddMessage("Loot Method set to |cFF00FF00Free-for-All|r") end
	)

	AutoGroupLootCheckButton = CreateCheckButton(
		UISettingsFrame, "AutoGroupLootCheckButton", LootHeader, startX + spacingX, -25,
		"Group",
		"Puts Group loot automatically on raid creation",
		FillRaidBotsSavedSettings.isGroupLootEnabled,
		function() SetLootOption(false, true, false) DEFAULT_CHAT_FRAME:AddMessage("Loot Method set to |cFF00FF00Group Loot|r") end
	)

	AutoMasterLootCheckButton = CreateCheckButton(
		UISettingsFrame, "AutoMasterLootCheckButton", LootHeader, startX + 2 * spacingX, -25,
		"Master",
		"Puts Master loot automatically on raid creation",
		FillRaidBotsSavedSettings.isMasterLootEnabled,
		function() SetLootOption(false, false, true) DEFAULT_CHAT_FRAME:AddMessage("Loot Method set to |cFF00FF00Master Loot|r") end
	)

    DebugMessagesCheckButton = CreateCheckButton(
        UISettingsFrame, "DebugMessagesCheckButton", AutoMasterLootCheckButton, 0, -25,
        "Debug",
        "Debug messages will be shown.",
        FillRaidBotsSavedSettings.debugMessagesEnabled,
        function(isChecked) if isChecked then debuggerFrame:Show() else debuggerFrame:Hide() end end
    )
end

--========================
-- Apply Saved Settings
--========================
local function ApplySavedSettings()
    if FillRaidBotsSavedSettings.isSmallEnabled then
        ToggleSmallbuttonCheck(true)
    end

    if FillRaidBotsSavedSettings.moveButtonsEnabled then
        ToggleButtonMovement(OpenFillRaidButton)
    end

    if FillRaidBotsSavedSettings.isRefillEnabled then
        UpdateReFillButtonVisibility()
    end

    if FillRaidBotsSavedSettings.isClickToFillEnabled then
        ToggleClickToFill(true)
    end

    if FillRaidBotsSavedSettings.isAutoRepairEnabled then
        ToggleAutoRepair(true)
    end

    if FillRaidBotsSavedSettings.isAutoJoinGuildEnabled then
        ToggleAutoJoinGuild(true)
    end

    if FillRaidBotsSavedSettings.isAutoMuteSoundEnabled then
        ToggleAutoMuteSound(true)
    end

    if FillRaidBotsSavedSettings.isDailyTipEnabled then
        ToggleDailyTip(true)
    end

    if FillRaidBotsSavedSettings.debugMessagesEnabled then
        debuggerFrame:Show()
    else
        debuggerFrame:Hide()
    end

    -- Loot
    SetLootOption(
        FillRaidBotsSavedSettings.isFFAEnabled,
        FillRaidBotsSavedSettings.isGroupLootEnabled,
        FillRaidBotsSavedSettings.isMasterLootEnabled
    )
end

--========================
-- Load Settings
--========================
function FillRaidBots_LoadSettings()
    if settingsLoaded then return end
    settingsLoaded = true

    -- Se till att tabellen alltid finns
    if not FillRaidBotsSavedSettings then FillRaidBotsSavedSettings = {} end

    -- Standardvärden
    local defaults = {
        isCheckAndRemoveEnabled = true,
        isBotMessagesEnabled = true,
        debugMessagesEnabled = false,
        moveButtonsEnabled = false,
        isRefillEnabled = true,
        isSmallEnabled = false,
        isClickToFillEnabled = true,
        isAutoRepairEnabled = false,
        isAutoJoinGuildEnabled = true,
        isAutoMuteSoundEnabled = true,
        isAutoDailyTipEnabled = true,		
        isFFAEnabled = false,
        isGroupLootEnabled = true,
        isMasterLootEnabled = false,
    }

    for k, v in pairs(defaults) do
        if FillRaidBotsSavedSettings[k] == nil then
            FillRaidBotsSavedSettings[k] = v
        end
    end

    -- Skapa UI
    CreateToggleCheckButton()
    InitializeButtonPosition()
    ToggleButtonMovement(OpenFillRaidButton)

    -- Apply alla inställningar
    ApplySavedSettings()

    -- Sätt checkboxes korrekt
    DebugMessagesCheckButton:SetChecked(FillRaidBotsSavedSettings.debugMessagesEnabled)
    ToggleCheckAndRemoveCheckButton:SetChecked(FillRaidBotsSavedSettings.isCheckAndRemoveEnabled)
end