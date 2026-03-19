local BR = _G.BalancedRolls
local GL -- set after Gargul loads

BR.RollEntries = {}
BR.rollRows = {}
BR.rollActive = false

---------------------------------------------------------------------------
-- Constants (matching GGD style)
---------------------------------------------------------------------------
local ROW_HEIGHT = 22
local MAX_VISIBLE_ROWS = 8
local FRAME_WIDTH = 300
local NAME_WIDTH = 100
local CALC_WIDTH = 110

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------
function BR:InitRollTracker()
    GL = _G.Gargul

    if not GL then
        self:Print("Gargul not found - roll tracking disabled.")
        return
    end

    self:CreateRollDisplay()

    GL.Events:register("BalancedRolls_RollStarted", "GL.ROLLOFF_STARTED", function()
        BR.RollEntries = {}
        BR.rollActive = true
        -- Defer anchoring so GargulGearDisplay has time to show and size itself
        C_Timer.After(0, function()
            BR:AnchorRollDisplay()
            BR.rollFrame:Show()
            BR:RefreshRollDisplay()
        end)
    end)

    GL.Events:register("BalancedRolls_RollAccepted", "GL.ROLLOFF_ROLL_ACCEPTED", function()
        if not BR.rollActive then
            BR.rollActive = true
            C_Timer.After(0, function()
                BR:AnchorRollDisplay()
                BR.rollFrame:Show()
            end)
        end
        BR:ProcessRolls()
    end)

    GL.Events:register("BalancedRolls_RollStopped", "GL.ROLLOFF_STOPPED", function()
        -- Keep window open so ML can review results
    end)
end

---------------------------------------------------------------------------
-- Roll processing
---------------------------------------------------------------------------
function BR:ProcessRolls()
    if not GL or not GL.RollOff or not GL.RollOff.CurrentRollOff then return end

    local rolls = GL.RollOff.CurrentRollOff.Rolls
    if not rolls then return end

    self.RollEntries = {}
    for _, roll in pairs(rolls) do
        local name = roll.player:match("^([^%-]+)") or roll.player
        local modifier = self:GetModifier(name) or 1
        local adjustedRoll = roll.amount * modifier

        table.insert(self.RollEntries, {
            name = name,
            class = roll.class,
            rawRoll = roll.amount,
            modifier = modifier,
            adjustedRoll = adjustedRoll,
        })
    end

    table.sort(self.RollEntries, function(a, b)
        return a.adjustedRoll > b.adjustedRoll
    end)

    self:RefreshRollDisplay()
end

---------------------------------------------------------------------------
-- Display UI (GGD-matching style)
---------------------------------------------------------------------------
function BR:CreateRollDisplay()
    local f = CreateFrame("Frame", "BalancedRollsRollFrame", UIParent, "BackdropTemplate")
    f:SetSize(FRAME_WIDTH, 40)
    f:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    f:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    f:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    f:Hide()

    -- Close button
    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function()
        f:Hide()
        BR.rollActive = false
    end)

    -- Title bar for dragging
    local titleBar = CreateFrame("Frame", nil, f)
    titleBar:SetHeight(20)
    titleBar:SetPoint("TOPLEFT", f, "TOPLEFT", 4, -4)
    titleBar:SetPoint("TOPRIGHT", closeBtn, "TOPLEFT", -2, 0)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() f:StartMoving() end)
    titleBar:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)

    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    titleText:SetPoint("LEFT", titleBar, "LEFT", 2, 0)
    titleText:SetText("Balanced Rolls")
    titleText:SetTextColor(1, 0.82, 0, 1)

    -- Column headers
    local headerRow = CreateFrame("Frame", nil, f)
    headerRow:SetHeight(16)
    headerRow:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -24)
    headerRow:SetPoint("TOPRIGHT", f, "TOPRIGHT", -28, -24)

    local nameHeader = headerRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameHeader:SetPoint("LEFT", headerRow, "LEFT", 2, 0)
    nameHeader:SetText("Player")
    nameHeader:SetTextColor(0.6, 0.6, 0.6)

    local calcHeader = headerRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    calcHeader:SetPoint("LEFT", headerRow, "LEFT", NAME_WIDTH, 0)
    calcHeader:SetText("Roll * Mod")
    calcHeader:SetTextColor(0.6, 0.6, 0.6)

    local resultHeader = headerRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    resultHeader:SetPoint("RIGHT", headerRow, "RIGHT", 0, 0)
    resultHeader:SetText("Result")
    resultHeader:SetTextColor(0.6, 0.6, 0.6)

    -- Separator line under header
    local headerSep = headerRow:CreateTexture(nil, "ARTWORK")
    headerSep:SetHeight(1)
    headerSep:SetPoint("BOTTOMLEFT", headerRow, "BOTTOMLEFT", 0, 0)
    headerSep:SetPoint("BOTTOMRIGHT", headerRow, "BOTTOMRIGHT", 0, 0)
    headerSep:SetColorTexture(0.4, 0.4, 0.4, 0.6)

    -- Scroll frame for rows
    local scrollFrame = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -42)
    scrollFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -28, 8)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(FRAME_WIDTH - 36, 1)
    scrollFrame:SetScrollChild(content)

    self.rollFrame = f
    self.rollScrollFrame = scrollFrame
    self.rollContent = content
end

