local _G, tonumber = _G, tonumber

AllNinjas = LibStub("AceAddon-3.0"):NewAddon("AllNinjas", "AceEvent-3.0", "AceHook-3.0")
AllNinjas.version = GetAddOnMetadata("AllNinjas", "Version");
AllNinjas.currentKey = "ruRU";

AllNinjasData = {};
AllNinjasData.quests = {};
AllNinjasData.globals = {};

function AllNinjas:OnInitialize()
    print("AllNinjas "..self.version.." loaded");

    self:LoadDefaults();

    QuestLogFrame.currentIdLabel = QuestLogFrame:CreateFontString();
    QuestLogFrame.currentIdLabel:SetFont("Fonts\\FRIZQT__.TTF", 12);
    QuestLogFrame.currentIdLabel:SetSize(100, 36);
    QuestLogFrame.currentIdLabel:SetText("Id:");
    QuestLogFrame.currentIdLabel:SetPoint("LEFT", QuestLogCount, "RIGHT");
    QuestLogFrame.currentIdLabel:SetJustifyH("LEFT");

    -- self:RegisterEvent("QUEST_LOG_UPDATE");
    -- SideQuestTitle:GetText() = Large Snake

    self:SecureHook("QuestLog_SetSelection", "QuestLog_SetSelection");
    self:SecureHook("QuestLog_Update", "QUEST_LOG_UPDATE");
    self:SecureHook("QuestInfo_ShowObjectives", "QuestInfo_ShowObjectives");
    self:SecureHook("WatchFrame_Update", "WatchFrame_Update");
    self:SecureHook("BattlefieldFrame_Update", "BattlefieldFrame_Update");
    self:SecureHook("FriendsFrame_Update", "FriendsFrame_Update");
    self:SecureHook("PendingList_UpdateTab", "PendingList_UpdateTab");
    self:SecureHook("GuildStatus_Update", "GuildStatus_Update");
    self:SecureHook("WhoList_Update", "WhoList_Update");
    self:SecureHook("QuestLog_UpdateQuestCount", "QuestLog_UpdateQuestCount");
    -- self:RawHook("QuestInfo_ShowTitle", "QuestInfo_ShowTitle", true);
    self:RawHook("GetQuestLogTitle", "GetQuestLogTitle", true);
    self:RawHook("GetQuestLogQuestText", "GetQuestLogQuestText", true);
    self:RawHook("GetQuestLogLeaderBoard", "GetQuestLogLeaderBoard", true);
    self:RawHook("GetQuestLogCompletionText", "GetQuestLogCompletionText", true);
    self:RawHook("GetProgressText", "GetProgressText", true);
    self:RawHook("GetItemInfo", "GetItemInfo", true);
    self:RawHook("GameTooltip_OnTooltipAddMoney", "GameTooltip_OnTooltipAddMoney", true);

    self:HookScript(GameTooltip, "OnTooltipSetItem", "ItemTooltip");
	self:HookScript(ItemRefTooltip, "OnTooltipSetItem",	"ItemTooltip");
	self:HookScript(ItemRefShoppingTooltip1, "OnTooltipSetItem", "ItemTooltip");
	self:HookScript(ItemRefShoppingTooltip2, "OnTooltipSetItem", "ItemTooltip");
	self:HookScript(ItemRefShoppingTooltip3, "OnTooltipSetItem", "ItemTooltip");
	self:HookScript(ShoppingTooltip1, "OnTooltipSetItem", "ItemTooltip");
	self:HookScript(ShoppingTooltip2, "OnTooltipSetItem", "ItemTooltip");
	self:HookScript(ShoppingTooltip3, "OnTooltipSetItem", "ItemTooltip");

    -- REWARD_ITEMS_ONLY - "Вы получите"
end

local function FormatQuestText(questText)
    questText = string.gsub(questText, "$[Nn]", UnitName("player"));
    -- questText = string.gsub(questText, "$[Cc]", strlower(UnitClass("player")));
    -- questText = string.gsub(questText, "$[Rr]", strlower(UnitRace("player")));
    questText = string.gsub(questText, "$[Bb]", "\n");
    return string.gsub(questText, "($[Gg])([^:]+):([^;]+);", "%"..UnitSex("player"));
end

