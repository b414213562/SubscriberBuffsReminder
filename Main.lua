import "Turbine";
import "Turbine.Gameplay";
import "Turbine.UI.Lotro";

SHOW_DEBUG_OUTPUT = false;

import "CubePlugins.SubscriberBuffsReminder.Functions";
import "CubePlugins.SubscriberBuffsReminder.Strings";
import "CubePlugins.SubscriberBuffsReminder.Options";
import "CubePlugins.SubscriberBuffsReminder.Settings";
import "CubePlugins.SubscriberBuffsReminder.Timer";

LocalPlayer = Turbine.Gameplay.LocalPlayer.GetInstance();

-- If this is loaded during session play, don't do anything.
function IsSessionPlay()
    local name = LocalPlayer:GetName();

    local firstChar = name:sub(1,1);
    local isSessionPlay = firstChar == "~";

    return isSessionPlay;
end

if (IsSessionPlay()) then
    return; -- stop processing the rest of this file
end
-- End check for session play

-- On startup:
-- Figure out the client language

-- Using the client language to determine strings:
-- Look at the buffs on player
-- If we do not find subscriber buffs,
-- or if they have less than 24 hours remaining
--   then show a window that says so.
-- Once we see an update of the subscriber buffs
--   close the window if open

ClientLanguage = GetClientLanguage();
Effects = LocalPlayer:GetEffects();
BuffName = _LANG["BUFF_NAME"][ClientLanguage];

Effects.EffectAdded = function(sender, args)
    local effect = Effects:Get(args.Index);
    if (effect:GetName() == BuffName) then
        HandleSubscriberBuffs(effect);
    end
end

function CheckForSubscriberBuffs()
    for i=1, Effects:GetCount() do
        local effect = Effects:Get(i);
        if (effect:GetName() == BuffName) then
            HandleSubscriberBuffs(effect);
            return;
        end
    end
    HandleSubscriberBuffs(nil);
end

function IsBackpackItemSubscriberTownServices(item)
    local isSubscriberTownServices = item and item:GetName() == _LANG.INVENTORY_ITEM_NAME[ClientLanguage];
    return isSubscriberTownServices;
end

---Returns whether we have the Subscriber Town Services inventory item. We can't see the expiration time, so just checking for presence or absence.
---@return boolean; true if present, false if absent
function DoesBackpackContainSubscriberTownServices()
    local backpack = LocalPlayer:GetBackpack();
    for i=1, backpack:GetSize() do
        local item = backpack:GetItem(i);
        local isItem = IsBackpackItemSubscriberTownServices(item);
        if (isItem) then
            return true;
        end
    end
    return false;
end

function CheckForSubscriberTownServices()
    -- Normally, the effect will be present for the same approximate duration.
    -- Check for inventory item anyway, just in case the player threw it away accidentally.
    if (not DoesBackpackContainSubscriberTownServices()) then
        ShowWindow();
        return;
    end

end

local timerDelay = 5000; -- 5 seconds seems to work well
BackpackTimer = MakeTimer(timerDelay, false, function() CheckForSubscriberTownServices() end);
StartTimer(BackpackTimer);

LocalPlayer:GetBackpack().ItemAdded = function(sender,args)
    local item = sender:GetItem(args.Index);
    local isItem = IsBackpackItemSubscriberTownServices(item);
    if (isItem) then
        StopTimer(BackpackTimer); -- we found it, no need to look anymore!
        sender.ItemAdded = nil;
    else
        StartTimer(BackpackTimer); -- restart how much time is left on the timer.
    end
end

function HandleSubscriberBuffs(effect)
    -- If it's nil, show the window:
    if (effect == nil) then
        ShowWindow();
        return;
    end

    effect.StartTimeChanged = function(sender, args)
        HandleSubscriberBuffs(effect);
    end

    local secondsElapsed = Turbine.Engine.GetGameTime() - effect:GetStartTime();
    local secondsRemaining = effect:GetDuration() - secondsElapsed;
    local minimumSeconds = GetSavedSeconds();

    if (secondsRemaining < minimumSeconds) then
        ShowWindow();
        return;
    end

    ReminderWindow:SetVisible(false);
end

function CreateWindow()
    local displayWidth, displayHeight = Turbine.UI.Display.GetSize();
    ReminderWindow = Turbine.UI.Lotro.Window();
    ReminderWindow:SetSize(500, 200);
    ReminderWindow:SetText(_LANG["WINDOW_TITLE"][ClientLanguage]);
    ReminderWindow:SetPosition(
        (displayWidth - ReminderWindow:GetWidth()) / 2,
        (displayHeight - ReminderWindow:GetHeight()) / 3);

    local marginTop = 32;
    local marginLeft = 18;
    local marginRight = 18;
    local marginBottom = 18;

    local label = Turbine.UI.Label();
    label:SetParent(ReminderWindow);
    if (ClientLanguage == RU) then
        label:SetFont(Turbine.UI.Lotro.Font.BookAntiqua36);
    else
        label:SetFont(Turbine.UI.Lotro.Font.TrajanPro28);
    end
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
    label:SetText(_LANG["WINDOW_TEXT"][ClientLanguage]);
    label:SetSize(
        ReminderWindow:GetWidth() - marginLeft - marginRight,
        ReminderWindow:GetHeight() - marginTop - marginBottom);
    label:SetPosition(marginLeft, marginTop);
    --label:SetBackColor(Turbine.UI.Color.DarkSlateGray);
end

function ShowWindow()
    ReminderWindow:SetVisible(true);
end

function RegisterForUnload()
    Turbine.Plugin.Unload = function(sender, args)
        SaveSettings();
    end
end

RegisterForUnload();
LoadSettings();

CreateWindow();
CheckForSubscriberBuffs();
CreateOptionsControl();