---------------------------------------------------------------------------
-- Anchoring
---------------------------------------------------------------------------
function BR:AnchorRollDisplay()
    if not self.rollFrame then return end

    -- Try to anchor below GargulGearDisplay if present and visible
    local ggdFrame = _G.GargulGearDisplayFrame
    if ggdFrame and ggdFrame:IsShown() then
        self.rollFrame:ClearAllPoints()
        self.rollFrame:SetPoint("TOPLEFT", ggdFrame, "BOTTOMLEFT", 0, -2)
        self:HookGGDResize(ggdFrame)
    else
        -- Anchor directly to Gargul's MasterLooterUI window
        local Window = GL.Interface:get(GL.MasterLooterUI, "Window")
        if Window and Window.frame then
            self.rollFrame:ClearAllPoints()
            self.rollFrame:SetPoint("TOPLEFT", Window.frame, "TOPRIGHT", 2, 0)
        else
            if not self.rollFrame:GetPoint() then
                self.rollFrame:SetPoint("CENTER")
            end
        end
    end

    -- Hook Gargul loot window hide to also hide us
    if not self.hookedLootWindowHide then
        local Window = GL.Interface:get(GL.MasterLooterUI, "Window")
        if Window and Window.frame then
            Window.frame:HookScript("OnHide", function()
                BR.rollFrame:Hide()
                BR.rollActive = false
            end)
            self.hookedLootWindowHide = true
        end
    end
end

function BR:HookGGDResize(ggdFrame)
    -- Re-anchor when GGD resizes so we stay right below it
    if self.hookedGGDResize then return end
    ggdFrame:HookScript("OnSizeChanged", function()
        if BR.rollFrame and BR.rollFrame:IsShown() then
            BR.rollFrame:ClearAllPoints()
            BR.rollFrame:SetPoint("TOPLEFT", ggdFrame, "BOTTOMLEFT", 0, -2)
        end
    end)
    ggdFrame:HookScript("OnHide", function()
        -- If GGD hides, re-anchor to loot window directly
        if BR.rollFrame and BR.rollFrame:IsShown() then
            local Window = GL.Interface:get(GL.MasterLooterUI, "Window")
            if Window and Window.frame then
                BR.rollFrame:ClearAllPoints()
                BR.rollFrame:SetPoint("TOPLEFT", Window.frame, "TOPRIGHT", 2, 0)
            end
        end
    end)
    self.hookedGGDResize = true
end

---------------------------------------------------------------------------
-- Row management
---------------------------------------------------------------------------
function BR:GetOrCreateRollRow(index)
    if self.rollRows[index] then
        return self.rollRows[index]
    end

    local row = CreateFrame("Frame", nil, self.rollContent)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("TOPLEFT", self.rollContent, "TOPLEFT", 0, -(index - 1) * ROW_HEIGHT)
    row:SetPoint("TOPRIGHT", self.rollContent, "TOPRIGHT", 0, -(index - 1) * ROW_HEIGHT)

    -- Alternating row background
    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    if index % 2 == 0 then
        bg:SetColorTexture(1, 1, 1, 0.05)
    else
        bg:SetColorTexture(0, 0, 0, 0)
    end
    row.bg = bg

    -- Player name
    local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameText:SetPoint("LEFT", row, "LEFT", 4, 0)
    nameText:SetWidth(NAME_WIDTH - 8)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)
    row.nameText = nameText

    -- Calculation text (e.g. "52 * 0.9")
    local calcText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    calcText:SetPoint("LEFT", row, "LEFT", NAME_WIDTH, 0)
    calcText:SetWidth(CALC_WIDTH)
    calcText:SetJustifyH("LEFT")
    calcText:SetWordWrap(false)
    row.calcText = calcText

    -- Result text
    local resultText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    resultText:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    resultText:SetJustifyH("RIGHT")
    row.resultText = resultText

    self.rollRows[index] = row
    return row
end

---------------------------------------------------------------------------
-- Refresh display
---------------------------------------------------------------------------
function BR:RefreshRollDisplay()
    if not self.rollFrame or not self.rollContent then return end

    -- Hide existing rows
    for _, row in ipairs(self.rollRows) do
        row:Hide()
    end

    local numRows = #self.RollEntries

    local contentHeight = math.max(numRows * ROW_HEIGHT, 1)
    self.rollContent:SetHeight(contentHeight)

    local visibleRows = math.min(numRows, MAX_VISIBLE_ROWS)
    local frameHeight = math.max(visibleRows * ROW_HEIGHT + 52, 54)
    self.rollFrame:SetHeight(frameHeight)

    for i, entry in ipairs(self.RollEntries) do
        local row = self:GetOrCreateRollRow(i)

        -- Player name with class color
        local classColor = entry.class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[entry.class]
        if classColor then
            row.nameText:SetTextColor(classColor.r, classColor.g, classColor.b)
        else
            row.nameText:SetTextColor(1, 1, 1)
        end
        row.nameText:SetText(entry.name)

        -- Calculation
        row.calcText:SetText(entry.rawRoll .. " * " .. tostring(entry.modifier))
        row.calcText:SetTextColor(0.8, 0.8, 0.8)

        -- Result
        local resultStr
        if entry.adjustedRoll == math.floor(entry.adjustedRoll) then
            resultStr = tostring(math.floor(entry.adjustedRoll))
        else
            resultStr = string.format("%.1f", entry.adjustedRoll)
        end
        row.resultText:SetText(resultStr)

        -- Highlight top roller in green
        if i == 1 and numRows > 1 then
            row.resultText:SetTextColor(0, 1, 0)
        else
            row.resultText:SetTextColor(1, 1, 1)
        end

        row:Show()
    end
end

---------------------------------------------------------------------------
-- Hook into init
---------------------------------------------------------------------------
local originalInit = BR.Init
function BR:Init()
    originalInit(self)
    self:InitRollTracker()
end
