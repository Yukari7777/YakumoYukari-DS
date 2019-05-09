YAKUMOYUKARI_MODNAME = KnownModIndex:GetModActualName("Yakumo Yukari")
DLC_ENABLED_FLAG = 0 + (IsDLCEnabled(REIGN_OF_GIANTS) and 1 or 0) + (IsDLCEnabled(CAPY_DLC) and 2 or 0) + (IsDLCEnabled(PORKLAND_DLC) and 4 or 0)
-- ROG = 1, SW = 2, HL = 4 

if YUKARI_LANGUAGE == "AUTO" then
	for _, moddir in ipairs(KnownModIndex:GetModsToLoad()) do
		local modname = KnownModIndex:GetModInfo(moddir).name
--		if modname == "한글 모드 서버 버전" or modname == "한글 모드 클라이언트 버전" then 
--			YUKARI_LANGUAGE = "kr"
		if modname == "Chinese Language Pack" or modname == "Chinese Plus" then
			YUKARI_LANGUAGE = "ch"
--		elseif modname == "Russian Language Pack" or modname == "Russification Pack for DST" or modname == "Russian For Mods (Client)" then
--			YUKARI_LANGUAGE = "ru"
		end 
	end 
end

YUKARISTATINDEX = { "health", "hunger", "sanity", "power" }