--==================================================
-- FillRaidBots - Dynamic Settings System (1.12.1)
-- With Headers + Separators
--==================================================

local settingsLoaded = false

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "FillRaidBots" then
            FillRaidBots_LoadSettings()
        end
    elseif event == "PLAYER_LOGOUT" then
        FillRaidBots_SaveSettings()
    end
end)


--==================================================
-- SETTINGS CONFIG (EDIT self ONLY)
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

local ADDON_PATH = "Interface\\AddOns\\FillRaidBots\\"
local IMG_PATH = ADDON_PATH.."img\\"
local HIGHLIGHT = "Interface\\Buttons\\UI-Common-MouseHilight"
local function CreateThemeButtons(folder, width, height)

    local path = IMG_PATH..folder.."\\"

    return {

        openFillRaidButton = {
            width = width,
            height = height,
            normal = path.."fillraid",
            highlight = HIGHLIGHT,
            pushed = path.."fillraid"
        },

        kickAllButton = {
            width = width,
            height = height,
            normal = path.."kickall",
            highlight = HIGHLIGHT,
            pushed = path.."kickall"
        },

        reFillButton = {
            width = width,
            height = height,
            normal = path.."refill",
            highlight = HIGHLIGHT,
            pushed = path.."refill"
        }

    }

end

