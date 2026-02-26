local theme = {
    backdropColor1 = {0.15, 0.15, 0.15, 1}, 
    backdropColor2 = {0.2, 0.2, 0.2, 0.95}, 
    textColor = {0.20, 1, 0.8, 1}, 
    font = "Interface\\AddOns\\fillraidbots\\fonts\\PT-Sans-Narrow-Bold.ttf",
    fontSize = 10,
    fontMono = "Interface\\AddOns\\fillraidbots\\fonts\\Envy-Code-R.ttf",
    fontSizeMono = 9,
    spacing = 5, 
}

local texturePath = "Interface\\AddOns\\fillraidbots\\img\\"

debuggerFrame = CreateFrame("Frame", "FillraidbotsDebuggerFrame", UIParent, "BackdropTemplate")
debuggerFrame:SetWidth(620)
debuggerFrame:SetHeight(670)
debuggerFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
debuggerFrame:SetBackdrop({
    bgFile = texturePath .. "bg.tga", 
    tile = true, tileSize = 32, edgeSize = 16,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
debuggerFrame:SetBackdropColor(unpack(theme.backdropColor1)) 
debuggerFrame:EnableMouse(true)
debuggerFrame:SetMovable(true)
debuggerFrame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and not debuggerFrame.isMoving then
        debuggerFrame:StartMoving()
        debuggerFrame.isMoving = true
    end
end)
debuggerFrame:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" and debuggerFrame.isMoving then
        debuggerFrame:StopMovingOrSizing()
        debuggerFrame.isMoving = false
    end
end)

local header = debuggerFrame:CreateFontString(nil, "OVERLAY")
header:SetFont(theme.font, theme.fontSize)
header:SetPoint("TOP", debuggerFrame, "TOP", 0, -10)
header:SetText("Fillraidbots Debugger")
header:SetTextColor(unpack(theme.textColor))

-- Create the scroll frame with just UIPanelScrollFrameTemplate
local scrollFrame = CreateFrame("ScrollFrame", "FillraidbotsScrollFrame", debuggerFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetWidth(600)
scrollFrame:SetHeight(570)
scrollFrame:SetPoint("TOPLEFT", debuggerFrame, "TOPLEFT", 10, -40)

  

local scrollChild = CreateFrame("Frame", "FillraidbotsScrollChild", scrollFrame)
scrollChild:SetWidth(560)
scrollChild:SetHeight(1) 
scrollFrame:SetScrollChild(scrollChild)

-- Create EditBox for selectable text
local debugEditBox = CreateFrame("EditBox", "FillraidbotsDebugEditBox", scrollChild)
debugEditBox:SetMultiLine(true)
debugEditBox:SetFont(theme.fontMono, theme.fontSizeMono)
debugEditBox:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, 0)
debugEditBox:SetWidth(550)
debugEditBox:SetHeight(1)
debugEditBox:SetAutoFocus(false)
debugEditBox:EnableMouse(true)
debugEditBox:SetText("")

-- Set text properties (like your CopyChat)
debugEditBox:SetTextInsets(0, 0, 0, 0)
debugEditBox:SetJustifyH("LEFT")
debugEditBox:SetJustifyV("TOP")

-- Use your theme's bright text color
debugEditBox:SetTextColor(unpack(theme.textColor))

-- Keep the selectability scripts
debugEditBox:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
end)
debugEditBox:SetScript("OnEditFocusGained", function(self)
    self:HighlightText()
end)
debugEditBox:SetScript("OnEditFocusLost", function(self)
    self:HighlightText(0, 0)
end)


-- Create a background frame BEHIND the EditBox WITHOUT BackdropTemplate
local editBoxBG = CreateFrame("Frame", nil, scrollChild)
editBoxBG:SetPoint("TOPLEFT", debugEditBox, "TOPLEFT", -5, 5)
editBoxBG:SetPoint("BOTTOMRIGHT", debugEditBox, "BOTTOMRIGHT", 5, -5)

-- Create solid background texture
local bgTex = editBoxBG:CreateTexture(nil, "BACKGROUND")
bgTex:SetAllPoints(true)
bgTex:SetColorTexture(0, 0, 0, 1)  -- Solid black

-- Create border textures manually
local borderTop = editBoxBG:CreateTexture(nil, "BORDER")
borderTop:SetColorTexture(0.4, 0.4, 0.4, 1)
borderTop:SetHeight(1)
borderTop:SetPoint("TOPLEFT", editBoxBG, "TOPLEFT", 0, 0)
borderTop:SetPoint("TOPRIGHT", editBoxBG, "TOPRIGHT", 0, 0)

