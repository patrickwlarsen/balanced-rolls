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

    -- Main frame
    local frame = CreateFrame("Frame", "BalancedRollsImportFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(500, 400)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    frame.title:SetPoint("TOP", frame.TitleBg, "TOP", 0, -3)
    frame.title:SetText("Import Balanced Rolls Data")

    -- Scroll frame for text input
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame.InsetBg, "TOPLEFT", 8, -8)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame.InsetBg, "BOTTOMRIGHT", -28, 40)

    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject(ChatFontNormal)
    editBox:SetWidth(scrollFrame:GetWidth() - 10)
    editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    scrollFrame:SetScrollChild(editBox)

    -- Import button
    local importBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    importBtn:SetSize(120, 25)
    importBtn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 8)
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
    local cancelBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
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
