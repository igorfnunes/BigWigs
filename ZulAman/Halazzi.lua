﻿------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Halazzi"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

local hp = nil
local UnitName = UnitName
local UnitHealth = UnitHealth
local first, second, third, fourth, fifth, sixth

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Halazzi",

	engage_trigger = "Get on ya knees and bow.... to da fang and claw!",

	totem = "Totem",
	totem_desc = "Warn when Halazzi casts a Lightning Totem.",
	totem_trigger = "Halazzi  begins to cast Lightning Totem.",
	totem_message = "Incoming Lightning Totem!",

	phase = "Phases",
	phase_desc = "Warn for phase changes.",
	phase_spirit = "I fight wit' untamed spirit....",
	phase_normal = "Spirit, come back to me!",
	normal_message = "Normal Phase!",
	spirit_message = "%d HP! - Spirit Phase!",
	spirit_soon = "Spirit Phase soon!",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

local mod = BigWigs:NewModule(boss)
mod.zonename = AceLibrary("Babble-Zone-2.2")["Zul'Aman"]
mod.enabletrigger = boss
mod.toggleoptions = {"totem", "phase", "bosskill"}
mod.revision = tonumber(("$Revision$"):sub(12, -3))

------------------------------
--      Initialization      --
------------------------------

function mod:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("UNIT_HEALTH")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "HalHP", 4.5)
	self:TriggerEvent("BigWigs_ThrottleSync", "HalSoon", 4.5)
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
end

------------------------------
--      Event Handlers      --
------------------------------

function mod:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF(msg)
	if self.db.profile.totem and msg == L["totem_trigger"] then
		self:Message(L["totem_message"], "Attention")
	end
end

function mod:BigWigs_RecvSync(sync, rest, nick)
	if not self.db.profile.phase then return end

	if sync == "HalHP" and rest then
		hp = rest
	elseif sync == "HalSoon" then
		self:Message(L["spirit_soon"], "Positive")
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if not self.db.profile.phase then return end

	if msg == L["phase_spirit"] then
		self:Message(L["spirit_message"]:format(hp), "Urgent")
		self:Bar(L["spirit_bar"], 60, "Spell_Nature_Regenerate")
	elseif msg == L["phase_normal"] then
		self:Message(L["normal_message"], "Attention")
	elseif msg == L["engage_trigger"] then
		hp = nil; first = nil; second = nil; third = nil; fourth = nil; fifth = nil; sixth = nil;
	end
end

function mod:UNIT_HEALTH(msg)
	if not self.db.profile.phase then return end

	if UnitName(msg) == boss then
		local health = UnitHealth(msg)
		if health == 75 and not first then
			first = true
			self:Sync("HalHP ", health)
		elseif health == 50 and not second then
			second = true
			self:Sync("HalHP ", health)
		elseif health == 25 and not third then
			third = true
			self:Sync("HalHP ", health)
		elseif health == 80 and not fourth then
			fourth = true
			self:Sync("HalSoon")
		elseif health == 55 and not fifth then
			fifth = true
			self:Sync("HalSoon")
		elseif health == 30 and not sixth then
			sixth = true
			self:Sync("HalSoon")
		end
	end
end
