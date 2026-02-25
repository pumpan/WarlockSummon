--==================================================
-- FillRaidBots - Dynamic Settings System (1.12.1)
-- With Headers + Separators
--==================================================

local settingsLoaded = false

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" then
        if arg1 == "FillRaidBots" then
            FillRaidBots_LoadSettings()
        end
    elseif event == "PLAYER_LOGOUT" then
        FillRaidBots_SaveSettings()
    end
end)


--==================================================
-- SETTINGS CONFIG (EDIT THIS ONLY)
--==================================================
function SetLootOption(isFFA, isGroup, isMaster)

    if isFFA then
        SetLootMethod("freeforall")
    elseif isGroup then
        SetLootMethod("group")
    elseif isMaster then
        SetLootMethod("master", UnitName("player"))
    end
end
local SettingsConfig = {

    sections = {

        --------------------------------------------------
        -- MAIN
        --------------------------------------------------
        {
            name = "Main",
            items = {

                {
                    type = "checkbox",
                    key = "isCheckAndRemoveEnabled",
                    label = "Auto Remove Dead Bots",
                    tooltip = "Automatically removes dead bots from raid/party.",
                    default = true,
                    onApply = function(value) 
                        -- Ingen funktion i ditt gamla ApplySavedSettings, bara sparar värdet
                        -- Lägg till om du vill ha live-effekt
                    end
                },

                {
                    type = "checkbox",
                    key = "isBotMessagesEnabled",
                    label = "Suppress Messages",
                    tooltip = "Suppress bot messages.",
                    default = true,
                    onApply = function(value)
                        -- Samma som ovan
                    end
                },
            }
        },

        --------------------------------------------------
        -- FUNCTION
        --------------------------------------------------
        {
            name = "Function",
            items = {

                {
                    type = "checkbox",
                    key = "isClickToFillEnabled",
                    label = "Click-To-Fill",
                    tooltip = "Hold ctrl+alt+click boss to fill raid.",
                    default = true,
                    onApply = function(value) ToggleClickToFill(value) end
                },

                {
                    type = "checkbox",
                    key = "isAutoRepairEnabled",
                    label = "Auto Repair",
                    tooltip = "Automatically repair after resurrection.",
                    default = false,
                    onApply = function(value) ToggleAutoRepair(value) end
                },

                {
                    type = "checkbox",
                    key = "isAutoJoinGuildEnabled",
                    label = "Auto Join Guild",
                    tooltip = "Automatically join the guild.",
                    default = true,
                    onApply = function(value) ToggleAutoJoinGuild(value) end
                },

                {
                    type = "checkbox",
                    key = "isAutoMuteSoundEnabled",
                    label = "Auto Mute Sound",
                    tooltip = "Automatically lower sound while filling raid.",
                    default = true,
                    onApply = function(value) ToggleAutoMuteSound(value) end
                },

                {
                    type = "checkbox",
                    key = "isDailyTipEnabled",
                    label = "Daily Tip",
                    tooltip = "Shows a daily tip.",
                    default = true,
                    onApply = function(value) ToggleDailyTip(value) end
                },
            }
        },

        --------------------------------------------------
        -- BUTTONS
        --------------------------------------------------
        {
            name = "Buttons",
            items = {

                {
                    type = "checkbox",
                    key = "moveButtonsEnabled",
                    label = "Enable moving buttons",
                    tooltip = "Enable moving of fillraid and kick buttons.",
                    default = false,
                    onApply = function(value)
                        ToggleButtonMovement(OpenFillRaidButton)
                    end
                },

                {
                    type = "checkbox",
                    key = "isRefillEnabled",
                    label = "Enable Refill Button",
                    tooltip = "The Refill Button will be available.",
                    default = true,
                    onApply = function()
                        UpdateReFillButtonVisibility()
                    end
                },

                {
                    type = "checkbox",
                    key = "isSmallEnabled",
                    label = "Enable Small Button",
                    tooltip = "Buttons will be small.",
                    default = false,
                    onApply = function(value) ToggleSmallbuttonCheck(value) end
                },
            }
        },

        --------------------------------------------------
        -- LOOT TYPE (RADIO GROUP)
        --------------------------------------------------
        {
            name = "Loot Type",
            items = {

                {
                    type = "radio",
                    group = "lootType",

                    options = {
                        { key = "isFFAEnabled", label = "FFA", default = false },
                        { key = "isGroupLootEnabled", label = "Group", default = true },
                        { key = "isMasterLootEnabled", label = "Master", default = false },
                    },

                    onApply = function(selectedKey)
                        SetLootOption(
                            selectedKey == "isFFAEnabled",
                            selectedKey == "isGroupLootEnabled",
                            selectedKey == "isMasterLootEnabled"
                        )
                    end
                },
            }
        },
    }
}

