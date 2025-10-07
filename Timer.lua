-- A class-free variant of the timer in Deed Tracker

---A helper function to make a timer.
---@param timeoutMS number
---@param autoRepeat boolean
---@param callback function
---@return Control
function MakeTimer(timeoutMS, autoRepeat, callback)
    local timer = Turbine.UI.Control();
    timer.Update = function(sender, args) UpdateTimer(timer); end

    if (timeoutMS <= 0) then
        error("Can't make a timer for no time.");
    end
    if (callback == nil) then
        error("Can't make a timer without a callback");
    end

    timer.timeoutMS = timeoutMS;
    timer.autoRepeat = autoRepeat;
    timer.callback = callback;
    return timer;
end

function StartTimer(timer)
    local time = Turbine.Engine.GetGameTime();
    timer.endTime = time + (timer.timeoutMS / 1000);
    timer:SetWantsUpdates(true);
end

function StopTimer(timer)
    timer:SetWantsUpdates(false);
end

function UpdateTimer(timer)
    local time = Turbine.Engine.GetGameTime();
    if (time >= timer.endTime) then
        if (timer.autoRepeat) then
            StartTimer(timer);
        else
            StopTimer(timer);
        end
        timer.callback();
    end
end
