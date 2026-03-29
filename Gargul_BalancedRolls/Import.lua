local BR = _G.BalancedRolls

function BR:ToggleImportWindow()
    if self.ImportFrame and self.ImportFrame:IsShown() then
        self.ImportFrame:Hide()
        return
    end
    self:ShowImportWindow()
end

function BR:ShowImportWindow()
    if self.ImportFrame then
        self.ImportFrame:Show()
        self.ImportEditBox:SetText("")
        self.ImportEditBox:SetFocus()
        return
    end

    -- Main frame (Gargul dark dialog style)
    local frame = CreateFrame("Frame", "BalancedRollsImportFrame", UIParent, "BackdropTemplate")
    frame:SetSize(500, 400)
    frame:SetPoint("CENTER")
    frame:SetBackdrop(_G.BACKDROP_DARK_DIALOG_32_32)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:SetFrameLevel(100)
    frame:SetToplevel(true)

    -- Make escapable
    _G.BALANCED_ROLLS_IMPORT_WINDOW = frame
    tinsert(UISpecialFrames, "BALANCED_ROLLS_IMPORT_WINDOW")

    -- Close button (Gargul style)
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetSize(30, 30)
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 8, 5)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    -- Title bar for dragging
    local titleBar = CreateFrame("Frame", nil, frame)
    titleBar:SetHeight(24)
    titleBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -8)
    titleBar:SetPoint("TOPRIGHT", closeBtn, "TOPLEFT", -2, 0)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() frame:StartMoving() end)
    titleBar:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)

    -- Title text (Gargul gold)
    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetPoint("LEFT", titleBar, "LEFT", 4, 0)
    titleText:SetText("Import Balanced Rolls Data")
    titleText:SetTextColor(1, 0.84, 0, 1)

    -- Description text
    local desc = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    desc:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -38)
    desc:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, -38)
    desc:SetJustifyH("LEFT")
    desc:SetText("Paste your JSON data below and click Import.")
    desc:SetTextColor(0.7, 0.7, 0.7)

    -- Text area background (Gargul textArea style)
    local textBg = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    textBg:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 3, top = 4, bottom = 3 },
    })
    textBg:SetBackdropColor(0, 0, 0)
    textBg:SetBackdropBorderColor(0.4, 0.4, 0.4)
    textBg:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -56)
    textBg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 48)

    -- Scroll frame for text input
    local scrollFrame = CreateFrame("ScrollFrame", nil, textBg, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", textBg, "TOPLEFT", 8, -8)
    scrollFrame:SetPoint("BOTTOMRIGHT", textBg, "BOTTOMRIGHT", -28, 8)

    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject(ChatFontNormal)
    editBox:SetWidth(scrollFrame:GetWidth() - 10)
    editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    scrollFrame:SetScrollChild(editBox)

    -- Click background to focus edit box
    textBg:SetScript("OnMouseUp", function() editBox:SetFocus() end)

    -- Import button (Gargul UIPanelButtonTemplate style)
    local importBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    importBtn:SetSize(120, 25)
    importBtn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 12)
    importBtn:SetText("Import")
    importBtn:SetScript("OnClick", function()
        local text = editBox:GetText()
        if not text or text:trim() == "" then
            BR:Print("Please paste data to import.")
            return
        end

        local success = BR:ImportData(text)
        if success then
            StaticPopup_Show("BALANCED_ROLLS_IMPORT_SUCCESS")
            frame:Hide()
        end
    end)

    -- Cancel button
    local cancelBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    cancelBtn:SetSize(120, 25)
    cancelBtn:SetPoint("RIGHT", importBtn, "LEFT", -10, 0)
    cancelBtn:SetText("Cancel")
    cancelBtn:SetScript("OnClick", function()
        frame:Hide()
    end)

    self.ImportFrame = frame
    self.ImportEditBox = editBox
    editBox:SetFocus()
end

-- Success popup dialog
StaticPopupDialogs["BALANCED_ROLLS_IMPORT_SUCCESS"] = {
    text = "Balanced Rolls data imported successfully!",
    button1 = "OK",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}