function AllNinjas:ItemTooltip(tooltip)
    local _, link = tooltip:GetItem();
    if (not link) then
        return;
    end
	local id = tonumber(string.match(link, "item:(%d*)"));
    if (not id) then
        return;
    end
    local itemInfo = AllNinjasData.items[self.currentKey][id];
    if (not itemInfo) then
        return;
    end
    local toolTipName = tooltip:GetName();
    if (itemInfo.t) then
        _G[toolTipName.."TextLeft1"]:SetText(itemInfo.t);
    end
    local startIndex = 2;
    local str = _G[toolTipName.."TextLeft2"]
    local text;
    -- print(str:GetText());
    local textColor;
    while (str) do
        text = str:GetText();
        if (text and text ~= "" and text ~= " ") then
            -- print("start_", text, "_end");
            textColor = {str:GetTextColor()};
            -- print(textColor[1], textColor[2], textColor[3], textColor[4]);
            if (string.find(text, ITEM_BIND_ON_PICKUP)) then
                -- print(text);
                -- textColor = {str:GetTextColor()};
                -- print(textColor[1], textColor[2], textColor[3], textColor[4]);
                str:SetText(string.gsub(text, ITEM_BIND_ON_PICKUP, self:GetGlobalValue("ITEM_BIND_ON_PICKUP")));
                str:SetTextColor(textColor[1], textColor[2], textColor[3], textColor[4]);
            elseif (string.sub(text, 1, 1) == '"' and string.sub(text, -1) == '"') then
                -- print("Desc:", text);
                str:SetText(text:gsub('"(.-)"', '"'..itemInfo.d..'"'));
            elseif (string.find(text, SELL_PRICE)) then
                str:SetText(string.gsub(text, SELL_PRICE, self:GetGlobalValue("SELL_PRICE")));
            end
            str:SetTextColor(textColor[1], textColor[2], textColor[3], textColor[4]);
        end
        startIndex = startIndex + 1;
        str = _G[toolTipName.."TextLeft"..startIndex];
    end
end

function AllNinjas:UISetText(button, text)
    button:SetText(self:GetGlobalValue(text));
end

