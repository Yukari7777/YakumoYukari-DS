-- This is not for the local variable CONST I use. It is written in tunings_yukari.

YAKUMOYUKARI_MODNAME = KnownModIndex:GetModActualName("Yakumo Yukari")

RATE_SCALE = {
    NEUTRAL = 0,
    INCREASE_HIGH = 1,
    INCREASE_MED = 2,
    INCREASE_LOW = 3,
    DECREASE_HIGH = 4,
    DECREASE_MED = 5,
    DECREASE_LOW = 6,
}

if YUKARI_LANGUAGE == "AUTO" then
	for _, moddir in ipairs(KnownModIndex:GetModsToLoad()) do
		local modname = KnownModIndex:GetModInfo(moddir).name
--		if modname == "�ѱ� ��� ���� ����" or modname == "�ѱ� ��� Ŭ���̾�Ʈ ����" then 
--			YUKARI_LANGUAGE = "kr"
		if modname == "Chinese Language Pack" or modname == "Chinese Plus" then
			YUKARI_LANGUAGE = "ch"
--		elseif modname == "Russian Language Pack" or modname == "Russification Pack for DST" or modname == "Russian For Mods (Client)" then
--			YUKARI_LANGUAGE = "ru"
		end 
	end 
end

YUKARISTATINDEX = { "health", "hunger", "sanity", "power" }