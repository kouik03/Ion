﻿--Ion, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

local ION, GDB, CDB, PEW, SPEC, player, realm, btnGDB, btnCDB = Ion

ION.BUTTON = setmetatable({}, { __index = CreateFrame("CheckButton") })

local BUTTON = ION.BUTTON

local BTNIndex = ION.BTNIndex

local L = LibStub("AceLocale-3.0"):GetLocale("Ion")

local	SKIN = LibStub("Masque", true)

local MacroDrag, StartDrag, ItemCache = ION.MacroDrag, ION.StartDrag

--local copies of often used globals
local floor = math.floor
local ceil = math.ceil
local select = _G.select
local tonumber = _G.tonumber
local unpack = _G.unpack
local next = _G.next
local pi, cos, sin = math.pi, cos, sin

local HasAction = _G.HasAction
local GetTime = _G.GetTime
local UnitAura = _G.UnitAura
local UnitMana = _G.UnitMana
local UnitHasVehicleUI = _G.UnitHasVehicleUI
local InCombatLockdown = _G.InCombatLockdown
local SecureCmdOptionParse = _G.SecureCmdOptionParse
local QueryCastSequence = _G.QueryCastSequence
local SetCVar = _G.SetCVar
local UIErrorsFrame = _G.UIErrorsFrame

local GetNumShapeshiftForms = _G.GetNumShapeshiftForms
local GetShapeshiftFormInfo = _G.GetShapeshiftFormInfo
local GetContainerNumSlots = _G.GetContainerNumSlots
local GetComboPoints = _G.GetComboPoints

local GetCursorInfo = _G.GetCursorInfo

local GetActionInfo = _G.GetActionInfo
local IsActionInRange = _G.IsActionInRange

local GetMacroInfo = _G.GetMacroInfo

local GetSpellCooldown = _G.GetSpellCooldown
local GetSpellTexture = _G.GetSpellTexture
local GetSpellCount = _G.GetSpellCount
local IsCurrentSpell = _G.IsCurrentSpell
local IsAutoRepeatSpell = _G.IsAutoRepeatSpell
local IsAttackSpell = _G.IsAttackSpell
local IsSpellInRange = _G.IsSpellInRange

local GetInventoryItemLink = _G.GetInventoryItemLink
local GetItemCooldown = _G.GetItemCooldown
local GetItemInfo = _G.GetItemInfo
local GetItemCount = _G.GetItemCount
local GetItemIcon = _G.GetItemIcon
local IsCurrentItem = _G.IsCurrentItem
local IsItemInRange = _G.IsItemInRange
local IsEquippableItem = _G.IsEquippableItem

local GetPossessInfo = _G.GetPossessInfo
local GetCompanionCooldown = _G.GetCompanionCooldown

local ShowOverlayGlow = ActionButton_ShowOverlayGlow
local HideOverlayGlow = ActionButton_HideOverlayGlow

local sIndex = ION.sIndex
local cIndex = ION.cIndex
local iIndex = ION.iIndex

local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT

local tooltipScan = IonTooltipScan
local tooltipScanTextLeft2 = IonTooltipScanTextLeft2

local currMacro = {}

local configData = {

	btnType = "macro",

	mouseAnchor = false,
	clickAnchor = false,
	anchorDelay = false,
	anchoredBar = false,
	flyoutDock = false,

	upClicks = true,
	downClicks = false,
	copyDrag = false,
	muteSFX = false,
	clearerrors= false,
	cooldownAlpha = 1,

	bindText = true,
	bindColor = "1;1;1;1",

	countText = true,
	spellCounts = false,
	comboCounts = false,
	countColor = "1;1;1;1",

	macroText = true,
	macroColor = "1;1;1;1",

	cdText = false,
	cdcolor1 = "1;0.82;0;1",
	cdcolor2 = "1;0.1;0.1;1",

	auraText = false,
	auracolor1 = "0;0.82;0;1",
	auracolor2 = "1;0.1;0.1;1",

	auraInd = false,
	buffcolor = "0;0.8;0;1",
	debuffcolor = "0.8;0;0;1",

	rangeInd = true,
	rangecolor = "0.7;0.15;0.15;1",

	skincolor = "1;1;1;1",
	hovercolor = "0.1;0.1;1;1",
	equipcolor = "0.1;1;0.1;1",

	scale = 1,
	alpha = 1,
	XOffset = 0,
	YOffset = 0,
	HHitBox = 0,
	VHitBox = 0,

}

local keyData = {

	hotKeys = ":",
	hotKeyText = ":",
	hotKeyLock = false,
	hotKeyPri = false,
}

local keyDefaults = {

	[1] = { hotKeys = ":1:", hotKeyText = ":1:" },
	[2] = { hotKeys = ":2:", hotKeyText = ":2:" },
	[3] = { hotKeys = ":3:", hotKeyText = ":3:" },
	[4] = { hotKeys = ":4:", hotKeyText = ":4:" },
	[5] = { hotKeys = ":5:", hotKeyText = ":5:" },
	[6] = { hotKeys = ":6:", hotKeyText = ":6:" },
	[7] = { hotKeys = ":7:", hotKeyText = ":7:" },
	[8] = { hotKeys = ":8:", hotKeyText = ":8:" },
	[9] = { hotKeys = ":9:", hotKeyText = ":9:" },
	[10] = { hotKeys = ":0:", hotKeyText = ":0:" },
	[11] = { hotKeys = ":-:", hotKeyText = ":-:" },
	[12] = { hotKeys = ":=:", hotKeyText = ":=:" },
}

local stateData = {

	actionID = 1,

	macro_Text = "",
	macro_Icon = false,
	macro_Name = "",
	macro_Auto = false,
	macro_Watch = false,
	macro_Note = "",
	macro_UseNote = false,
}

ION.VehicleActions = {
	--exit_veh = { "Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up", { 0.140625, 0.859375, 0.140625, 0.859375 }, "vehicle_exit" },
	exit_veh = { "Interface\\PlayerActionBarAlt\\DarkMoon", { 0.0859375, 0.1679688, 0.359375, 0.4414063 }, "vehicle_exit" },
	exit_pos = { "Interface\\Icons\\Spell_Shadow_SacrificialShield", { 0, 1, 0, 1 }, "possess_exit" },
}

local VehicleActions = ION.VehicleActions

-- Moonfire: 8921
-- Solar Eclipse: 48517
-- Sunfire: 93402

-- Holy Word: Chastise: 88625
-- Chakra: 14751
-- Chakra: Prayer of Healing: 81206 - 88685
-- Chakra: Renew: 81207 - 88682
-- Chakra: Heal: 81208 - 88684

local morphSpells = {
	[8921] = false,
	[88625] = false,
}

local unitAuras = { player = {}, target = {}, focus = {} }

local alphaTimer, alphaDir = 0, 0

local autoCast = { speeds = { 2, 4, 6, 8 }, timers = { 0, 0, 0, 0 }, circle = { 0, 22, 44, 66 }, shines = {}, r = 0.95, g = 0.95, b = 0.32 }

local spellGlows, cooldowns, cdAlphas = {}, {}, {}

local function AutoCastStart(shine, r, g, b)

	autoCast.shines[shine] = shine

	if (not r) then
		r, g, b = autoCast.r, autoCast.g, autoCast.b
	end

	for _,sparkle in pairs(shine.sparkles) do
		sparkle:Show(); sparkle:SetVertexColor(r, g, b)
	end
end

local function AutoCastStop(shine)

	autoCast.shines[shine] = nil

	for _,sparkle in pairs(shine.sparkles) do
		sparkle:Hide()
	end
end

local cou_distance, cou_radius, cou_timer, cou_speed, cou_degree, cou_x, cou_y, cou_position

local function controlOnUpdate(self, elapsed)

	for i in next,autoCast.timers do

		autoCast.timers[i] = autoCast.timers[i] + elapsed

		if ( autoCast.timers[i] > autoCast.speeds[i]*4 ) then
			autoCast.timers[i] = 0
		end

	end

	for i in next,autoCast.circle do

		autoCast.circle[i] = autoCast.circle[i] - i

		if ( autoCast.circle[i] < 0 ) then
			autoCast.circle[i] = 359
		end

	end

	for shine in next, autoCast.shines do

		cou_distance, cou_radius = shine:GetWidth(), shine:GetWidth()/2.7

		for i=1,4 do

			cou_timer, cou_speed, cou_degree, cou_x, cou_y, cou_position = autoCast.timers[i], autoCast.speeds[i], autoCast.circle[i]

			if ( cou_timer <= cou_speed ) then

				if (shine.shape == "round") then

					cou_x = ((cou_radius)*(4/pi))*(cos(cou_degree)); cou_y = ((cou_radius)*(4/pi))*(sin(cou_degree))
					shine.sparkles[0+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/pi))*(cos(cou_degree-90)); cou_y = ((cou_radius)*(4/pi))*(sin(cou_degree-90))
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/pi))*(cos(cou_degree-180)); cou_y = ((cou_radius)*(4/pi))*(sin(cou_degree-180))
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/pi))*(cos(cou_degree-270)); cou_y = ((cou_radius)*(4/pi))*(sin(cou_degree-270))
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

				else

					cou_position = cou_timer/cou_speed*cou_distance

					shine.sparkles[0+i]:SetPoint("CENTER", shine, "TOPLEFT", cou_position, 0)
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "BOTTOMRIGHT", -cou_position, 0)
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "TOPRIGHT", 0, -cou_position)
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "BOTTOMLEFT", 0, cou_position)
				end

			elseif (cou_timer <= cou_speed*2) then

				if (shine.shape == "round") then

					cou_x = ((cou_radius)*(4/pi))*(cos(cou_degree)); cou_y = ((cou_radius)*(4/pi))*(sin(cou_degree))
					shine.sparkles[0+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/pi))*(cos(cou_degree+90)); cou_y = ((cou_radius)*(4/pi))*(sin(cou_degree+90))
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/pi))*(cos(cou_degree+180)); cou_y = ((cou_radius)*(4/pi))*(sin(cou_degree+180))
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/pi))*(cos(cou_degree+270)); cou_y = ((cou_radius)*(4/pi))*(sin(cou_degree+270))
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

				else

					cou_position = (cou_timer-cou_speed)/cou_speed*cou_distance

					shine.sparkles[0+i]:SetPoint("CENTER", shine, "TOPRIGHT", 0, -cou_position)
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "BOTTOMLEFT", 0, cou_position)
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "BOTTOMRIGHT", -cou_position, 0)
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "TOPLEFT", cou_position, 0)

				end

			elseif (cou_timer <= cou_speed*3) then

				if (shine.shape == "round") then

					cou_x = ((cou_radius)*(4/pi))*(cos(cou_degree)); cou_y = ((cou_radius)*(4/pi))*(sin(cou_degree))
					shine.sparkles[0+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/pi))*(cos(cou_degree+90)); cou_y = ((cou_radius)*(4/pi))*(sin(cou_degree+90))
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/pi))*(cos(cou_degree+180)); cou_y = ((cou_radius)*(4/pi))*(sin(cou_degree+180))
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/pi))*(cos(cou_degree+270)); cou_y = ((cou_radius)*(4/pi))*(sin(cou_degree+270))
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

				else

					cou_position = (cou_timer-cou_speed*2)/cou_speed*cou_distance

					shine.sparkles[0+i]:SetPoint("CENTER", shine, "BOTTOMRIGHT", -cou_position, 0)
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "TOPLEFT", cou_position, 0)
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "BOTTOMLEFT", 0, cou_position)
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "TOPRIGHT", 0, -cou_position)

				end

			else

				if (shine.shape == "round") then

					cou_x = ((cou_radius)*(4/pi))*(cos(cou_degree)); cou_y = ((cou_radius)*(4/pi))*(sin(cou_degree))
					shine.sparkles[0+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/pi))*(cos(cou_degree+90)); cou_y = ((cou_radius)*(4/pi))*(sin(cou_degree+90))
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/pi))*(cos(cou_degree+180)); cou_y = ((cou_radius)*(4/pi))*(sin(cou_degree+180))
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/pi))*(cos(cou_degree+270)); cou_y = ((cou_radius)*(4/pi))*(sin(cou_degree+270))
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

				else

					cou_position = (cou_timer-cou_speed*3)/cou_speed*cou_distance

					shine.sparkles[0+i]:SetPoint("CENTER", shine, "BOTTOMLEFT", 0, cou_position)
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "TOPRIGHT", 0, -cou_position)
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "TOPLEFT", cou_position, 0)
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "BOTTOMRIGHT", -cou_position, 0)

				end
			end
		end
	end

	alphaTimer = alphaTimer + elapsed * 2.5

	if (alphaDir == 1) then
		if (1-alphaTimer <= 0) then
			alphaDir = 0; alphaTimer = 0
		end
	else
		if (alphaTimer >= 1) then
			alphaDir = 1; alphaTimer = 0
		end
	end

	if (MacroDrag[0]) then
		SetCursor(MacroDrag.texture)
	end