SettingsConfig = {

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
                {
					type = "button",
					label = "Suppress",
					tooltip = "Add/Edit Messages to be Suppressed",
					width = 80,
					onClick = function()
						if SuppressEditor:IsShown() then
							SuppressEditor:Hide()
						else
							RefreshSuppressList()
							SuppressEditor:Show()
							SuppressEditor:SetFrameLevel(200) 
						end
					end
				},
				{
					type = "checkbox",
					key = "debugMessagesEnabled",
					label = "Enable Debug Messages",
					tooltip = "Shows debug messages in chat for development.",
					default = false,
					onApply = function(value)
						if value then
							debuggerFrame:Show()
							DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00Debug messages enabled|r")
						else
							debuggerFrame:Hide()
							DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000Debug messages disabled|r")
						end
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
                    key = "isZonePresetsEnabled",
                    label = "Zone Presets",
                    tooltip = "Checks what zone you are in and opens \nthe correct preset list.",
                    default = true,
                    onApply = function(value) ToggleZonePresets(value) end
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
                    key = "OthersButtonsEnabled",
                    label = "Enable Others button",
                    tooltip = "Enables Others button on all instance frames.",
                    default = false,
                    onApply = function(value) ToggleOthersButton(value) end
                },

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
					type = "button",
					label = "Button Themes",
					tooltip = "Button Themes",
					width = 80,

					createFrame = true,
					frameWidth = 270,
					frameTitle = "Button Themes"
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
                    type = "checkbox",
                    key = "isLootTypeEnabled",
                    label = "Loot type",
                    tooltip = "Enables auto change loot type.",
                    default = true,
                    onApply = function(value) ToggleLootType(value) end
                },
                {
                    type = "radio",
                    group = "lootType",
					textposition = "over", 

                    options = {
                        { key = "isFFAEnabled", label = "FFA", default = false, tooltip = "Automatically set to \nFree For All loot" },
                        { key = "isGroupLootEnabled", label = "Group", default = true, tooltip = "Automatically set to \nGroup loot" },
                        { key = "isMasterLootEnabled", label = "Master", default = false, tooltip = "Automatically set to \nMaster loot" },
                    },

                    onApply = function(selectedKey)
                        SetLootOption(
                            selectedKey == "isFFAEnabled",
                            selectedKey == "isGroupLootEnabled",
                            selectedKey == "isMasterLootEnabled"
                        )
                    end
                },
				{
					type = "radio",
					group = "buttonTheme",
					framename = "FillRaidBots_ButtonThemes_Frame",
					layout = "vertical",
				
					options = {
						
						{
							key = "Mini",
							label = "Mini",
							tooltip = "Small compact buttons",
							default = true,
							buttons = CreateThemeButtons("Mini", 32, 32)
						},
						{
							key = "Classic",
							label = "Classic",
							tooltip = "Vertical tall buttons",
							default = false,
							buttons = CreateThemeButtons("Classic", 40, 100)
						},
						{
							key = "AI",
							label = "AI",
							tooltip = "AI Generated Buttons",
							default = false,
							buttons = CreateThemeButtons("AI", 40, 100)
						},
						{
							key = "AISmall",
							label = "AISmall",
							tooltip = "Small AI buttons",
							default = false,
							buttons = CreateThemeButtons("AISmall", 32, 32)
						},
						{
							key = "AIHorizontal",
							label = "AIHorizontal",
							tooltip = "Horizontal AI buttons",
							offsetX = -80,  -- flytta hela preview-gruppen horisontellt
							offsetY = 0,    -- flytta hela preview-gruppen vertikalt							
							default = false,
							buttons = CreateThemeButtons("AIHorizontal", 100, 40)
						},
						{
							key = "Nymz",
							label = "Nymz",
							tooltip = "Nymz theme",
							default = false,
							spacing = -30,
							buttons = CreateThemeButtons("Nymz", 40, 100)
						},
						{
							key = "Nymzmini",
							label = "Nymz Mini",
							tooltip = "Nymz small buttons",
							default = false,
							buttons = CreateThemeButtons("Nymzmini", 32, 32)
						},
						{
							key = "Gemma",
							label = "Gemma",
							tooltip = "Gemma theme",
							default = false,
							buttons = CreateThemeButtons("Gemma", 40, 100)
						}						
					},

					onApply = function(selectedKey, item)
						FillRaidBotsSavedSettings.selectedButtonTheme = selectedKey
					end
				}				
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
-- CHECKBUTTON CREATOR (WoW 1.12 SAFE)
--==================================================
local function CreateCheckButton(parent, name, anchor, x, y, label, tooltip, value, onClick, framename)

    -- Välj dynamiskt parent-frame (Vanilla 1.12 fix)
    local parentForItem = parent
    if framename then
        local globalFrame = getglobal(framename)
        if globalFrame then
            parentForItem = globalFrame
        end
    end

    local cb = CreateFrame("CheckButton", name, parentForItem, "UICheckButtonTemplate")
    cb:SetWidth(20)
    cb:SetHeight(20)
    cb:SetPoint("TOPLEFT", parentForItem, "TOPLEFT", x, y)

    -- Textlabel
    cb.text = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	cb.text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    cb.text:SetPoint("LEFT", cb, "RIGHT", 5, 0)
    cb.text:SetText(label)

    -- Se till att värdet alltid blir true/false
    cb:SetChecked(value and true or false)

    -- Klickhändelse
    cb:SetScript("OnClick", function()
        local checked = cb:GetChecked() and true or false

        if name and FillRaidBotsSavedSettings then
            FillRaidBotsSavedSettings[name] = checked
        end

        if onClick then
            onClick(checked)
        end

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
local function GenerateSafeFrameName(label)

    if not label then
        return nil
    end

    -- Ta bort allt som inte är bokstav eller siffra
    local clean = string.gsub(label, "[^%w]", "")

    -- Prefix så vi aldrig krockar globalt
    return "FillRaidBots_" .. clean .. "_Frame"
end

function CreateSettingsUI()

    if not FillRaidBotsSavedSettings then
        FillRaidBotsSavedSettings = {}
    end

    --------------------------------------------------
    -- LAYOUT BASE SETTINGS
    --------------------------------------------------
    local columnWidth = 170
    local startX = 20
    local startY = -20
    local sectionSpacing = 8
    local maxColumns = 2

    --------------------------------------------------
    -- ESTIMATE TOTAL HEIGHT (for auto-balance)
    --------------------------------------------------
    local totalHeight = 0

    for _, section in ipairs(SettingsConfig.sections) do
        local estimatedHeight = 40

        for _, item in ipairs(section.items) do
            if item.type == "checkbox" then
                estimatedHeight = estimatedHeight + 25
            elseif item.type == "radio" then
                estimatedHeight = estimatedHeight + 50
            elseif item.type == "button" then
                estimatedHeight = estimatedHeight + 30
            end
        end

        totalHeight = totalHeight + estimatedHeight + sectionSpacing
    end

    local maxColumnHeight = math.ceil(totalHeight / maxColumns)

    --------------------------------------------------
    -- COLUMN STATE
    --------------------------------------------------
    local currentColumnX = startX
    local currentColumnHeight = 0
    local columnsUsed = 1
    local columnHeights = {}
    columnHeights[1] = 0

    --------------------------------------------------
    -- BUILD SECTIONS
    --------------------------------------------------
    for _, section in ipairs(SettingsConfig.sections) do

        local sectionFrame = CreateFrame("Frame", nil, UISettingsFrame, "BackdropTemplate")
        sectionFrame:SetWidth(columnWidth)

        -- Blizzard style boxed section
        sectionFrame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        sectionFrame:SetBackdropColor(0,0,0,0.6)

        local sectionY = -12

        --------------------------------------------------
        -- HEADER
        --------------------------------------------------
        local header = sectionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        header:SetPoint("TOPLEFT", sectionFrame, "TOPLEFT", 8, sectionY)
        header:SetText(section.name)

        sectionY = sectionY - 15

        --------------------------------------------------
        -- SEPARATOR
        --------------------------------------------------
        local separator = sectionFrame:CreateTexture(nil, "ARTWORK")
        separator:SetHeight(1)
        separator:SetTexture(1,1,1,0.2)
        separator:SetPoint("TOPLEFT", sectionFrame, "TOPLEFT", 8, sectionY)
        separator:SetPoint("TOPRIGHT", sectionFrame, "TOPRIGHT", -8, sectionY)

        sectionY = sectionY - 12

        --------------------------------------------------
        -- ITEMS
        --------------------------------------------------
        for _, item in ipairs(section.items) do

            --------------------------------------------------
            -- CHECKBOX
            --------------------------------------------------
			if item.type == "checkbox" then

				local key = item.key
				local currentItem = item

				local parentFrame = sectionFrame
				local posY = sectionY
				local posX = 8
				local usePopupLayout = false

				-- Om checkbox ska in i popup
				if currentItem.framename then
					local customParent = getglobal(currentItem.framename)
					if customParent then
						parentFrame = customParent
						usePopupLayout = true

						posX = 10
						posY = customParent.nextY or -30

						-- flytta intern Y för popup
						customParent.nextY = posY - 25
						customParent.contentHeight = customParent.contentHeight + 25
						customParent:SetHeight(customParent.contentHeight + 10)
					end
				end

				local cb = CreateCheckButton(
					parentFrame,
					key,
					parentFrame,
					posX,
					posY,
					currentItem.label,
					currentItem.tooltip,
					FillRaidBotsSavedSettings[key],
					function(value)

						FillRaidBotsSavedSettings[key] = value

						if currentItem.onApply then
							currentItem.onApply(value)
						end

						local status = value and "|cFF00FF00enabled|r" or "|cFFFF0000disabled|r"
						DEFAULT_CHAT_FRAME:AddMessage(currentItem.label .. ": " .. status)
					end,
					nil
				)

				currentItem.frame = cb

				-- ⭐ Endast sektion-checkboxar påverkar layout
				if not usePopupLayout then
					sectionY = sectionY - 25
				end
			

            --------------------------------------------------
            -- RADIO
            --------------------------------------------------
			elseif item.type == "radio" then

				local currentItem = item
				local parentFrame = sectionFrame
				local usePopupLayout = false
				local posX = 8
				local posY = sectionY

				if currentItem.framename then
					local customParent = getglobal(currentItem.framename)
					if customParent then
						parentFrame = customParent
						usePopupLayout = true
						posX = 10
						posY = customParent.nextY or -30

						if not customParent.contentHeight then
							customParent.contentHeight = 0
						end
					end
				end

				local layout = currentItem.layout or "horizontal"
				local textPosition = currentItem.textposition or "side"

				local extraLabelHeight = 0
				if textPosition == "over" then
					extraLabelHeight = 14
				end

				local spacingX = 50
				local spacingY = 28 + extraLabelHeight
				local optionCount = table.getn(currentItem.options)

				--------------------------------------------------
				-- PREVIEW GROUP
				--------------------------------------------------

				local groupPreview = {}

				for i = 1, optionCount do
					if currentItem.options[i].buttons then

						groupPreview.fill = parentFrame:CreateTexture(nil, "ARTWORK")
						groupPreview.kick = parentFrame:CreateTexture(nil, "ARTWORK")
						groupPreview.refill = parentFrame:CreateTexture(nil, "ARTWORK")

						break
					end
				end

				--------------------------------------------------
				-- CREATE RADIO BUTTONS
				--------------------------------------------------

				local i
				for i = 1, optionCount do

					local option = currentItem.options[i]

					local xOffset = posX
					local yOffset = posY

					if layout == "horizontal" then
						xOffset = posX + ((i - 1) * spacingX)
					else
						yOffset = posY - ((i - 1) * spacingY)
					end

					local cb = CreateFrame("CheckButton", nil, parentFrame, "UICheckButtonTemplate")
					cb:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", xOffset, yOffset - extraLabelHeight)
					cb:SetWidth(20)
					cb:SetHeight(20)

					cb:SetChecked(FillRaidBotsSavedSettings[option.key] and true or false)

					--------------------------------------------------
					-- LABEL
					--------------------------------------------------

					local label = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
					label:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
					label:SetText(option.label)

					if textPosition == "over" then
						label:SetPoint("BOTTOM", cb, "TOP", 0, 2)
					else
						label:SetPoint("LEFT", cb, "RIGHT", 5, 0)
					end

					--------------------------------------------------
					-- TOOLTIP
					--------------------------------------------------

					local tooltipText = option.tooltip or currentItem.tooltip

					if tooltipText then
						cb:SetScript("OnEnter", function(self)
							GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
							GameTooltip:SetText(tooltipText, 1,1,1,1)
							GameTooltip:Show()
						end)

						cb:SetScript("OnLeave", function()
							GameTooltip:Hide()
						end)
					end

					--------------------------------------------------
					-- CLICK
					--------------------------------------------------

					cb:SetScript("OnClick", function()

						for j = 1, optionCount do
							local opt = currentItem.options[j]
							FillRaidBotsSavedSettings[opt.key] = false
							if opt.frame then
								opt.frame:SetChecked(false)
							end
						end

						FillRaidBotsSavedSettings[option.key] = true
						FillRaidBotsSavedSettings.buttonStyle = option.key
						cb:SetChecked(true)

						ApplyButtonStyle(option.key)

						--------------------------------------------------
						-- UPDATE PREVIEW
						--------------------------------------------------

						if groupPreview.fill and option.buttons then

							local fill = option.buttons["openFillRaidButton"]
							local kick = option.buttons["kickAllButton"]
							local refill = option.buttons["reFillButton"]

							if fill then

								local isHorizontal = fill.width >= fill.height

								groupPreview.fill:ClearAllPoints()
								groupPreview.kick:ClearAllPoints()
								groupPreview.refill:ClearAllPoints()

								if isHorizontal then

									groupPreview.fill:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", posX + 120, posY)
									groupPreview.kick:SetPoint("TOPLEFT", groupPreview.fill, "BOTTOMLEFT", 0, -2)
									groupPreview.refill:SetPoint("TOPLEFT", groupPreview.kick, "BOTTOMLEFT", 0, -2)

								else

									groupPreview.fill:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", posX + 120, posY)
									groupPreview.kick:SetPoint("LEFT", groupPreview.fill, "RIGHT", 4, 0)
									groupPreview.refill:SetPoint("LEFT", groupPreview.kick, "RIGHT", 4, 0)

								end

								groupPreview.fill:SetTexture(fill.normal)
								groupPreview.fill:SetWidth(fill.width)
								groupPreview.fill:SetHeight(fill.height)

							end

							if kick then
								groupPreview.kick:SetTexture(kick.normal)
								groupPreview.kick:SetWidth(kick.width)
								groupPreview.kick:SetHeight(kick.height)
							end

							if refill then
								groupPreview.refill:SetTexture(refill.normal)
								groupPreview.refill:SetWidth(refill.width)
								groupPreview.refill:SetHeight(refill.height)
							end

						end

						if currentItem.onApply then
							currentItem.onApply(option.key, currentItem)
						end

					end)

					option.frame = cb
				end

				--------------------------------------------------
				-- DEFAULT PREVIEW
				--------------------------------------------------

				for i = 1, optionCount do
					local opt = currentItem.options[i]

					if FillRaidBotsSavedSettings[opt.key] and opt.buttons and groupPreview.fill then

						local fill = opt.buttons["openFillRaidButton"]
						local kick = opt.buttons["kickAllButton"]
						local refill = opt.buttons["reFillButton"]

						local isHorizontal = fill.width > fill.height

						if isHorizontal then
							groupPreview.fill:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", posX + 120, posY)
							groupPreview.kick:SetPoint("TOPLEFT", groupPreview.fill, "BOTTOMLEFT", 0, -2)
							groupPreview.refill:SetPoint("TOPLEFT", groupPreview.kick, "BOTTOMLEFT", 0, -2)
						else
							groupPreview.fill:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", posX + 120, posY)
							groupPreview.kick:SetPoint("LEFT", groupPreview.fill, "RIGHT", 4, 0)
							groupPreview.refill:SetPoint("LEFT", groupPreview.kick, "RIGHT", 4, 0)
						end

						groupPreview.fill:SetTexture(fill.normal)
						groupPreview.fill:SetWidth(fill.width)
						groupPreview.fill:SetHeight(fill.height)

						groupPreview.kick:SetTexture(kick.normal)
						groupPreview.kick:SetWidth(kick.width)
						groupPreview.kick:SetHeight(kick.height)

						groupPreview.refill:SetTexture(refill.normal)
						groupPreview.refill:SetWidth(refill.width)
						groupPreview.refill:SetHeight(refill.height)

					end
				end

				--------------------------------------------------
				-- HEIGHT
				--------------------------------------------------

				local totalHeight = 0

				if layout == "horizontal" then
					totalHeight = spacingY
				else
					totalHeight = optionCount * spacingY
				end

				if usePopupLayout then
					parentFrame.nextY = posY - totalHeight - 10
					parentFrame.contentHeight = parentFrame.contentHeight + totalHeight
					parentFrame:SetHeight(parentFrame.contentHeight + 20)
				else
					sectionY = sectionY - totalHeight - 10
				end

            --------------------------------------------------
            -- BUTTON
            --------------------------------------------------
			elseif item.type == "button" then

				local currentItem = item

				local btn = CreateFrame("Button", nil, sectionFrame, "GameMenuButtonTemplate")
				btn:SetWidth(currentItem.width or 120)
				btn:SetHeight(20)
				btn:SetPoint("TOPLEFT", sectionFrame, "TOPLEFT", 8, sectionY)
				btn:SetText(currentItem.label)
				local textWidth = btn:GetFontString():GetStringWidth()
				btn:SetWidth(textWidth + 20)
				--------------------------------------------------
				-- AUTO CREATE FRAME (WITH GLOBAL NAME)
				--------------------------------------------------
				if currentItem.createFrame then

					-- Generera säkert globalt namn
					local frameName = currentItem.frameName
					if not frameName then
						local clean = string.gsub(currentItem.label or "", "[^%w]", "")
						frameName = "FillRaidBots_" .. clean .. "_Frame"
					end

					-- Skapa frame med GLOBALT namn
					-- Skapa frame med GLOBALT namn
					local popup = CreateFrame("Frame", frameName, btn, "BackdropTemplate")

					popup:SetWidth(currentItem.frameWidth or 200)
					popup:SetHeight(40) -- start height (minimal)

					popup:SetBackdrop({
						bgFile = "Interface/Buttons/WHITE8X8",
						edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
						tile = true,
						tileSize = 16,
						edgeSize = 12,
						insets = { left = 3, right = 3, top = 3, bottom = 3 }
					})
					popup:SetBackdropColor(0,0,0,0.9)

					popup:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", 0, -2)
					popup:Hide()

					-- Intern layout
					popup.nextY = -30
					popup.contentHeight = 0 -- start padding

					-- Titel
					if currentItem.frameTitle then
						local title = popup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
						title:SetPoint("TOP", popup, "TOP", 0, -8)
						title:SetText(currentItem.frameTitle)

						popup.contentHeight = popup.contentHeight + 20
					end

					-- Spara referenser
					currentItem.generatedFrameName = frameName
					currentItem.popupFrame = popup

					btn:SetScript("OnClick", function()
						if popup:IsShown() then
							popup:Hide()
						else
							popup:Show()
						end
					end)

				else
					-- fallback if normal button
					btn:SetScript("OnClick", function()
						if currentItem.onClick then
							currentItem.onClick()
						end
					end)
				end

				--------------------------------------------------
				-- Tooltip
				--------------------------------------------------
				btn:SetScript("OnEnter", function()
					if currentItem.tooltip then
						GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
						GameTooltip:SetText(currentItem.tooltip)
						GameTooltip:Show()
					end
				end)

				btn:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)

				sectionY = sectionY - 30
			end
        end

        --------------------------------------------------
        -- FINALIZE SECTION HEIGHT
        --------------------------------------------------
        local sectionHeight = -sectionY + 6
        sectionFrame:SetHeight(sectionHeight)

        --------------------------------------------------
        -- COLUMN WRAP
        --------------------------------------------------
        if currentColumnHeight + sectionHeight > maxColumnHeight then
            columnsUsed = columnsUsed + 1
            currentColumnX = startX + (columnsUsed - 1) * columnWidth
            currentColumnHeight = 0
            columnHeights[columnsUsed] = 0
        end

        sectionFrame:SetPoint(
            "TOPLEFT",
            UISettingsFrame,
            "TOPLEFT",
            currentColumnX,
            startY - currentColumnHeight
        )

        currentColumnHeight = currentColumnHeight + sectionHeight + sectionSpacing
        columnHeights[columnsUsed] = currentColumnHeight
    end

    --------------------------------------------------
    -- FINAL FRAME SIZE
    --------------------------------------------------
    local tallest = 0
    for i = 1, columnsUsed do
        if columnHeights[i] and columnHeights[i] > tallest then
            tallest = columnHeights[i]
        end
    end

    UISettingsFrame:SetWidth(startX + columnsUsed * columnWidth + 20)
    UISettingsFrame:SetHeight(tallest + 30)
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

	if not FillRaidBotsSavedSettings.selectedButtonTheme then
		for _, section in ipairs(SettingsConfig.sections) do
			for _, item in ipairs(section.items) do
				if item.type == "radio" and item.group == "buttonTheme" then
					for _, option in ipairs(item.options) do
						if option.default then
							FillRaidBotsSavedSettings.selectedButtonTheme = option.key
							break
						end
					end
				end
			end
		end
	end

	if FillRaidBotsSavedSettings.isAutoRepairEnabled == nil then
		for _, section in ipairs(SettingsConfig.sections) do
			for _, item in ipairs(section.items) do
				if item.type == "checkbox" and item.key == "isAutoRepairEnabled" then
					FillRaidBotsSavedSettings.isAutoRepairEnabled = item.default
					break
				end
			end
		end
	end

    InitializeDefaults()

    if not settingsLoaded then
        settingsLoaded = true
        CreateSettingsUI()
    end
	ApplyButtonStyle(FillRaidBotsSavedSettings.selectedButtonTheme)
    ApplySavedSettings()
end

--==================================================
-- EVENT HANDLER
--==================================================
function GetSettingsCheckbox(key)

    for _, section in ipairs(SettingsConfig.sections) do
        for _, item in ipairs(section.items) do
            if item.type == "checkbox" and item.key == key then
                return item.frame
            end
        end
    end

end

function GetSetting(key)
    if FillRaidBotsSavedSettings then
        return FillRaidBotsSavedSettings[key]
    end
    return nil
end
