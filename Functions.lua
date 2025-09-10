
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