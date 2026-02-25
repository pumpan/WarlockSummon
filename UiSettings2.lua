--==================================================
-- FillRaidBots - Dynamic Settings System (1.12.1)
-- With Headers + Separators
--==================================================

local settingsLoaded = false

--==================================================
-- SETTINGS CONFIG (EDIT THIS ONLY)
--==================================================

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
                },

                {
                    type = "checkbox",
                    key = "isBotMessagesEnabled",
                    label = "Suppress Messages",
                    tooltip = "Suppress bot messages.",
                    default = true,
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
                    onApply = ToggleClickToFill
                },

                {
                    type = "checkbox",
                    key = "isAutoRepairEnabled",
                    label = "Auto Repair",
                    tooltip = "Automatically repair after resurrection.",
                    default = false,
                    onApply = ToggleAutoRepair
                },

                {
                    type = "checkbox",
                    key = "isAutoJoinGuildEnabled",
                    label = "Auto Join Guild",
                    tooltip = "Automatically join the guild.",
                    default = true,
                    onApply = ToggleAutoJoinGuild
                },

                {
                    type = "checkbox",
                    key = "isAutoMuteSoundEnabled",
                    label = "Auto Mute Sound",
                    tooltip = "Automatically lower sound while filling raid.",
                    default = true,
                    onApply = ToggleAutoMuteSound
                },

                {
                    type = "checkbox",
                    key = "isDailyTipEnabled",
                    label = "Daily Tip",
                    tooltip = "Shows a daily tip.",
                    default = true,
                    onApply = ToggleDailyTip
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
                    onApply = function()
                        ToggleButtonMovement(OpenFillRaidButton)
                    end
                },

                {
                    type = "checkbox",
                    key = "isRefillEnabled",
                    label = "Enable Refill Button",
                    tooltip = "The Refill Button will be available.",
                    default = true,
                    onApply = UpdateReFillButtonVisibility
                },

                {
                    type = "checkbox",
                    key = "isSmallEnabled",
                    label = "Enable Small Button",
                    tooltip = "Buttons will be small.",
                    default = false,
                    onApply = ToggleSmallbuttonCheck
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

local function CreateCheckButton(parent, name, anchor, x, y, label, tooltip, value, onClick)

    local cb = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
    cb:SetWidth(20)
    cb:SetHeight(20)
    cb:SetPoint("TOPLEFT", anchor, "TOPLEFT", x, y)

    cb.text = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cb.text:SetPoint("LEFT", cb, "RIGHT", 5, 0)
    cb.text:SetText(label)

    cb:SetChecked(value)

    cb:SetScript("OnClick", function()
        local checked = this:GetChecked()
        if onClick then
            onClick(checked)
        end
    end)

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

    local anchor = UISettingsFrame
    local yOffset = -20

    for _, section in ipairs(SettingsConfig.sections) do

        local header, separator = CreateUISectionHeader(
            UISettingsFrame,
            anchor,
            section.name,
            10,
            yOffset
        )

        anchor = separator
        yOffset = -15

        for _, item in ipairs(section.items) do

            if item.type == "checkbox" then

                local cb = CreateCheckButton(
                    UISettingsFrame,
                    item.key,
                    anchor,
                    10,
                    yOffset,
                    item.label,
                    item.tooltip,
                    FillRaidBotsSavedSettings[item.key],
                    function(value)

                        FillRaidBotsSavedSettings[item.key] = value

                        if item.onApply then
                            item.onApply(value)
                        end
                    end
                )

                item.frame = cb
                anchor = cb
                yOffset = -20

            elseif item.type == "radio" then

                local startX = 10
                local spacing = 70

                for i, option in ipairs(item.options) do

                    local cb = CreateCheckButton(
                        UISettingsFrame,
                        option.key,
                        anchor,
                        startX + (i - 1) * spacing,
                        yOffset,
                        option.label,
                        "",
                        FillRaidBotsSavedSettings[option.key],
                        function()

                            for _, opt in ipairs(item.options) do
                                FillRaidBotsSavedSettings[opt.key] = false
                                if opt.frame then
                                    opt.frame:SetChecked(false)
                                end
                            end

                            FillRaidBotsSavedSettings[option.key] = true
                            option.frame:SetChecked(true)

                            if item.onApply then
                                item.onApply(option.key)
                            end
                        end
                    )

                    option.frame = cb
                end

                anchor = item.options[1].frame
                yOffset = -30
            end
        end

        yOffset = yOffset - 10
    end
end

--==================================================
-- APPLY SETTINGS
--==================================================

local function ApplySavedSettings()

    for _, section in ipairs(SettingsConfig.sections) do
        for _, item in ipairs(section.items) do

            if item.type == "checkbox" then

                local value = FillRaidBotsSavedSettings[item.key]

                if item.frame then
                    item.frame:SetChecked(value)
                end

                if item.onApply then
                    item.onApply(value)
                end

            elseif item.type == "radio" then

                for _, option in ipairs(item.options) do
                    if option.frame then
                        option.frame:SetChecked(
                            FillRaidBotsSavedSettings[option.key]
                        )
                    end
                end

                if item.onApply then
                    for _, option in ipairs(item.options) do
                        if FillRaidBotsSavedSettings[option.key] then
                            item.onApply(option.key)
                        end
                    end
                end
            end
        end
    end
end

--==================================================
-- LOAD SETTINGS
--==================================================

function FillRaidBots_LoadSettings()

    if settingsLoaded then return end
    settingsLoaded = true

    InitializeDefaults()
    CreateSettingsUI()
    ApplySavedSettings()
end

--==================================================
-- EVENT HANDLER
--==================================================

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" then
        FillRaidBots_LoadSettings()
    end
end)
