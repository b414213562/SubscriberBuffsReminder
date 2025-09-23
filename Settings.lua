
SettingsDataScope = Turbine.DataScope.Account;
SettingsFilename = "SubscriberBuffsReminder_Settings";

SETTINGS = {};

function SaveSettings()


    Turbine.PluginData.Save(
        SettingsDataScope,
        SettingsFilename,
        SETTINGS,
        nil);
end

function LoadSettings()
    local loadedSettings = Turbine.PluginData.Load(
        SettingsDataScope,
        SettingsFilename,
        nil);

    -- did we load something good?
    if (type(loadedSettings) == 'table') then
        -- Yes, use what we loaded
        SETTINGS = loadedSettings;

        if (not SETTINGS.SavedTime) then SETTINGS.SavedTime = {}; end

        SETTINGS.SavedTime.Days = SETTINGS.SavedTime.Days;
        SETTINGS.SavedTime.Hours = SETTINGS.SavedTime.Hours;
        SETTINGS.SavedTime.Minutes = SETTINGS.SavedTime.Minutes;
        SETTINGS.SavedTime.Seconds = SETTINGS.SavedTime.Seconds;
    else
        -- No, start with the default values, they're OK.
        SETTINGS = deepcopy(DEFAULT_SETTINGS);
    end
end

DEFAULT_SETTINGS = {
    SavedTime = {
        Days = "1";
        Hours = "0";
        Minutes = "0";
        Seconds = "0";
    };
};

function GetSavedSeconds()
    local seconds = 0;

    if (SETTINGS and SETTINGS.SavedTime) then
        if (SETTINGS.SavedTime.Seconds) then
            seconds = seconds + SETTINGS.SavedTime.Seconds;
        end
        if (SETTINGS.SavedTime.Minutes) then
            seconds = seconds + SETTINGS.SavedTime.Minutes * 60;
        end
        if (SETTINGS.SavedTime.Hours) then
            seconds = seconds + SETTINGS.SavedTime.Hours * 60 * 60;
        end
        if (SETTINGS.SavedTime.Days) then
            seconds = seconds + SETTINGS.SavedTime.Days * 24 * 60 * 60;
        end
    end

    return seconds;
end