end

local function cooldownsOnUpdate(self, elapsed)

	local coolDown, formatted, size

	for cd in next,cooldowns do

		coolDown = floor(cd.duration-(GetTime()-cd.start))
		formatted, size = coolDown, cd.button:GetWidth()*0.45

		if (coolDown < 1) then

			if (coolDown < 0) then

				cooldowns[cd] = nil

				cd.timer:Hide()
				cd.timer:SetText("")
				cd.timerCD = nil
				cd.expirecolor = nil
				cd.cdsize = nil
				cd.active = nil
				cd.expiry = nil

			elseif (coolDown >= 0) then

				cd.timer:SetAlpha(cd.duration-(GetTime()-cd.start))

				if (cd.alphafade) then
					cd:SetAlpha(cd.duration-(GetTime()-cd.start))
				end

			end

		elseif (cd.timer:IsShown() and coolDown ~= cd.timerCD) then

			if (coolDown >= 86400) then
				formatted = ceil(coolDown/86400)
				formatted = formatted.."d"; size = cd.button:GetWidth()*0.3
			elseif (coolDown >= 3600) then
				formatted = ceil(coolDown/3600)
				formatted = formatted.."h"; size = cd.button:GetWidth()*0.3
			elseif (coolDown >= 60) then
				formatted = ceil(coolDown/60)
				formatted = formatted.."m"; size = cd.button:GetWidth()*0.3
			elseif (coolDown < 6) then
				size = cd.button:GetWidth()*0.6
				if (cd.expirecolor) then
					cd.timer:SetTextColor(cd.expirecolor[1], cd.expirecolor[2], cd.expirecolor[3]); cd.expirecolor = nil
					cd.expiry = true
				end
			end

			if (not cd.cdsize or cd.cdsize ~= size) then
				cd.timer:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE"); cd.cdsize = size
			end

			cd.timerCD = coolDown
			cd.timer:SetAlpha(1)
			cd.timer:SetText(formatted)

		end
	end

	for cd in next,cdAlphas do

		coolDown = ceil(cd.duration-(GetTime()-cd.start))

		if (coolDown < 1) then

			cdAlphas[cd] = nil
			cd.button:SetAlpha(1)
			cd.alphaOn = nil

		elseif (not cd.alphaOn) then

			cd.button:SetAlpha(cd.button.cdAlpha)
			cd.alphaOn = true
		end
	end

end

-- Moonfire: 8921
-- Solar Eclipse: 48517
-- Sunfire: 93402

-- Holy Word: Chastise: 88625
-- Chakra: 14751
-- Chakra: Prayer of Healing: 81206 - 88685
-- Chakra: Renew: 81207 - 88682
-- Chakra: Heal: 81208 - 88684

local morphSpells = {
	[8921] = false,
	[88625] = false,
}

local uai__, uai_index, uai_spell, uai_count, uai_duration, uai_timeLeft, uai_caster, uai_spellID = 1

local function updateAuraInfo(unit)

	uai_index = 1

	wipe(unitAuras[unit])

	repeat
		uai_spell, uai__, uai__, uai_count, uai__, uai_duration, uai_timeLeft, uai_caster, uai__, uai__, uai_spellID = UnitAura(unit, uai_index, "HELPFUL")

		if (uai_duration and (uai_caster == "player" or uai_caster == "pet")) then
			unitAuras[unit][uai_spell:lower()] = "buff"..":"..uai_duration..":"..uai_timeLeft..":"..uai_count
			unitAuras[unit][uai_spell:lower().."()"] = "buff"..":"..uai_duration..":"..uai_timeLeft..":"..uai_count
		end

		-- temp fix to detect mighty morphing power spells
		    if (uai_spellID == 48517) then morphSpells[8921] = 93402
		elseif (uai_spellID == 81206) then morphSpells[88625] = 88685
		elseif (uai_spellID == 81207) then morphSpells[88625] = 88682
		elseif (uai_spellID == 81208) then morphSpells[88625] = 88684
		end

		uai_index = uai_index + 1

   	until (not uai_spell)

	uai_index = 1

	repeat

		uai_spell, uai__, uai__, uai_count, uai__, uai_duration, uai_timeLeft, uai_caster = UnitAura(unit, uai_index, "HARMFUL")

		if (uai_duration and (uai_caster == "player" or uai_caster == "pet")) then
			unitAuras[unit][uai_spell:lower()] = "debuff"..":"..uai_duration..":"..uai_timeLeft..":"..uai_count
			unitAuras[unit][uai_spell:lower().."()"] = "debuff"..":"..uai_duration..":"..uai_timeLeft..":"..uai_count
		end

		uai_index = uai_index + 1

	until (not uai_spell)
end

local function isActiveShapeshiftSpell(spell)

	local shapeshift, texture, name, isActive = spell:match("^[^(]+")

	if (shapeshift) then
		for i=1, GetNumShapeshiftForms() do
			texture, name, isActive = GetShapeshiftFormInfo(i)
			if (isActive and name:lower() == shapeshift:lower()) then
				return texture
			end
		end
	end
end

local function checkCursor(self, button)

	if (MacroDrag[0]) then

		if (button == "LeftButton" or button == "RightButton") then

			MacroDrag[0] = false; SetCursor(nil); PlaySound("igSpellBookSpellIconDrop")

			ION:ToggleButtonGrid(nil, true)
		else

			SetCursor(MacroDrag.texture)

			ION:ToggleButtonGrid(true)
		end
	end
end

function BUTTON:SetTimer(cd, start, duration, enable, timer, color1, color2, cdAlpha)

	if ( start and start > 0 and duration > 0 and enable > 0) then

		cd:SetAlpha(1)

		CooldownFrame_SetTimer(cd, start, duration, enable)

		if (duration >= GDB.timerLimit) then

			cd.duration = duration
			cd.start = start
			cd.active = true

			if (timer) then
				cd.timer:Show()
				if (not cd.expiry) then
					cd.timer:SetTextColor(color1[1], color1[2], color1[3])
				end
				cd.expirecolor = color2
			end

			cooldowns[cd] = true

			if (cdAlpha) then
				cdAlphas[cd] = true
			end
		end
	else
		CooldownFrame_SetTimer(cd, 0, 0, 0)
		cd.duration = 0
	end
end