local borderBottom = editBoxBG:CreateTexture(nil, "BORDER")
borderBottom:SetColorTexture(0.4, 0.4, 0.4, 1)
borderBottom:SetHeight(1)
borderBottom:SetPoint("BOTTOMLEFT", editBoxBG, "BOTTOMLEFT", 0, 0)
borderBottom:SetPoint("BOTTOMRIGHT", editBoxBG, "BOTTOMRIGHT", 0, 0)

local borderLeft = editBoxBG:CreateTexture(nil, "BORDER")
borderLeft:SetColorTexture(0.4, 0.4, 0.4, 1)
borderLeft:SetWidth(1)
borderLeft:SetPoint("TOPLEFT", editBoxBG, "TOPLEFT", 0, 0)
borderLeft:SetPoint("BOTTOMLEFT", editBoxBG, "BOTTOMLEFT", 0, 0)

local borderRight = editBoxBG:CreateTexture(nil, "BORDER")
borderRight:SetColorTexture(0.4, 0.4, 0.4, 1)
borderRight:SetWidth(1)
borderRight:SetPoint("TOPRIGHT", editBoxBG, "TOPRIGHT", 0, 0)
borderRight:SetPoint("BOTTOMRIGHT", editBoxBG, "BOTTOMRIGHT", 0, 0)

debugEditBox:SetTextColor(1, 1, 1, 1)

-- Create border for EditBox
local editBoxBorderTop = debugEditBox:CreateTexture(nil, "BORDER")
editBoxBorderTop:SetColorTexture(0.4, 0.4, 0.4, 1)
editBoxBorderTop:SetHeight(1)
editBoxBorderTop:SetPoint("TOPLEFT", debugEditBox, "TOPLEFT", -4, 4)
editBoxBorderTop:SetPoint("TOPRIGHT", debugEditBox, "TOPRIGHT", 4, 4)

local editBoxBorderBottom = debugEditBox:CreateTexture(nil, "BORDER")
editBoxBorderBottom:SetColorTexture(0.4, 0.4, 0.4, 1)
editBoxBorderBottom:SetHeight(1)
editBoxBorderBottom:SetPoint("BOTTOMLEFT", debugEditBox, "BOTTOMLEFT", -4, -4)
editBoxBorderBottom:SetPoint("BOTTOMRIGHT", debugEditBox, "BOTTOMRIGHT", 4, -4)

local editBoxBorderLeft = debugEditBox:CreateTexture(nil, "BORDER")
editBoxBorderLeft:SetColorTexture(0.4, 0.4, 0.4, 1)
editBoxBorderLeft:SetWidth(1)
editBoxBorderLeft:SetPoint("TOPLEFT", debugEditBox, "TOPLEFT", -4, 4)
editBoxBorderLeft:SetPoint("BOTTOMLEFT", debugEditBox, "BOTTOMLEFT", -4, -4)

local editBoxBorderRight = debugEditBox:CreateTexture(nil, "BORDER")
editBoxBorderRight:SetColorTexture(0.4, 0.4, 0.4, 1)
editBoxBorderRight:SetWidth(1)
editBoxBorderRight:SetPoint("TOPRIGHT", debugEditBox, "TOPRIGHT", 4, 4)
editBoxBorderRight:SetPoint("BOTTOMRIGHT", debugEditBox, "BOTTOMRIGHT", 4, -4)

-- Get the scroll bar that's created by UIPanelScrollFrameTemplate
local scrollBar = _G["FillraidbotsScrollFrameScrollBar"]
if scrollBar then
    scrollBar:ClearAllPoints()
    scrollBar:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", 0, 0)
    scrollBar:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 0, 0)
end

local debugMessages = {}
local lineHeight = 10 
local maxMessages = 150

local function GetTimestamp()
    return date("%H:%M:%S") 
end

local function UpdateDebugMessages()
    local text = ""
    for i = 1, #debugMessages do
        text = text .. "" .. tostring(i) .. ": " .. debugMessages[i] .. "\n"
    end
    
    -- Update EditBox text
    debugEditBox:SetText(text)
    
    -- Calculate and set EditBox height based on content
    local numLines = #debugMessages + 1
    local editBoxHeight = numLines * lineHeight + 20  -- Add padding
    debugEditBox:SetHeight(math.max(editBoxHeight, scrollFrame:GetHeight()))

    -- Update scroll child height
    local contentHeight = numLines * lineHeight
    scrollChild:SetHeight(math.max(contentHeight, scrollFrame:GetHeight()))
