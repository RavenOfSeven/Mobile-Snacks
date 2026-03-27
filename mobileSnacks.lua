
function mobileSnacksOnLoad()
	--math.randomseed(floor(GetTime()));			-- initialize the randomizer
	mobileSnacks:RegisterEvent("VARIABLES_LOADED")
	mobileSnacks:RegisterEvent("TRADE_SHOW")			-- used to activate the automated trade
	mS_Temp.timeSlice = 0
	mS_Temp.broadcastSlice = 0
	mS_Temp.Target = {
		["Name"]=nil,
		["EnglishClass"]=nil,
		["Class"]=nil,
		["Level"]=nil,
	};		
end


function mobileSnacks_Eventhandler()
	if (mS_Temp.isEnabled) then
		mobileSnacksVerbose(1,"Gonna activate some events");
		mobileSnacks:RegisterEvent("TRADE_CLOSED")
		mobileSnacks:RegisterEvent("TRADE_ACCEPT_UPDATE")   -- used, if the opposite player changes the items -> re-accept
		mobileSnacks:RegisterEvent("UI_ERROR_MESSAGE")
		mobileSnacks:RegisterEvent("UI_INFO_MESSAGE")
		mS_Temp.InitiateTrade=nil;
		mS_Temp.Countdown=-1;		
	else
		mobileSnacksVerbose(1,"Gonna deactivate some events");
		mobileSnacks:UnregisterEvent("TRADE_CLOSED")
		mobileSnacks:UnregisterEvent("TRADE_ACCEPT_UPDATE")   -- used, if the opposite player changes the items -> re-accept
		mobileSnacks:UnregisterEvent("UI_ERROR_MESSAGE")
		mobileSnacks:UnregisterEvent("UI_INFO_MESSAGE")
		mobileSnacks:UnregisterEvent("PLAYER_TARGET_CHANGED")
	end
	mobileSnacksVerbose(2,"TRADE_SHOW, TRADE_CLOSED, TRADE_ACCEPT_UPDATE, UI_ERROR_MESSAGE, UI_INFO_MESSAGE");
end


function mobileSnacksSetFaction() 	-- sets the "paladine" or "shamane" to the profiles...damn burning crusade...
	if (mobileSnacksProfileDDframe) then
		if (mobileSnacks_IsBurningCrusade) then 
			mobileSnacksProfileDDframe:SetHeight(285)
		else
			mobileSnacksProfileDDframe:SetHeight(268)
			if (UnitFactionGroup("player")=="Alliance") then
				mobileSnacksProfileDDframeSub10:Hide();
				mobileSnacksProfileDDframeSub11:ClearAllPoints()
				mobileSnacksProfileDDframeSub11:SetPoint("TOP", mobileSnacksProfileDDframeSub9, "BOTTOM" , 0, -5)
			else
				mobileSnacksProfileDDframeSub9:Hide();
				mobileSnacksProfileDDframeSub10:ClearAllPoints()
				mobileSnacksProfileDDframeSub10:SetPoint("TOP", mobileSnacksProfileDDframeSub8, "BOTTOM" , 0, 0)
			end
		end
	end
end



