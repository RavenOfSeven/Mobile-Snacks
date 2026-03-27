function mobileSnacksSettings_OnUpdate()
	mobileSnacksVerbose(2, "Updated Settings-Frame")
	if (mobileSnacksSettingsChannelDDframe) then mobileSnacksSettingsChannelDDframe:Hide(); end
	if (mobileSnacksSettingsOSDscale and mobileSnacksSettingsSwatch and mS_CharDatas.OSD) then
		if ( mS_CharDatas.OSD.isEnabled ) then
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
		mobileSnacksSettingsOSDLock:SetChecked(mS_CharDatas.OSD.locked);
	end

	if (mS_CharDatas.ChannelID) then mobileSnacks_ChannelUpdate() end
	
	if (mS_CharDatas.broadcastSlice and mobileSnacksSettingsBroadcastTimerLbl) then 
		mobileSnacksSettingsBroadcastTimerLbl:SetText(floor(mS_CharDatas.broadcastSlice/60).." min")
	end
	
	if (mobileSnacksSettingsBroadcastCheck) then
		if (mS_CharDatas.AutoBroadcast and mobileSnacksSettingsBroadcastTimer) then
			mobileSnacksSettingsBroadcastCheck:SetChecked(1);
			mobileSnacksSettingsBroadcastTimer:Show();
			mobileSnacksSettingsBroadcastTimer:SetValue(math.floor(mS_CharDatas.broadcastSlice/60));
		else 
			mobileSnacksSettingsBroadcastCheck:SetChecked(0);
			mobileSnacksSettingsBroadcastTimer:Hide();
			mS_CharDatas.AutoBroadcast=false;
		end
	end
	
	if (mobileSnacksSettingsTimelimitCheck) then
		if (mS_CharDatas.TimelimitCheck) then
			mobileSnacksSettingsTimelimitCheck:SetChecked(1);
			mobileSnacksSettingsTimelimitSlider:Show();
			mobileSnacksSettingsTimelimitSlider:SetValue(mS_CharDatas.Timelimit);
			mobileSnacksSettingsTimelimitSliderLbl:SetText(mS_CharDatas.Timelimit.." sec");
		else
			mobileSnacksSettingsTimelimitCheck:SetChecked(0);
			mobileSnacksSettingsTimelimitSlider:Hide();
		end
	end
	if (mobileSnacksSettingsSoundCheck) then
		mobileSnacksSettingsSoundCheck:SetChecked(mS_CharDatas.SoundCheck);
	end

	if (mobileSnacksSettingsDisplayStockCheck) then
		mobileSnacksSettingsDisplayStockCheck:SetChecked(mS_CharDatas.DisplayStockCheck);
	end
end

function mobileSnacks_EditBoxUpdate()
	mobileSnacksVerbose(2,"EditBox updated")
	local temp = 480;
	if (not mobileSnacksTradeControl or not mobileSnacksSettingsText) then return end;
	
	if (mobileSnacksTradeControl:IsShown()) then temp=temp+184 end
	
	mobileSnacksSettingsText:SetWidth( temp );
	mobileSnacksSettingsText:SetHeight( 24*mS_CharDatas.Random + 6);
	
	local i;
	for i=1,8 do
		local obj = getglobal("mobileSnacksSettingsTextBroadcastText"..i);
		obj:SetWidth( temp-130 );
		getglobal("mobileSnacksSettingsTextBroadcastText"..i.."Middle"):SetWidth( temp-130 );

		if (i<=mS_CharDatas.Random) then	obj:Show()		else 	obj:Hide() 		end
		if (mS_CharDatas.RndText and mS_CharDatas.RndText[i]) then
			obj:SetText(mS_CharDatas.RndText[i]);
		else 
			obj:SetText("empty");
		end
	end	
end


function mobileSnacks_ChannelUpdate()
	mobileSnacksSettingsChannelDDTitleLbL:SetText(strupper( mobileSnacksChannelColors[mS_CharDatas.ChannelID].text ));
	local col = mobileSnacksChannelColors[mS_CharDatas.ChannelID];
	mobileSnacksSettingsChannelDDTitleLbL:SetTextColor(col.r, col.g, col.b);
