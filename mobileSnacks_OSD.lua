function mobileSnacks_OSD_OnLoad(obj) 
	obj:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	obj:SetWidth(32*obj:GetParent():GetScale());
	obj:SetHeight(32*obj:GetParent():GetScale());
end

-- mobileSnacksGFX = path to artwork... defined in mobileSnacks_Initialize.lua

function mobileSnacks_OSD_buttons()
	local GFX = "Interface\\AddOns\\mobileSnacks\\artwork\\";		-- path to artwork, used for the buttons of the OSD
	if (mS_Temp.isEnabled) then
		mobileSnacksOSDActivateBtn:SetNormalTexture(GFX.."OSD_msToggle_Active_1")
		mobileSnacksOSDActivateBtn:SetPushedTexture(GFX.."OSD_msToggle_Active_2")
		
		mobileSnacksOSDConfigBtn:SetNormalTexture(GFX.."OSD_msConfig_Normal_1")
		mobileSnacksOSDConfigBtn:SetPushedTexture(GFX.."OSD_msConfig_Normal_2")		
				
		if (mS_CharDatas.AutoBroadcast) then
			mobileSnacksOSDBroadcastBtn:SetNormalTexture(GFX.."OSD_msBroadcast_Active_1")
			mobileSnacksOSDBroadcastBtn:SetPushedTexture(GFX.."OSD_msBroadcast_Active_2")
		else
			mobileSnacksOSDBroadcastBtn:SetNormalTexture(GFX.."OSD_msBroadcast_Normal_1")
			mobileSnacksOSDBroadcastBtn:SetPushedTexture(GFX.."OSD_msBroadcast_Normal_2")
		end
	else
		mobileSnacksOSDActivateBtn:SetNormalTexture(GFX.."OSD_msToggle_Inactive_1")
		mobileSnacksOSDActivateBtn:SetPushedTexture(GFX.."OSD_msToggle_Inactive_2")
		mobileSnacksOSDBroadcastBtn:SetNormalTexture(GFX.."OSD_msBroadcast_Inactive_1")
		mobileSnacksOSDBroadcastBtn:SetPushedTexture(GFX.."OSD_msBroadcast_Inactive_2")
		mobileSnacksOSDConfigBtn:SetNormalTexture(GFX.."OSD_msConfig_Inactive_1")
		mobileSnacksOSDConfigBtn:SetPushedTexture(GFX.."OSD_msConfig_Inactive_2")
	end

	if (mS_Temp.isVisible) then
		mobileSnacksOSDConfigBtn:SetNormalTexture(GFX.."OSD_msConfig_Active_1")
		mobileSnacksOSDConfigBtn:SetPushedTexture(GFX.."OSD_msConfig_Active_2")
	end	
end



function mobileSnacksOSD_OnUpdate()
	if (not mS_CharDatas.OSD) then return end
	mobileSnacksVerbose(2,"OSD_OnUpdate")
	if (not mS_CharDatas.OSD.isEnabled) then
		mobileSnacksOSD:Hide();
		return true;
	end
	
	mobileSnacksOSD:Show();
	
	if (mS_CharDatas.OSD.border) then
		mobileSnacksOSD:SetBackdropBorderColor(1, 1, 1, 1);
	else 
		mobileSnacksOSD:SetBackdropBorderColor(0,0,0,0);
	end
	
	local col = mS_CharDatas.OSD;
	mobileSnacksOSD:SetBackdropColor(col.r, col.g, col.b, col.alpha);
	mobileSnacks_OSD_buttons();
	
	local s=1;
	if (mS_CharDatas.OSD.scale) then
		s = mS_CharDatas.OSD.scale;
	end
	if (mS_CharDatas.OSD.horiz) then
		mobileSnacksOSD:SetWidth(28+3*32*s);
		mobileSnacksOSD:SetHeight(32*s+14);

		mobileSnacksOSDBroadcastBtn:ClearAllPoints();		
		mobileSnacksOSDBroadcastBtn:SetPoint("RIGHT", "mobileSnacksOSDActivateBtn", "LEFT", -5,0);	
		mobileSnacksOSDConfigBtn:ClearAllPoints();	
		mobileSnacksOSDConfigBtn:SetPoint("LEFT","mobileSnacksOSDActivateBtn","RIGHT",5,0);
	else
		mobileSnacksOSD:SetHeight(28+3*32*s);
		mobileSnacksOSD:SetWidth(32*s+14);
		mobileSnacksOSDBroadcastBtn:ClearAllPoints();		
		mobileSnacksOSDBroadcastBtn:SetPoint("BOTTOM", "mobileSnacksOSDActivateBtn", "TOP", 0,5);		
		mobileSnacksOSDConfigBtn:ClearAllPoints();	
		mobileSnacksOSDConfigBtn:SetPoint("TOP","mobileSnacksOSDActivateBtn","BOTTOM",0,-5);
	end
	mobileSnacksOSDBroadcastBtn:SetWidth(32*s);
	mobileSnacksOSDBroadcastBtn:SetHeight(32*s);
	mobileSnacksOSDActivateBtn:SetWidth(32*s);
	mobileSnacksOSDActivateBtn:SetHeight(32*s);
	mobileSnacksOSDConfigBtn:SetWidth(32*s);
	mobileSnacksOSDConfigBtn:SetHeight(32*s);	
end
