-- ============================================
--  Locals
-- ============================================

local AddonName = "PlayerTools"
local PlayerTools_LogInTime = GetTime()
local menuLoaded = false
local waitForRoster

-- ============================================
--  PlayerTools: Custom UnitPopup menu entries
-- ============================================

UnitPopupButtons["PLAYERTOOLS_INVITE_GUILD"] = {
    text = "|cffffa64dInvite to Guild|r",
    dist = 0,
}

UnitPopupButtons["PLAYERTOOLS_ARMORY"] = {
    text = "|cffe6c07dArmory Link|r",
    dist = 0,
}

UnitPopupButtons["PLAYERTOOLS_LOG"] = {
    text = "|cff80d4ffLog Link|r",
    dist = 0,
}

UnitPopupButtons["PLAYERTOOLS_SEPARATOR"] = {
    text = "|cff606060····································|r",
    dist = 0,
    disabled = 1,
    notClickable = 1,
}

-- ============================================
--  Add our entries to the unit popup menus
-- ============================================

local function PlayerTools_AddToMenu(menuKey)
    if not UnitPopupMenus[menuKey] then
        return
    end

    table.insert(UnitPopupMenus[menuKey], "PLAYERTOOLS_SEPARATOR")

    local _, _, _, _, _, _, canGuildInvite = GuildControlGetRankFlags()

    if (canGuildInvite) then
        table.insert(UnitPopupMenus[menuKey], "PLAYERTOOLS_INVITE_GUILD")
    end

    table.insert(UnitPopupMenus[menuKey], "PLAYERTOOLS_ARMORY")
    table.insert(UnitPopupMenus[menuKey], "PLAYERTOOLS_LOG")
end

local function PlayerTools_SetupMenus()
    PlayerTools_AddToMenu("SELF")
    PlayerTools_AddToMenu("PLAYER")
    PlayerTools_AddToMenu("PARTY")
    PlayerTools_AddToMenu("FRIEND")
    PlayerTools_AddToMenu("RAID")
end

-- ============================================
--  Sort the guild by names and then by ranks.
-- ============================================

local function PlayerTools_GuildSort()
    SortGuildRoster("name")
    SortGuildRoster("rank")
    SortGuildRoster("rank")
end

-- ============================================
--  Event handling
-- ============================================

local PlayerTools_EventFrame = CreateFrame("Frame")
PlayerTools_EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
PlayerTools_EventFrame:RegisterEvent("ADDON_LOADED")
PlayerTools_EventFrame:RegisterEvent("GUILD_ROSTER_UPDATE")

PlayerTools_EventFrame:SetScript("OnEvent", function()
    if (event == "ADDON_LOADED") and (arg1 == AddonName) then
        -- Maybe something here, now it's ready.
        PlayerTools_EventFrame:UnregisterEvent("ADDON_LOADED")
    elseif (event == "PLAYER_ENTERING_WORLD") then
        if IsInGuild() then
            GuildRoster()
            waitForRoster = "YES"
            PlayerTools_LogInTime = GetTime()
        else
            waitForRoster = "NO"
        end
        PlayerTools_EventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    elseif (event == "GUILD_ROSTER_UPDATE") then
        -- In some cases the addon may take a while (10–60 seconds) to initialize after logging in.
        -- This happens because PlayerTools must wait for GuildControlGetRankFlags() to return valid guild-permission data before the right-click menu entries can be safely added.
        -- The delay depends entirely on how quickly the server provides this information, and the timing can vary from login to login.
        -- There is currently no reliable way to speed this up without risking incorrect or missing menu entries.
        local guildchat_listen, _, _, _, _, _, canGuildInvite = GuildControlGetRankFlags()
        if (waitForRoster == "YES") then
            if (guildchat_listen) then
                if (canGuildInvite) then
                    createMenu = true
                    PlayerTools_EventFrame:UnregisterEvent("GUILD_ROSTER_UPDATE")
                else
                    waitForRoster = "NO"
                    PlayerTools_EventFrame:UnregisterEvent("GUILD_ROSTER_UPDATE")
                end
            end
        end
    end
end)

-- ============================================
--  OnUpdate
-- ============================================

PlayerTools_EventFrame:SetScript("OnUpdate", function()
    if (waitForRoster == "YES") and (createMenu) then
        if (PlayerTools_LogInTime) and ((PlayerTools_LogInTime + 5) < GetTime()) and (menuLoaded == false) then
            PlayerTools_SetupMenus()
            menuLoaded = true
            DEFAULT_CHAT_FRAME:AddMessage("|cffFF8000" .. AddonName .. "|r" .. " by " .. "|cFFFFF468" .. "Subby" .. "|r" .. " is loaded.")
            waitForRoster = false
            PlayerTools_GuildSort()
        end
    elseif (waitForRoster == "NO") then
        if (PlayerTools_LogInTime) and ((PlayerTools_LogInTime + 5) < GetTime()) and (menuLoaded == false) then
            PlayerTools_SetupMenus()
            menuLoaded = true
            DEFAULT_CHAT_FRAME:AddMessage("|cffFF8000" .. AddonName .. "|r" .. " by " .. "|cFFFFF468" .. "Subby" .. "|r" .. " is loaded.")
            waitForRoster = false
            PlayerTools_GuildSort()
        end
    end
end)

-- ============================================
--  URL encoding helper
-- ============================================