--==================================================
-- SECTION HEADER + SEPARATOR
--==================================================

local function CreateUISectionHeader(parentFrame, anchorTo, label, offsetX, offsetY)

    local header = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetPoint("TOPLEFT", anchorTo, "TOPLEFT", offsetX or 10, offsetY or -20)
    header:SetText(label)

    local separator = parentFrame:CreateTexture(nil, "ARTWORK")
    separator:SetHeight(2)
    separator:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -2)
    separator:SetPoint("TOPRIGHT", parentFrame, "TOPRIGHT", -10, 0)
    separator:SetTexture("Interface\\Buttons\\WHITE8x8")
    separator:SetVertexColor(1, 1, 1, 0.8)

    return header, separator
end

--==================================================
-- DEFAULT INITIALIZATION
--==================================================

local function InitializeDefaults()

    if not FillRaidBotsSavedSettings then
        FillRaidBotsSavedSettings = {}
    end

    for _, section in ipairs(SettingsConfig.sections) do
        for _, item in ipairs(section.items) do

            if item.type == "checkbox" then

                if FillRaidBotsSavedSettings[item.key] == nil then
                    FillRaidBotsSavedSettings[item.key] = item.default
                end

            elseif item.type == "radio" then

                for _, option in ipairs(item.options) do
                    if FillRaidBotsSavedSettings[option.key] == nil then
                        FillRaidBotsSavedSettings[option.key] = option.default
                    end
                end

            end
        end
    end
end

--==================================================
-- CHECKBUTTON CREATOR (1.12 SAFE)
--==================================================

--==================================================
-- CHECKBUTTON CREATOR (WoW 1.12 SAFE)
--==================================================
local function CreateCheckButton(parent, name, anchor, x, y, label, tooltip, value, onClick)

    local cb = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
    cb:SetWidth(20)
    cb:SetHeight(20)
    cb:SetPoint("TOPLEFT", anchor, "TOPLEFT", x, y)

    -- Textlabel
    cb.text = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cb.text:SetPoint("LEFT", cb, "RIGHT", 5, 0)
    cb.text:SetText(label)

    -- Se till att värdet alltid blir true/false
    cb:SetChecked(value and true or false)

    -- Klickhändelse
    cb:SetScript("OnClick", function()
        -- GetChecked kan returnera 1/nil i 1.12, så konvertera alltid till boolean
        local checked = cb:GetChecked() and true or false

        -- Uppdatera SavedVariables
        if name and FillRaidBotsSavedSettings then
            FillRaidBotsSavedSettings[name] = checked
        end

        -- Kör eventuell callback
        if onClick then
            onClick(checked)
        end
		-- Skriv ut status i chatten
		local status = checked and "|cFF00FF00enabled|r" or "|cFFFF0000disabled|r"
		DEFAULT_CHAT_FRAME:AddMessage((label or name) .. ": " .. status)		
    end)

    -- Tooltip
    cb:SetScript("OnEnter", function()
        if tooltip and tooltip ~= "" then
            GameTooltip:SetOwner(cb, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltip)
            GameTooltip:Show()
        end
    end)

    cb:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return cb
end

--==================================================
-- UI CREATION
--==================================================