end

-- Clear Button
local clearButton = CreateFrame("Button", "FillraidbotsClearButton", debuggerFrame, "UIPanelButtonTemplate")
clearButton:SetPoint("BOTTOM", debuggerFrame, "BOTTOM", -80, 20)
clearButton:SetWidth(100)
clearButton:SetHeight(30)
clearButton:SetText("Clear Messages")
clearButton:SetScript("OnClick", function()
    debugMessages = {}
    DebugMessage("Cleared messages", "debuginfo")
end)

-- Select All Button
local selectAllButton = CreateFrame("Button", "FillraidbotsSelectAllButton", debuggerFrame, "UIPanelButtonTemplate")
selectAllButton:SetPoint("BOTTOM", debuggerFrame, "BOTTOM", 80, 20)
selectAllButton:SetWidth(100)
selectAllButton:SetHeight(30)
selectAllButton:SetText("Select All")

selectAllButton:SetScript("OnClick", function()
    local text = debugEditBox:GetText()
    if text and text ~= "" then
        -- Set focus to the EditBox and select all text
        debugEditBox:SetFocus()
        debugEditBox:HighlightText()
        -- Don't call DebugMessage() - just select the text silently
    end
end)

local closeButton = CreateFrame("Button", "FillraidbotsCloseButton", debuggerFrame)
closeButton:SetPoint("TOPRIGHT", debuggerFrame, "TOPRIGHT", -10, -10)
closeButton:SetWidth(15)
closeButton:SetHeight(15)

local normalTexture = closeButton:CreateTexture(nil, "BACKGROUND")
normalTexture:SetTexture(texturePath .. "close.tga")
normalTexture:SetAllPoints(closeButton)
normalTexture:SetVertexColor(1, 0, 0) 
closeButton:SetNormalTexture(normalTexture)

local highlightTexture = closeButton:CreateTexture(nil, "HIGHLIGHT")
highlightTexture:SetTexture(texturePath .. "close.tga")
highlightTexture:SetAllPoints(closeButton)
highlightTexture:SetVertexColor(1, 0.5, 0.5) 
closeButton:SetHighlightTexture(highlightTexture)

local pushedTexture = closeButton:CreateTexture(nil, "PUSHED")
pushedTexture:SetTexture(texturePath .. "close.tga")
pushedTexture:SetAllPoints(closeButton)
pushedTexture:SetVertexColor(0.8, 0, 0) 
closeButton:SetPushedTexture(pushedTexture)

closeButton:SetScript("OnClick", function()
    debuggerFrame:Hide()
end)

local logLevelButton = CreateFrame("Button", "FillraidbotsLogLevelButton", debuggerFrame)
logLevelButton:SetPoint("BOTTOM", debuggerFrame, "TOPLEFT", 25, -30)
logLevelButton:SetWidth(15) 
logLevelButton:SetHeight(15)

local logLevelNormalTexture = logLevelButton:CreateTexture(nil, "BACKGROUND")
logLevelNormalTexture:SetTexture(texturePath .. "editor.tga")
logLevelNormalTexture:SetAllPoints(logLevelButton)
logLevelButton:SetNormalTexture(logLevelNormalTexture)

local logLevelHighlightTexture = logLevelButton:CreateTexture(nil, "HIGHLIGHT")
logLevelHighlightTexture:SetTexture(texturePath .. "editor.tga")
logLevelHighlightTexture:SetAllPoints(logLevelButton)
logLevelHighlightTexture:SetVertexColor(1, 1, 0) 
logLevelButton:SetHighlightTexture(logLevelHighlightTexture)

local logLevelPushedTexture = logLevelButton:CreateTexture(nil, "PUSHED")
logLevelPushedTexture:SetTexture(texturePath .. "editor.tga")
logLevelPushedTexture:SetAllPoints(logLevelButton)
logLevelPushedTexture:SetVertexColor(0.8, 0.2, 0.2) 
logLevelButton:SetPushedTexture(logLevelPushedTexture)

logLevelButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText("Log Level", 1, 1, 1) 
    GameTooltip:AddLine("Adjust log level settings.", 0.8, 0.8, 0.8) 
    GameTooltip:Show()
end)

logLevelButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