function AllNinjas:LoadDefaults()
    self:UISetText(FriendsFrameSendMessageButton, "SEND_MESSAGE");
    self:UISetText(FriendsFrameAddFriendButton, "ADD_FRIEND");
    self:UISetText(FriendsTabHeaderTab3, "PENDING_INVITE");
    self:UISetText(FriendsTabHeaderTab2, "IGNORE");
    self:UISetText(FriendsTabHeaderTab1, "FRIENDS");
    self:UISetText(QuestInfoItemChooseText, "REWARD_CHOICES");
    self:UISetText(QuestInfoXPFrameReceiveText, "EXPERIENCE_COLON");
    self:UISetText(QuestLogFrameTrackButton, "TRACK_QUEST_ABBREV");
    self:UISetText(QuestLogFramePushQuestButton, "SHARE_QUEST_ABBREV");
    self:UISetText(QuestLogFrameAbandonButton, "ABANDON_QUEST_ABBREV");
    self:UISetText(QuestLogFrameCancelButton, "CLOSE");
    self:UISetText(GossipFrameGreetingGoodbyeButton, "GOODBYE");
    self:UISetText(QuestFrameGreetingGoodbyeButton, "GOODBYE");
    self:UISetText(BattlefieldFrameJoinButton, "BATTLEFIELD_JOIN");
    self:UISetText(BattlefieldFrameGroupJoinButton, "BATTLEFIELD_GROUP_JOIN");
    self:UISetText(BattlefieldFrameCancelButton, "CANCEL");
    self:UISetText(QuestFrameCompleteQuestButton, "COMPLETE_QUEST");
    self:UISetText(QuestFrameCancelButton, "CANCEL");
    self:UISetText(QuestFrameAcceptButton, "ACCEPT");
    self:UISetText(QuestFrameDeclineButton, "DECLINE");
    self:UISetText(QuestInfoObjectivesHeader, "QUEST_OBJECTIVES");
    self:UISetText(QuestFrameCompleteButton, "CONTINUE");
    self:UISetText(QuestFrameGoodbyeButton, "CANCEL");
    self:UISetText(QuestProgressRequiredItemsText, "TURN_IN_ITEMS");
    self:UISetText(CharacterFrameTab1, "CHARACTER");
    self:UISetText(CharacterFrameTab2, "PETS");
    self:UISetText(CharacterFrameTab3, "REPUTATION_ABBR");
    self:UISetText(CharacterFrameTab4, "SKILLS_ABBR");
    self:UISetText(CharacterFrameTab5, "CURRENCY");
    self:UISetText(FriendsFrameTab1, "FRIENDS");
    self:UISetText(FriendsFrameTab2, "WHO");
    self:UISetText(FriendsFrameTab3, "GUILD");
    -- FriendsFrameTab3:SetText(string.sub(AllNinjas:GetGlobalValue("GUILD"), 1, 3));
    self:UISetText(QuestInfoRewardsHeader, "QUEST_REWARDS");
    self:UISetText(QuestInfoDescriptionHeader, "QUEST_DESCRIPTION");
    self:UISetText(WhoFrameColumnHeader1, "NAME");
    self:UISetText(WhoFrameColumnHeader3, "LEVEL_ABBR");
    self:UISetText(WhoFrameColumnHeader4, "CLASS");
    self:UISetText(WhoFrameGroupInviteButton, "GROUP_INVITE");
    self:UISetText(WhoFrameAddFriendButton, "ADD_FRIEND");
    self:UISetText(WhoFrameWhoButton, "REFRESH");
    self:UISetText(GuildFrameColumnHeader1, "NAME");
    self:UISetText(GuildFrameColumnHeader2, "ZONE");
    self:UISetText(GuildFrameColumnHeader3, "LEVEL_ABBR");
    self:UISetText(GuildFrameColumnHeader4, "CLASS");
    self:UISetText(GuildFrameLFGButtonText, "SHOW_OFFLINE_MEMBERS");
    self:UISetText(GuildFrameNotesLabel, "GUILD_MOTD_LABEL");
    self:UISetText(GuildFrameGuildStatusColumnHeader1, "NAME");
    self:UISetText(GuildFrameGuildStatusColumnHeader2, "RANK");
    self:UISetText(GuildFrameGuildStatusColumnHeader3, "LABEL_NOTE");
    self:UISetText(GuildFrameGuildStatusColumnHeader4, "LASTONLINE");

    QuestLogFrameTrackButton:SetScript("OnEnter", function (frame)
		GameTooltip_AddNewbieTip(frame, self:GetGlobalValue("TRACK_QUEST"), 1.0, 1.0, 1.0, self:GetGlobalValue("NEWBIE_TOOLTIP_TRACKQUEST"), 1);
    end);
    QuestLogFrameAbandonButton:SetScript("OnEnter", function (frame)
		GameTooltip_AddNewbieTip(frame, self:GetGlobalValue("ABANDON_QUEST"), 1.0, 1.0, 1.0, self:GetGlobalValue("NEWBIE_TOOLTIP_ABANDONQUEST"), 1);
    end);
    QuestLogFramePushQuestButton:SetScript("OnEnter", function (frame)
		GameTooltip_AddNewbieTip(frame, self:GetGlobalValue("SHARE_QUEST"), 1.0, 1.0, 1.0, self:GetGlobalValue("NEWBIE_TOOLTIP_SHAREQUEST"), 1);
    end);
    CharacterFrameTab1:SetScript("OnEnter", function (frame)
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
        GameTooltip:SetText(MicroButtonTooltipText(self:GetGlobalValue("CHARACTER_INFO"), "TOGGLECHARACTER0"), 1.0, 1.0, 1.0);
    end);
    CharacterFrameTab2:SetScript("OnEnter", function (frame)
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
        GameTooltip:SetText(MicroButtonTooltipText(self:GetGlobalValue("PETS"), "TOGGLECHARACTER3"), 1.0, 1.0, 1.0);
    end);
    CharacterFrameTab3:SetScript("OnEnter", function (frame)
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
        GameTooltip:SetText(MicroButtonTooltipText(self:GetGlobalValue("REPUTATION"), "TOGGLECHARACTER2"), 1.0, 1.0, 1.0);
    end);
    CharacterFrameTab4:SetScript("OnEnter", function (frame)
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
        GameTooltip:SetText(MicroButtonTooltipText(self:GetGlobalValue("SKILLS"), "TOGGLECHARACTER1"), 1.0, 1.0, 1.0);
    end);
    CharacterFrameTab5:SetScript("OnEnter", function (frame)
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
        GameTooltip:SetText(MicroButtonTooltipText(self:GetGlobalValue("CURRENCY"), "TOGGLECURRENCY"), 1.0, 1.0, 1.0);
    end);
    FriendsFrameTab1:SetScript("OnEnter", function (frame)
		GameTooltip_AddNewbieTip(frame, MicroButtonTooltipText(self:GetGlobalValue("FRIENDS"), "TOGGLEFRIENDSTAB"), 1.0, 1.0, 1.0, self:GetGlobalValue("NEWBIE_TOOLTIP_FRIENDSTAB"), 1);
    end);
    FriendsFrameTab2:SetScript("OnEnter", function (frame)
		GameTooltip_AddNewbieTip(frame, MicroButtonTooltipText(self:GetGlobalValue("WHO"), "TOGGLEWHOTAB"), 1.0, 1.0, 1.0, self:GetGlobalValue("NEWBIE_TOOLTIP_WHOTAB"), 1);
    end);
    FriendsFrameTab3:SetScript("OnEnter", function (frame)
		GameTooltip_AddNewbieTip(frame, MicroButtonTooltipText(self:GetGlobalValue("GUILD"), "TOGGLEGUILDTAB"), 1.0, 1.0, 1.0, self:GetGlobalValue("NEWBIE_TOOLTIP_GUILDTAB"), 1);
    end);
    FriendsFrameAddFriendButton:SetScript("OnEnter", function (frame)
		GameTooltip_AddNewbieTip(frame, self:GetGlobalValue("ADD_FRIEND"), 1.0, 1.0, 1.0, self:GetGlobalValue("NEWBIE_TOOLTIP_ADDFRIEND"), 1);
    end);
    FriendsFrameSendMessageButton:SetScript("OnEnter", function (frame)
		GameTooltip_AddNewbieTip(frame, self:GetGlobalValue("SEND_MESSAGE"), 1.0, 1.0, 1.0, self:GetGlobalValue("NEWBIE_TOOLTIP_SENDMESSAGE"), 1);
    end);
    QuestLogDailyQuestCountMouseOverFrame:SetScript("OnEnter", function (frame)
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
        GameTooltip:SetText(format(self:GetGlobalValue("QUEST_LOG_DAILY_TOOLTIP"), GetMaxDailyQuests(), SecondsToTime(GetQuestResetTime(), nil, 1)));
    end);
