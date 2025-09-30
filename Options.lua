
function CreateOptionsControl()
    Options = Turbine.UI.Control();
    plugin.GetOptionsPanel = function(_) return Options; end

    Options:SetBackColor(Turbine.UI.Color(0.1,0.1,0.1));
    Options:SetHeight(250);

    local advancedNoticeLabel = Turbine.UI.Label();
    advancedNoticeLabel:SetParent(Options);
    advancedNoticeLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14);
    advancedNoticeLabel:SetText(_LANG.ADVANCED_NOTICE_LABEL[ClientLanguage]);
    advancedNoticeLabel:SetSize(200, 50);
    advancedNoticeLabel:SetPosition(10, 10);

    -- Add text boxes for Days, Hours, Minutes, Seconds
    -- Days: [0, 13]
    -- Hours: [0, 23]
    -- Minutes: [0, 59]
    -- Seconds: [0, 59]
    local labelWidths = { 60, 60, 60, 65, };
    local labelLefts = { 10 };
    local top = 60;
    local rowHeight = 30;
    for i = 2, #labelWidths do
        labelLefts[i] = labelLefts[i - 1] + labelWidths[i - 1];
    end
    local minMaxDefault = {
        [1] = { 0, 13, 1, };
        [2] = { 0, 23, 0, };
        [3] = { 0, 59, 0, };
        [4] = { 0, 59, 0, };
    };

    TextBoxes = {};
    for i = 1, #labelWidths do
        local label = CreateLabel(_LANG.TIME_LABELS[ClientLanguage][i]);
        local left = labelLefts[i];

        label:SetPosition(left, top);
        label:SetWidth(labelWidths[i]);

        local textBox = CreateMinMaxTextBox(i, minMaxDefault[i][1], minMaxDefault[i][2], minMaxDefault[i][3]);
        textBox:SetPosition(labelLefts[i], top + rowHeight);
        TextBoxes[i] = textBox;
    end

    -- todo: load from save file:
    LoadNoticeTime();
end

function LoadNoticeTime()
    TextBoxes[1]:SetTime(SETTINGS.SavedTime.Days);
    TextBoxes[2]:SetTime(SETTINGS.SavedTime.Hours);
    TextBoxes[3]:SetTime(SETTINGS.SavedTime.Minutes);
    TextBoxes[4]:SetTime(SETTINGS.SavedTime.Seconds);

    SaveNoticeTime();
end

function SaveNoticeTime()
    SETTINGS.SavedTime = {};
    SETTINGS.SavedTime.Days = tostring(TextBoxes[1].LastValidValue);
    SETTINGS.SavedTime.Hours = tostring(TextBoxes[2].LastValidValue);
    SETTINGS.SavedTime.Minutes = tostring(TextBoxes[3].LastValidValue);
    SETTINGS.SavedTime.Seconds = tostring(TextBoxes[4].LastValidValue);
end

function CreateLabel(text)
    local label = Turbine.UI.Label();
    label:SetParent(Options);
    label:SetFont(Turbine.UI.Lotro.Font.Verdana14);
    label:SetText(text);
    label:SetHeight(25);
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);

    return label;
end

function CreateMinMaxTextBox(index, min, max, default)
    local textBox = Turbine.UI.Lotro.TextBox();
    textBox:SetParent(Options);
    textBox.Index = index;
    textBox.LastValidValue = default;
    textBox:SetText(default);
    textBox:SetMultiline(false);
    textBox:SetSize(35, 25);

    local validate = function()
        local text = textBox:GetText();
        local value = tonumber(textBox:GetText());
        local revertValue = false;
        if (not value) then
            revertValue = true;
        elseif (value == 0 and #text > 1) then
            revertValue = true;
        else
            if (value < min) then revertValue = true; end
            if (value > max) then revertValue = true; end
        end

        if (revertValue) then
            textBox:SetText(textBox.LastValidValue);
        else
            textBox.LastValidValue = value;
            SaveNoticeTime();
        end
    end
    textBox.SetTime = function(sender, timeText)
        local value = tonumber(timeText);
        if (not value) then value = 0; end
        if (value < min) then value = min; end
        if (value > max) then value = max; end
        textBox.LastValidValue = value;
        sender:SetText(value);
    end
    textBox.TextChanged = function(sender, args)
        validate();
    end
    textBox.KeyDown = function(sender, args)
        if (args.Action == 162) then -- enter
            -- move to next box
            local change = 1;
            if (args.Shift) then change = -1; end -- or previous box
            local newI = textBox.Index + change;
            if (newI < 1) then newI = #TextBoxes; end
            if (newI > #TextBoxes) then newI = 1; end
            TextBoxes[newI]:Focus();
        end
    end
    textBox.FocusGained = function(sender, args)
        textBox:SelectAll();
    end

    textBox.KeyUp = function(sender, args)
        validate();
    end

    return textBox;
end
