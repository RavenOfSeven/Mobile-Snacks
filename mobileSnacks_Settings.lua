function mobileSnacksSettings_OnUpdate()
	mobileSnacksVerbose(2, "Updated Settings-Frame")
	if (mobileSnacksSettingsChannelDDframe) then mobileSnacksSettingsChannelDDframe:Hide(); end
	if (mobileSnacksSettingsOSDscale and mobileSnacksSettingsSwatch and tD_CharDatas.OSD) then
		if ( tD_CharDatas.OSD.isEnabled ) then
			mobileSnacksSettingsOSDCheck:SetChecked(1);
			mobileSnacksSettingsOSDLock:Show();
			mobileSnacksSettingsOSDscale:Show();
			mobileSnacksSettingsSwatch:Show();
			mobileSnacksSettingsOSDborder:Show();
			mobileSnacksSettingsOSDhoriz:Show();
		else
			mobileSnacksSettingsOSDCheck:SetChecked(0);
			mobileSnacksSettingsOSDLock:Hide();
			mobileSnacksSettingsOSDscale:Hide();
			mobileSnacksSettingsSwatch:Hide();
			mobileSnacksSettingsOSDborder:Hide();	
			mobileSnacksSettingsOSDhoriz:Hide();			
		end
		mobileSnacksSettingsOSDLock:SetChecked(tD_CharDatas.OSD.locked);
	end

	if (tD_CharDatas.ChannelID) then mobileSnacks_ChannelUpdate() end
	
	if (tD_CharDatas.broadcastSlice and mobileSnacksSettingsBroadcastTimerLbl) then 
		mobileSnacksSettingsBroadcastTimerLbl:SetText(floor(tD_CharDatas.broadcastSlice/60).." min")
	end
	
	if (mobileSnacksSettingsBroadcastCheck) then
		if (tD_CharDatas.AutoBroadcast and mobileSnacksSettingsBroadcastTimer) then
			mobileSnacksSettingsBroadcastCheck:SetChecked(1);
			mobileSnacksSettingsBroadcastTimer:Show();
			mobileSnacksSettingsBroadcastTimer:SetValue(math.floor(tD_CharDatas.broadcastSlice/60));
		else 
			mobileSnacksSettingsBroadcastCheck:SetChecked(0);
			mobileSnacksSettingsBroadcastTimer:Hide();
			tD_CharDatas.AutoBroadcast=false;
		end
	end
	
	if (mobileSnacksSettingsTimelimitCheck) then
		if (tD_CharDatas.TimelimitCheck) then
			mobileSnacksSettingsTimelimitCheck:SetChecked(1);
			mobileSnacksSettingsTimelimitSlider:Show();
			mobileSnacksSettingsTimelimitSlider:SetValue(tD_CharDatas.Timelimit);
			mobileSnacksSettingsTimelimitSliderLbl:SetText(tD_CharDatas.Timelimit.." sec");
		else
			mobileSnacksSettingsTimelimitCheck:SetChecked(0);
			mobileSnacksSettingsTimelimitSlider:Hide();
		end
	end
	if (mobileSnacksSettingsSoundCheck) then
		mobileSnacksSettingsSoundCheck:SetChecked(tD_CharDatas.SoundCheck);
	end

	if (mobileSnacksSettingsDisplayStockCheck) then
		mobileSnacksSettingsDisplayStockCheck:SetChecked(tD_CharDatas.DisplayStockCheck);
	end
end

function mobileSnacks_EditBoxUpdate()
	mobileSnacksVerbose(2,"EditBox updated")
	local temp = 480;
	if (not mobileSnacksTradeControl or not mobileSnacksSettingsText) then return end;
	
	if (mobileSnacksTradeControl:IsShown()) then temp=temp+184 end
	
	mobileSnacksSettingsText:SetWidth( temp );
	mobileSnacksSettingsText:SetHeight( 24*tD_CharDatas.Random + 6);
	
	local i;
	for i=1,8 do
		local obj = getglobal("mobileSnacksSettingsTextBroadcastText"..i);
		obj:SetWidth( temp-130 );
		getglobal("mobileSnacksSettingsTextBroadcastText"..i.."Middle"):SetWidth( temp-130 );

		if (i<=tD_CharDatas.Random) then	obj:Show()		else 	obj:Hide() 		end
		if (tD_CharDatas.RndText and tD_CharDatas.RndText[i]) then
			obj:SetText(tD_CharDatas.RndText[i]);
		else 
			obj:SetText("empty");
		end
	end	
end


