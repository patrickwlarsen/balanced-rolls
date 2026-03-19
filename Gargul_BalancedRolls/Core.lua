local BR = {}
_G.BalancedRolls = BR

BR.version = "1.0.0"
BR.PlayerData = {}      -- imported data keyed by lowercase name
BR.EventFrame = CreateFrame("Frame")

-- Simple JSON parser for our specific format: array of objects with string values
local function parseJSON(input)
    local results = {}
    -- Match each {...} object block
    for block in input:gmatch("{(.-)}") do
        local entry = {}
        -- Match "key": "value" pairs
        for key, value in block:gmatch('"([^"]+)"%s*:%s*"([^"]*)"') do
            entry[key] = value
        end
        if entry.name then
            table.insert(results, entry)
        end
    end
    return results
end

function BR:Init()
    -- Load saved variables (set after ADDON_LOADED)
    if not BalancedRollsDB then
        BalancedRollsDB = {}
    end

    self.PlayerData = {}
    if BalancedRollsDB.PlayerData then
        for k, v in pairs(BalancedRollsDB.PlayerData) do
            self.PlayerData[k] = v
        end
    end

    self:InitMinimapButton()
    self:Print("v" .. self.version .. " loaded. Type /br to open.")
end

function BR:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00CCFFBalanced Rolls:|r " .. msg)
end

function BR:ImportData(jsonString)
    local parsed = parseJSON(jsonString)

    if not parsed or #parsed == 0 then
        self:Print("Import failed - no valid data found.")
        return false
    end

    -- Clear previous data
    BalancedRollsDB.PlayerData = {}
    self.PlayerData = {}

    for _, entry in ipairs(parsed) do
        local key = entry.name:lower()
        self.PlayerData[key] = {
            name = entry.name,
            rollModifier = tonumber(entry.rollModifier) or 1,
        }
        BalancedRollsDB.PlayerData[key] = self.PlayerData[key]
    end

    self:Print("Imported data for " .. #parsed .. " players.")
    return true
end

function BR:GetModifier(playerName)
    -- playerName may be "Name-Realm", strip realm
    local name = playerName:match("^([^%-]+)") or playerName
    local entry = self.PlayerData[name:lower()]
    if entry then
        return entry.rollModifier
    end
    return nil
end

function BR:InitMinimapButton()
    local LDB = LibStub("LibDataBroker-1.1")
    local LDBIcon = LibStub("LibDBIcon-1.0")

    if not BalancedRollsDB.MinimapButton then
        BalancedRollsDB.MinimapButton = {}
    end

    local dataBroker = LDB:NewDataObject("BalancedRolls", {
        type = "data source",
        text = "Balanced Rolls",
        icon = "Interface/AddOns/Gargul_BalancedRolls/Assets/Icons/dice",
        OnClick = function(_, button)
            if button == "LeftButton" then
                BR:ToggleImportWindow()
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("Balanced Rolls")
            tooltip:AddLine("|cFFFFFFFFLeft-click:|r Open import window", 1, 1, 1)
        end,
    })

    LDBIcon:Register("BalancedRolls", dataBroker, BalancedRollsDB.MinimapButton)
end

-- Slash command
SLASH_BALANCEDROLLS1 = "/br"
SLASH_BALANCEDROLLS2 = "/balancedrolls"
SlashCmdList["BALANCEDROLLS"] = function()
    BR:ToggleImportWindow()
end

-- Bootstrap on addon load
BR.EventFrame:RegisterEvent("ADDON_LOADED")
BR.EventFrame:SetScript("OnEvent", function(_, event, addonName)
    if event == "ADDON_LOADED" and addonName == "Gargul_BalancedRolls" then
        BR.EventFrame:UnregisterEvent("ADDON_LOADED")
        -- Defer init slightly so Gargul is fully loaded
        C_Timer.After(0, function()
            BR:Init()
        end)
    end
end)