function mobileSnacksOnEvent(event)
	if (event == "VARIABLES_LOADED") then
		mobileSnacksVerbose(0,mS_Loc.logon.welcome);
		mobileSnacks_OnVariablesLoaded()			-- found in mobileSnacks_initialize
	end
	if (event == "PLAYER_TARGET_CHANGED") then
		if (UnitIsPlayer("target") and UnitIsFriend("target", "player")) then
			mobileSnacksBanlistName:SetText(UnitName("target"));
		end
	end
		
	if (event == "TRADE_SHOW" and (not mS_Temp.isEnabled) and mS_CharDatas.ClientInfos and UnitName("NPC")~=nil) then
		local targetClass, targetEnglishClass = UnitClass("NPC");
		local guildName2, guildRankName2, guildRankIndex2 = GetGuildInfo("NPC");		
		local guildName3 = "";
		if (guildName2~=nil) then guildName3 = "<"..guildName2.."> ";	end		
		DEFAULT_CHAT_FRAME:AddMessage(mS_Loc.Opposite.." "..UnitName("NPC").." "..guildName3.." -  "..targetClass.." Level "..UnitLevel("NPC"),1,1,0);
	end
	
	
	if (not mS_Temp.isEnabled) then
		return
	end
	
	if ((event=="UI_ERROR_MESSAGE" or event=="UI_INFO_MESSAGE") and mS_Temp.Target.Name and arg1) then
		if (strfind(arg1,mS_Loc.UImessages.cancelled)~=nil or strfind(arg1,mS_Loc.UImessages.failed)~=nil) then
			mobileSnacksVerbose(2,arg1);
			mS_Temp.Target.Name=nil;
		end
		if (strfind(arg1,mS_Loc.UImessages.complete)~=nil) then
			mobileSnacksVerbose(2,arg1);
			mobileSnacksVerbose(1,"Gonna Registrate the Player "..mS_Temp.Target.Name);
			mobileSnacksAddClient(mS_Temp.Target.Name);
		end
	end


	if (event == "TRADE_SHOW" and mS_Temp.isEnabled and mS_Temp.InitiateTrade==nil) then
		mobileSnacks_GetBlockedItems_ForOwnUsage();			-- found in SLAVE_FRAME
		if (CursorHasItem()) then   PutItemInBackpack()  end	-- if the player's got an item on the cursor, mS's not running correctly
		if (mS_CharDatas.SoundCheck) then PlaySound("LEVELUPSOUND") end
		mS_Temp.Target = {};
		if (UnitName("NPC")==nil) then 
			mS_Temp.Target.Name="map-bug";
			mS_Temp.Target.Name="60";
			mS_Temp.Target.Class, mS_Temp.Target.EnglishClass = "BUG", "BUG"
		else
			if (UnitAffectingCombat("Player")==nil) then TargetUnit("NPC") end	-- target player, if you're not in combat
			mS_Temp.Target.Name 	= UnitName("NPC");
			mS_Temp.Target.Level	= UnitLevel("NPC");
			mS_Temp.Target.Class, mS_Temp.Target.EnglishClass = UnitClass("NPC");
		end
		
		if (not mobileSnacksTradeControlChecker(mS_Temp.Target)) then
			mS_Temp.Target.Name=nil;
			CloseTrade();
		else
			local itemsToTrade = mobileSnacksCompileProfile();
			if (itemsToTrade) then
				if (itemsToTrade==0) then		-- no items to trade - mobileSnacks should be inactive
					mobileSnacksVerbose(0,mS_Loc.noItemsToTrade);
					mS_Temp.Target.Name=nil;
				else
					mS_Temp.timeSlice = 0
					mS_Temp.tradeState = "populate"
					mS_Temp.tradeData = {}
					mS_Temp.tradeData.slotID = 1
					mS_Temp.tradeData.numAttempts = 0
					mS_Temp.tradeData.containerLocation = nil
				end
			end
		end
	end
	if (event == "TRADE_ACCEPT_UPDATE") then
		mobileSnacksVerbose(1,"TRADE_ACCEPT_UPDATE: Player="..arg1.." - Target="..arg2);
		if (arg1==0 and arg2==1 and mS_CharDatas.AutoAccept) then 
			mobileSnacksAccept()
		end
		if (arg1==1 and arg2==0 and mS_CharDatas.TimelimitCheck) then
			mobileSnacksStartTimelimiter()
		end
	end
	if (event == "TRADE_CLOSED") then
		mS_Temp.tradeState = nil
		mS_Temp.tradeData = nil
		mS_Temp.InitiateTrade=nil;
		mS_Temp.Countdown=-1;
		mobileSnacksVerbose(1,"Trade Closed")

		--if (UnitIsPlayer("target")) then TargetLastEnemy() end
	end
end


function mobileSnacksAddClient(name)
	if (not name) then return end
	
	local i=0
	local index=nil;
	while (mS_Temp.RegUser[i]~=nil) do
		mobileSnacksVerbose(3,"Registred Player at index "..i.." is: "..mS_Temp.RegUser[i].name);
		if (mS_Temp.RegUser[i].name == name) then
			mobileSnacksVerbose(2,name.." found in the List at position "..i);
			index=i;
		end
		i=i+1;
	end
	
	if (index==nil) then
		mobileSnacksVerbose(2,name.." was unregistred!  New Registration-Index is: "..i);
		mS_Temp.RegUser[i]= {
			["name"] = name,  	["trades"] = 1
		}
	else
		mS_Temp.RegUser[index].trades = mS_Temp.RegUser[index].trades+1;
	end
end



