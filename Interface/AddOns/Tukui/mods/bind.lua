-- feature offered by Nightcracker !

local bind, localmacros = CreateFrame("Frame", "ncHoverBind", UIParent), 0

bind:SetFrameStrata("DIALOG")
bind:EnableMouse(true)
bind:EnableKeyboard(true)
bind:EnableMouseWheel(true)
bind.texture = bind:CreateTexture()
bind.texture:SetAllPoints(bind)
bind.texture:SetTexture(0, 0, 0, .25)
bind:Hide()

bind.hash = "32hn9t832utggfhkmesyrhut89q3tu2"
bind:SetScript("OnEvent", function(self) self:Deactivate(false) end)
bind:SetScript("OnLeave", function(self) self:HideFrame() end)
bind:SetScript("OnKeyUp", function(self, key) self:Listener(key) end)
bind:SetScript("OnMouseUp", function(self, key) self:Listener(key) end)
bind:SetScript("OnMouseWheel", function(self, delta) if delta>0 then self:Listener("MOUSEWHEELUP") else self:Listener("MOUSEWHEELDOWN") end end)

function bind:Update(b, spellmacro)
	if not self.enabled or InCombatLockdown() then return end
	self.button = b
	self.spellmacro = spellmacro

	self:ClearAllPoints()
	self:SetAllPoints(b)
	self:Show()

	if spellmacro=="SPELL" then
		self.button.id = SpellBook_GetSpellID(self.button:GetID())
		self.button.name = GetSpellName(self.button.id, SpellBookFrame.bookType)

		GameTooltip:AddLine("Trigger")
		GameTooltip:Show()
		GameTooltip:SetScript("OnHide", function(self)
			self:SetOwner(bind, "ANCHOR_NONE")
			self:SetPoint("BOTTOM", bind, "TOP", 0, 1)
			self:AddLine(bind.button.name, 1, 1, 1)
			bind.button.bindings = {GetBindingKey(spellmacro.." "..bind.button.name)}
			if #bind.button.bindings == 0 then
				self:AddLine("No bindings set.", .6, .6, .6)
			else
				self:AddDoubleLine("Binding", "Key", .6, .6, .6, .6, .6, .6)
				for i = 1, #bind.button.bindings do
					self:AddDoubleLine(i, bind.button.bindings[i])
				end
			end
			self:Show()
			self:SetScript("OnHide", nil)
		end)
	elseif spellmacro=="MACRO" then
		self.button.id = self.button:GetID()

		if localmacros==1 then self.button.id = self.button.id + 36 end

		self.button.name = GetMacroInfo(self.button.id)

		GameTooltip:SetOwner(bind, "ANCHOR_NONE")
		GameTooltip:SetPoint("BOTTOM", bind, "TOP", 0, 1)
		GameTooltip:AddLine(bind.button.name, 1, 1, 1)

		bind.button.bindings = {GetBindingKey(spellmacro.." "..bind.button.name)}
			if #bind.button.bindings == 0 then
				GameTooltip:AddLine("No bindings set.", .6, .6, .6)
			else
				GameTooltip:AddDoubleLine("Binding", "Key", .6, .6, .6, .6, .6, .6)
				for i = 1, #bind.button.bindings do
					GameTooltip:AddDoubleLine("Binding"..i, bind.button.bindings[i], 1, 1, 1)
				end
			end
		GameTooltip:Show()
	else
		self.button.id = b:GetAttribute("action")
		self.button.name = b:GetName()

		GameTooltip:AddLine("Trigger")
		GameTooltip:Show()
		GameTooltip:SetScript("OnHide", function(self)
			self:SetOwner(bind, "ANCHOR_NONE")
			self:SetPoint("BOTTOM", bind, "TOP", 0, 1)
			self:AddLine(bind.button.name, 1, 1, 1)
			bind.button.bindings = {GetBindingKey("CLICK "..bind.button.name..":LeftButton")}
			if #bind.button.bindings == 0 then
				self:AddLine("No bindings set.", .6, .6, .6)
			else
				self:AddDoubleLine("Binding", "Key", .6, .6, .6, .6, .6, .6)
				for i = 1, #bind.button.bindings do
					self:AddDoubleLine(i, bind.button.bindings[i])
				end
			end
			self:Show()
			self:SetScript("OnHide", nil)
		end)
	end

	--[[
	elseif spellmacro=="MACRO" then
		self.button.id = self.button:GetID()
		if localmacros==1 then self.button.id = self.button.id + 36 end
		self.button.name = GetMacroInfo(self.button.id)

		GameTooltip:SetOwner(bind, "ANCHOR_NONE")
		GameTooltip:SetPoint("BOTTOM", bind, "TOP", 0, 1)
		GameTooltip:AddLine(bind.button.name, 0, 1, 0)
		bind.button.bindings = {GetBindingKey(spellmacro.." "..bind.button.name)}
			if #bind.button.bindings == 0 then
				GameTooltip:AddLine("No Bindings Set")
			else
				for i = 1, #bind.button.Bindings do
					GameTooltip:AddDoubleLine("Binding"..i, bind.button.bindings[i], 1, 1, 1)
				end
			end
		GameTooltip:Show()
	else
	end
	--]]
