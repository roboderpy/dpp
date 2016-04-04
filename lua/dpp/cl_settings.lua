
DPP.SettingsClass = DPP.SettingsClass or {}

local SettingsClass = DPP.SettingsClass
local FUNCTIONS = {}
DPP.SettingsClass.FUNCTIONS = FUNCTIONS

function FUNCTIONS.CheckBoxThink(self)
	local val = DPP.GetConVar(self.val)
	self:SetChecked(val)
	self.LastVal = val
end

function FUNCTIONS.CheckBoxDoClick(self)
	if not LocalPlayer():IsSuperAdmin() then return end
	
	RunConsoleCommand('dpp_setvar', self.val, tobool(self.LastVal) and '0' or '1')
end

function FUNCTIONS.CCheckBoxThink(self)
	local val = DPP.PlayerConVar(LocalPlayer(), self.val)
	self:SetChecked(val)
	self.LastVal = val
end

function FUNCTIONS.CCheckBoxDoClick(self)
	RunConsoleCommand('dpp_' .. self.val, (not self.LastVal) == false and '0' or '1')
end

SettingsClass.Styles = SettingsClass.Styles or {}
local Style = SettingsClass.Styles

SettingsClass.Background = Color(65, 65, 65)
SettingsClass.Glow = Color(125, 125, 125)
SettingsClass.Checked = Color(82, 255, 152, 255)
SettingsClass.UnChecked = Color(255, 148, 148, 255)
SettingsClass.CheckBox = Color(200, 200, 200)
SettingsClass.FrameColor = SettingsClass.Background
SettingsClass.TextColor = color_white
SettingsClass.Chars = {'!','@','#','$','%','^','&','*','(',')'}

function Style.ScramblingCharsThink(self)
	local isHovered = IsValid(hoverPanel) and hoverPanel:IsHovered() or IsValid(hoverPanel2) and hoverPanel2:IsHovered() or self:IsHovered()
	
	if isHovered and not self.IsScrambling and not self.AfterScramble then
		self.IsScrambling = true
		self.OriginalText = self:GetText()
		self.CurrentChar = 1
		self.Chars = #self.OriginalText
		self.NextChar = CurTime() + 0.1
	end
	
	if not isHovered and self.AfterScramble then
		self.AfterScramble = false
	end
	
	if self.IsScrambling and self.NextChar < CurTime() then
		if self.Chars >= self.CurrentChar then
			local t = string.sub(self.OriginalText, 1, self.CurrentChar) .. table.Random(SettingsClass.Chars) .. table.Random(SettingsClass.Chars) .. table.Random(SettingsClass.Chars) .. string.sub(self.OriginalText, self.CurrentChar + 3)
			self:SetText(t)
			self:SizeToContents()
			self.CurrentChar = self.CurrentChar + 1
		else
			self:SetText(self.OriginalText)
			self.IsScrambling = false
			self.AfterScramble = true
			self:SizeToContents()
		end
	end
	
	if self.oldThink then self.oldThink(self) end
end

function Style.ScramblingCharsThinkButton(self)
	local isHovered = IsValid(hoverPanel) and hoverPanel:IsHovered() or IsValid(hoverPanel2) and hoverPanel2:IsHovered() or self:IsHovered()
	
	if isHovered and not self.IsScrambling and not self.AfterScramble then
		self.IsScrambling = true
		self.OriginalText = self:GetText()
		self.CurrentChar = 1
		self.Chars = #self.OriginalText
		self.NextChar = CurTime() + 0.1
	end
	
	if not isHovered and self.AfterScramble then
		self.AfterScramble = false
	end
	
	if self.IsScrambling and self.NextChar < CurTime() then
		if self.Chars >= self.CurrentChar then
			local t = string.sub(self.OriginalText, 1, self.CurrentChar) .. table.Random(SettingsClass.Chars) .. table.Random(SettingsClass.Chars) .. table.Random(SettingsClass.Chars) .. string.sub(self.OriginalText, self.CurrentChar + 3)
			self:SetText(t)
			--self:SizeToContents()
			self.CurrentChar = self.CurrentChar + 1
		else
			self:SetText(self.OriginalText)
			self.IsScrambling = false
			self.AfterScramble = true
			--self:SizeToContents()
		end
	end
	
	if self.oldThink then self.oldThink(self) end
end

function SettingsClass.AddScramblingChars(panel, hoverPanel, hoverPanel2)
	local oldThink = panel.Think
	panel.hoverPanel = hoverPanel
	panel.hoverPanel2 = hoverPanel2
	panel.Think = Style.ScramblingCharsThink
end

function Style.NeonButtonPaint(self, w, h)
	self.Neon = self.Neon or 0
	
	if not self:IsDown() then
		draw.RoundedBox(0, 0, 0,w, h,Color(self.Neon, self.Neon, self.Neon, 150))
	else
		draw.RoundedBox(0, 0, 0,w, h,Color(200, 200, 200, 150))
	end
	
	if self:IsHovered() then
		self.Neon = math.min(self.Neon + 5 * (66 / (1/FrameTime())), 150)
	else
		self.Neon = math.max(self.Neon - 5 * (66 / (1/FrameTime())), 0)
	end
end

function SettingsClass.ApplyButtonStyle(panel)
	panel.Paint = Style.NeonButtonPaint
	panel.Think = Style.ScramblingCharsThinkButton
	
	timer.Simple(0, function() if IsValid(panel) then panel:SetTextColor(Color(255, 255, 255)) end end)
end

function Style.FramePaint(self, w, h)
	draw.RoundedBox(0, 0, 0, w, h, SettingsClass.FrameColor)
end

function SettingsClass.ApplyFrameStyle(frame)
	frame.Paint = Style.FramePaint
end

surface.CreateFont('DPP.CheckBox', {
	font = 'Tahoma',
	weight = 800,
	size = 24,
})

SettingsClass.CheckBoxShift = -5

function Style.CheckBoxThink(self)
	local isHovered = self.Label:IsHovered() or self.Button:IsHovered() or self:IsHovered()
	
	self.IMyX = self:GetSize()
	if isHovered then
		self.CurrentArrowMove = math.Clamp(self.CurrentArrowMove + 1000 / (1/FrameTime()), -10, self.IMyX)
	else
		self.CurrentArrowMove = math.Clamp(self.CurrentArrowMove - 1000 / (1/FrameTime()), -10, self.IMyX)
	end
	
	if self.oldThink then self.oldThink() end
end

function Style.CheckBoxPaint(self, w, h)
	surface.SetDrawColor(SettingsClass.Glow)
	surface.DrawRect(0, 0, self.CurrentArrowMove, 30)
	
	--[[surface.DrawPoly{
		{x = x, y = 0},
		{x = x + 15, y = 0},
		{x = x - 2, y = 6},
		{x = x + 15, y = 12},
		{x = x, y = 12},
		{x = x - 15, y = 6},
	}]]
	
	self.oldPaint(w, h)
end

function Style.CheckBoxButtonPaint(self, w, h)
	local isChecked = self:GetChecked()
	
	surface.SetDrawColor(color_white)
	surface.DrawRect(0, 0, w, h)
	
	surface.SetFont('DPP.CheckBox')
	surface.SetTextPos(0, SettingsClass.CheckBoxShift)
	surface.SetTextColor(isChecked and SettingsClass.Checked or SettingsClass.UnChecked)
	surface.DrawText(isChecked and 'E' or 'D')
end

function SettingsClass.MakeCheckboxBetter(panel)
	panel.oldThink = panel.Think
	panel.oldPaint = panel.Paint
	
	panel.CurrentArrowMove = 0
	panel.SizeOfArrow = 0
	
	panel.Label:SetTextColor(SettingsClass.TextColor)
	panel.Think = Style.CheckBoxThink
	panel.Paint = Style.CheckBoxPaint
	
	panel.Button.Paint = Style.CheckBoxButtonPaint