function mobileSnacksClick(slotID)
	MoneyInputFrame_ClearFocus(mobileSnacksMoneyFrame)
		
	ClickTradeButton(slotID)
	local itemName, itemTexture, itemCount = GetTradePlayerItemInfo(slotID)
	local itemLink = GetTradePlayerItemLink(slotID)

	if ( itemName ) then
		ClickTradeButton(slotID)
		local i=mS_CharDatas.ActualProfile;		
		mS_CharDatas.profile[mS_CharDatas.ActualRack][i][slotID] = {}
		mS_CharDatas.profile[mS_CharDatas.ActualRack][i][slotID].itemLink = itemLink
		mS_CharDatas.profile[mS_CharDatas.ActualRack][i][slotID].itemName = itemName
		mS_CharDatas.profile[mS_CharDatas.ActualRack][i][slotID].itemTexture = itemTexture
		mS_CharDatas.profile[mS_CharDatas.ActualRack][i][slotID].itemCount = itemCount
	else
		mS_CharDatas.profile[mS_CharDatas.ActualRack][mS_CharDatas.ActualProfile][slotID]=nil
	end
	mobileSnacksVerbose(2, "Recieved Item on Slot "..slotID);
	mobileSnacksUpdate()
end


function mobileSnacksUpdate()
	local ActPro=mS_CharDatas.ActualProfile;

	MoneyInputFrame_ClearFocus(mobileSnacksMoneyFrame)
	if (mobileSnacksProfileDDframe) then mobileSnacksProfileDDframe:Hide(); end
	if (mobileSnacksRackDDframe) then mobileSnacksRackDDframe:Hide(); end
	
	
	if (mobileSnacksSettingsChannelDDframe) then mobileSnacksSettingsChannelDDframe:Hide(); end
	for slotID=1,6 do
		local buttonText = getglobal("mobileSnacksItem"..slotID.."Name")
		local itemButton = getglobal("mobileSnacksItem"..slotID.."ItemButton")
		
		if ( mS_CharDatas.profile and mS_CharDatas.profile[mS_CharDatas.ActualRack] and 
			 mS_CharDatas.profile[mS_CharDatas.ActualRack][ActPro] and
		     mS_CharDatas.profile[mS_CharDatas.ActualRack][ActPro][slotID] and 
			 mS_CharDatas.profile[mS_CharDatas.ActualRack][ActPro][slotID].itemName ) then
			local temp = mS_CharDatas.profile[mS_CharDatas.ActualRack][ActPro][slotID];
			mobileSnacksVerbose(3,"mobileSnacksUpdate: slotID '"..slotID.."' is used")
			buttonText:SetText(temp.itemName)
			SetItemButtonTexture(itemButton, temp.itemTexture)
			SetItemButtonCount(itemButton, temp.itemCount)
		else
			mobileSnacksVerbose(3,"mobileSnacksUpdate: slotID '"..slotID.."' is free")
			buttonText:SetText("")
			SetItemButtonTexture(itemButton, nil)
			SetItemButtonCount(itemButton, nil)
		end
	end
	
	if (mS_Temp.isVisible) then	mobileSnacks:Show()  
	else
		if (mobileSnacksTradeControl) then
			mobileSnacks:Hide()	
			if (not mobileSnacksMessages:IsShown()) then
				mobileSnacksSettings:Hide();
				mobileSnacksTradeControl:Hide()
				mobileSnacksSettingsBtn:UnlockHighlight();
				mobileSnacksTradeControlBtn:UnlockHighlight();
			end
		end
	end
	
	if (mS_Temp.isEnabled) then	
		mobileSnacksState:SetText(mS_Loc.buttons.enabled)
		mobileSnacksState:LockHighlight();
	else	
		mobileSnacksState:SetText(mS_Loc.buttons.disabled)
		mobileSnacksState:UnlockHighlight();
	end
		
	if (mS_CharDatas.broadcastSlice) then
		if (mS_CharDatas.broadcastSlice < 0) then
			mS_CharDatas.broadcastSlice = 0
		elseif (mS_CharDatas.broadcastSlice > mobileSnacks_MaxBroadcastLength*60) then
			mS_CharDatas.broadcastSlice = mobileSnacks_MaxBroadcastLength*60
		end
	else
		mS_CharDatas.broadcastSlice = math.floor(mobileSnacks_MaxBroadcastLength/2)
	end
	
	if (mS_CharDatas.AutoBroadcast) then
		mobileSnacksSettingsBroadcastTimer:Show();
		mobileSnacksSettingsBroadcastCheck:SetChecked(1);
	else
		mobileSnacksSettingsBroadcastTimer:Hide();
		mobileSnacksSettingsBroadcastCheck:SetChecked(0);
	end
	
	local tmp = mS_CharDatas.ActualProfile;
	if (mS_CharDatas.profile and mS_CharDatas.profile[mS_CharDatas.ActualRack] and tmp and mS_CharDatas.profile[mS_CharDatas.ActualRack][tmp].Charge) then
		MoneyInputFrame_SetCopper(mobileSnacksMoneyFrame, mS_CharDatas.profile[mS_CharDatas.ActualRack][tmp].Charge)
	end
	if (tmp==14) then
		mobileSnacksMoneyLbL:Hide();		mobileSnacksMoneyFrame:Hide();
	else
		mobileSnacksMoneyLbL:Show();		mobileSnacksMoneyFrame:Show();
	end
	
	
	local s = 1
	if (mS_CharDatas.ActualRack) then
		s = mobileSnacksRackColor[mS_CharDatas.ActualRack]
	end
	local r,g,b = 0.8,0.8,0.8;
	if (mS_Temp.isEnabled) then
		r=s.r; g=s.g; b=s.b;
	end
			
	mobileSnacksBkg1:SetVertexColor(r,g,b,1);
	mobileSnacksBkg2:SetVertexColor(r,g,b,1);
	mobileSnacksBkg3:SetVertexColor(r,g,b,1);