function CreateSettingsUI()

    if not FillRaidBotsSavedSettings then
        FillRaidBotsSavedSettings = {}
    end

    local currentY = -20

    for _, section in ipairs(SettingsConfig.sections) do

        --------------------------------------------------
        -- SECTION HEADER
        --------------------------------------------------
        local header, separator = CreateUISectionHeader(
            UISettingsFrame,
            UISettingsFrame,
            section.name,
            10,
            currentY
        )

        currentY = currentY - 30

        --------------------------------------------------
        -- ITEMS
        --------------------------------------------------
        for _, item in ipairs(section.items) do

            --------------------------------------------------
            -- CHECKBOX
            --------------------------------------------------
            if item.type == "checkbox" then

                local currentItem = item  -- 🔥 closure-safe copy
                local key = currentItem.key

                local cb = CreateCheckButton(
                    UISettingsFrame,
                    key,
                    UISettingsFrame,
                    20,
                    currentY,
                    currentItem.label,
                    currentItem.tooltip,
                    FillRaidBotsSavedSettings[key],
                    function(value)

                        FillRaidBotsSavedSettings[key] = value

                        if currentItem.onApply then
                            currentItem.onApply(value)
                        end
                    end
                )

                currentItem.frame = cb
                currentY = currentY - 25


            --------------------------------------------------
            -- RADIO GROUP
            --------------------------------------------------
            elseif item.type == "radio" then

                local currentItem = item  -- 🔥 closure-safe copy
                local startX = 20
                local spacing = 50

				-- Inuti din CreateSettingsUI, där du skapar radio-knapparna
				for i, option in ipairs(currentItem.options) do
					local currentOption = option
					local xPos = startX + (i - 1) * spacing

					-- Label ovanför
					local label = UISettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
					label:SetPoint("TOPLEFT", UISettingsFrame, "TOPLEFT", xPos, currentY)
					label:SetText(currentOption.label)

					-- Checkbox nedanför
					local cb = CreateFrame("CheckButton", nil, UISettingsFrame, "UICheckButtonTemplate")
					cb:SetWidth(20)
					cb:SetHeight(20)
					cb:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 5, -2)

					cb:SetChecked(FillRaidBotsSavedSettings[currentOption.key])

					cb:SetScript("OnClick", function()
						-- Reset hela gruppen
						for _, opt in ipairs(currentItem.options) do
							FillRaidBotsSavedSettings[opt.key] = false
							if opt.frame then
								opt.frame:SetChecked(false)
							end
						end

						-- Markera det valda alternativet
						FillRaidBotsSavedSettings[currentOption.key] = true
						cb:SetChecked(true)

						-- Uppdatera loot-metoden direkt
						SetLootOption(
							FillRaidBotsSavedSettings.isFFAEnabled,
							FillRaidBotsSavedSettings.isGroupLootEnabled,
							FillRaidBotsSavedSettings.isMasterLootEnabled
						)

						-- Chat-feedback
						DEFAULT_CHAT_FRAME:AddMessage(currentOption.label .. ": |cFF00FF00enabled|r")

						-- Kör eventuell callback
						if currentItem.onApply then
							currentItem.onApply(currentOption.key)
						end
					end)

					currentOption.frame = cb
				end

                currentY = currentY - 50
            end
        end

        currentY = currentY - 10
    end
	--==================================================
	-- AUTO-RESIZE UISettingsFrame
	--==================================================

	-- Auto-resize based on currentY
	local topPadding = 10 -- samma som startY
	local bottomPadding = 0

	-- currentY är längst ner efter sista element
	-- Höjden = startY (top padding) minus sista currentY plus bottenpadding
	local totalHeight = topPadding - currentY + bottomPadding
	UISettingsFrame:SetHeight(totalHeight)
end
--==================================================
-- APPLY SETTINGS
--==================================================

local function ApplySavedSettings()
    for _, section in ipairs(SettingsConfig.sections) do
        for _, item in ipairs(section.items) do

            if item.type == "checkbox" then
                local value = FillRaidBotsSavedSettings[item.key]

                -- Update the checkbox UI
                if item.frame then
                    item.frame:SetChecked(value)
                end

                -- Apply saved value
                if item.onApply then
                    item.onApply(value)
                end

            elseif item.type == "radio" then
                local selectedKey = nil

                -- Update radio UI and determine selected
                for _, option in ipairs(item.options) do
                    local checked = FillRaidBotsSavedSettings[option.key]
                    if option.frame then
                        option.frame:SetChecked(checked)
                    end
                    if checked then
                        selectedKey = option.key
                    end
                end

                -- Apply selected radio
                if item.onApply and selectedKey then
                    item.onApply(selectedKey)
                end
            end
        end
    end

    -- Special cases: debugger
    if debuggerFrame then
        if FillRaidBotsSavedSettings.debugMessagesEnabled then
            debuggerFrame:Show()
        else
            debuggerFrame:Hide()
        end
    end

    -- Loot
    SetLootOption(
        FillRaidBotsSavedSettings.isFFAEnabled,
        FillRaidBotsSavedSettings.isGroupLootEnabled,
        FillRaidBotsSavedSettings.isMasterLootEnabled
    )
end
--==================================================
-- LOAD SETTINGS
--==================================================
function FillRaidBots_LoadSettings()

    if not FillRaidBotsSavedSettings then
        FillRaidBotsSavedSettings = {}
    end

    InitializeDefaults()

    if not settingsLoaded then
        settingsLoaded = true
        CreateSettingsUI()
    end

    ApplySavedSettings()
end

--==================================================
-- EVENT HANDLER
--==================================================


