
function IsClientRussian(clientLanguage)
    if (clientLanguage == Turbine.Language.English) then
        local russianAlphabet = "АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя";
        local skillName = Turbine.Gameplay.LocalPlayer.GetInstance():GetTrainedSkills():GetItem(1):GetSkillInfo():GetName();
        local firstCharacter = skillName:sub(1, 2);
        if (russianAlphabet:match(firstCharacter)) then
            return true;
        end
    end
    return false;
end

function GetClientLanguage()
    local clientLanguage = Turbine.Engine.GetLanguage();

    if (IsClientRussian(clientLanguage)) then
        clientLanguage = Turbine.Language.Russian;
    end

    return clientLanguage;
end

--This function returns a deep copy of a given table ---------------
function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

-- Basic debug function to look at a table:
function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function Debug(message)
    if (message == nil or message == "" or not SHOW_DEBUG_OUTPUT) then
        return;
    end

    Turbine.Shell.WriteLine("<rgb=#FF5555>" .. message .. "</rgb>");
end

function Info(message)
    if (message == nil or message == "") then
        return;
    end

    Turbine.Shell.WriteLine("<rgb=#55FF55>" .. message .. "</rgb>");
end