end

function SettingsClass.PaintBackground(s, w, h)
	surface.SetDrawColor(SettingsClass.Background)
	surface.DrawRect(0, 0, w, h)
end

function SettingsClass.SetupBackColor(Panel)
	Panel.Paint = SettingsClass.PaintBackground
end

function SettingsClass.ApplySliderStyle(Slider)
	Slider.Label:SetTextColor(SettingsClass.TextColor)
	Slider.TextArea:SetTextColor(SettingsClass.TextColor)
end

local SortedConVars = {
	'enable',
	'enable_tool',
	'enable_physgun',
	'enable_gravgun',
	'enable_veh',
	'enable_use',
	'enable_pickup',
	'enable_damage',
	'enable_drive',
	'toolgun_player',
	'toolgun_player_admin',
	'can_admin_touch_world',
	'admin_can_everything',
	'can_touch_world',
	
	'clear_disconnected',
	'clear_disconnected_admin',
	
	'grabs_disconnected',
	'grabs_disconnected_admin',
}

local MiscConVars = {
	'no_rope_world',
	'log_spawns',
	'player_cant_punt',
	'prevent_prop_throw',
	'prevent_player_stuck',
	'prevent_explosions_crash',
	'advanced_spawn_checks',
	'experemental_spawn_checks',
	'verbose_logging',
	'allow_damage_vehicles',
	'allow_damage_sent',
	'allow_damage_npc',
}

local PlacedCVars = {}