function BUTTON:MACRO_HasAction()

	local hasAction = self.data.macro_Text

	if (self.vehicleID) then
		if (self.vehicleID == 0) then
			return true
		else
			return HasAction(self.vehicleID)
		end
	elseif (hasAction and #hasAction>0) then
		return true
	else
		return false
	end
end

function BUTTON:MACRO_GetDragAction()

	return "macro"

end

local ud_parse, ud_spell, ud_spellcmd, ud_show, ud_showcmd, ud_cd, ud_cdcmd, ud_aura, ud_auracmd, ud_item, ud_target, ud__

function BUTTON:MACRO_UpdateData(...)

	if (self.macroparse) then

		ud_parse = self.macroparse

		ud_spell, ud_spellcmd, ud_show, ud_showcmd, ud_cd, ud_cdcmd, ud_aura, ud_auracmd, ud_item, ud_target, ud__ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil

		for cmd, options in gmatch(ud_parse, "(%c%p%a+)(%C+)") do

			--after gmatch, remove unneeded characters
			if (cmd) then cmd = cmd:gsub("^%c+", "") end
			if (options) then options = options:gsub("^%s+", "") end

			--find #ud_show option!
			if (not ud_show and cmd:find("^#show")) then
				ud_show = SecureCmdOptionParse(options); ud_showcmd = cmd
			--sometimes SecureCmdOptionParse will return "" since that is not what we want, keep looking
			elseif (ud_show and #ud_show < 1 and cmd:find("^#show")) then
				ud_show = SecureCmdOptionParse(options); ud_showcmd = cmd
			end

			--find #cdwatch option!
			if (not ud_cd and cmd:find("^#cdwatch")) then
				ud_cd = SecureCmdOptionParse(options); ud_cdcmd = cmd
			elseif (ud_cd and #ud_cd < 1 and cmd:find("^#cdwatch")) then
				ud_cd = SecureCmdOptionParse(options); ud_cdcmd = cmd
			end

			--find #aurawatch option!
			if (not ud_aura and cmd:find("^#aurawatch")) then
				ud_aura = SecureCmdOptionParse(options); ud_auracmd = cmd
			elseif (ud_aura and #ud_aura < 1 and cmd:find("^#aurawatch")) then
				ud_aura = SecureCmdOptionParse(options); ud_auracmd = cmd
			end

			--find the ud_spell!
			if (not ud_spell and cmdSlash[cmd]) then
				ud_spell, ud_target = SecureCmdOptionParse(options); ud_spellcmd = cmd
			elseif (ud_spell and #ud_spell < 1) then
				ud_spell, ud_target = SecureCmdOptionParse(options); ud_spellcmd = cmd
			end
   		end

   		if (ud_spell and ud_spellcmd:find("/castsequence")) then
     			ud__, ud_item, ud_spell = QueryCastSequence(ud_spell)
     		elseif (ud_spell) then
     		     	if (#ud_spell < 1) then
     				ud_spell = nil
     			elseif(GetItemInfo(ud_spell) or ItemCache[ud_spell]) then
     				ud_item = ud_spell; ud_spell = nil
     			elseif(tonumber(ud_spell) and GetInventoryItemLink("player", ud_spell)) then
     				ud_item = GetInventoryItemLink("player", ud_spell); ud_spell = nil
     			end
     		end

     		self.unit = ud_target or "target"

		if (ud_spell) then
			self.macroitem = nil
			if (ud_spell ~= self.macrospell) then
				ud_spell = ud_spell:gsub("!", ""); self.macrospell = ud_spell
				if (sIndex[ud_spell:lower()]) then
					self.spellID = sIndex[ud_spell:lower()].spellID
				else
					self.spellID = nil
				end
			end
		else
			self.macrospell = nil; self.spellID = nil
		end

		if (ud_show and ud_showcmd:find("#showicon")) then
			if (ud_show ~= self.macroicon) then
     				if(tonumber(ud_show) and GetInventoryItemLink("player", ud_show)) then
     					ud_show = GetInventoryItemLink("player", ud_show)
     				end
				self.macroicon = ud_show; self.macroshow = nil
			end
		elseif (ud_show) then
			if (ud_show ~= self.macroshow) then
     				if(tonumber(ud_show) and GetInventoryItemLink("player", ud_show)) then
     					ud_show = GetInventoryItemLink("player", ud_show)
     				end
				self.macroshow = ud_show; self.macroicon = nil
			end
		else
			self.macroshow = nil; self.macroicon = nil
		end

		if (ud_cd) then
			if (ud_cd ~= self.macrocd) then
     				if(tonumber(ud_aura) and GetInventoryItemLink("player", ud_cd)) then
     					ud_aura = GetInventoryItemLink("player", ud_cd)
     				end
				self.macrocd = ud_aura
			end
		else
			self.macrocd = nil
		end

		if (ud_aura) then
			if (ud_aura ~= self.macroaura) then
     				if(tonumber(ud_aura) and GetInventoryItemLink("player", ud_aura)) then
     					ud_aura = GetInventoryItemLink("player", ud_aura)
     				end
				self.macroaura = ud_aura
			end
		else
			self.macroaura = nil
		end

		if (ud_item) then
			self.macrospell = nil; self.spellID = nil
			if (ud_item ~= self.macroitem) then
				self.macroitem = ud_item
			end
		else
			self.macroitem = nil
		end
	end
end

function BUTTON:MACRO_SetSpellIcon(spell)

	local _, texture

	if (not self.data.macro_Icon) then

		spell = spell:lower()

		if (sIndex[spell]) then

			local spell_id = sIndex[spell].spellID

			if (morphSpells[spell_id]) then
				texture = GetSpellTexture(morphSpells[spell_id])
			elseif spell_id then
				texture = GetSpellTexture(spell_id)
			end

		elseif (cIndex[spell]) then

			texture = cIndex[spell].icon

		elseif (spell) then

			texture = GetSpellTexture(spell)
		end

		if (texture) then

			local shapeshift = isActiveShapeshiftSpell(spell)

			if (shapeshift) then
				self.iconframeicon:SetTexture(shapeshift)
			else
				self.iconframeicon:SetTexture(texture)

			end

		else
			self.iconframeicon:SetTexture("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")
		end

	elseif (#self.data.macro_Icon > 0) then

		self.iconframeicon:SetTexture(self.data.macro_Icon)

	else

		if (self.data.macro_Watch) then
			_, texture = GetMacroInfo(self.data.macro_Watch)

		end

		if (texture) then
			self.iconframeicon:SetTexture(texture)
		else
			self.iconframeicon:SetTexture("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")
		end
	end

	self.iconframeicon:Show()

	return self.iconframeicon:GetTexture()

end

function BUTTON:MACRO_SetItemIcon(item)

	local _,texture, link, itemID

	if (IsEquippedItem(item)) then

		self.border:SetVertexColor(0, 1.0, 0, 0.5)
		self.border:Show()

	else
		self.border:Hide()
	end

	if (not self.data.macro_Icon) then

		_, link, _, _, _, _, _, _, _, texture = GetItemInfo(item)

		if (link and not ItemCache[item]) then

			_, itemID = (":"):split(link)

			if (itemID) then
				ItemCache[item] = itemID
			end
		end

		if (not texture) then

			if (ItemCache[item]) then
				texture = GetItemIcon("item:"..ItemCache[item]..":0:0:0:0:0:0:0")
			end
		end

		if (texture) then
			self.iconframeicon:SetTexture(texture)
		else
			self.iconframeicon:SetTexture("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")
		end

	elseif (#self.data.macro_Icon > 0) then

		self.iconframeicon:SetTexture(self.data.macro_Icon)
	else

		self.iconframeicon:SetTexture("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")
	end

	self.iconframeicon:Show()

	return self.iconframeicon:GetTexture()

end

function BUTTON:ACTION_SetIcon(action)

	local actionID = tonumber(action)

	if (actionID) then

		if (actionID == 0) then

			if (UnitHasVehicleUI("player")) then
				self.iconframeicon:SetTexture(VehicleActions.exit_veh[1])
				self.iconframeicon:SetTexCoord(unpack(VehicleActions.exit_veh[2]))
			else
				self.iconframeicon:SetTexture(VehicleActions.exit_pos[1])
				self.iconframeicon:SetTexCoord(unpack(VehicleActions.exit_pos[2]))
			end

		else
			self.macroname:SetText(GetActionText(actionID))

			if (HasAction(actionID)) then
				self.iconframeicon:SetTexture(GetActionTexture(actionID))
			else
				self.iconframeicon:SetTexture(0,0,0)
			end
		end

		self.iconframeicon:Show()
	else
		self.iconframeicon:SetTexture("")
		self.iconframeicon:Hide()
	end

	return self.iconframeicon:GetTexture()
end

function BUTTON:MACRO_UpdateIcon(...)

	self.updateMacroIcon = nil

	local spell, item, show, texture = self.macrospell, self.macroitem, self.macroshow or self.macroicon

	if (self.vehicleID) then

		texture = self:ACTION_SetIcon(self.vehicleID)

	elseif (show and #show>0) then

    		if(GetItemInfo(show) or ItemCache[show]) then
			texture = self:MACRO_SetItemIcon(show)
    		else
			texture = self:MACRO_SetSpellIcon(show)
    		end

	elseif (spell and #spell>0) then

		texture = self:MACRO_SetSpellIcon(spell)

	elseif (item and #item>0) then

		texture = self:MACRO_SetItemIcon(item)

	elseif (self:GetAttribute("macroShow")) then

		show = self:GetAttribute("macroShow")

    		if(GetItemInfo(show) or ItemCache[show]) then
			texture = self:MACRO_SetItemIcon(show)
    		else
			texture = self:MACRO_SetSpellIcon(show)
    		end

	else
		self.iconframeicon:SetTexture("")
		self.iconframeicon:Hide()
		self.border:Hide()
	end

	if (not self.vehicleID) then
		self.iconframeicon:SetTexCoord(0.05,0.95,0.05,0.95)
	end

	if (spellGlows[self.spellID] and not self.glowing) then
		self:MACRO_StartGlow()
	end

	if (self.glowing and not spellGlows[self.spellID]) then
		self:MACRO_StopGlow()
	end

	return texture
end

function BUTTON:MACRO_StartGlow()

	if (self.spellGlowDef) then
		ShowOverlayGlow(self)
	elseif (self.spellGlowAlt) then
		AutoCastStart(self.shine)
	end

	self.glowing = true

end

function BUTTON:MACRO_StopGlow()

	if (self.spellGlowDef) then
		HideOverlayGlow(self)
	elseif (self.spellGlowAlt) then
		AutoCastStop(self.shine)
	end

	self.glowing = nil
end


function BUTTON:MACRO_SetSpellState(spell)

	if (GetSpellCount(spell) and  GetSpellCount(spell) > 1) then

		self.count:SetText(GetSpellCount(spell))
	else
		self.count:SetText("")
	end

	if (cIndex[spell:lower()]) then

		spell = cIndex[spell:lower()].spellID

		if (IsCurrentSpell(spell) or IsAutoRepeatSpell(spell)) then
			self:SetChecked(1)
		else
			self:SetChecked(nil)
		end
	else

		if (IsCurrentSpell(spell) or IsAutoRepeatSpell(spell) or isActiveShapeshiftSpell(spell:lower())) then
			self:SetChecked(1)
		else
			self:SetChecked(nil)
		end
	end

	if ((IsAttackSpell(spell) and IsCurrentSpell(spell)) or IsAutoRepeatSpell(spell)) then
		self.mac_flash = true
	else
		self.mac_flash = false
	end
end

function BUTTON:MACRO_SetItemState(item)

	if (GetItemCount(item,nil,true) and  GetItemCount(item,nil,true) > 1) then
		self.count:SetText(GetItemCount(item,nil,true))
	else
		self.count:SetText("")
	end

	if(IsCurrentItem(item)) then
		self:SetChecked(1)
	else
		self:SetChecked(nil)
	end
end

function BUTTON:ACTION_UpdateState(action)

	local actionID = tonumber(action)

	self.count:SetText("")

	if (actionID) then

		if (IsCurrentAction(actionID) or IsAutoRepeatAction(actionID)) then
			self:SetChecked(1)
		else
			self:SetChecked(nil)
		end

		if ((IsAttackAction(actionID) and IsCurrentAction(actionID)) or IsAutoRepeatAction(actionID)) then
			self.mac_flash = true
		else
			self.mac_flash = false
		end
	else
		self:SetChecked(nil)
		self.mac_flash = false
	end
end

function BUTTON:MACRO_UpdateState(...)

	local spell, item, show = self.macrospell, self.macroitem, self.macroshow

	self.macroname:SetText(self.data.macro_Name)

	if (self.vehicleID) then

		self:ACTION_UpdateState(self.vehicleID)

	elseif (show and #show>0) then

    		if(GetItemInfo(show) or ItemCache[show]) then
			self:MACRO_SetItemState(show)
    		else
			self:MACRO_SetSpellState(show)
    		end

	elseif (spell and #spell>0) then

		self:MACRO_SetSpellState(spell)

	elseif (item and #item>0) then

		self:MACRO_SetItemState(item)

	elseif (self:GetAttribute("macroShow")) then

		show = self:GetAttribute("macroShow")

    		if(GetItemInfo(show) or ItemCache[show]) then
			self:MACRO_SetItemState(show)
    		else
			self:MACRO_SetSpellState(show)
    		end
	else
		self:SetChecked(nil)
		self.count:SetText("")
	end
end

local uaw_auraType, uaw_duration, uaw_timeLeft, uaw_count, uaw_color

function BUTTON:MACRO_UpdateAuraWatch(unit, spell)

	if (spell and (unit == self.unit or unit == "player")) then

		if (self.spellID and morphSpells[self.spellID]) then
			spell = GetSpellInfo(morphSpells[self.spellID])
		end

		spell = spell:gsub("%s*%(.+%)", ""):lower()

		if (unitAuras[unit][spell]) then

			uaw_auraType, uaw_duration, uaw_timeLeft, uaw_count = (":"):split(unitAuras[unit][spell])

			uaw_duration = tonumber(uaw_duration); uaw_timeLeft = tonumber(uaw_timeLeft)

			if (self.auraInd) then

				self.auraBorder = true

				if (uaw_auraType == "buff") then
					self.border:SetVertexColor(self.buffcolor[1], self.buffcolor[2], self.buffcolor[3], 1.0)
				elseif (uaw_auraType == "debuff" and unit == "target") then
					self.border:SetVertexColor(self.debuffcolor[1], self.debuffcolor[2], self.debuffcolor[3], 1.0)
				end

				self.border:Show()
			else
				self.border:Hide()
			end

			uaw_color = self.auracolor1

			if (self.auraText) then

				if (uaw_auraType == "debuff" and (unit == "target" or (unit == "focus" and UnitIsEnemy("player", "focus")))) then
					uaw_color = self.auracolor2
				end

				self.iconframeaurawatch.queueinfo = unit..":"..spell
			end

			if (self.iconframecooldown.timer:IsShown()) then
				self.auraQueue = unit..":"..spell; self.iconframeaurawatch.uaw_duration = 0; self.iconframeaurawatch:Hide()
			elseif (self.auraInd or self.auraText) then
				if (self.auraText) then
					self:SetTimer(self.iconframecooldown, 0, 0, 0)
				end
				self:SetTimer(self.iconframeaurawatch, uaw_timeLeft-uaw_duration, uaw_duration, 1, self.auraText, uaw_color)
			end

			self.auraWatchUnit = unit

		elseif (self.auraWatchUnit == unit) then

			self.iconframeaurawatch.uaw_duration = 0
			self.iconframeaurawatch:Hide()
			self.iconframeaurawatch.timer:SetText("")
			self.border:Hide()
			self.auraBorder = nil
			self.auraWatchUnit = nil
			self.auraTimer = nil
			self.auraQueue = nil
		end
	end
end

function BUTTON:MACRO_SetSpellCooldown(spell)

	local start, duration, enable

	spell = (spell):lower()

	if (cIndex[spell]) then

		local companion, index = cIndex[spell].creatureType, cIndex[spell].index
		start, duration, enable = GetCompanionCooldown(companion, index)

	elseif (sIndex[spell]) then

		local spell_id = sIndex[spell].spellID

		if (morphSpells[spell_id]) then
			start, duration, enable = GetSpellCooldown(morphSpells[spell_id])
		elseif spell_id then
			start, duration, enable = GetSpellCooldown(spell_id)
		end
	end

	if (duration and duration >= GDB.timerLimit and self.iconframeaurawatch.active) then
		self.auraQueue = self.iconframeaurawatch.queueinfo
		self.iconframeaurawatch.duration = 0
		self.iconframeaurawatch:Hide()
	end

	self:SetTimer(self.iconframecooldown, start, duration, enable, self.cdText, self.cdcolor1, self.cdcolor2, self.cdAlpha)

end

function BUTTON:MACRO_SetItemCooldown(item)

	local id = ItemCache[item]

	if (id) then

		local start, duration, enable = GetItemCooldown(id)

		if (duration and duration >= GDB.timerLimit and self.iconframeaurawatch.active) then
			self.auraQueue = self.iconframeaurawatch.queueinfo
			self.iconframeaurawatch.duration = 0
			self.iconframeaurawatch:Hide()
		end

		self:SetTimer(self.iconframecooldown, start, duration, enable, self.cdText, self.cdcolor1, self.cdcolor2, self.cdAlpha)
	end
end

function BUTTON:ACTION_SetCooldown(action)

	local actionID = tonumber(action)

	if (actionID) then

		if (HasAction(actionID)) then

			local start, duration, enable = GetActionCooldown(actionID)

			if (duration and duration >= GDB.timerLimit and self.iconframeaurawatch.active) then
				self.auraQueue = self.iconframeaurawatch.queueinfo
				self.iconframeaurawatch.duration = 0
				self.iconframeaurawatch:Hide()
			end

			self:SetTimer(self.iconframecooldown, start, duration, enable, self.cdText, self.cdcolor1, self.cdcolor2, self.cdAlpha)
		end
	end
end

function BUTTON:MACRO_UpdateCooldown(update)

	local spell, item, show = self.macrospell, self.macroitem, self.macroshow

	if (self.vehicleID) then

		self:ACTION_SetCooldown(self.vehicleID)

	elseif (show and #show>0) then

    		if(GetItemInfo(show) or ItemCache[show]) then
			self:MACRO_SetItemCooldown(show)
    		else
			self:MACRO_SetSpellCooldown(show)
    		end

	elseif (spell and #spell>0) then

		self:MACRO_SetSpellCooldown(spell)

	elseif (item and #item>0) then

		self:MACRO_SetItemCooldown(item)

	else

		self:SetTimer(self.iconframecooldown, 0, 0, 0, self.cdText, self.cdcolor1, self.cdcolor2, self.cdAlpha)

	end
end

function BUTTON:MACRO_UpdateTimers(...)

	self:MACRO_UpdateCooldown()

	for k in pairs(unitAuras) do
		self:MACRO_UpdateAuraWatch(k, self.macrospell)
	end

end

function BUTTON:MACRO_UpdateTexture(force)

	local hasAction = self:MACRO_HasAction()

	if (not self:GetSkinned()) then

		if (hasAction or force) then
			self:SetNormalTexture(self.hasAction or "")
			self:GetNormalTexture():SetVertexColor(1,1,1,1)
		else
			self:SetNormalTexture(self.noAction or "")
			self:GetNormalTexture():SetVertexColor(1,1,1,0.5)
		end
	end
end

function BUTTON:MACRO_UpdateAll(updateTexture)

	self:MACRO_UpdateData()
	self:MACRO_UpdateButton()
	self:MACRO_UpdateIcon()
	self:MACRO_UpdateState()
	self:MACRO_UpdateTimers()

	if (updateTexture) then
		self:MACRO_UpdateTexture()
	end
end

function BUTTON:MACRO_UpdateUsableSpell(spell)

	local isUsable, notEnoughMana = IsUsableSpell(spell)

	if (notEnoughMana) then

		self.iconframeicon:SetVertexColor(self.manacolor[1], self.manacolor[2], self.manacolor[3])

	elseif (isUsable) then

		if (self.rangeInd and IsSpellInRange(spell, self.unit) == 0) then
			self.iconframeicon:SetVertexColor(self.rangecolor[1], self.rangecolor[2], self.rangecolor[3])
		else
			self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
		end

	else
		if (sIndex[(spell):lower()]) then

			self.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)
		else
			self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
		end
	end

end

function BUTTON:MACRO_UpdateUsableItem(item)

      local isUsable, notEnoughMana = IsUsableItem(item)

	if (notEnoughMana and self.manacolor) then

		self.iconframeicon:SetVertexColor(self.manacolor[1], self.manacolor[2], self.manacolor[3])

	elseif (isUsable) then

		if (self.rangeInd and IsItemInRange(spell, self.unit) == 0) then
			self.iconframeicon:SetVertexColor(self.rangecolor[1], self.rangecolor[2], self.rangecolor[3])
		else
			self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
		end
	else
		self.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)
	end
end

function BUTTON:ACTION_UpdateUsable(action)

	local actionID = tonumber(action)

	if (actionID) then

		if (actionID == 0) then

			self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
		else

			local isUsable, notEnoughMana = IsUsableAction(actionID)

			if (isUsable) then

				if (IsActionInRange(action, self.unit) == 0) then
					self.iconframeicon:SetVertexColor(self.rangecolor[1], self.rangecolor[2], self.rangecolor[3])
				else
					self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
				end

			elseif (notEnoughMana and self.manacolor) then

				self.iconframeicon:SetVertexColor(self.manacolor[1], self.manacolor[2], self.manacolor[3])

			else
				self.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)
			end
		end

	else
		self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
	end
end

function BUTTON:MACRO_UpdateButton(...)

	if (self.editmode) then

		self.iconframeicon:SetVertexColor(0.2, 0.2, 0.2)

	elseif (self.vehicleID) then

		self:ACTION_UpdateUsable(self.vehicleID)

	elseif (self.macroshow and #self.macroshow>0) then

    		if(GetItemInfo(self.macroshow) or ItemCache[self.macroshow]) then
			self:MACRO_UpdateUsableItem(self.macroshow)
    		else
			self:MACRO_UpdateUsableSpell(self.macroshow)
    		end

	elseif (self.macrospell and #self.macrospell>0) then

		self:MACRO_UpdateUsableSpell(self.macrospell)

	elseif (self.macroitem and #self.macroitem>0) then

		self:MACRO_UpdateUsableItem(self.macroitem)

	else
		self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
	end
end

function BUTTON:MACRO_OnUpdate(elapsed)

	if (self.mac_flash) then

		self.mac_flashing = true

		if (alphaDir == 1) then
			if ((1-(alphaTimer)) >= 0) then
				self.iconframeflash:Show()
			end
		elseif (alphaDir == 0) then
			if ((alphaTimer) <= 1) then
				self.iconframeflash:Hide()
			end
		end

	elseif (self.mac_flashing) then

		self.iconframeflash:Hide()
		self.mac_flashing = false
	end

	self.elapsed = self.elapsed + elapsed

	if (self.elapsed > GDB.throttle) then
		self:MACRO_UpdateButton()
	end

	if (self.auraQueue and not self.iconframecooldown.active) then
		local unit, spell = (":"):split(self.auraQueue)
		if (unit and spell) then
			self.auraQueue = nil; self:MACRO_UpdateAuraWatch(unit, spell)
		end
	end

end

function BUTTON:MACRO_ShowGrid()

	if (not InCombatLockdown()) then
		self:Show()
	end

	self:MACRO_UpdateState()
end

function BUTTON:MACRO_HideGrid()

	if (not InCombatLockdown()) then

		if (not self.showGrid and not self:MACRO_HasAction()) then
			self:Hide()
		end
	end

	self:MACRO_UpdateState()
end

function BUTTON:MACRO_ACTIONBAR_UPDATE_COOLDOWN(...)

	self:MACRO_UpdateTimers(...)

end

BUTTON.MACRO_RUNE_POWER_UPDATE = BUTTON.MACRO_ACTIONBAR_UPDATE_COOLDOWN


function BUTTON:MACRO_ACTIONBAR_UPDATE_STATE(...)

	self:MACRO_UpdateState(...)

end

BUTTON.MACRO_COMPANION_UPDATE = BUTTON.MACRO_ACTIONBAR_UPDATE_STATE
BUTTON.MACRO_TRADE_SKILL_SHOW = BUTTON.MACRO_ACTIONBAR_UPDATE_STATE
BUTTON.MACRO_TRADE_SKILL_CLOSE = BUTTON.MACRO_ACTIONBAR_UPDATE_STATE
BUTTON.MACRO_ARCHAEOLOGY_CLOSED = BUTTON.MACRO_ACTIONBAR_UPDATE_STATE


function BUTTON:MACRO_BAG_UPDATE_COOLDOWN(...)

	if (self.macroitem) then
		self:MACRO_UpdateState(...)
	end

end

BUTTON.MACRO_BAG_UPDATE = BUTTON.MACRO_BAG_UPDATE_COOLDOWN


function BUTTON:MACRO_UNIT_AURA(...)

	local unit = select(2, ...)

	if (unitAuras[unit]) then

		self:MACRO_UpdateAuraWatch(unit, self.macrospell)

		if (unit == "player") then
			self:MACRO_UpdateData(...)
			self:MACRO_UpdateIcon(...)
		end
	end
end

BUTTON.MACRO_UPDATE_MOUSEOVER_UNIT = BUTTON.MACRO_UNIT_AURA


function BUTTON:MACRO_UNIT_SPELLCAST_INTERRUPTED(...)

	local unit = select(1, ...)

	if ((unit == "player" or unit == "pet") and spell and self.macrospell) then

		self:MACRO_UpdateTimers(...)
	end

end

BUTTON.MACRO_UNIT_SPELLCAST_FAILED = BUTTON.MACRO_UNIT_SPELLCAST_INTERRUPTED
BUTTON.MACRO_UNIT_PET = BUTTON.MACRO_UNIT_SPELLCAST_INTERRUPTED
BUTTON.MACRO_UNIT_ENTERED_VEHICLE = BUTTON.MACRO_UNIT_SPELLCAST_INTERRUPTED
BUTTON.MACRO_UNIT_ENTERING_VEHICLE = BUTTON.MACRO_UNIT_SPELLCAST_INTERRUPTED
BUTTON.MACRO_UNIT_EXITED_VEHICLE = BUTTON.MACRO_UNIT_SPELLCAST_INTERRUPTED


function BUTTON:MACRO_SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(...)

	local spellID = select(2, ...)

	if (self.spellGlow and self.spellID and spellID == self.spellID) then

		spellGlows[spellID] = true

		self:MACRO_UpdateTimers(...)

		self:MACRO_StartGlow()
	end
end

function BUTTON:MACRO_SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(...)

	local spellID = select(2, ...)

	if ((self.overlay or self.spellGlow) and self.spellID and spellID == self.spellID) then

		spellGlows[spellID] = nil

		self:MACRO_StopGlow()

	end
end

function BUTTON:MACRO_ACTIVE_TALENT_GROUP_CHANGED(...)

	local spec = select(2,...)

	self:Show()

	self:LoadData(spec, self:GetParent():GetAttribute("activestate") or "homestate")
	self:SetType()
	self:SetGrid()
end

function BUTTON:MACRO_PLAYER_ENTERING_WORLD(...)

	self:MACRO_Reset()
	self:MACRO_UpdateAll(true)
	self.binder:ApplyBindings(self)

end

function BUTTON:MACRO_MODIFIER_STATE_CHANGED(...)
	self:MACRO_UpdateAll(true)
end

function BUTTON:MACRO_ACTIONBAR_SLOT_CHANGED(...)
	if (self.data.macro_Watch) then
		self:MACRO_UpdateIcon()
	end
end

function BUTTON:MACRO_PLAYER_TARGET_CHANGED(...)
	self:MACRO_UpdateTimers()
end

BUTTON.MACRO_PLAYER_FOCUS_CHANGED = BUTTON.MACRO_PLAYER_TARGET_CHANGED

function BUTTON:MACRO_ITEM_LOCK_CHANGED(...)

end

function BUTTON:MACRO_ACTIONBAR_SHOWGRID(...)

	self:MACRO_ShowGrid()

end

function BUTTON:MACRO_ACTIONBAR_HIDEGRID(...)

	self:MACRO_HideGrid()

end

function BUTTON:MACRO_UPDATE_MACROS(...)

	if (PEW and not InCombatLockdown() and self.data.macro_Watch) then
		self:MACRO_PlaceBlizzMacro(self.data.macro_Watch)
	end
end

function BUTTON:MACRO_OnEvent(...)

	local event = "MACRO_"..select(1,...)

	if (BUTTON[event]) then
		BUTTON[event](self, ...)
	end
end

function BUTTON:MACRO_PlaceMacro()

	self.data.macro_Text = MacroDrag[2]
	self.data.macro_Icon = MacroDrag[3]
	self.data.macro_Name = MacroDrag[4]
	self.data.macro_Auto = MacroDrag[5]
	self.data.macro_Watch = MacroDrag[6]
	self.data.macro_Note = MacroDrag[7]
	self.data.macro_UseNote = MacroDrag[8]

	if (not self.cursor) then
		self:SetType(true)
	end

	MacroDrag[0] = false

	ClearCursor(); SetCursor(nil)

	ION:ToggleButtonGrid(nil, true)
end

function BUTTON:MACRO_PlaceSpell(action1, action2, hasAction)

	local _, modifier, spell, subName, spellID, texture = " "

	if (action1 == 0) then
		return
	else
	 	_, subName = GetSpellBookItemName(action1, action2)
	 	_, spellID = GetSpellBookItemInfo(action1, action2)

	 	spell = GetSpellInfo(spellID)

	 	self.data.macro_Text = self:AutoWriteMacro(spell, subName)
	 	self.data.macro_Auto = spell..";"..subName
	 	self.data.macro_Icon = false
		self.data.macro_Name = ""
		self.data.macro_Watch = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

		if (not self.cursor) then
			self:SetType(true)
		end

		MacroDrag[0] = false

		ClearCursor(); SetCursor(nil)
	end
end

function BUTTON:MACRO_PlaceItem(action1, action2, hasAction)

	local item, link = GetItemInfo(action2)

	if (IsEquippableItem(item)) then
		self.data.macro_Text = "/equip "..item.."\n/use "..item
	else
		self.data.macro_Text = "/use "..item
	end

	self.data.macro_Icon = false
	self.data.macro_Name = ""
	self.data.macro_Auto = false
	self.data.macro_Watch = false
	self.data.macro_Note = ""
	self.data.macro_UseNote = false

	if (not self.cursor) then
		self:SetType(true)
	end

	MacroDrag[0] = false

	ClearCursor(); SetCursor(nil)

end

function BUTTON:MACRO_PlaceBlizzMacro(action1)

	if (action1 == 0) then
		return
	else

	 	local name, icon, body = GetMacroInfo(action1)

	 	if (body) then

	 		self.data.macro_Text = body
	 		self.data.macro_Name = name
	 		self.data.macro_Watch = action1
	 		self.data.macro_Icon = iIndex[icon:upper()] or ""
	 	else
	 		self.data.macro_Text = ""
	 		self.data.macro_Name = ""
	 		self.data.macro_Watch = false
	 		self.data.macro_Icon = false
	 	end

		self.data.macro_Auto = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

		if (not self.cursor) then
			self:SetType(true)
		end

		MacroDrag[0] = false

		ClearCursor(); SetCursor(nil)
	end
end

function BUTTON:MACRO_PlaceCompanion(action1, action2, hasAction)

	if (action1 == 0) then
		return
	else

		local _, _, spellID = GetCompanionInfo(action2, action1)
	 	local name = GetSpellInfo(spellID)

	 	if (name) then

	 		self.data.macro_Text = self:AutoWriteMacro(name)
	 		self.data.macro_Auto = name
	 	else
	 		self.data.macro_Text = ""
	 		self.data.macro_Auto = false
	 	end

		self.data.macro_Icon = false
		self.data.macro_Name = ""
		self.data.macro_Watch = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

		if (not self.cursor) then
			self:SetType(true)
		end

		MacroDrag[0] = false

		ClearCursor(); SetCursor(nil)
	end
end

function BUTTON:MACRO_PlaceFlyout(action1, action2, hasAction)

	MacroDrag[0] = false

	ClearCursor(); SetCursor(nil)

end

function BUTTON:MACRO_PickUpMacro()

	local pickup = nil

	if (not self.barLock) then
		pickup = true
	elseif (self.barLockAlt and IsAltKeyDown()) then
		pickup = true
	elseif (self.barLockCtrl and IsControlKeyDown()) then
		pickup = true
	elseif (self.barLockShift and IsShiftKeyDown()) then
		pickup = true
	end

	if (pickup or currMacro[0]) then

		local texture, move = self.iconframeicon:GetTexture()

		wipe(MacroDrag)

		if (currMacro[0]) then

			for k,v in pairs(currMacro) do
				MacroDrag[k] = v
			end

			wipe(currMacro)

			SetCursor(MacroDrag.texture)

		elseif (self:MACRO_HasAction()) then

			MacroDrag[0] = self:MACRO_GetDragAction()
			MacroDrag[1] = self
			MacroDrag[2] = self.data.macro_Text
			MacroDrag[3] = self.data.macro_Icon
			MacroDrag[4] = self.data.macro_Name
			MacroDrag[5] = self.data.macro_Auto
			MacroDrag[6] = self.data.macro_Watch
			MacroDrag[7] = self.data.macro_Note
			MacroDrag[8] = self.data.macro_UseNote
			MacroDrag.texture = texture

			self.data.macro_Text = ""
			self.data.macro_Icon = false
			self.data.macro_Name = ""
			self.data.macro_Auto = false
			self.data.macro_Watch = false
			self.data.macro_Note = ""
			self.data.macro_UseNote = false

			self.macrospell = nil
			self.spellID = nil
			self.macroitem = nil
			self.macroshow = nil
			self.macroicon = nil

			self:SetType(true)

			SetCursor(MacroDrag.texture)
		end
	end
end

function BUTTON:MACRO_OnReceiveDrag(preclick)

	if (InCombatLockdown()) then return end

	local cursorType, action1, action2, move = GetCursorInfo()

	local texture = self.iconframeicon:GetTexture()

	if (self:MACRO_HasAction()) then

		wipe(currMacro)

		currMacro[0] = self:MACRO_GetDragAction()
		currMacro[1] = self
		currMacro[2] = self.data.macro_Text
		currMacro[3] = self.data.macro_Icon
		currMacro[4] = self.data.macro_Name
		currMacro[5] = self.data.macro_Auto
		currMacro[6] = self.data.macro_Watch
		currMacro[7] = self.data.macro_Note
		currMacro[8] = self.data.macro_UseNote


		currMacro.texture = texture

	end

	if  (action1 == 0) then

		-- do nothing for now

	else

		if (MacroDrag[0]) then

			self:MACRO_PlaceMacro(); PlaySound("igSpellBookSpellIconDrop")

		elseif (cursorType == "spell") then

			self:MACRO_PlaceSpell(action1, action2, self:MACRO_HasAction())

		elseif (cursorType == "item") then

			self:MACRO_PlaceItem(action1, action2, self:MACRO_HasAction())

		elseif (cursorType == "macro") then

			self:MACRO_PlaceBlizzMacro(action1)

		elseif (cursorType == "companion") then

			self:MACRO_PlaceCompanion(action1, action2, self:MACRO_HasAction())

		elseif (cursorType == "flyout") then

			self:MACRO_PlaceFlyout(action1, action2, self:MACRO_HasAction())

		end

		--self:MACRO_SetTooltip()

	end

	if (StartDrag and currMacro[0]) then
		self:MACRO_PickUpMacro(); ION:ToggleButtonGrid(true)
	end

	self:MACRO_UpdateAll(true)

	self.elapsed = 0.2

	StartDrag = false

end

function BUTTON:MACRO_OnDragStart(button)

	if (InCombatLockdown() or not self.bar or self.vehicle_edit or self.vehicleID) then
		StartDrag = false; return
	end

	self.drag = nil

	if (not self.barLock) then
		self.drag = true
	elseif (self.barLockAlt and IsAltKeyDown()) then
		self.drag = true
	elseif (self.barLockCtrl and IsControlKeyDown()) then
		self.drag = true
	elseif (self.barLockShift and IsShiftKeyDown()) then
		self.drag = true
	end

	if (self.drag) then

		StartDrag = self:GetParent():GetAttribute("activestate")

		self.dragbutton = button

		self:MACRO_PickUpMacro()

		if (MacroDrag[0]) then

			PlaySound("igSpellBookSpellIconPickup"); self.sound = true

			if (MacroDrag[1] ~= self) then
				self.dragbutton = nil
			end

			ION:ToggleButtonGrid(true)
		else
			self.dragbutton = nil
		end

		self:MACRO_UpdateAll()

		self.iconframecooldown.duration = 0
		self.iconframecooldown.timer:SetText("")
		self.iconframecooldown:Hide()

		self.iconframeaurawatch.duration = 0
		self.iconframeaurawatch.timer:SetText("")
		self.iconframeaurawatch:Hide()

		self.macrospell = nil
		self.spellID = nil
		self.macroitem = nil
		self.macroshow = nil
		self.macroicon = nil

		self.auraQueue = nil

		self.border:Hide()

	else
		StartDrag = false
	end
end

function BUTTON:MACRO_OnDragStop()

	self.drag = nil

end

function BUTTON:MACRO_PreClick(button)

	self.cursor = nil

	if (not InCombatLockdown() and MouseIsOver(self)) then

		local cursorType = GetCursorInfo()

		if (cursorType or MacroDrag[0]) then

			self.cursor = true

			StartDrag = self:GetParent():GetAttribute("activestate")

			self:SetType(true, true)

			ION:ToggleButtonGrid(true)

			self:MACRO_OnReceiveDrag(true)

		elseif (button == "MiddleButton") then

			self.middleclick = self:GetAttribute("type")

			self:SetAttribute("type", "")

			self:SetType(true, true)

		end
	end
end

function BUTTON:MACRO_PostClick(button)

	if (not InCombatLockdown() and MouseIsOver(self)) then

		if (self.cursor) then

			self:SetType(true)

			self.cursor = nil

		elseif (self.middleclick) then

			self:SetAttribute("type", self.middleclick)

			self:SetType(true)

			self.middleclick = nil
		end
	end

	self:MACRO_UpdateState()

end

function BUTTON:MACRO_SetSpellTooltip(spell)

	if (sIndex[spell]) then

		local spell_id = sIndex[spell].spellID

		if (morphSpells[spell_id]) then

			if (self.UberTooltips) then
				GameTooltip:SetHyperlink("spell:"..morphSpells[spell_id])
			else
				local spell = GetSpellInfo(morphSpells[spell_id])
				GameTooltip:SetText(spell, 1, 1, 1)
			end

		elseif (self.UberTooltips) then
			GameTooltip:SetSpellBookItem(sIndex[spell].index, sIndex[spell].booktype)
		else
			GameTooltip:SetText(sIndex[spell].spellName, 1, 1, 1)
		end

		self.UpdateTooltip = macroButton_SetTooltip

	elseif (cIndex[spell]) then

		if (self.UberTooltips) then
			GameTooltip:SetHyperlink("spell:"..cIndex[spell].spellID)
		else
			GameTooltip:SetText(cIndex[spell].creatureName, 1, 1, 1)
		end

		self.UpdateTooltip = nil
	end
end

function BUTTON:MACRO_SetItemTooltip(item)

	local name, link = GetItemInfo(item)

	if (link) then

		if (self.UberTooltips) then
			GameTooltip:SetHyperlink(link)
		else
			GameTooltip:SetText(name, 1, 1, 1)
		end

	elseif (ItemCache[item]) then

		if (self.UberTooltips) then
			GameTooltip:SetHyperlink("item:"..ItemCache[item]..":0:0:0:0:0:0:0")
		else
			GameTooltip:SetText(ItemCache[item], 1, 1, 1)
		end
	end
end

function BUTTON:ACTION_SetTooltip(action)

	local actionID = tonumber(action)

	if (actionID) then

		self.UpdateTooltip = nil

		if (HasAction(actionID)) then
			GameTooltip:SetAction(actionID)
		end
	end
end

function BUTTON:MACRO_SetTooltip(edit)

	self.UpdateTooltip = nil

	local spell, item, show = self.macrospell, self.macroitem, self.macroshow

	if (self.vehicleID) then

		self:ACTION_SetTooltip(self.vehicleID)

	elseif (show and #show>0) then

		if(GetItemInfo(show) or ItemCache[show]) then
			self:MACRO_SetItemTooltip(show)
		else
			self:MACRO_SetSpellTooltip(show:lower())
		end

	elseif (spell and #spell>0) then

		self:MACRO_SetSpellTooltip(spell:lower())

	elseif (item and #item>0) then

		self:MACRO_SetItemTooltip(item)

	elseif (self:GetAttribute("macroShow")) then

		show = self:GetAttribute("macroShow")

		if(GetItemInfo(show) or ItemCache[show]) then
			self:MACRO_SetItemTooltip(show)
		else
			self:MACRO_SetSpellTooltip(show:lower())
		end
	else
		if (#self.data.macro_Name>0) then
			GameTooltip:SetText(self.data.macro_Name)
		end
	end
end

function BUTTON:MACRO_OnEnter(...)

	if (self.bar) then

		if (self.tooltipsCombat and InCombatLockdown()) then
			return
		end

		if (self.tooltips) then

			if (self.tooltipsEnhanced) then
				self.UberTooltips = true
				GameTooltip_SetDefaultAnchor(GameTooltip, self)
			else
				self.UberTooltips = false
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			end

			self:MACRO_SetTooltip()

			GameTooltip:Show()
		end
	end
end

function BUTTON:MACRO_OnLeave(...)

	self.UpdateTooltip = nil

	GameTooltip:Hide()

end

function BUTTON:MACRO_OnShow(...)

	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
	self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	self:RegisterEvent("ACTIONBAR_UPDATE_STATE")

	self:RegisterEvent("RUNE_POWER_UPDATE")

	self:RegisterEvent("TRADE_SKILL_SHOW")
	self:RegisterEvent("TRADE_SKILL_CLOSE")
	self:RegisterEvent("ARCHAEOLOGY_CLOSED")

	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

	self:RegisterEvent("MODIFIER_STATE_CHANGED")

	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	self:RegisterEvent("UNIT_SPELLCAST_FAILED")
	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("UNIT_ENTERED_VEHICLE")
	self:RegisterEvent("UNIT_ENTERING_VEHICLE")
	self:RegisterEvent("UNIT_EXITED_VEHICLE")

	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("PLAYER_FOCUS_CHANGED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_ENTER_COMBAT")
	self:RegisterEvent("PLAYER_LEAVE_COMBAT")
	self:RegisterEvent("PLAYER_CONTROL_LOST")
	self:RegisterEvent("PLAYER_CONTROL_GAINED")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

	self:RegisterEvent("UNIT_INVENTORY_CHANGED")
	self:RegisterEvent("BAG_UPDATE_COOLDOWN")
	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("COMPANION_UPDATE")
	self:RegisterEvent("PET_STABLE_UPDATE")
	self:RegisterEvent("PET_STABLE_SHOW")

	self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
	self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")

end

function BUTTON:MACRO_OnHide(...)

	self:UnregisterEvent("ACTIONBAR_SLOT_CHANGED")
	self:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	self:UnregisterEvent("ACTIONBAR_UPDATE_STATE")

	self:UnregisterEvent("RUNE_POWER_UPDATE")

	self:UnregisterEvent("TRADE_SKILL_SHOW")
	self:UnregisterEvent("TRADE_SKILL_CLOSE")
	self:UnregisterEvent("ARCHAEOLOGY_CLOSED")

	self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")

	self:UnregisterEvent("MODIFIER_STATE_CHANGED")

	self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	self:UnregisterEvent("UNIT_SPELLCAST_FAILED")
	self:UnregisterEvent("UNIT_PET")
	self:UnregisterEvent("UNIT_AURA")
	self:UnregisterEvent("UNIT_ENTERED_VEHICLE")
	self:UnregisterEvent("UNIT_ENTERING_VEHICLE")
	self:UnregisterEvent("UNIT_EXITED_VEHICLE")

	self:UnregisterEvent("PLAYER_TARGET_CHANGED")
	self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("PLAYER_ENTER_COMBAT")
	self:UnregisterEvent("PLAYER_LEAVE_COMBAT")
	self:UnregisterEvent("PLAYER_CONTROL_LOST")
	self:UnregisterEvent("PLAYER_CONTROL_GAINED")
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")

	self:UnregisterEvent("UNIT_INVENTORY_CHANGED")
	self:UnregisterEvent("BAG_UPDATE_COOLDOWN")
	self:UnregisterEvent("BAG_UPDATE")
	self:UnregisterEvent("COMPANION_UPDATE")
	self:UnregisterEvent("PET_STABLE_UPDATE")
	self:UnregisterEvent("PET_STABLE_SHOW")

	self:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
	self:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")

end

function BUTTON:MACRO_OnAttributeChanged(name, value)

	if (value and self.data) then

		if (name == "activestate") then

			if (value:find("vehicle")) then

				self.vehicleID = self:GetAttribute("*action*")

			else

				if (not self.statedata) then
					self.statedata = { homestate = CopyTable(stateData) }
				end

				if (not self.statedata[value]) then
					self.statedata[value] = CopyTable(stateData)
				end

				self.data = self.statedata[value]

				self:MACRO_UpdateParse()

				self:MACRO_Reset()

				self.vehicleID = false

			end

			self:MACRO_UpdateAll(true)
		end

		if (name == "update") then
			self:MACRO_UpdateAll(true)
		end
	end
end

function BUTTON:MACRO_Reset()

	self.macrospell = nil
	self.spellID = nil
	self.macroitem = nil
	self.macroshow = nil
	self.macroicon = nil

end

function BUTTON:MACRO_UpdateParse()

	self.macroparse = self.data.macro_Text

	if (#self.macroparse > 0) then
		self.macroparse = "\n"..self.macroparse.."\n"
		self.macroparse = (self.macroparse):gsub("(%c+)", " %1")
	else
		self.macroparse = nil
	end

end

local btnData = {}

function BUTTON:SetSkinned()

	if (SKIN) then

		local bar = self.bar

		if (bar) then

			wipe(btnData)

			btnData.Normal = self.normaltexture
			btnData.Icon = self.iconframeicon
			btnData.Cooldown = self.iconframecooldown
			btnData.HotKey = self.hotkey
			btnData.Count = self.count
			btnData.Name = self.name
			btnData.Border = self.border
			btnData.AutoCast = false

			SKIN:Group("Ion", bar.gdata.name):AddButton(self, btnData)
		end
	end
end

function BUTTON:GetSkinned()

	if (self.__MSQ_NormalTexture) then

		local Skin = self.__MSQ_NormalSkin

		if (Skin) then

			self.hasAction = Skin.Texture or false
			self.noAction = Skin.EmptyTexture or false

			if (self.__MSQ_Shape) then
				self.shape = self.__MSQ_Shape:lower()
			else
				self.shape = "square"
			end
		else
			self.hasAction = false
			self.noAction = false
			self.shape = "square"
		end

		self.shine.shape = self.shape

		return true
	else
		self.hasAction = "Interface\\Buttons\\UI-Quickslot2"
		self.noAction = "Interface\\Buttons\\UI-Quickslot"

		return false
	end
end

function BUTTON:SetData(bar)

	if (bar) then

		self.bar = bar

		self.barLock = bar.cdata.barLock
		self.barLockAlt = bar.cdata.barLockAlt
		self.barLockCtrl = bar.cdata.barLockCtrl
		self.barLockShift = bar.cdata.barLockShift

		self.tooltips = bar.cdata.tooltips
		self.tooltipsEnhanced = bar.cdata.tooltipsEnhanced
		self.tooltipsCombat = bar.cdata.tooltipsCombat

		self.spellGlow = bar.cdata.spellGlow
		self.spellGlowDef = bar.cdata.spellGlowDef
		self.spellGlowAlt = bar.cdata.spellGlowAlt

		self.bindText = bar.cdata.bindText
		self.macroText = bar.cdata.macroText
		self.countText = bar.cdata.countText

		self.cdText = bar.cdata.cdText

		if (bar.cdata.cdAlpha) then
			self.cdAlpha = 0.2
		else
			self.cdAlpha = 1
		end

		self.auraText = bar.cdata.auraText
		self.auraInd = bar.cdata.auraInd

		self.upClicks = bar.cdata.upClicks
		self.downClicks = bar.cdata.downClicks

		self.rangeInd = bar.cdata.rangeInd

		self.showGrid = bar.gdata.showGrid

		self:SetFrameStrata(bar.gdata.objectStrata)

		self:SetScale(bar.gdata.scale)

	end

	if (self.bindText) then self.hotkey:Show() else self.hotkey:Hide() end
	if (self.macroText) then self.macroname:Show() else self.macroname:Hide() end
	if (self.countText) then self.count:Show() else self.count:Hide() end

	local down, up = "", ""

	if (self.upClicks) then up = up.."AnyUp" end
	if (self.downClicks) then down = down.."AnyDown" end

	self:RegisterForClicks(down, up)
	self:RegisterForDrag("LeftButton", "RightButton")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	self.equipcolor = { 0.1, 1, 0.1, 1 }
	self.cdcolor1 = { 1, 0.82, 0, 1 }
	self.cdcolor2 = { 1, 0.1, 0.1, 1 }
	self.auracolor1 = { 0, 0.82, 0, 1 }
	self.auracolor2 = { 1, 0.1, 0.1, 1 }
	self.buffcolor = { 0, 0.8, 0, 1 }
	self.debuffcolor = { 0.8, 0, 0, 1 }
	self.manacolor = { 0.5, 0.5, 1.0 }
	self.rangecolor = { 0.7, 0.15, 0.15, 1 }

	self:SetFrameLevel(4)
	self.iconframe:SetFrameLevel(2)
	self.iconframecooldown:SetFrameLevel(3)
	self.iconframeaurawatch:SetFrameLevel(3)

	self:GetSkinned()
end

function BUTTON:SaveData(state)

	local index, spec = self.id, GetActiveSpecGroup()

	if (not state) then
		state = self:GetParent():GetAttribute("activestate") or "homestate"
	end

	if (index and spec and state) then

		if (not btnGDB[index].config) then
			btnGDB[index].config = CopyTable(configData)
		end

		for key,value in pairs(self.config) do
			btnGDB[index].config[key] = value
		end

		if (not btnGDB[index].keys) then
			btnGDB[index].keys = CopyTable(keyData)
		end

		if (not btnCDB[index].keys) then
			btnCDB[index].keys = CopyTable(keyData)
		end

		if (CDB.perCharBinds) then
			for key,value in pairs(self.keys) do
				btnCDB[index].keys[key] = value
			end
		else
			for key,value in pairs(self.keys) do
				btnGDB[index].keys[key] = value
			end
		end

		if (not btnCDB[index][spec]) then
			btnCDB[index][spec] = { homestate = CopyTable(stateData) }
		end

		if (not btnCDB[index][spec][state]) then
			btnCDB[index][spec][state] = CopyTable(stateData)
		end

		for key,value in pairs(self.data) do
			btnCDB[index][spec][state][key] = value
		end

		self:BuildStateData()

	else
		print("DEBUG: Bad Save Data for "..self:GetName().." ?")
		--print(debugstack())
		--print(self:GetParent():GetName())
		print(index); print(spec); print(state)
	end
end

function BUTTON:LoadData(spec, state)

	local id = self.id

	self.GDB = btnGDB
	self.CDB = btnCDB

	if (self.GDB and self.CDB) then

		if (not self.GDB[id]) then
			self.GDB[id] = {}
		end

		if (not self.GDB[id].config) then
			self.GDB[id].config = CopyTable(configData)
		end

		if (not self.GDB[id].keys) then
			self.GDB[id].keys = CopyTable(keyData)
		end

		if (not self.CDB[id]) then
			self.CDB[id] = { [1] = { homestate = CopyTable(stateData) }, [2] = { homestate = CopyTable(stateData) } }
		end

		if (not self.CDB[id].keys) then
			self.CDB[id].keys = CopyTable(keyData)
		end

		if (not self.CDB[id][spec]) then
			self.CDB[id][spec] = { homestate = CopyTable(stateData) }
		end

		if (not self.CDB[id][spec][state]) then
			self.CDB[id][spec][state] = CopyTable(stateData)
		end

		ION:UpdateData(self.GDB[id].config, configData)
		ION:UpdateData(self.GDB[id].keys, keyData)

		for spec,states in pairs(self.CDB[id]) do
			for state,data in pairs(states) do
				if (type(data) == "table") then
					ION:UpdateData(data, stateData)
				end
			end
		end

		self.config = self.GDB[id].config

		if (CDB.perCharBinds) then
			self.keys = self.CDB[id].keys
		else
			self.keys = self.GDB[id].keys
		end

		self.statedata = self.CDB[id][spec]

		self.data = self.statedata[state]

		self:BuildStateData()

	end
end

function BUTTON:BuildStateData()

	for state, data in pairs(self.statedata) do
		self:SetAttribute(state.."-macro_Text", data.macro_Text)
	end
end

function BUTTON:Reset()

	self:SetAttribute("unit", nil)
	self:SetAttribute("useparent-unit", nil)
	self:SetAttribute("type", nil)
	self:SetAttribute("type1", nil)
	self:SetAttribute("type2", nil)
	self:SetAttribute("*action*", nil)
	self:SetAttribute("*macrotext*", nil)
	self:SetAttribute("*action1", nil)
	self:SetAttribute("*macrotext2", nil)

	self:UnregisterEvent("ITEM_LOCK_CHANGED")
	self:UnregisterEvent("UPDATE_BONUS_ACTIONBAR")
	self:UnregisterEvent("ACTIONBAR_SHOWGRID")
	self:UnregisterEvent("ACTIONBAR_HIDEGRID")
	self:UnregisterEvent("PET_BAR_SHOWGRID")
	self:UnregisterEvent("PET_BAR_HIDEGRID")
	self:UnregisterEvent("PET_BAR_UPDATE")
	self:UnregisterEvent("PET_BAR_UPDATE_COOLDOWN")
	self:UnregisterEvent("UNIT_FLAGS")
	self:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	self:UnregisterEvent("UPDATE_MACROS")

	self:MACRO_Reset()
end

function BUTTON:SetGrid(show, hide)

	if (not InCombatLockdown()) then

		self:SetAttribute("isshown", self.showGrid)
		self:SetAttribute("showgrid", show)

		if (show or self.showGrid) then
			self:Show()
		elseif (not (self:IsMouseOver() and self:IsVisible()) and not self:MACRO_HasAction()) then
			self:Hide()
		end
	end
end

function BUTTON:SetAux()

	self:SetSkinned()

end


function BUTTON:LoadAux()

	self:CreateBindFrame(self.objTIndex)

end

function BUTTON:SetDefaults(config, keys)

	if (config) then
		for k,v in pairs(config) do
			self.config[k] = v
		end
	end

	if (keys) then
		for k,v in pairs(keys) do
			self.keys[k] = v
		end
	end
end

function BUTTON:GetDefaults()

	return nil, keyDefaults[self.id]

end

function BUTTON:SetType(save, kill, init)

	local state = self:GetParent():GetAttribute("activestate")

	self:Reset()

	if (kill) then

		self:SetScript("OnEvent", function() end)
		self:SetScript("OnUpdate", function() end)
		self:SetScript("OnAttributeChanged", function() end)

	else

		SecureHandler_OnLoad(self)

		self:RegisterEvent("ITEM_LOCK_CHANGED")
		self:RegisterEvent("ACTIONBAR_SHOWGRID")
		self:RegisterEvent("ACTIONBAR_HIDEGRID")
		self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		self:RegisterEvent("UPDATE_MACROS")

		self:MACRO_UpdateParse()

		self:SetAttribute("type", "macro")
		self:SetAttribute("*macrotext*", self.macroparse)

		self:SetScript("OnEvent", BUTTON.MACRO_OnEvent)
		self:SetScript("PreClick", BUTTON.MACRO_PreClick)
		self:SetScript("PostClick", BUTTON.MACRO_PostClick)
		self:SetScript("OnReceiveDrag", BUTTON.MACRO_OnReceiveDrag)
		self:SetScript("OnDragStart", BUTTON.MACRO_OnDragStart)
		self:SetScript("OnDragStop", BUTTON.MACRO_OnDragStop)
		self:SetScript("OnUpdate", BUTTON.MACRO_OnUpdate)
		self:SetScript("OnEnter", BUTTON.MACRO_OnEnter)
		self:SetScript("OnLeave", BUTTON.MACRO_OnLeave)
		self:SetScript("OnShow", BUTTON.MACRO_OnShow)
		self:SetScript("OnHide", BUTTON.MACRO_OnHide)
		self:SetScript("OnAttributeChanged", BUTTON.MACRO_OnAttributeChanged)

		self:WrapScript(self, "OnShow", [[
						for i=1,select('#',(":"):split(self:GetAttribute("hotkeys"))) do
							self:SetBindingClick(self:GetAttribute("hotkeypri"), select(i,(":"):split(self:GetAttribute("hotkeys"))), self:GetName())
						end
						]])

		self:WrapScript(self, "OnHide", [[
						for key in gmatch(self:GetAttribute("hotkeys"), "[^:]+") do
							self:ClearBinding(key)
						end
						]])

		self:SetAttribute("_childupdate", [[

				if (message)  then

					local msg = (":"):split(message)

					if (msg:find("vehicle")) then

						if (self:GetAttribute("lastPos")) then

							self:SetAttribute("type", "macro")

							if (UnitHasVehicleUI("player")) then
								self:SetAttribute("*macrotext*", "/click VehicleMenuBarLeaveButton")
							else
								self:SetAttribute("*macrotext*", "/click PossessButton2")
							end

							self:SetAttribute("*action*", 0)

						else

							self:SetAttribute("type", "action")

							self:SetAttribute("*action*", self:GetAttribute("barPos")+120)
						end

						self:Show()

					else

						self:SetAttribute("type", "macro")

						self:SetAttribute("*macrotext*", self:GetAttribute(msg.."-macro_Text"))

						if ((self:GetAttribute("*macrotext*") and #self:GetAttribute("*macrotext*") > 0) or (self:GetAttribute("showgrid"))) then
							self:Show()
						elseif (not self:GetAttribute("isshown")) then
							self:Hide()
						end

					end

					self:SetAttribute("useparent-unit", nil)

					self:SetAttribute("activestate", msg)

				end

			]])

		if (not init) then
			self:MACRO_UpdateAll(true)
		end

		self:MACRO_OnShow()

	end

	if (save) then
		self:SaveData(state)
	end
end

function BUTTON:AutoWriteMacro(spell, subName)

	local modifier, modkey = " "

	if (GDB.selfCast) then
		modKey = ((GDB.selfCast):match("^%a+")):lower(); modifier = modifier.."[@player,mod:"..modKey.."]"
	end

	if (GDB.focusCast) then
		modKey = ((GDB.focusCast):match("^%a+")):lower(); modifier = modifier.."[@focus,mod:"..modKey.."]"
	end

	if (GDB.rightClickTarget) then
		modKey = GDB.rightClickTarget; modifier = modifier.."[@"..modKey..",btn:2]"
	end

	if (modKey) then
		modifier = modifier.."[] "
	end

	if (subName and #subName > 0) then
		return "#autowrite\n/cast"..modifier..spell.."("..subName..")"
	else
		return "#autowrite\n/cast"..modifier..spell.."()"
	end
end

local function controlOnEvent(self, event, ...)

	if (event:find("UNIT_")) then

		if (unitAuras[select(1,...)]) then
			if (... == "player") then
				for k,v in pairs(morphSpells) do
					morphSpells[k] = false
				end
			end
			updateAuraInfo(select(1,...))
		end

	elseif (event == "PLAYER_TARGET_CHANGED") then

		for k in pairs(unitAuras) do
			updateAuraInfo(k)
		end

	elseif (event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW") then

		local spellID = select(2, ...)

		spellGlows[spellID] = true

	elseif (event == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE") then

		local spellID = select(2, ...)

		spellGlows[spellID] = nil

	elseif (event == "ADDON_LOADED" and ... == "Ion") then

		GDB, CDB = IonGDB, IonCDB

		btnGDB = GDB.buttons

		btnCDB = CDB.buttons

		ItemCache = IonItemCache

		cmdSlash = {
			[SLASH_CAST1] = true,
			[SLASH_CAST2] = true,
			[SLASH_CAST3] = true,
			[SLASH_CAST4] = true,
			[SLASH_CASTRANDOM1] = true,
			[SLASH_CASTRANDOM2] = true,
			[SLASH_CASTSEQUENCE1] = true,
			[SLASH_CASTSEQUENCE2] = true,
			[SLASH_EQUIP1] = true,
			[SLASH_EQUIP2] = true,
			[SLASH_EQUIP3] = true,
			[SLASH_EQUIP4] = true,
			[SLASH_EQUIP_TO_SLOT1] = true,
			[SLASH_EQUIP_TO_SLOT2] = true,
			[SLASH_USE1] = true,
			[SLASH_USE2] = true,
			[SLASH_USERANDOM1] = true,
			[SLASH_USERANDOM2] = true,
			["/cast"] = true,
			["/castrandom"] = true,
			["/castsequence"] = true,
			["/spell"] = true,
			["/equip"] = true,
			["/eq"] = true,
			["/equipslot"] = true,
			["/use"] = true,
			["/userandom"] = true,
		}

		ION.AutoCastStart = AutoCastStart
		ION.AutoCastStop = AutoCastStop

		ION.SetTimer = BUTTON.SetTimer
		ION.SetSkinned = BUTTON.SetSkinned
		ION.GetSkinned = BUTTON.GetSkinned

	elseif (event == "VARIABLES_LOADED") then


	elseif (event == "PLAYER_LOGIN") then

		SPEC = IonSpec

		for k in pairs(unitAuras) do
			updateAuraInfo(k)
		end

		WorldFrame:HookScript("OnMouseUp", checkCursor)
		WorldFrame:HookScript("OnMouseDown", checkCursor)

	elseif (event == "PLAYER_ENTERING_WORLD" and not PEW) then

		PEW = true

	elseif (event == "ACTIONBAR_SHOWGRID") then

		StartDrag = true

	end
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnUpdate", cooldownsOnUpdate)

frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", controlOnEvent)
frame:SetScript("OnUpdate", controlOnUpdate)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("VARIABLES_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("ACTIONBAR_SHOWGRID")
frame:RegisterEvent("UNIT_AURA")
frame:RegisterEvent("UNIT_SPELLCAST_SENT")
frame:RegisterEvent("UNIT_SPELLCAST_START")
frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
frame:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
frame:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")