local function PlayerTools_UrlEncode(str)
    if not str then return "" end
    return string.gsub(str, " ", "%%20")
end

-- ============================================
--  Movable One-Line Copy Popup
-- ============================================

local PlayerToolsCopyFrame = CreateFrame("Frame", "PlayerToolsCopyFrame", UIParent)
    PlayerToolsCopyFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

    PlayerToolsCopyFrame:SetWidth(380)
    PlayerToolsCopyFrame:SetHeight(90)

    PlayerToolsCopyFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\White8x8",
        tile = true, tileSize = 8,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    PlayerToolsCopyFrame:SetBackdropColor(0, 0, 0, 0.7)
    PlayerToolsCopyFrame:Hide()

    PlayerToolsCopyFrame:EnableMouse(true)
    PlayerToolsCopyFrame:SetMovable(true)
    PlayerToolsCopyFrame:RegisterForDrag("LeftButton")
    PlayerToolsCopyFrame:SetScript("OnDragStart", function() this:StartMoving() end)
    PlayerToolsCopyFrame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)

local PlayerToolsCopyLabel = PlayerToolsCopyFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    PlayerToolsCopyLabel:SetPoint("TOPLEFT", PlayerToolsCopyFrame, "TOPLEFT", 10, -10)
    PlayerToolsCopyLabel:SetText("Press Ctrl+C to copy")
    PlayerToolsCopyLabel:SetTextColor(1, 0.82, 0)

local PlayerToolsLinkBox = CreateFrame("EditBox", nil, PlayerToolsCopyFrame)
    PlayerToolsLinkBox:SetPoint("TOPLEFT", PlayerToolsCopyLabel, "BOTTOMLEFT", 0, -5)
    PlayerToolsLinkBox:SetWidth(350)
    PlayerToolsLinkBox:SetHeight(25)
    PlayerToolsLinkBox:SetFontObject(GameFontHighlight)

    PlayerToolsLinkBox:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    PlayerToolsLinkBox:SetBackdropColor(0.1, 0.1, 0.1, 1)
    PlayerToolsLinkBox:SetTextInsets(5, 5, 0, 0)
    PlayerToolsLinkBox:SetScript("OnEscapePressed", function() PlayerToolsCopyFrame:Hide() end)

local PlayerToolsCloseBtn = CreateFrame("Button", nil, PlayerToolsCopyFrame, "UIPanelButtonTemplate")
    PlayerToolsCloseBtn:SetPoint("TOPRIGHT", PlayerToolsLinkBox, "BOTTOMRIGHT", 0, -5)
    PlayerToolsCloseBtn:SetWidth(70)
    PlayerToolsCloseBtn:SetHeight(22)
    PlayerToolsCloseBtn:SetText("CLOSE")
    PlayerToolsCloseBtn:SetScript("OnClick", function() PlayerToolsCopyFrame:Hide() end)

-- ============================================
--  Popup display function
-- ============================================

function PlayerTools_ShowCopyPopup(url)
    PlayerToolsCopyFrame:Show()
    PlayerToolsLinkBox:SetText(url)
    PlayerToolsLinkBox:SetFocus()
    PlayerToolsLinkBox:HighlightText()

    PlaySoundFile("Interface\\AddOns\\PlayerTools\\Sounds\\Click.wav")
end

-- ============================================
--  Click handling (Vanilla-style)
-- ============================================

local Original_UnitPopup_OnClick = UnitPopup_OnClick

function UnitPopup_OnClick()
    if not this then
        return Original_UnitPopup_OnClick()
    end

    local button = this.value
    local dropdownFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)
    if not dropdownFrame then
        return Original_UnitPopup_OnClick()
    end

    local name = dropdownFrame.name
    if not name then
        return Original_UnitPopup_OnClick()
    end

    -- 1) Invite to Guild
    if button == "PLAYERTOOLS_INVITE_GUILD" then
        if GuildInvite then
            GuildInvite(name)
        elseif GuildInviteByName then
            GuildInviteByName(name)
        elseif SlashCmdList and SlashCmdList["GUILD_INVITE"] then
            SlashCmdList["GUILD_INVITE"](name)
        end
        DEFAULT_CHAT_FRAME:AddMessage("Guild invite sent to: " .. name)
        CloseDropDownMenus()
        return
    end

    -- 2) Armory Link
    if button == "PLAYERTOOLS_ARMORY" then
        local realm = GetCVar("realmName") or "UnknownRealm"
        local realmEnc = PlayerTools_UrlEncode(realm)
        local nameEnc  = PlayerTools_UrlEncode(name)
        local link = "https://turtlecraft.gg/armory/" .. realmEnc .. "/" .. nameEnc
        PlayerTools_ShowCopyPopup(link)
        CloseDropDownMenus()
        return
    end

    -- 3) Log Link
    if button == "PLAYERTOOLS_LOG" then
        local realm = GetCVar("realmName") or "UnknownRealm"
        local realmEnc = PlayerTools_UrlEncode(realm)
        local nameEnc = PlayerTools_UrlEncode(name)
        local link = "https://turtlogs.com/armory/character/Turtle%20WoW%20" .. realmEnc .. "/" .. nameEnc
        PlayerTools_ShowCopyPopup(link)
        CloseDropDownMenus()
        return
    end

    return Original_UnitPopup_OnClick()
end