function mobileSnacks_ChannelUpdate()
	mobileSnacksSettingsChannelDDTitleLbL:SetText(strupper( mobileSnacksChannelColors[tD_CharDatas.ChannelID].text ));
	local col = mobileSnacksChannelColors[tD_CharDatas.ChannelID];
	mobileSnacksSettingsChannelDDTitleLbL:SetTextColor(col.r, col.g, col.b);
end


function mobileSnacksSettings_OnColorChange(frame)
	frame.r = tD_CharDatas.OSD.r;
	frame.g = tD_CharDatas.OSD.g;
	frame.b = tD_CharDatas.OSD.b;
	frame.opacity = 1-tD_CharDatas.OSD.alpha;
	frame.opacityFunc = mobileSnacksSettings_SetColor;
	frame.swatchFunc = mobileSnacksSettings_SetOpacity;
	frame.hasOpacity = 1;
	ColorPickerFrame.frame = frame;
	CloseMenus();
	UIDropDownMenuButton_OpenColorPicker(frame);
end

function mobileSnacksSettings_SetColor()
	local r, g, b = ColorPickerFrame:GetColorRGB();
	tD_CharDatas.OSD.r=r;
	tD_CharDatas.OSD.g=g;
	tD_CharDatas.OSD.b=b;
	mobileSnacksSettings_OnUpdate();
	mobileSnacksOSD_OnUpdate();
	getglobal(ColorPickerFrame.frame:GetName() .. "SwatchNormalTexture"):SetVertexColor(r, g, b);
end

function mobileSnacksSettings_SetOpacity()
	local a = OpacitySliderFrame:GetValue();
	tD_CharDatas.OSD.alpha=1-a;
	mobileSnacksSettings_OnUpdate();
	mobileSnacksOSD_OnUpdate();
end




-- FUNCTIONS to insert ITEMLINKS --
-- copied and modified from the addon "SuperMacro" --
-- really well done! thx.      
-- btw: they expands the "default" functions by some features

function mobileSnacksSettings_InsertItemText(link)
	if ( not link ) then return end;
	if ( IsAltKeyDown() or IsShiftKeyDown() or IsControlKeyDown() ) then
		local temp = tD_CharDatas.OnBroadcastText:GetText();
		tD_CharDatas.OnBroadcastText:Insert(link);
		mobileSnacksVerbose(1,"Added "..link);
		return 1;
	end
end


local tD_oldContainerFrameItemButton_OnClick = ContainerFrameItemButton_OnClick;
function ContainerFrameItemButton_OnClick(button, ignoreShift)
	if ( button=="LeftButton" and not ignoreShift and tD_CharDatas.OnBroadcastText~=nil ) then
		local link = GetContainerItemLink(this:GetParent():GetID(), this:GetID());
		if ( not mobileSnacksSettings_InsertItemText(link) ) then
			tD_oldContainerFrameItemButton_OnClick(button, ignoreShift);
		end
		return;
	end
	tD_oldContainerFrameItemButton_OnClick(button, ignoreShift);
end

local tD_oldPaperDollItemSlotButton_OnClick = PaperDollItemSlotButton_OnClick;
function PaperDollItemSlotButton_OnClick(button, ignoreShift)
	if ( button=="LeftButton" and not ignoreShift and tD_CharDatas.OnBroadcastText~=nil ) then
		local link = GetInventoryItemLink("player", this:GetID());
		if ( not mobileSnacksSettings_InsertItemText(link) ) then
			tD_oldPaperDollItemSlotButton_OnClick(button, ignoreShift);
		end
		return;
	end
	tD_oldPaperDollItemSlotButton_OnClick(button, ignoreShift);
end

local tD_oldBagSlotButton_OnClick = BagSlotButton_OnClick;
function BagSlotButton_OnClick()
	if ( arg1=="LeftButton" and tD_CharDatas.OnBroadcastText~=nil ) then
		this:SetChecked(not this:GetChecked());
		local link = GetInventoryItemLink("player", this:GetID());
		if ( not mobileSnacksSettings_InsertItemText(link) ) then
			tD_oldBagSlotButton_OnClick();
		end
		return;
	end
	tD_oldBagSlotButton_OnClick();
end

local tD_oldBagSlotButton_OnShiftClick = BagSlotButton_OnShiftClick;
function BagSlotButton_OnShiftClick()
	if ( tD_CharDatas.OnBroadcastText~=nil ) then
		this:SetChecked(not this:GetChecked());
		local link = GetInventoryItemLink("player", this:GetID());
		if ( not mobileSnacksSettings_InsertItemText(link) ) then
			tD_oldBagSlotButton_OnShiftClick();
		end
		return;
	end
	tD_oldBagSlotButton_OnShiftClick();
end
