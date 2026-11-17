-- Enchant Bypass for WoW Forever.
-- /epass toggles (saved). Auto-yes REPLACE_TRADESKILL_ENCHANT.

local ADDON = ...
local enabled = false

local POPUPS = {
	REPLACE_ENCHANT = true,
	REPLACE_TRADESKILL_ENCHANT = true,
}

local function Chat(msg)
	print("|cff66ccffEnchant Bypass|r: " .. msg)
end

local function DialogWhich(dialog)
	if not dialog then
		return
	end
	if dialog.which then
		return dialog.which
	end
	if dialog.GetWhich then
		return dialog:GetWhich()
	end
end

local function ForEachDialog(fn)
	if StaticPopup_ForEachShownDialog then
		StaticPopup_ForEachShownDialog(fn)
		return
	end
	for i = 1, (STATICPOPUP_NUMDIALOGS or 4) do
		local dialog = _G["StaticPopup" .. i]
		if dialog then
			fn(dialog)
		end
	end
end

local function AcceptReplace(which)
	if not enabled then
		return
	end
	ForEachDialog(function(dialog)
		if not dialog:IsShown() then
			return
		end
		local w = DialogWhich(dialog)
		if which and w and w ~= which then
			return
		end
		if w and not POPUPS[w] then
			return
		end
		if StaticPopup_OnClick then
			StaticPopup_OnClick(dialog, 1)
		end
	end)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
if not C_EventUtils or C_EventUtils.IsEventValid("REPLACE_ENCHANT") then
	frame:RegisterEvent("REPLACE_ENCHANT")
end
frame:SetScript("OnEvent", function(_, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 ~= ADDON then
			return
		end
		EnchantBypassDB = EnchantBypassDB or {}
		enabled = EnchantBypassDB.enabled == true
		if enabled then
			print("|cffff7f00EnchantBypass is active|r")
		end
	elseif event == "REPLACE_ENCHANT" then
		AcceptReplace("REPLACE_ENCHANT")
	end
end)

if hooksecurefunc and StaticPopup_Show then
	hooksecurefunc("StaticPopup_Show", function(which)
		if which and POPUPS[which] then
			AcceptReplace(which)
		end
	end)
end

SLASH_ENCHANTBYPASS1 = "/epass"
SLASH_ENCHANTBYPASS2 = "/enchantbypass"
SlashCmdList.ENCHANTBYPASS = function()
	enabled = not enabled
	EnchantBypassDB = EnchantBypassDB or {}
	EnchantBypassDB.enabled = enabled
	Chat(enabled and "on" or "off")
end