end

function AllNinjas:QuestLog_UpdateQuestCount(numQuests)
	QuestLogQuestCount:SetFormattedText(self:GetGlobalValue("QUEST_LOG_COUNT_TEMPLATE"), numQuests, MAX_QUESTLOG_QUESTS);
	local dailyQuestsComplete = GetDailyQuestsCompleted();
    if (dailyQuestsComplete > 0) then
		QuestLogDailyQuestCount:SetFormattedText(self:GetGlobalValue("QUEST_LOG_DAILY_COUNT_TEMPLATE"), dailyQuestsComplete, GetMaxDailyQuests());
    end
end

function AllNinjas:WhoList_Update()
    local _, totalCount = GetNumWhoResults();
	local displayedText = "";
    if (totalCount > MAX_WHOS_FROM_SERVER) then
		displayedText = format(WHO_FRAME_SHOWN_TEMPLATE, MAX_WHOS_FROM_SERVER);
    end
	WhoFrameTotals:SetText(format(self:GetGlobalValue("WHO_FRAME_TOTAL_TEMPLATE"), totalCount).."  "..displayedText);
end

function AllNinjas:PendingList_UpdateTab()
	local numPending = BNGetNumFriendInvites();
	if (numPending > 0) then
		FriendsTabHeaderTab3:SetText(self:GetGlobalValue("PENDING_INVITE").." ("..numPending..")");
    else
        FriendsTabHeaderTab3:SetText(self:GetGlobalValue("PENDING_INVITE"));
    end
	PanelTemplates_TabResize(FriendsTabHeaderTab3, 0);
end

function AllNinjas:GuildStatus_Update()
    local numGuildMembers = GetNumGuildMembers();
	local onlinecount = 0;
    local online;
    for i = 1, numGuildMembers do
        online = select(9, GetGuildRosterInfo(i));
        if (online) then
            onlinecount = onlinecount + 1;
        end
    end
	GuildFrameTotals:SetFormattedText(self:GetGlobalValue("GUILD_TOTAL"), numGuildMembers);
	GuildFrameOnlineTotals:SetFormattedText(self:GetGlobalValue("GUILD_TOTALONLINE"), onlinecount);
    if (FriendsFrame.playerStatusFrame) then
        self:UISetText(GuildFrameGuildListToggleButton, "PLAYER_STATUS")
    else
        self:UISetText(GuildFrameGuildListToggleButton, "GUILD_STATUS")
    end