end


function mobileSnacks_ResetFrames()
	mobileSnacks:ClearAllPoints()
	mobileSnacks:SetPoint("CENTER", "UIParent", "CENTER", 0, 0)
	mobileSnacksMessages:ClearAllPoints()
	mobileSnacksMessages:SetPoint("CENTER", "UIParent", "CENTER", 0, 0)
	mobileSnacksOSD:ClearAllPoints()
	mobileSnacksOSD:SetPoint("LEFT", "UIParent", "LEFT", 15, 0)
	mobileSnacksVerbose(0,mS_Loc.resetframes)
end



SLASH_TRADE_DISPENSER1 = "/mobileSnacks"
SLASH_TRADE_DISPENSER2 = "/td"
SlashCmdList["TRADE_DISPENSER"] = function(msg)	
	mobileSnacks_SlashCommand(msg)
end


function mobileSnacks_SlashCommand(msg)
	if (not msg) then mobileSnacks_Print(mS_Loc.help) 
	else
		local command=string.lower(msg);
		if (command=="config") then
			mS_Temp.isVisible = not mS_Temp.isVisible;
			mobileSnacksMessages:Hide();
			mobileSnacksUpdate();
			mobileSnacksOSD_OnUpdate();
		elseif (command=="toggle") then
			mS_Temp.isEnabled = not mS_Temp.isEnabled;
			if (mS_Temp.isEnabled) then
				DEFAULT_CHAT_FRAME:AddMessage(mS_Loc.activated)
			else
				DEFAULT_CHAT_FRAME:AddMessage(mS_Loc.deactivated)
			end
			mobileSnacks_Eventhandler();
			mobileSnacksUpdate();
			mobileSnacksOSD_OnUpdate();
		elseif (command=="broadcast") then
			if (mS_Temp.isEnabled) then
				mobileSnacksBroadcastItems()
			else
				DEFAULT_CHAT_FRAME:AddMessage(mS_Loc.OSD.notenabled)
			end
		elseif (command=="osd") then
			mS_CharDatas.OSD.isEnabled = not mS_CharDatas.OSD.isEnabled;
			mobileSnacksUpdate();
			mobileSnacksSettings_OnUpdate();
			mobileSnacksOSD_OnUpdate();
		elseif (command=="about") then mobileSnacks_Print(mS_Loc.about)
		elseif (command=="resetpos") then mobileSnacks_ResetFrames()
		elseif (string.sub(command, 1,7)=="verbose") then
			local temp=tonumber(string.sub(command, 8,10));
			if (not temp) then
				mobileSnacksVerbose(0, mS_Loc.verbose.isset..mS_GlobalDatas.Verbose);
			else 
				mS_GlobalDatas.Verbose=temp;
				mobileSnacksVerbose(0,mS_Loc.verbose.setto..mS_GlobalDatas.Verbose);
			end
		else 	mobileSnacks_Print(mS_Loc.help);
		end		-- no correct command was found
	end
end