local function BuildSVarPanel(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()
	Panel:Dock(FILL)
	SettingsClass.SetupBackColor(Panel)
	
	local Lab = vgui.Create('DLabel', Panel)
	Panel:AddItem(Lab)
	Lab:SetText('DPP is created by DBot')
	Lab:SetTextColor(SettingsClass.TextColor)
	
	for a, b in pairs(SortedConVars) do
		local v = DPP.Settings[b]
		local k = b
		PlacedCVars[k] = true
		
		local val = tobool(DPP.GetConVar(k))
		
		local checkbox = Panel:CheckBox(v.desc)
		checkbox:SetChecked(val)
		checkbox.Button.LastVal = val
		checkbox.Button.val = k
		checkbox.Button.DoClick = FUNCTIONS.CheckBoxDoClick
		checkbox.Button.Think = FUNCTIONS.CheckBoxThink
		checkbox:SetTooltip(v.desc)
		SettingsClass.AddScramblingChars(checkbox.Label, checkbox, checkbox.Button)
		SettingsClass.MakeCheckboxBetter(checkbox)
	end
	
	local Slider = Panel:NumSlider('Clear timer in seconds', nil, 1, 600, 1)
	SettingsClass.ApplySliderStyle(Slider)
	Slider:SetValue(DPP.GetConVar('clear_timer'))
	Slider.OnValueChanged = function()
		local v = tostring(math.floor(tonumber(Slider:GetValue())))
		timer.Create('DPP.ChangeTimer', 1, 1, function()
			RunConsoleCommand('dpp_setvar', 'clear_timer', v)
		end)
	end
	
	local Slider = Panel:NumSlider('Grab timer in seconds', nil, 1, 600, 1)
	SettingsClass.ApplySliderStyle(Slider)
	Slider:SetValue(DPP.GetConVar('grabs_timer'))
	Slider.OnValueChanged = function()
		local v = tostring(math.floor(tonumber(Slider:GetValue())))
		timer.Create('DPP.ChangeGrabTimer', 1, 1, function()
			RunConsoleCommand('dpp_setvar', 'grabs_timer', v)
		end)
	end
end

local function BuildCVarPanel(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()
	SettingsClass.SetupBackColor(Panel)
	
	for k, v in pairs(DPP.CSettings) do
		--local v = DPP.Settings[b]
		--local k = b
		PlacedCVars[k] = true
		
		local val = DPP.PlayerConVar(LocalPlayer(), k)
		
		local checkbox = Panel:CheckBox(v.desc)
		checkbox:SetChecked(val)
		checkbox.Button.LastVal = val
		checkbox.Button.val = k
		checkbox.Button.DoClick = FUNCTIONS.CCheckBoxDoClick
		checkbox.Button.Think = FUNCTIONS.CCheckBoxThink
		checkbox:SetTooltip(v.desc)
		SettingsClass.AddScramblingChars(checkbox.Label, checkbox, checkbox.Button)
		SettingsClass.MakeCheckboxBetter(checkbox)
	end
	
	local FontBox = Panel:ComboBox('Font')
	for k, v in pairs(DPP.Fonts) do
		FontBox:AddChoice(v.name)
	end
	FontBox:SetValue(DPP.GetFont(true))
	FontBox:SetHeight(20)
	FontBox.OnSelect = function(self, i, num)
		RunConsoleCommand('dpp_font', i)
	end
end

local function BuildMiscVarsPanel(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()
	SettingsClass.SetupBackColor(Panel)
	
	for a, b in pairs(MiscConVars) do
		local v = DPP.Settings[b]
		local k = b
		PlacedCVars[k] = true
		
		local val = tobool(DPP.GetConVar(k))
		
		local checkbox = Panel:CheckBox(v.desc)
		checkbox:SetChecked(val)
		checkbox.Button.LastVal = val
		checkbox.Button.val = k
		checkbox.Button.DoClick = FUNCTIONS.CheckBoxDoClick
		checkbox.Button.Think = FUNCTIONS.CheckBoxThink
		checkbox:SetTooltip(v.desc)
		SettingsClass.AddScramblingChars(checkbox.Label, checkbox, checkbox.Button)
		SettingsClass.MakeCheckboxBetter(checkbox)
	end
end

local function BuildAntispamPanel(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()
	SettingsClass.SetupBackColor(Panel)
	
	local checkbox = Panel:CheckBox('Check sizes of entites')
	checkbox.Button.val = 'check_sizes'
	checkbox.Button.DoClick = FUNCTIONS.CheckBoxDoClick
	checkbox.Button.Think = FUNCTIONS.CheckBoxThink
	SettingsClass.AddScramblingChars(checkbox.Label, checkbox, checkbox.Button)
	SettingsClass.MakeCheckboxBetter(checkbox)
	
	local checkbox = Panel:CheckBox('Prevent prop from stucking in each other')
	checkbox.Button.val = 'check_stuck'
	checkbox.Button.DoClick = FUNCTIONS.CheckBoxDoClick
	checkbox.Button.Think = FUNCTIONS.CheckBoxThink
	SettingsClass.AddScramblingChars(checkbox.Label, checkbox, checkbox.Button)
	SettingsClass.MakeCheckboxBetter(checkbox)
	
	local Slider = Panel:NumSlider('Max size of props \nbefore they ghosted', nil, 200, 4000, 1)
	SettingsClass.ApplySliderStyle(Slider)
	Slider:SetValue(DPP.GetConVar('max_size'))
	Slider.OnValueChanged = function()
		local v = tostring(math.floor(tonumber(Slider:GetValue())))
		timer.Create('DPP.ChangeMaxSizeTimer', 1, 1, function()
			RunConsoleCommand('dpp_setvar', 'max_size', v)
		end)
	end
	
	local checkbox = Panel:CheckBox('Enable Antispam')
	checkbox.Button.val = 'antispam'
	checkbox.Button.DoClick = FUNCTIONS.CheckBoxDoClick
	checkbox.Button.Think = FUNCTIONS.CheckBoxThink
	SettingsClass.AddScramblingChars(checkbox.Label, checkbox, checkbox.Button)
	SettingsClass.MakeCheckboxBetter(checkbox)
	
	local Slider = Panel:NumSlider('Antispam delay Higher \nmeans more strict antispam', nil, 0, 4, 1)
	SettingsClass.ApplySliderStyle(Slider)
	Slider:SetValue(DPP.GetConVar('antispam_delay'))
	Slider:SetTooltip('Antispam delay Higher \nmeans more strict antispam')
	Slider.OnValueChanged = function()
		local v = tonumber(Slider:GetValue())
		timer.Create('DPP.AntispamDelay', 1, 1, function()
			RunConsoleCommand('dpp_setvar', 'antispam_delay', v)
		end)
	end
	
	local Slider = Panel:NumSlider('Antispam remove multiplier Lower \nmeans removing entites earlier', nil, 4, 20, 1)
	SettingsClass.ApplySliderStyle(Slider)
	Slider:SetValue(DPP.GetConVar('antispam_remove'))
	Slider:SetTooltip('Antispam remove multiplier Lower \nmeans removing entites earlier')
	Slider.OnValueChanged = function()
		local v = math.floor(tonumber(Slider:GetValue()))
		timer.Create('DPP.AntispamRemove', 1, 1, function()
			RunConsoleCommand('dpp_setvar', 'antispam_remove', v)
		end)
	end
	
	local Slider = Panel:NumSlider('Antispam ghost multiplier Lower \nmeans ghosting entites earlier', nil, 1, 10, 1)
	SettingsClass.ApplySliderStyle(Slider)
	Slider:SetTooltip('Antispam ghost multiplier Lower \nmeans ghosting entites earlier')
	Slider:SetValue(DPP.GetConVar('antispam_ghost'))
	Slider.OnValueChanged = function()
		local v = math.floor(tonumber(Slider:GetValue()))
		timer.Create('DPP.AntispamGhost', 1, 1, function()
			RunConsoleCommand('dpp_setvar', 'antispam_ghost', v)
		end)
	end
	
	local Slider = Panel:NumSlider('Antispam max cooldown multiplier Lower \nmeans removing entites earlier', nil, 1, 10, 1)
	SettingsClass.ApplySliderStyle(Slider)
	Slider:SetValue(DPP.GetConVar('antispam_max'))
	Slider:SetTooltip('Antispam max cooldown multiplier Lower \nmeans removing entites earlier')
	Slider.OnValueChanged = function()
		local v = math.floor(tonumber(Slider:GetValue()))
		timer.Create('DPP.AntispamGhost', 1, 1, function()
			RunConsoleCommand('dpp_setvar', 'antispam_max', v)
		end)
	end
	
	local Slider = Panel:NumSlider('Antispam cooldown divider Lower \nmeans faster cooldown', nil, 0, 4, 1)
	SettingsClass.ApplySliderStyle(Slider)
	Slider:SetValue(DPP.GetConVar('antispam_cooldown_divider'))
	Slider:SetTooltip('Antispam cooldown divider Lower \nmeans faster cooldown')
	Slider.OnValueChanged = function()
		local v = tonumber(Slider:GetValue())
		timer.Create('DPP.AntispamCooldown', 1, 1, function()
			RunConsoleCommand('dpp_setvar', 'antispam_cooldown_divider', v)
		end)
	end
end

local function BuildPlayerList(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()
	SettingsClass.SetupBackColor(Panel)
	
	DPP.SettingsClass.PlayerPanel = Panel
	
	SettingsClass.ApplyButtonStyle(Panel:Button('Delete all player\'s entities', 'dpp_clearmap'))
	SettingsClass.ApplyButtonStyle(Panel:Button('Freeze all player\'s entities', 'dpp_freezeall'))
	SettingsClass.ApplyButtonStyle(Panel:Button('Delete disconnected player entities', 'dpp_cleardisconnected'))
	
	for k, v in pairs(player.GetAll()) do
		local lab = Label(v:Nick())
		Panel:AddItem(lab)
		lab:SetTextColor(SettingsClass.TextColor)
		SettingsClass.ApplyButtonStyle(Panel:Button('Delete ' .. v:Nick() .. ' entites', 'dpp_clearplayer', tostring(v:UserID())))
		SettingsClass.ApplyButtonStyle(Panel:Button('Freeze ' .. v:Nick() .. ' entites', 'dpp_freezeplayer', tostring(v:UserID())))
		SettingsClass.ApplyButtonStyle(Panel:Button('UnFreeze ' .. v:Nick() .. ' entites', 'dpp_unfreezeplayer', tostring(v:UserID())))
	end
end

local function BuildModelsList(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()
	SettingsClass.SetupBackColor(Panel)
	DPP.SettingsClass.ModelPanel = Panel
	
	local list = vgui.Create('DListView', Panel)
	Panel:AddItem(list)
	
	list:SetHeight(600)
	list:AddColumn('Model')

	local L = DPP.BlockedModels
	
	for k, v in pairs(L) do
		list:AddLine(k)
	end
	
	list.OnRowRightClick = function(self, line)
		local val = self:GetLine(line):GetValue(1)
		local menu = vgui.Create('DMenu')
		menu:AddOption('Copy model to clipboard', function()
			SetClipboardText(val)
		end)
		
		menu:AddOption('Remove from blacklist', function()
			RunConsoleCommand('dpp_removeblockedmodel', val)
		end)
		menu:Open()
	end
	
	local entry = vgui.Create('DTextEntry', Panel)
	Panel:AddItem(entry)
	local Apply = Panel:Button('Add model')
	Apply.DoClick = function()
		RunConsoleCommand('dpp_addblockedmodel', entry:GetText())
	end
	SettingsClass.ApplyButtonStyle(Apply)
	
	local Apply = Panel:Button('Remove model')
	Apply.DoClick = function()
		RunConsoleCommand('dpp_removeblockedmodel', entry:GetText())
	end
	SettingsClass.ApplyButtonStyle(Apply)
	
	local Apply = Panel:Button('Add model of entity that you are looking at')
	Apply.DoClick = function()
		local ent = LocalPlayer():GetEyeTrace().Entity
		if not IsValid(ent) then return end
		RunConsoleCommand('dpp_addblockedmodel', ent:GetModel())
	end
	SettingsClass.ApplyButtonStyle(Apply)
	
	local Apply = Panel:Button('Remove model of entity that you are looking at')
	Apply.DoClick = function()
		local ent = LocalPlayer():GetEyeTrace().Entity
		if not IsValid(ent) then return end
		RunConsoleCommand('dpp_removeblockedmodel', ent:GetModel())
	end
	SettingsClass.ApplyButtonStyle(Apply)
end

local function OpenLimitEditPanel(class)
	local t = DPP.EntsLimits[class] or {}
	
	local height = 50
	
	local frame = vgui.Create('DFrame')
	frame:SetTitle('Modifying ' .. class)
	SettingsClass.ApplyFrameStyle(frame)
	
	local groups = DPP.GetGroups()
	local Panels = {}
	
	for k, v in pairs(groups) do
		height = height + 50
		local l = frame:Add('DLabel')
		local p = frame:Add('DTextEntry')
		table.insert(Panels, p)
		p.Group = v
		l:Dock(TOP)
		l:SetText(v)
		l:SetTextColor(SettingsClass.TextColor)
		p:Dock(TOP)
		p:SetText(t[v] or '-1')
		p.OriginalValue = (t[v] or '-1')
	end
	
	local apply = frame:Add('DButton')
	apply:Dock(BOTTOM)
	apply:SetText('Apply')
	SettingsClass.ApplyButtonStyle(apply)
	
	function apply.DoClick()
		t = {}
		
		for k, v in pairs(Panels) do
			local n = tonumber(v:GetText())
			if not n then continue end
			if tonumber(v.OriginalValue) == n then continue end
			
			if n > 0 then
				RunConsoleCommand('dpp_addentitylimit', class, v.Group, n)
			else
				RunConsoleCommand('dpp_removeentitylimit', class, v.Group)
			end
		end
		
		frame:Close()
	end
	
	local discard = frame:Add('DButton')
	discard:Dock(BOTTOM)
	discard:SetText('Discard')
	SettingsClass.ApplyButtonStyle(discard)
	
	function discard.DoClick()
		frame:Close()
	end
	
	frame:SetHeight(height)
	frame:SetWidth(300)
	frame:Center()
	frame:MakePopup()
end

local function BuildLimitsList(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()
	SettingsClass.SetupBackColor(Panel)
	DPP.SettingsClass.LimitsPanel = Panel
	
	local Lab = vgui.Create('DLabel', Panel)
	Panel:AddItem(Lab)
	Lab:SetTextColor(SettingsClass.TextColor)
	Lab:SetText('NOTE: It just prevent player from spawning entities with given class\nif player spawned gived amount of entities with this class.\nThat means it DOES NOT allow group to spawn unlimited\namout of entities with that type.\nFor that use SBox limits list instead.')
	Lab:SizeToContents()
	
	local list = vgui.Create('DListView', Panel)
	Panel:AddItem(list)
	
	list:SetHeight(600)
	list:AddColumn('Class')
	list:AddColumn('Group')
	list:AddColumn('Limit')

	local L = DPP.EntsLimits
	
	for k, v in pairs(L) do
		for group, limit in pairs(v) do
			list:AddLine(k, group, limit)
		end
	end
	
	list.OnRowRightClick = function(self, line)
		local val = self:GetLine(line):GetValue(1)
		local group = self:GetLine(line):GetValue(2)
		local limit = self:GetLine(line):GetValue(3)
		
		local menu = vgui.Create('DMenu')
		menu:AddOption('Copy class to clipboard', function()
			SetClipboardText(val)
		end)
		
		menu:AddOption('Edit limit...', function()
			OpenLimitEditPanel(val)
		end)
		
		menu:AddOption('Remove this limit', function()
			RunConsoleCommand('dpp_removeentitylimit', val, group)
		end)
		
		menu:Open()
	end
	
	local entry = vgui.Create('DTextEntry', Panel)
	Panel:AddItem(entry)
	local Apply = Panel:Button('Add/Edit limit')
	Apply.DoClick = function()
		OpenLimitEditPanel(entry:GetText())
	end
	SettingsClass.ApplyButtonStyle(Apply)
	
	local Apply = Panel:Button('Remove limit')
	Apply.DoClick = function()
		RunConsoleCommand('dpp_removeentitylimit', entry:GetText())
	end
	SettingsClass.ApplyButtonStyle(Apply)
	
	local Apply = Panel:Button('Add limit of entity that you are looking at')
	Apply.DoClick = function()
		local ent = LocalPlayer():GetEyeTrace().Entity
		if not IsValid(ent) then return end
		OpenLimitEditPanel(ent:GetClass())
	end
	SettingsClass.ApplyButtonStyle(Apply)
	
	local Apply = Panel:Button('Remove limit of entity that you are looking at')
	Apply.DoClick = function()
		local ent = LocalPlayer():GetEyeTrace().Entity
		if not IsValid(ent) then return end
		RunConsoleCommand('dpp_removeentitylimit', ent:GetClass())
	end
	SettingsClass.ApplyButtonStyle(Apply)
	
	local idx = 'ent_limits_enable'
	PlacedCVars[idx] = true
	local val = tobool(DPP.GetConVar(idx))
	local checkbox = Panel:CheckBox(DPP.Settings[idx].desc)
	checkbox:SetChecked(val)
	checkbox.Button.LastVal = val
	checkbox.Button.val = idx
	checkbox.Button.DoClick = FUNCTIONS.CheckBoxDoClick
	checkbox.Button.Think = FUNCTIONS.CheckBoxThink
	checkbox:SetTooltip(DPP.Settings[idx].desc)
	SettingsClass.AddScramblingChars(checkbox.Label, checkbox, checkbox.Button)
	SettingsClass.MakeCheckboxBetter(checkbox)
end

local function RemoveAllSLimits(class)
	for k, v in pairs(DPP.GetGroups()) do
		RunConsoleCommand('dpp_removesboxlimit', class, v)
	end
end

local function OpenSLimitEditPanel(class)
	local t = DPP.SBoxLimits[class] or {}
	
	local height = 90
	
	local frame = vgui.Create('DFrame')
	frame:SetTitle('Modifying ' .. class)
	SettingsClass.ApplyFrameStyle(frame)
	
	local lab = frame:Add('DLabel')
	lab:SetTextColor(SettingsClass.TextColor)
	lab:SetText('Unlimited: -1\n0 - removes limit from db\nAny values higher than 0 is a limit')
	lab:Dock(TOP)
	lab:SizeToContents()
	
	local groups = DPP.GetGroups()
	local Panels = {}
	
	for k, v in pairs(groups) do
		height = height + 50
		local l = frame:Add('DLabel')
		local p = frame:Add('DTextEntry')
		table.insert(Panels, p)
		p.Group = v
		l:Dock(TOP)
		l:SetText(v)
		l:SetTextColor(SettingsClass.TextColor)
		p:Dock(TOP)
		p:SetText(t[v] or '0')
		p.OriginalValue = (t[v] or '0')
	end
	
	local apply = frame:Add('DButton')
	apply:Dock(BOTTOM)
	apply:SetText('Apply')
	SettingsClass.ApplyButtonStyle(apply)
	
	function apply.DoClick()
		t = {}
		
		for k, v in pairs(Panels) do
			local n = tonumber(v:GetText())
			if not n then continue end
			if tonumber(v.OriginalValue) == n then continue end
			
			if n ~= 0 then
				RunConsoleCommand('dpp_addsboxlimit', class, v.Group, n)
			else
				RunConsoleCommand('dpp_removesboxlimit', class, v.Group)
			end
		end
		
		frame:Close()
	end
	
	local discard = frame:Add('DButton')
	discard:Dock(BOTTOM)
	discard:SetText('Discard')
	SettingsClass.ApplyButtonStyle(discard)
	
	function discard.DoClick()
		frame:Close()
	end
	
	frame:SetHeight(height)
	frame:SetWidth(300)
	frame:Center()
	frame:MakePopup()
end

local function BuildSLimitsList(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()
	SettingsClass.SetupBackColor(Panel)
	DPP.SettingsClass.SLimitsPanel = Panel
	
	local Lab = vgui.Create('DLabel', Panel)
	Panel:AddItem(Lab)
	Lab:SetTextColor(SettingsClass.TextColor)
	Lab:SetText('WHAT THIS DOES:\nIt is convar sbox_max<...> overrides for user groups.\nTo add values, you must know what convar you are changing.\nFor example, if you want modify\nprop limits, id would be "props" (sbox_maxprops).\nONLY there -1 means no limit, and 0 means limits\nis not modified')
	Lab:SizeToContents()
	
	local list = vgui.Create('DListView', Panel)
	Panel:AddItem(list)
	
	list:SetHeight(600)
	list:AddColumn('sbox_max...')
	list:AddColumn('Group')
	list:AddColumn('Limit')

	local L = DPP.SBoxLimits
	
	for k, v in pairs(L) do
		for group, limit in pairs(v) do
			list:AddLine(k, group, limit)
		end
	end
	
	list.OnRowRightClick = function(self, line)
		local val = self:GetLine(line):GetValue(1)
		local group = self:GetLine(line):GetValue(2)
		local limit = self:GetLine(line):GetValue(3)
		
		local menu = vgui.Create('DMenu')
		menu:AddOption('Copy cvar name to clipboard', function()
			SetClipboardText('sbox_max' .. val)
		end)
		
		menu:AddOption('Edit limit...', function()
			OpenSLimitEditPanel(val)
		end)
		
		menu:AddOption('Remove this limit', function()
			RunConsoleCommand('dpp_removesboxlimit', val, group)
		end)
		
		menu:AddOption('Remove this limit for all groups', function()
			RemoveAllSLimits(val)
		end)
		
		menu:Open()
	end
	
	local entry = vgui.Create('DTextEntry', Panel)
	Panel:AddItem(entry)
	local Apply = Panel:Button('Add/Edit/Remove limit')
	Apply.DoClick = function()
		OpenSLimitEditPanel(entry:GetText())
	end
	SettingsClass.ApplyButtonStyle(Apply)
	
	local idx = 'sbox_limits_enable'
	PlacedCVars[idx] = true
	local val = tobool(DPP.GetConVar(idx))
	local checkbox = Panel:CheckBox(DPP.Settings[idx].desc)
	checkbox:SetChecked(val)
	checkbox.Button.LastVal = val
	checkbox.Button.val = idx
	checkbox.Button.DoClick = FUNCTIONS.CheckBoxDoClick
	checkbox.Button.Think = FUNCTIONS.CheckBoxThink
	checkbox:SetTooltip(DPP.Settings[idx].desc)
	SettingsClass.AddScramblingChars(checkbox.Label, checkbox, checkbox.Button)
	SettingsClass.MakeCheckboxBetter(checkbox)
end

local PanelsFunctions = {}
local PanelsFunctions2 = {}
DPP.SettingsClass.ValidPanels = DPP.SettingsClass.ValidPanels or {}
DPP.SettingsClass.ValidPanels2 = DPP.SettingsClass.ValidPanels2 or {}
local ValidPanels = DPP.SettingsClass.ValidPanels
local ValidPanels2 = DPP.SettingsClass.ValidPanels2

local function REMOVE_ALL(class)
	for k, v in pairs(DPP.BlockTypes) do
		RunConsoleCommand('dpp_removeblockedentity' .. k, class)
	end
end

local function ADD_ALL(class)
	for k, v in pairs(DPP.BlockTypes) do
		RunConsoleCommand('dpp_addblockedentity' .. k, class)
	end
end

local function SORTER(a, b)
	return a < b
end

for k, v in pairs(DPP.BlockTypes) do
	PanelsFunctions[k] = function(Panel)
		if not IsValid(Panel) then return end
		Panel:Clear()
		SettingsClass.SetupBackColor(Panel)
		ValidPanels[k] = Panel
		
		local list = vgui.Create('DListView', Panel)
		Panel:AddItem(list)
		
		list:SetHeight(600)
		list:AddColumn('Entity')
		
		local L = DPP.BlockedEntites[k]
		local New = {}
		for k, v in pairs(L) do
			table.insert(New, k)
		end
		
		table.sort(New, SORTER)
		
		for k, v in pairs(New) do
			list:AddLine(v)
		end
		
		list.OnRowRightClick = function(self, line)
			local val = self:GetLine(line):GetValue(1)
			local menu = vgui.Create('DMenu')
			menu:AddOption('Copy class to clipboard', function()
				SetClipboardText(val)
			end)
			
			menu:AddOption('Remove from blacklist', function()
				RunConsoleCommand('dpp_removeblockedentity' .. k, val)
			end)
			
			menu:AddOption('Add that entity to ALL blacklists', function()
				ADD_ALL(val)
			end)
			
			menu:AddOption('Remove that entity to ALL blacklists', function()
				REMOVE_ALL(val)
			end)
			menu:Open()
		end
		
		local entry = vgui.Create('DTextEntry', Panel)
		Panel:AddItem(entry)
		local Apply = Panel:Button('Add entity')
		Apply.DoClick = function()
			RunConsoleCommand('dpp_addblockedentity' .. k, entry:GetText())
		end
		SettingsClass.ApplyButtonStyle(Apply)
		
		local Apply = Panel:Button('Remove entity')
		Apply.DoClick = function()
			RunConsoleCommand('dpp_removeblockedentity' .. k, entry:GetText())
		end
		SettingsClass.ApplyButtonStyle(Apply)
		
		local Apply = Panel:Button('Add that entity to ALL blacklists')
		Apply.DoClick = function()
			ADD_ALL(entry:GetText())
		end
		SettingsClass.ApplyButtonStyle(Apply)
		
		local Apply = Panel:Button('Remove that entity from ALL blacklists')
		Apply.DoClick = function()
			REMOVE_ALL(entry:GetText())
		end
		SettingsClass.ApplyButtonStyle(Apply)
		
		local Apply = Panel:Button('Add entity that you are looking at to blacklist')
		Apply.DoClick = function()
			local ent = LocalPlayer():GetEyeTrace().Entity
			if not IsValid(ent) then return end
			RunConsoleCommand('dpp_addblockedentity' .. k, ent:GetClass())
		end
		SettingsClass.ApplyButtonStyle(Apply)
		
		local Apply = Panel:Button('Remove entity that you are looking at from blacklist')
		Apply.DoClick = function()
			local ent = LocalPlayer():GetEyeTrace().Entity
			if not IsValid(ent) then return end
			RunConsoleCommand('dpp_removeblockedentity' .. k, ent:GetClass())
		end
		SettingsClass.ApplyButtonStyle(Apply)
		
		local Apply = Panel:Button('Add entity that you are looking at to ALL blacklists')
		Apply.DoClick = function()
			local ent = LocalPlayer():GetEyeTrace().Entity
			if not IsValid(ent) then return end
			ADD_ALL(ent:GetClass())
		end
		SettingsClass.ApplyButtonStyle(Apply)
		
		local Apply = Panel:Button('Remove entity that you are looking at from ALL blacklists')
		Apply.DoClick = function()
			local ent = LocalPlayer():GetEyeTrace().Entity
			if not IsValid(ent) then return end
			REMOVE_ALL(ent:GetClass())
		end
		SettingsClass.ApplyButtonStyle(Apply)
		
		
		local idx = 'blacklist_' .. k
		PlacedCVars[idx] = true
		local val = tobool(DPP.GetConVar(idx))
		local checkbox = Panel:CheckBox(DPP.Settings[idx].desc)
		checkbox:SetChecked(val)
		checkbox.Button.LastVal = val
		checkbox.Button.val = idx
		checkbox.Button.DoClick = FUNCTIONS.CheckBoxDoClick
		checkbox.Button.Think = FUNCTIONS.CheckBoxThink
		checkbox:SetTooltip(DPP.Settings[idx].desc)
		SettingsClass.AddScramblingChars(checkbox.Label, checkbox, checkbox.Button)
		SettingsClass.MakeCheckboxBetter(checkbox)
		
		local idx = 'blacklist_' .. k .. '_white'
		PlacedCVars[idx] = true
		local val = tobool(DPP.GetConVar(idx))
		local checkbox = Panel:CheckBox(DPP.Settings[idx].desc)
		checkbox:SetChecked(val)
		checkbox.Button.LastVal = val
		checkbox.Button.val = idx
		checkbox.Button.DoClick = FUNCTIONS.CheckBoxDoClick
		checkbox.Button.Think = FUNCTIONS.CheckBoxThink
		checkbox:SetTooltip(DPP.Settings[idx].desc)
		SettingsClass.AddScramblingChars(checkbox.Label, checkbox, checkbox.Button)
		SettingsClass.MakeCheckboxBetter(checkbox)
		
		
		local idx = 'blacklist_' .. k .. '_player_can'
		PlacedCVars[idx] = true
		local val = tobool(DPP.GetConVar(idx))
		local checkbox = Panel:CheckBox(DPP.Settings[idx].desc)
		checkbox:SetChecked(val)
		checkbox.Button.LastVal = val
		checkbox.Button.val = idx
		checkbox.Button.DoClick = FUNCTIONS.CheckBoxDoClick
		checkbox.Button.Think = FUNCTIONS.CheckBoxThink
		checkbox:SetTooltip(DPP.Settings[idx].desc)
		SettingsClass.AddScramblingChars(checkbox.Label, checkbox, checkbox.Button)
		SettingsClass.MakeCheckboxBetter(checkbox)
		
		local idx = 'blacklist_' .. k .. '_admin_can'
		PlacedCVars[idx] = true
		local val = tobool(DPP.GetConVar(idx))
		local checkbox = Panel:CheckBox(DPP.Settings[idx].desc)
		checkbox:SetChecked(val)
		checkbox.Button.LastVal = val
		checkbox.Button.val = idx
		checkbox.Button.DoClick = FUNCTIONS.CheckBoxDoClick
		checkbox.Button.Think = FUNCTIONS.CheckBoxThink
		checkbox:SetTooltip(DPP.Settings[idx].desc)
		SettingsClass.AddScramblingChars(checkbox.Label, checkbox, checkbox.Button)
		SettingsClass.MakeCheckboxBetter(checkbox)
	end
end

local function SORTER(a, b)
	local a = a.class
	local b = b.class
	return a < b
end

for k, v in pairs(DPP.RestrictTypes) do
	local function OpenModifyPanel(class, isNew)
		local t = DPP.RestrictedTypes[k][class] or {
			groups = {},
			iswhite = false
		}
		
		local height = 50
		
		local frame = vgui.Create('DFrame')
		frame:SetTitle('Modifying ' .. class)
		SettingsClass.ApplyFrameStyle(frame)
		
		local groups = DPP.GetGroups()
		local Panels = {}
		
		for k, v in pairs(groups) do
			height = height + 20
			local p = frame:Add('DCheckBoxLabel')
			table.insert(Panels, p)
			p:Dock(TOP)
			p:SetText(v)
			p:SetChecked(table.HasValue(t.groups, v))
			p.Group = v
		end
		
		height = height + 30
		local iswhite = frame:Add('DCheckBoxLabel')
		iswhite:Dock(TOP)
		iswhite:SetText('Is White List')
		iswhite:SetChecked(t.iswhite)
		
		local apply = frame:Add('DButton')
		apply:Dock(BOTTOM)
		apply:SetText('Apply')
		
		function apply.DoClick()
			t.groups = {}
			for k, v in pairs(Panels) do
				if v:GetChecked() then
					table.insert(t.groups, v.Group)
				end
			end
			t.iswhite = iswhite:GetChecked()
			
			RunConsoleCommand('dpp_restrict' .. k, class, table.concat(t.groups, ','), t.iswhite and '1' or '0')
			frame:Close()
		end
		
		local discard = frame:Add('DButton')
		discard:Dock(BOTTOM)
		discard:SetText('Discard')
		SettingsClass.ApplyButtonStyle(discard)
		
		function discard.DoClick()
			frame:Close()
		end
		
		frame:SetHeight(height)
		frame:SetWidth(200)
		frame:Center()
		frame:MakePopup()
	end
	
	PanelsFunctions2[k] = function(Panel)
		if not IsValid(Panel) then return end
		Panel:Clear()
		SettingsClass.SetupBackColor(Panel)
		
		ValidPanels2[k] = Panel
		
		local list = vgui.Create('DListView', Panel)
		Panel:AddItem(list)
		
		list:SetHeight(600)
		list:AddColumn('Class')
		list:AddColumn('Groups')
		list:AddColumn('Is Whitelist')
		
		local L = DPP.RestrictedTypes[k]
		local New = {}
		for k, v in pairs(L) do
			table.insert(New, {class = k, groups = v.groups, iswhite = v.iswhite})
		end
		
		table.sort(New, SORTER)
		
		for k, v in pairs(New) do
			list:AddLine(v.class, table.concat(v.groups, ','), v.iswhite)
		end
		
		list.OnRowRightClick = function(self, line)
			local class = self:GetLine(line):GetValue(1)
			local groups = self:GetLine(line):GetValue(2)
			local iswhite = self:GetLine(line):GetValue(3)
			
			local menu = vgui.Create('DMenu')
			menu:AddOption('Copy class to clipboard', function()
				SetClipboardText(class)
			end)
			
			menu:AddOption('Remove from list', function()
				RunConsoleCommand('dpp_unrestrict' .. k, class)
			end)
			
			menu:AddOption('Modify...', function()
				OpenModifyPanel(class)
			end)
			
			menu:Open()
		end
		
		local entry = vgui.Create('DTextEntry', Panel)
		Panel:AddItem(entry)
		
		local Apply = Panel:Button('Add...')
		Apply.DoClick = function()
			OpenModifyPanel(entry:GetText(), true)
		end
		SettingsClass.ApplyButtonStyle(Apply)
		
		local idx = 'restrict_' .. k
		PlacedCVars[idx] = true
		local val = tobool(DPP.GetConVar(idx))
		local checkbox = Panel:CheckBox(DPP.Settings[idx].desc)
		checkbox:SetChecked(val)
		checkbox.Button.LastVal = val
		checkbox.Button.val = idx
		checkbox.Button.DoClick = FUNCTIONS.CheckBoxDoClick
		checkbox.Button.Think = FUNCTIONS.CheckBoxThink
		checkbox:SetTooltip(DPP.Settings[idx].desc)
		SettingsClass.AddScramblingChars(checkbox.Label, checkbox, checkbox.Button)
		SettingsClass.MakeCheckboxBetter(checkbox)
		
		local idx = 'restrict_' .. k .. '_white'
		PlacedCVars[idx] = true
		local val = tobool(DPP.GetConVar(idx))
		local checkbox = Panel:CheckBox(DPP.Settings[idx].desc)
		checkbox:SetChecked(val)
		checkbox.Button.LastVal = val
		checkbox.Button.val = idx
		checkbox.Button.DoClick = FUNCTIONS.CheckBoxDoClick
		checkbox.Button.Think = FUNCTIONS.CheckBoxThink
		checkbox:SetTooltip(DPP.Settings[idx].desc)
		SettingsClass.AddScramblingChars(checkbox.Label, checkbox, checkbox.Button)
		SettingsClass.MakeCheckboxBetter(checkbox)
		
		local idx = 'restrict_' .. k .. '_white_bypass'
		PlacedCVars[idx] = true
		local val = tobool(DPP.GetConVar(idx))
		local checkbox = Panel:CheckBox(DPP.Settings[idx].desc)
		checkbox:SetChecked(val)
		checkbox.Button.LastVal = val
		checkbox.Button.val = idx
		checkbox.Button.DoClick = FUNCTIONS.CheckBoxDoClick
		checkbox.Button.Think = FUNCTIONS.CheckBoxThink
		checkbox:SetTooltip(DPP.Settings[idx].desc)
		SettingsClass.AddScramblingChars(checkbox.Label, checkbox, checkbox.Button)
		SettingsClass.MakeCheckboxBetter(checkbox)
	end
end

local function BuildFriendsPanel(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()
	SettingsClass.SetupBackColor(Panel)
	
	DPP.SettingsClass.FriendPanel = Panel
	
	local list = vgui.Create('DListView', Panel)
	Panel:AddItem(list)
	
	list:SetHeight(300)
	list:AddColumn('Nick')
	list:AddColumn('SteamID')
	
	for k, v in pairs(DPP.GetLocalFriends()) do
		list:AddLine(v.nick, k)
	end
	
	list.OnRowRightClick = function(self, line)
		local name = self:GetLine(line):GetValue(1)
		local steamid = self:GetLine(line):GetValue(2)
		local menu = vgui.Create('DMenu')
		
		menu:AddOption('Copy Name to clipboard', function()
			SetClipboardText(name)
		end)
		
		menu:AddOption('Copy SteamID to clipboard', function()
			SetClipboardText(steamid)
		end)
		
		menu:AddOption('Remove from friends', function()
			DPP.RemoveFriendBySteamID(steamid)
		end)
		
		menu:Open()
	end
	
	local plys = player.GetAll()
	local active = DPP.GetActiveFriends()
	
	for k, v in pairs(plys) do
		if v == LocalPlayer() then continue end
		if active[v] then continue end
		local b = Panel:Button('Add ' .. v:Nick() .. ' to friendlist')
		SettingsClass.ApplyButtonStyle(b)
		b.DoClick = function()
			DPP.AddFriend(v)
		end
	end
	
	local entry = vgui.Create('DTextEntry', Panel)
	Panel:AddItem(entry)
	local Apply = Panel:Button('Add by SteamID')
	Apply.DoClick = function()
		DPP.AddFriendBySteamID(entry:GetText())
	end
	SettingsClass.ApplyButtonStyle(Apply)
end

local function PopulateToolMenu()
	spawnmenu.AddToolMenuOption('Utilities', 'DPP', 'DPP.SVars', 'Server ConVars', '', '', BuildSVarPanel)
	spawnmenu.AddToolMenuOption('Utilities', 'DPP', 'DPP.Players', 'Player Controls', '', '', BuildPlayerList)
	spawnmenu.AddToolMenuOption('Utilities', 'DPP', 'DPP.Misc', 'Other Server ConVars', '', '', BuildMiscVarsPanel)
	spawnmenu.AddToolMenuOption('Utilities', 'DPP', 'DPP.CVars', 'Client ConVars', '', '', BuildCVarPanel)
	spawnmenu.AddToolMenuOption('Utilities', 'DPP', 'DPP.APanel', 'Antispam Settings', '', '', BuildAntispamPanel)
	spawnmenu.AddToolMenuOption('Utilities', 'DPP', 'DPP.Limits', 'Entity Limits', '', '', BuildLimitsList)
	spawnmenu.AddToolMenuOption('Utilities', 'DPP', 'DPP.SLimits', 'SBox Limits', '', '', BuildSLimitsList)
	spawnmenu.AddToolMenuOption('Utilities', 'DPP Blacklists', 'DPP.ModelList', 'Model blacklist', '', '', BuildModelsList)
	spawnmenu.AddToolMenuOption('Utilities', 'DPP', 'DPP.Friends', 'Friends', '', '', BuildFriendsPanel)
	
	for k, v in pairs(DPP.BlockTypes) do
		spawnmenu.AddToolMenuOption('Utilities', 'DPP Blacklists', 'DPP.' .. k, v .. ' blacklist', '', '', PanelsFunctions[k])
	end

	for k, v in pairs(DPP.RestrictTypes) do
		spawnmenu.AddToolMenuOption('Utilities', 'DPP Restricts', 'DPP.restrict' .. k, v .. ' restrict list', '', '', PanelsFunctions2[k])
	end
end

hook.Add('DPP.BlockedEntitesChanged', 'DPP.Menu', function(s1, s2, b)
	if PanelsFunctions[s1] then
		PanelsFunctions[s1](DPP.SettingsClass.ValidPanels[s1])
	end
end)

hook.Add('DPP.EntsLimitsUpdated', 'DPP.Menu', function()
	BuildLimitsList(DPP.SettingsClass.LimitsPanel)
end)

hook.Add('DPP.EntsLimitsReloaded', 'DPP.Menu', function()
	BuildLimitsList(DPP.SettingsClass.LimitsPanel)
end)

hook.Add('DPP.SBoxLimitsUpdated', 'DPP.Menu', function()
	BuildSLimitsList(DPP.SettingsClass.SLimitsPanel)
end)

hook.Add('DPP.SBoxLimitsReloaded', 'DPP.Menu', function()
	BuildSLimitsList(DPP.SettingsClass.SLimitsPanel)
end)

hook.Add('DPP.FriendsChanged', 'DPP.Menu', function()
	BuildFriendsPanel(DPP.SettingsClass.FriendPanel)
end)

hook.Add('DPP.BlockedEntitesReloaded', 'DPP.Menu', function(s1)
	if PanelsFunctions[s1] then
		PanelsFunctions[s1](DPP.SettingsClass.ValidPanels[s1])
	end
end)

hook.Add('DPP.RestrictedTypesUpdated', 'DPP.Menu', function(s1)
	if PanelsFunctions2[s1] then
		PanelsFunctions2[s1](DPP.SettingsClass.ValidPanels2[s1])
	end
end)

hook.Add('DPP.RestrictedTypesReloaded', 'DPP.Menu', function(s1)
	if PanelsFunctions2[s1] then
		PanelsFunctions2[s1](DPP.SettingsClass.ValidPanels2[s1])
	end
end)

hook.Add('DPP.BlockedModelListChanged', 'DPP.Menu', function(s1)
	BuildModelsList(DPP.SettingsClass.ModelPanel)
end)

hook.Add('DPP.BlockedModelListReloaded', 'DPP.Menu', function(s1)
	BuildModelsList(DPP.SettingsClass.ModelPanel)
end)

hook.Add('PopulateToolMenu', 'DPP.Menu', PopulateToolMenu)

net.Receive('DPP.RefreshPlayerList', function()
	BuildFriendsPanel(DPP.SettingsClass.FriendPanel)
	BuildPlayerList(DPP.SettingsClass.PlayerPanel)
end)

local AddToBlocked = {
	MenuLabel = "Add to DPP Blocked Models",
	Order = 2500,
	MenuIcon = "icon16/cross.png",

	Filter = function(self, ent, ply)
		if not IsValid(ent) then return false end
		if not ply:IsSuperAdmin() then return false end
		if DPP.IsBlockedModel(ent:GetModel()) then return false end
		return true
	end,
	
	Action = function(self, ent)
		RunConsoleCommand('dpp_addblockedmodel', ent:GetModel())
	end,
}

local RemoveFromlocked = {
	MenuLabel = "Remove from DPP Blocked Models",
	Order = 2501,
	MenuIcon = "icon16/accept.png",

	Filter = function(self, ent, ply)
		if not IsValid(ent) then return false end
		if not ply:IsSuperAdmin() then return false end
		if not DPP.IsBlockedModel(ent:GetModel()) then return false end
		return true
	end,
	
	Action = function(self, ent)
		RunConsoleCommand('dpp_removeblockedmodel', ent:GetModel())
	end,
}

properties.Add("dpp.addblockedmodel", AddToBlocked)
properties.Add("dpp.delblockedmodel", RemoveFromlocked)

for k, v in pairs(DPP.BlockTypes) do
	local Add = {
		MenuLabel = "Add to DPP " .. v .. ' blacklist',
		Order = 2503,
		MenuIcon = 'icon16/cross.png',

		Filter = function(self, ent, ply)
			if not IsValid(ent) then return false end
			if not ply:IsSuperAdmin() then return false end
			if DPP['IsEntityBlocked' .. v](ent:GetClass(), ply) then return false end
			return true
		end,
		
		Action = function(self, ent)
			RunConsoleCommand('dpp_addblockedentity' .. k, ent:GetClass())
		end,
	}
	
	local Remove = {
		MenuLabel = "Remove from DPP " .. v .. ' blacklist',
		Order = 2503,
		MenuIcon = 'icon16/accept.png',

		Filter = function(self, ent, ply)
			if not IsValid(ent) then return false end
			if not ply:IsSuperAdmin() then return false end
			if not DPP['IsEntityBlocked' .. v](ent:GetClass(), ply) then return false end
			return true
		end,
		
		Action = function(self, ent)
			RunConsoleCommand('dpp_removeblockedentity' .. k, ent:GetClass())
		end,
	}

	properties.Add("dpp.addblocked" .. k, Add)
	properties.Add("dpp.removeblocked" .. k, Remove)
end

for k, v in pairs(DPP.RestrictTypes) do
	local function OpenModifyPanel(class, isNew)
		local t = DPP.RestrictedTypes[k][class] or {
			groups = {},
			iswhite = false
		}
		
		local height = 50
		
		local frame = vgui.Create('DFrame')
		frame:SetTitle('Modifying' .. class)
		SettingsClass.ApplyFrameStyle(frame)
		
		local groups = DPP.GetGroups()
		local Panels = {}
		
		for k, v in pairs(groups) do
			height = height + 20
			local p = frame:Add('DCheckBoxLabel')
			table.insert(Panels, p)
			p:Dock(TOP)
			p:SetText(v)
			p:SetChecked(table.HasValue(t.groups, v))
			p.Group = v
		end
		
		height = height + 30
		local iswhite = frame:Add('DCheckBoxLabel')
		iswhite:Dock(TOP)
		iswhite:SetText('Is White List')
		iswhite:SetChecked(t.iswhite)
		
		local apply = frame:Add('DButton')
		apply:Dock(BOTTOM)
		apply:SetText('Apply')
		
		function apply.DoClick()
			t.groups = {}
			for k, v in pairs(Panels) do
				if v:GetChecked() then
					table.insert(t.groups, v.Group)
				end
			end
			t.iswhite = iswhite:GetChecked()
			
			RunConsoleCommand('dpp_restrict' .. k, class, table.concat(t.groups, ','), t.iswhite and '1' or '0')
			frame:Close()
		end
		
		local discard = frame:Add('DButton')
		discard:Dock(BOTTOM)
		discard:SetText('Discard')
		SettingsClass.ApplyButtonStyle(discard)
		
		function discard.DoClick()
			frame:Close()
		end
		
		frame:SetHeight(height)
		frame:SetWidth(200)
		frame:Center()
		frame:MakePopup()
	end
	
	local Add = {
		MenuLabel = "Add to DPP " .. v .. ' restrict black/white list',
		Order = 2520,
		MenuIcon = 'icon16/cross.png',

		Filter = function(self, ent, ply)
			if not IsValid(ent) then return false end
			if not ply:IsSuperAdmin() then return false end
			local type = DPP.GetEntityType(ent)
			if type ~= k then return false end
			if DPP['IsEvenRestricted' .. v](ent:GetClass()) then return false end
			return true
		end,
		
		Action = function(self, ent)
			OpenModifyPanel(ent:GetClass(), true)
		end,
	}
	
	local Remove = {
		MenuLabel = "Remove from DPP " .. v .. ' restrict black/white list',
		Order = 2520,
		MenuIcon = 'icon16/accept.png',

		Filter = function(self, ent, ply)
			if not IsValid(ent) then return false end
			if not ply:IsSuperAdmin() then return false end
			local type = DPP.GetEntityType(ent)
			if type ~= k then return false end
			if not DPP['IsEvenRestricted' .. v](ent:GetClass()) then return false end
			return true
		end,
		
		Action = function(self, ent)
			RunConsoleCommand('dpp_unrestrict' .. k, ent:GetClass())
		end,
	}

	local Modify = {
		MenuLabel = "Modify DPP " .. v .. ' restriction...',
		Order = 2520,
		MenuIcon = 'icon16/pencil.png',

		Filter = function(self, ent, ply)
			if not IsValid(ent) then return false end
			if not ply:IsSuperAdmin() then return false end
			local type = DPP.GetEntityType(ent)
			if type ~= k then return false end
			if not DPP['IsEvenRestricted' .. v](ent:GetClass()) then return false end
			return true
		end,
		
		Action = function(self, ent)
			OpenModifyPanel(ent:GetClass(), false)
		end,
	}

	properties.Add("dpp.addrestricted" .. k, Add)
	properties.Add("dpp.removerestricted" .. k, Remove)
	properties.Add("dpp.modifyrestricted" .. k, Modify)
end

DPP.OldContentTypes = DPP.OldContentTypes or {}

--[[ --Can break spawnmenu
local function OpenMenu(self)
	if LocalPlayer():IsSuperAdmin() then
		local name, obj = debug.getupvalue(self.openFunc, 1)
		
		local menu = DermaMenu()
		
		menu:AddOption( "Copy to Clipboard", function() SetClipboardText( obj.spawnname ) end )
		menu:AddOption( "Spawn Using Toolgun", function() RunConsoleCommand( "gmod_tool", "creator" ) RunConsoleCommand( "creator_type", "0" ) RunConsoleCommand( "creator_name", obj.spawnname ) end )
		menu:AddSpacer()
		
		for k, v in pairs(DPP.BlockTypes) do
			menu:AddOption('Add to ' .. v .. ' blocked list', function()
				RunConsoleCommand('dpp_addblockedentity' .. k, obj.spawnname)
			end)
		end
		
		menu:AddSpacer()
		menu:AddOption( "Delete", function() icon:Remove() hook.Run( "SpawnlistContentChanged", icon ) end )
		
		menu:Open()
	else
		self.openFunc(self)
	end
end

--That's bad
local function OverrideSpawnMenuIcons()
	if not spawnmenu then return end --Not sandbox
	DPP.OldContentTypes.entity = DPP.OldContentTypes.entity or spawnmenu.GetContentType('entity')
	
	spawnmenu.AddContentType('entity', function(container, obj)
		local icon = DPP.OldContentTypes.entity(container, obj)
		local openFunc = icon.OpenMenu
		icon.openFunc = openFunc
		icon.OpenMenu = OpenMenu
		
		return icon
	end)
end

timer.Simple(0, OverrideSpawnMenuIcons)
]]

--[[ -- Fucking slow
local CachedMaterials = {}

local function Exists(class)
	return file.Exists("materials/entities/" .. class .. ".png", 'GAME')
end

local function OpenRestrictionMenu()
	local frame = vgui.Create('DFrame')
	SettingsClass.ApplyFrameStyle(frame)
	frame:SetSize(ScrW() - 200, ScrH() - 200)
	frame:SetPos(100, 100)
	frame:MakePopup()
	frame:SetTitle('DPP Restriction Menu')
	
	local w = ScrW() - 200
	
	local sheet = frame:Add('DPropertySheet')
	sheet:Dock(FILL)
	
	local NPCs = list.Get('NPC')
	local NPCsPanel = sheet:Add('DScrollPanel')
	sheet:AddSheet('NPCs', NPCsPanel)
	NPCsPanel:Dock(FILL)
	NPCsPanel:SetBackgroundColor(Color(0, 0, 0, 0))
	
	local SortedNPC = {}
	
	for k, v in pairs(NPCs) do
		SortedNPC[v.Category] = SortedNPC[v.Category] or {}
		SortedNPC[v.Category][k] = v
	end
	
	local CurrentLine = 0
	local CurrentColumn = 0
	local IWidth, IHeight = 128, 128
	
	local PanelsCateg = {}
	local i = 0
	
	for category, data in pairs(SortedNPC) do
		PanelsCateg[category] = NPCsPanel:Add('DCollapsibleCategory')
		PanelsCateg[category]:SetLabel(category)
		CurrentColumn = 0
		CurrentLine = 0
		
		for class, v in pairs(data) do
			local iW, iH = CurrentColumn * IWidth, CurrentLine * IHeight
			if ((CurrentColumn + 1) * IWidth) > w then
				CurrentLine = CurrentLine + 1
				CurrentColumn = 0
				iW, iH = CurrentColumn * IWidth, CurrentLine * IHeight
			end
			
			i = i + 1
			
			local icon = NPCsPanel:Add('ContentIcon')
			icon:SetContentType("vehicle")
			icon:SetSpawnName(v.Class)
			icon:SetName(v.Name)
			icon:SetPos(iW, iH)
			icon.SetIconAt = CurTime() + i * 0.05
			icon.Think = function(self)
				if self.SetIconAt < CurTime() and not self.IconSettedUp then
					self:SetMaterial("materials/entities/" .. v.Class .. ".png")
					self.IconSettedUp = true
				end
			end
			
			icon:SetColor(color_black)
			
			CurrentColumn = CurrentColumn + 1
		end
	end
end

OpenRestrictionMenu()
]]