end

function bind:Listener(key)
	if key == "ESCAPE" or key == "RightButton" then
		for i = 1, #self.button.bindings do
			SetBinding(self.button.bindings[i])
		end
		print("All keybindings cleared for |cff00ff00"..self.button.name.."|r.")
		self:Update(self.button, self.spellmacro)
		if self.spellmacro~="MACRO" then GameTooltip:Hide() end
		return
	end

	if key == "LSHIFT"
	or key == "RSHIFT"
	or key == "LCTRL"
	or key == "RCTRL"
	or key == "LALT"
	or key == "RALT"
	or key == "UNKNOWN"
	or key == "LeftButton"
	or key == "MiddleButton"
	then return end

	if key == "Button4" then key = "BUTTON4" end
	if key == "Button5" then key = "BUTTON5" end

	local alt = IsAltKeyDown() and "ALT-" or ""
	local ctrl = IsControlKeyDown() and "CTRL-" or ""
	local shift = IsShiftKeyDown() and "SHIFT-" or ""

	if not self.spellmacro then
		SetBinding(alt..ctrl..shift..key, "CLICK "..self.button.name..":LeftButton")
	else
		SetBinding(alt..ctrl..shift..key, self.spellmacro.." "..self.button.name)
	end
	print(alt..ctrl..shift..key.." |cff00ff00bound to |r"..self.button.name..".")
	self:Update(self.button, self.spellmacro)
	if self.spellmacro~="MACRO" then GameTooltip:Hide() end
end

function bind:HideFrame()
	self:ClearAllPoints()
	self:Hide()
	GameTooltip:Hide()
end
function bind:Activate()
	self.enabled = true
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
end
function bind:Deactivate(save)
	if save then
		SaveBindings(2)
		print("All keybindings have been saved.")
	else
		LoadBindings(2)
		print("All newly set keybindings have been discarded.")
	end
	self.enabled = false
	self:HideFrame()
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	StaticPopup_Hide("KEYBIND_MODE")
end

StaticPopupDialogs["KEYBIND_MODE"] = {
	text = "Hover your mouse over any actionbutton to bind it. Press the escape key or right click to clear the current actionbutton's keybinding.",
	button1 = "Save bindings",
	button2 = "Discard bindings",
	OnAccept = function() bind:Deactivate(true) end,
	OnCancel = function() bind:Deactivate(false) end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false
}

-- SLASH COMMAND
SlashCmdList.MOUSEOVERBIND = function()
	if InCombatLockdown() then
		print("You can't bind keys in combat.")
	elseif not bind.enabled then
		bind:Activate()
		StaticPopup_Show("KEYBIND_MODE")
	end
end
SLASH_MOUSEOVERBIND1 = "/hb"
SLASH_MOUSEOVERBIND2 = "/hoverbind"



-- REGISTERING
local event = CreateFrame("FRAME")
event:RegisterEvent("PLAYER_ENTERING_WORLD")
event:SetScript("OnEvent", function()
	for key, val in pairs(_G) do
		if type(val)=="table" and val.GetAttribute and val.GetObjectType and val:GetObjectType()=="CheckButton" and val:GetAttribute("type")=="action" then
			val:HookScript("OnEnter", function(self) bind:Update(self) end)
		end
	end
	event:UnregisterAllEvents()
end)

LoadAddOn("Blizzard_MacroUI")
for i=1,12 do
	local b = _G["SpellButton"..i]
	b:HookScript("OnEnter", function(self) bind:Update(self, "SPELL") end)
end
for i=1,36 do
	local b = _G["MacroButton"..i]
	b:HookScript("OnEnter", function(self) bind:Update(self, "MACRO") end)
end
MacroFrameTab1:HookScript("OnMouseUp", function() localmacros = 0 end)
MacroFrameTab2:HookScript("OnMouseUp", function() localmacros = 1 end)