end

function AllNinjas:FriendsFrame_Update()
    if (FriendsFrame.selectedTab == 1) then
        if (FriendsTabHeader.selectedTab == 1) then
            self:UISetText(FriendsFrameTitleText, "FRIENDS_LIST");
        elseif (FriendsTabHeader.selectedTab == 3) then
            self:UISetText(FriendsFrameTitleText, "PENDING_INVITE_LIST");
        else
            self:UISetText(FriendsFrameTitleText, "IGNORE_LIST");
        end
    else
        if (FriendsFrame.selectedTab == 2) then
            self:UISetText(FriendsFrameTitleText, "WHO_LIST");
        elseif (FriendsFrame.selectedTab == 3) then
            local guildName, title = GetGuildInfo("player");
			if (guildName) then
				FriendsFrameTitleText:SetFormattedText(self:GetGlobalValue("GUILD_TITLE_TEMPLATE"), title, guildName);
			else
				FriendsFrameTitleText:SetText("");
			end
        elseif (FriendsFrame.selectedTab == 4) then
            self:UISetText(FriendsFrameTitleText, "CHAT_CHANNELS");
        elseif (FriendsFrame.selectedTab == 5) then
            self:UISetText(FriendsFrameTitleText, "RAID");
        end
    end
end

function AllNinjas:WatchFrame_Update()
    self:UISetText(WatchFrameTitle, "OBJECTIVES_TRACKER_LABEL");
end

