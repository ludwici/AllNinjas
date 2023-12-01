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
    -- self:RawHook("QuestInfo_ShowTitle", "QuestInfo_ShowTitle", true);
    self:RawHook("GetQuestLogTitle", "GetQuestLogTitle", true);
    self:RawHook("GetQuestLogQuestText", "GetQuestLogQuestText", true);
    self:RawHook("GetQuestLogLeaderBoard", "GetQuestLogLeaderBoard", true);
    self:RawHook("GetQuestLogCompletionText", "GetQuestLogCompletionText", true);

    -- REWARD_ITEMS_ONLY - "Вы получите"
end

local function FormatQuestText(questText)
    questText = string.gsub(questText, "$[Nn]", UnitName("player"));
    -- questText = string.gsub(questText, "$[Cc]", strlower(UnitClass("player")));
    -- questText = string.gsub(questText, "$[Rr]", strlower(UnitRace("player")));
    questText = string.gsub(questText, "$[Bb]", "\n");
    return string.gsub(questText, "($[Gg])([^:]+):([^;]+);", "%"..UnitSex("player"));
end

function AllNinjas:LoadDefaults()
    QuestInfoDescriptionHeader:SetText(self:GetGlobalValue("QUEST_DESCRIPTION"));
    QuestInfoRewardsHeader:SetText(self:GetGlobalValue("QUEST_REWARDS"));
    QuestInfoItemChooseText:SetText(self:GetGlobalValue("REWARD_CHOICES"));
    QuestInfoXPFrameReceiveText:SetText(self:GetGlobalValue("EXPERIENCE_COLON"));
    QuestLogFrameTrackButton:SetText(self:GetGlobalValue("TRACK_QUEST_ABBREV"));
    QuestLogFramePushQuestButton:SetText(self:GetGlobalValue("SHARE_QUEST_ABBREV"));
    QuestLogFrameAbandonButton:SetText(self:GetGlobalValue("ABANDON_QUEST_ABBREV"));
    QuestLogFrameCancelButton:SetText(self:GetGlobalValue("CLOSE"));
    GossipFrameGreetingGoodbyeButton:SetText(self:GetGlobalValue("GOODBYE"));
    QuestFrameGreetingGoodbyeButton:SetText(self:GetGlobalValue("GOODBYE"));
    BattlefieldFrameJoinButton:SetText(self:GetGlobalValue("BATTLEFIELD_JOIN"));
    BattlefieldFrameGroupJoinButton:SetText(self:GetGlobalValue("BATTLEFIELD_GROUP_JOIN"));
    BattlefieldFrameCancelButton:SetText(self:GetGlobalValue("CANCEL"));
    QuestFrameCompleteQuestButton:SetText(self:GetGlobalValue("COMPLETE_QUEST"));
    QuestFrameCancelButton:SetText(self:GetGlobalValue("CANCEL"));
    QuestFrameAcceptButton:SetText(self:GetGlobalValue("ACCEPT"));
    QuestFrameDeclineButton:SetText(self:GetGlobalValue("DECLINE"));
    QuestInfoObjectivesHeader:SetText(self:GetGlobalValue("QUEST_OBJECTIVES"));
    QuestFrameCompleteButton:SetText(self:GetGlobalValue("CONTINUE"));
    QuestFrameGoodbyeButton:SetText(self:GetGlobalValue("CANCEL"));

    QuestLogFrameTrackButton:SetScript("OnEnter", function (frame)
		GameTooltip_AddNewbieTip(frame, self:GetGlobalValue("TRACK_QUEST"), 1.0, 1.0, 1.0, self:GetGlobalValue("NEWBIE_TOOLTIP_TRACKQUEST"), 1);
    end);
    QuestLogFrameAbandonButton:SetScript("OnEnter", function (frame)
		GameTooltip_AddNewbieTip(frame, self:GetGlobalValue("ABANDON_QUEST"), 1.0, 1.0, 1.0, self:GetGlobalValue("NEWBIE_TOOLTIP_ABANDONQUEST"), 1);
    end);
    QuestLogFramePushQuestButton:SetScript("OnEnter", function (frame)
		GameTooltip_AddNewbieTip(frame, self:GetGlobalValue("SHARE_QUEST"), 1.0, 1.0, 1.0, self:GetGlobalValue("NEWBIE_TOOLTIP_SHAREQUEST"), 1);
    end);
end

function AllNinjas:WatchFrame_Update()
    WatchFrameTitle:SetText(self:GetGlobalValue("OBJECTIVES_TRACKER_LABEL"));
end

function AllNinjas:GetQuestLogLeaderBoard(objIndex, questIndex)
    local text, type, finished = self.hooks.GetQuestLogLeaderBoard(objIndex, questIndex);
    local qId = self:GetQuestIDFromLog(GetQuestLogSelection());
    local questInfo = AllNinjasData.quests[self.currentKey][qId];
    if (questInfo and questInfo.ol) then
        if (objIndex <= #questInfo.ol) then
            if (type == "item") then
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
		BattlefieldFrameGroupJoinButton:SetText(self:GetGlobalValue("JOIN_AS_PARTY"));
	else
		BattlefieldFrameGroupJoinButton:SetText(self:GetGlobalValue("JOIN_AS_GROUP"));
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
    local questInfo = AllNinjasData.quests[self.currentKey][qId];
    if (questInfo and questInfo.o) then
        obj = questInfo.o;
        print(obj);
    end
    return obj;
end

function AllNinjas:GetQuestLogQuestText()
    local desc, objectives = self.hooks.GetQuestLogQuestText();
    local qId = self:GetQuestIDFromLog(GetQuestLogSelection());
    local questInfo = AllNinjasData.quests[self.currentKey][qId];
    if (questInfo) then
        if (questInfo.d) then
            desc = FormatQuestText(questInfo.d);
        end
        if (questInfo.o) then
            objectives = questInfo.o;
        end
    end
    return desc, objectives;
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
    -- print(index)
    local qId = self:GetQuestIDFromLog(index);
    if (not qId) then
        return;
    end
    QuestLogFrame.currentIdLabel:SetText("Id: "..qId);
    -- print(qId, type(qId))
    -- local questInfo = AllNinjasData.quests[self.currentKey][qId];
    -- print(questInfo)
    -- if (not questInfo) then
    --     return;
    -- end
    -- if (questInfo.t) then
    --     QuestInfoTitleHeader:SetText(questInfo.t);
    -- end
    -- if (questInfo.d) then
    --     QuestInfoDescriptionText:SetText(questInfo.d);
    -- end
    -- QuestInfoTitleHeader:SetText(questTitle);
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