local logLevelFrame = CreateFrame("Frame", "FillraidbotsLogLevelFrame", FillraidbotsLogLevelButton, "BackdropTemplate")
logLevelFrame:SetWidth(200)
logLevelFrame:SetHeight(230)
logLevelFrame:SetPoint("BOTTOMLEFT", FillraidbotsLogLevelButton, "BOTTOMLEFT", 15, -200)
logLevelFrame:SetBackdrop({
    bgFile = texturePath .. "bg.tga",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 32, edgeSize = 12,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
logLevelFrame:SetBackdropColor(unpack(theme.backdropColor2))
logLevelFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1) 
logLevelFrame:Hide() 

local logLevelHeader = logLevelFrame:CreateFontString(nil, "OVERLAY")
logLevelHeader:SetFont(theme.font, theme.fontSize)
logLevelHeader:SetPoint("TOP", logLevelFrame, "TOP", 0, -10)
logLevelHeader:SetText("Log Levels")
logLevelHeader:SetTextColor(unpack(theme.textColor))

local function CreateLogLevelCheckbox(name, label, parent, offsetY)
    local checkbox = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, offsetY)
    checkbox.text = checkbox:CreateFontString(nil, "OVERLAY")
    checkbox.text:SetFont(theme.font, theme.fontSize)
    checkbox.text:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
    checkbox.text:SetText(label)
    checkbox.text:SetTextColor(unpack(theme.textColor))
    return checkbox
end

local debugFillingCheckbox = CreateLogLevelCheckbox("DebugFillingCheckbox", "Debug Filling", logLevelFrame, -40)
local debugDetectionCheckbox = CreateLogLevelCheckbox("DebugDetectionCheckbox", "Debug Detection", logLevelFrame, -70)
local debugRemoveCheckbox = CreateLogLevelCheckbox("DebugRemoveCheckbox", "Debug Remove", logLevelFrame, -100)
local debugErrorCheckbox = CreateLogLevelCheckbox("DebugErrorCheckbox", "Debug Error", logLevelFrame, -130)
local debugInfoCheckbox = CreateLogLevelCheckbox("DebugInfoCheckbox", "Debug Info", logLevelFrame, -160)
local debugVersionCheckbox = CreateLogLevelCheckbox("DebugVersionCheckbox", "Debug Version", logLevelFrame, -190)

debugFillingCheckbox:SetChecked(true)
debugDetectionCheckbox:SetChecked(true)
debugRemoveCheckbox:SetChecked(true)
debugErrorCheckbox:SetChecked(true)
debugInfoCheckbox:SetChecked(true)
debugVersionCheckbox:SetChecked(true)

logLevelButton:SetScript("OnClick", function()
    if logLevelFrame:IsShown() then
        logLevelFrame:Hide()
    else
        logLevelFrame:Show()
    end
end)

local function IsLogLevelEnabled(level)
    if level == "debugfilling" then
        return debugFillingCheckbox:GetChecked()
    elseif level == "debugdetection" then
        return debugDetectionCheckbox:GetChecked()
    elseif level == "debugremove" then
        return debugRemoveCheckbox:GetChecked()
    elseif level == "debugerror" then
        return debugErrorCheckbox:GetChecked()
    elseif level == "debuginfo" then
        return debugInfoCheckbox:GetChecked()
    elseif level == "debugversion" then
        return debugVersionCheckbox:GetChecked()
    end
    return false
end

function DebugMessage(message, level)
    if not IsLogLevelEnabled(level) then return end

    -- Add timestamp to the message
    local timestampedMessage = "[" .. GetTimestamp() .. "] " .. message

    -- Add to messages table
    table.insert(debugMessages, timestampedMessage)

    -- Limit number of messages
    if #debugMessages > maxMessages then
        table.remove(debugMessages, 1)
    end

    -- Update display (but don't print to chat)
    UpdateDebugMessages()
end

SLASH_FILLRAIDBOTSDEBUG1 = "/frbdebug" 

SlashCmdList["FILLRAIDBOTSDEBUG"] = function()
    if debuggerFrame:IsShown() then
        debuggerFrame:Hide()
        print("FillRaidBots Debugger Frame hidden.")
    else
        debuggerFrame:Show()
        print("FillRaidBots Debugger Frame shown.")
    end
end

DebugMessage("Debugger initialized.", "debuginfo")
DebugMessage("Fillraidbots loaded successfully.", "debuginfo")

local eventFrame = CreateFrame("Frame", "FillraidbotsEventFrame", UIParent)
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        DebugMessage("Player logged in.", "debuginfo")
    elseif event == "PLAYER_ENTERING_WORLD" then
        DebugMessage("Player entering the world.", "debuginfo")
    elseif event == "GROUP_ROSTER_UPDATE" then
        DebugMessage("Group roster updated.", "debuginfo")
    end
end)