import "Turbine";
import "Turbine.Gameplay";
import "Turbine.UI.Lotro";

import "CubePlugins.SubscriberBuffsReminder.Functions";
import "CubePlugins.SubscriberBuffsReminder.Strings";
import "CubePlugins.SubscriberBuffsReminder.Options";
import "CubePlugins.SubscriberBuffsReminder.Settings";

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
LocalPlayer = Turbine.Gameplay.LocalPlayer.GetInstance();
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