end


function mobileSnacksSettings_OnColorChange(frame)
	frame.r = mS_CharDatas.OSD.r;
	frame.g = mS_CharDatas.OSD.g;
	frame.b = mS_CharDatas.OSD.b;
	frame.opacity = 1-mS_CharDatas.OSD.alpha;
	frame.opacityFunc = mobileSnacksSettings_SetColor;
	frame.swatchFunc = mobileSnacksSettings_SetOpacity;
	frame.hasOpacity = 1;
	ColorPickerFrame.frame = frame;
	CloseMenus();
	UIDropDownMenuButton_OpenColorPicker(frame);
end

function mobileSnacksSettings_SetColor()
	local r, g, b = ColorPickerFrame:GetColorRGB();
	mS_CharDatas.OSD.r=r;
	mS_CharDatas.OSD.g=g;
	mS_CharDatas.OSD.b=b;
	mobileSnacksSettings_OnUpdate();
	mobileSnacksOSD_OnUpdate();
	getglobal(ColorPickerFrame.frame:GetName() .. "SwatchNormalTexture"):SetVertexColor(r, g, b);
end

function mobileSnacksSettings_SetOpacity()
	local a = OpacitySliderFrame:GetValue();
	mS_CharDatas.OSD.alpha=1-a;
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
		local temp = mS_CharDatas.OnBroadcastText:GetText();
		mS_CharDatas.OnBroadcastText:Insert(link);
		mobileSnacksVerbose(1,"Added "..link);
		return 1;
	end
end


local mS_oldContainerFrameItemButton_OnClick = ContainerFrameItemButton_OnClick;
function ContainerFrameItemButton_OnClick(button, ignoreShift)
	if ( button=="LeftButton" and not ignoreShift and mS_CharDatas.OnBroadcastText~=nil ) then
		local link = GetContainerItemLink(this:GetParent():GetID(), this:GetID());
		if ( not mobileSnacksSettings_InsertItemText(link) ) then
			mS_oldContainerFrameItemButton_OnClick(button, ignoreShift);
		end
		return;
	end
	mS_oldContainerFrameItemButton_OnClick(button, ignoreShift);
end

local mS_oldPaperDollItemSlotButton_OnClick = PaperDollItemSlotButton_OnClick;
function PaperDollItemSlotButton_OnClick(button, ignoreShift)
	if ( button=="LeftButton" and not ignoreShift and mS_CharDatas.OnBroadcastText~=nil ) then
		local link = GetInventoryItemLink("player", this:GetID());
		if ( not mobileSnacksSettings_InsertItemText(link) ) then
			mS_oldPaperDollItemSlotButton_OnClick(button, ignoreShift);
		end
		return;
	end
	mS_oldPaperDollItemSlotButton_OnClick(button, ignoreShift);
end

local mS_oldBagSlotButton_OnClick = BagSlotButton_OnClick;
function BagSlotButton_OnClick()
	if ( arg1=="LeftButton" and mS_CharDatas.OnBroadcastText~=nil ) then
		this:SetChecked(not this:GetChecked());
		local link = GetInventoryItemLink("player", this:GetID());
		if ( not mobileSnacksSettings_InsertItemText(link) ) then
			mS_oldBagSlotButton_OnClick();
		end
		return;
	end
	mS_oldBagSlotButton_OnClick();
end

local mS_oldBagSlotButton_OnShiftClick = BagSlotButton_OnShiftClick;
function BagSlotButton_OnShiftClick()
	if ( mS_CharDatas.OnBroadcastText~=nil ) then
		this:SetChecked(not this:GetChecked());
		local link = GetInventoryItemLink("player", this:GetID());
		if ( not mobileSnacksSettings_InsertItemText(link) ) then
			mS_oldBagSlotButton_OnShiftClick();
		end
		return;
	end
	mS_oldBagSlotButton_OnShiftClick();
end