function AllNinjas:GetQuestLogLeaderBoard(objIndex, questIndex)
    local text, type, finished = self.hooks.GetQuestLogLeaderBoard(objIndex, questIndex);
    if (not questIndex) then
        questIndex = GetQuestLogSelection();
    end

    local qId = self:GetQuestIDFromLog(questIndex);
    local questInfo = AllNinjasData.quests[self.currentKey][qId];
    if (questInfo and questInfo.ol) then
        if (objIndex <= #questInfo.ol) then
            if (type == "item" or type == "monster") then
                local _, _, _, numItems, numNeeded = string.find(text, "(.*):%s*([%d]+)%s*/%s*([%d]+)");
                text = questInfo.ol[objIndex]..": "..numItems.."/"..numNeeded;
            end
        end
    end

    return text, type, finished;
end

function AllNinjas:BattlefieldFrame_Update()
	local mapName, mapDescription, maxGroup = GetBattlefieldInfo();
    -- print(mapName, mapDescription);
    if (maxGroup and maxGroup == 5) then
        self:UISetText(BattlefieldFrameGroupJoinButton, "JOIN_AS_PARTY");
	else
        self:UISetText(BattlefieldFrameGroupJoinButton, "JOIN_AS_GROUP");
	end
end

function AllNinjas:QuestInfo_ShowObjectives()
    print("Checl")
    local numObjectives = GetNumQuestLeaderBoards();
	local objective;
    local text;
    local finished;
    for i = 1, numObjectives do
        objective = _G["QuestInfoObjective"..i];
        _, _, finished = GetQuestLogLeaderBoard(i);
        if (finished) then
            text = objective:GetText();
            objective:SetText(string.gsub(text, COMPLETE, self:GetGlobalValue("COMPLETE")));
        end
    end
end

function AllNinjas:GetQuestLogCompletionText(index)
    local obj = self.hooks.GetQuestLogCompletionText(index);
    local questInfo = self:GetQuestInfo();
    if (questInfo and questInfo.o) then
        obj = questInfo.o;
    end
    return obj;
end

function AllNinjas:GetQuestInfo()
    local qId = self:GetQuestIDFromLog(GetQuestLogSelection());
    local questInfo = AllNinjasData.quests[self.currentKey][qId];
    return questInfo;
end

function AllNinjas:GetProgressText()
    local progress = self.hooks.GetProgressText();
    -- local questInfo = self:GetQuestInfo();
    -- if (questInfo and questInfo.p) then
    --     progress = questInfo.p;
    -- end
    -- print(progress)
    return progress;
end

function AllNinjas:GetQuestLogQuestText()
    local desc, objectives = self.hooks.GetQuestLogQuestText();
    local questInfo = self:GetQuestInfo();
    if (questInfo) then
        print(questInfo.d)
        if (questInfo.d) then
            desc = FormatQuestText(questInfo.d);
        end
        if (questInfo.o) then
            objectives = questInfo.o;
        end
    end
    return desc, objectives;
end

function AllNinjas:GetItemInfo(itemID)
    local values = {self.hooks.GetItemInfo(itemID)};
    local item = AllNinjasData.items[self.currentKey][itemID];
    if (item) then
        values[1] = item.t;
    end
    return unpack(values);
end

function AllNinjas:GameTooltip_OnTooltipAddMoney(frame, cost, maxcost)
    if( not maxcost ) then
		SetTooltipMoney(frame, cost, nil, string.format("%s:", self:GetGlobalValue("SELL_PRICE")));
	else
		frame:AddLine(string.format("%s:", self:GetGlobalValue("SELL_PRICE")), 1.0, 1.0, 1.0);
		local indent = string.rep(" ",4);
		SetTooltipMoney(frame, cost, nil, string.format("%s%s:", indent, MINIMUM));
		SetTooltipMoney(frame, maxcost, nil, string.format("%s%s:", indent, MAXIMUM));
	end
end

function AllNinjas:GetQuestLogTitle(index)
    local values = {self.hooks.GetQuestLogTitle(index)};
    local qId = values[9];
    if (qId) then
        local questInfo = AllNinjasData.quests[self.currentKey][qId];
        if (questInfo and questInfo.t) then
            values[1] = questInfo.t;
        end
    end
    return unpack(values);
end

function AllNinjas:GetGlobalValue(key)
    local result = AllNinjasData.globals[self.currentKey][key];
    if (result) then
        return result;
    end
    return _G[key];
end

-- function AllNinjas:QuestInfo_ShowTitle()
--     -- local questInfo;
--     local questTitle;
--     if (QuestInfoFrame.questLog) then
--         -- find by id
--         -- questInfo = AllNinjasData.quests[self.currentKey][qId];
--         if (questInfo) then
--             questTitle = questInfo.t;
--         else
--             questTitle = GetQuestLogTitle(GetQuestLogSelection());
--         end

--         if (not questTitle) then
--             questTitle = "";
--         end

--         if (IsCurrentQuestFailed()) then
-- 			questTitle = questTitle.." - ("..self:GetGlobalValue("FAILED")..")";
-- 		end

--     else
--         -- find by title
--         questTitle = GetTitleText();
--     end
--     QuestInfoTitleHeader:SetText(questTitle);
--     print(questTitle);
--     return questTitle;
-- end

function AllNinjas:GetQuestIDFromLog(selectionId)
    local link = GetQuestLink(selectionId);
    if (link) then
        local id = tonumber(link:match(":(%d+):"));
        if (id) then
            return tonumber(id);
        end
    end
    return nil;
end

function AllNinjas:QuestLog_SetSelection(index)
    local qId = self:GetQuestIDFromLog(index);
    if (not qId) then
        return;
    end
    QuestLogFrame.currentIdLabel:SetText("Id: "..qId);
end

function AllNinjas:QUEST_LOG_UPDATE()
    local buttons = QuestLogScrollFrame.buttons;
    local numButtons = #buttons;
    local questLogTitle;
    local questTitleTag;
    -- local questInfo;
    for i = 1, numButtons do
        questLogTitle = buttons[i];
        questTitleTag = questLogTitle.tag;
        local questIndex = questLogTitle:GetID();
        local title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID, displayQuestID = GetQuestLogTitle(questIndex);
        if (isHeader) then
        else
            local origTag = questTitleTag:GetText();
            if (origTag) then
                if (string.find(origTag, COMPLETE)) then
                    questTitleTag:SetText(string.gsub(origTag, COMPLETE, self:GetGlobalValue("COMPLETE")));
                elseif (string.find(origTag, FAILED)) then
                    questTitleTag:SetText(string.gsub(origTag, FAILED, self:GetGlobalValue("FAILED")));
                elseif (string.find(origTag, DAILY)) then
                    questTitleTag:SetText(string.gsub(origTag, DAILY, self:GetGlobalValue("DAILY")));
                end
            end
        end
    end
end