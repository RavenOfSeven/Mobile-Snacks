
function mobileSnacksOnLoad()
	--math.randomseed(floor(GetTime()));			-- initialize the randomizer
	mobileSnacks:RegisterEvent("VARIABLES_LOADED")
	mobileSnacks:RegisterEvent("TRADE_SHOW")			-- used to activate the automated trade
	tD_Temp.timeSlice = 0
	tD_Temp.broadcastSlice = 0
	tD_Temp.Target = {
		["Name"]=nil,
		["EnglishClass"]=nil,
		["Class"]=nil,
		["Level"]=nil,
	};		
end


function mobileSnacks_Eventhandler()
	if (tD_Temp.isEnabled) then
		mobileSnacksVerbose(1,"Gonna activate some events");
		mobileSnacks:RegisterEvent("TRADE_CLOSED")
		mobileSnacks:RegisterEvent("TRADE_ACCEPT_UPDATE")   -- used, if the opposite player changes the items -> re-accept
		mobileSnacks:RegisterEvent("UI_ERROR_MESSAGE")
		mobileSnacks:RegisterEvent("UI_INFO_MESSAGE")
		tD_Temp.InitiateTrade=nil;
		tD_Temp.Countdown=-1;		
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
		mobileSnacksVerbose(0,tD_Loc.logon.welcome);
		mobileSnacks_OnVariablesLoaded()			-- found in mobileSnacks_initialize
	end
	if (event == "PLAYER_TARGET_CHANGED") then
		if (UnitIsPlayer("target") and UnitIsFriend("target", "player")) then
			mobileSnacksBanlistName:SetText(UnitName("target"));
		end
	end
		
	if (event == "TRADE_SHOW" and (not tD_Temp.isEnabled) and tD_CharDatas.ClientInfos and UnitName("NPC")~=nil) then
		local targetClass, targetEnglishClass = UnitClass("NPC");
		local guildName2, guildRankName2, guildRankIndex2 = GetGuildInfo("NPC");		
		local guildName3 = "";
		if (guildName2~=nil) then guildName3 = "<"..guildName2.."> ";	end		
		DEFAULT_CHAT_FRAME:AddMessage(tD_Loc.Opposite.." "..UnitName("NPC").." "..guildName3.." -  "..targetClass.." Level "..UnitLevel("NPC"),1,1,0);
	end
	
	
	if (not tD_Temp.isEnabled) then
		return
	end
	
	if ((event=="UI_ERROR_MESSAGE" or event=="UI_INFO_MESSAGE") and tD_Temp.Target.Name and arg1) then
		if (strfind(arg1,tD_Loc.UImessages.cancelled)~=nil or strfind(arg1,tD_Loc.UImessages.failed)~=nil) then
			mobileSnacksVerbose(2,arg1);
			tD_Temp.Target.Name=nil;
		end
		if (strfind(arg1,tD_Loc.UImessages.complete)~=nil) then
			mobileSnacksVerbose(2,arg1);
			mobileSnacksVerbose(1,"Gonna Registrate the Player "..tD_Temp.Target.Name);
			mobileSnacksAddClient(tD_Temp.Target.Name);
		end
	end


	if (event == "TRADE_SHOW" and tD_Temp.isEnabled and tD_Temp.InitiateTrade==nil) then
		mobileSnacks_GetBlockedItems_ForOwnUsage();			-- found in SLAVE_FRAME
		if (CursorHasItem()) then   PutItemInBackpack()  end	-- if the player's got an item on the cursor, tD's not running correctly
		if (tD_CharDatas.SoundCheck) then PlaySound("LEVELUPSOUND") end
		tD_Temp.Target = {};
		if (UnitName("NPC")==nil) then 
			tD_Temp.Target.Name="map-bug";
			tD_Temp.Target.Name="60";
			tD_Temp.Target.Class, tD_Temp.Target.EnglishClass = "BUG", "BUG"
		else
			if (UnitAffectingCombat("Player")==nil) then TargetUnit("NPC") end	-- target player, if you're not in combat
			tD_Temp.Target.Name 	= UnitName("NPC");
			tD_Temp.Target.Level	= UnitLevel("NPC");
			tD_Temp.Target.Class, tD_Temp.Target.EnglishClass = UnitClass("NPC");
		end
		
		if (not mobileSnacksTradeControlChecker(tD_Temp.Target)) then
			tD_Temp.Target.Name=nil;
			CloseTrade();
		else
			local itemsToTrade = mobileSnacksCompileProfile();
			if (itemsToTrade) then
				if (itemsToTrade==0) then		-- no items to trade - mobileSnacks should be inactive
					mobileSnacksVerbose(0,tD_Loc.noItemsToTrade);
					tD_Temp.Target.Name=nil;
				else
					tD_Temp.timeSlice = 0
					tD_Temp.tradeState = "populate"
					tD_Temp.tradeData = {}
					tD_Temp.tradeData.slotID = 1
					tD_Temp.tradeData.numAttempts = 0
					tD_Temp.tradeData.containerLocation = nil
				end
			end
		end
	end
	if (event == "TRADE_ACCEPT_UPDATE") then
		mobileSnacksVerbose(1,"TRADE_ACCEPT_UPDATE: Player="..arg1.." - Target="..arg2);
		if (arg1==0 and arg2==1 and tD_CharDatas.AutoAccept) then 
			mobileSnacksAccept()
		end
		if (arg1==1 and arg2==0 and tD_CharDatas.TimelimitCheck) then
			mobileSnacksStartTimelimiter()
		end
	end
	if (event == "TRADE_CLOSED") then
		tD_Temp.tradeState = nil
		tD_Temp.tradeData = nil
		tD_Temp.InitiateTrade=nil;
		tD_Temp.Countdown=-1;
		mobileSnacksVerbose(1,"Trade Closed")

		--if (UnitIsPlayer("target")) then TargetLastEnemy() end
	end
end


function mobileSnacksAddClient(name)
	if (not name) then return end
	
	local i=0
	local index=nil;
	while (tD_Temp.RegUser[i]~=nil) do
		mobileSnacksVerbose(3,"Registred Player at index "..i.." is: "..tD_Temp.RegUser[i].name);
		if (tD_Temp.RegUser[i].name == name) then
			mobileSnacksVerbose(2,name.." found in the List at position "..i);
			index=i;
		end
		i=i+1;
	end
	
	if (index==nil) then
		mobileSnacksVerbose(2,name.." was unregistred!  New Registration-Index is: "..i);
		tD_Temp.RegUser[i]= {
			["name"] = name,  	["trades"] = 1
		}
	else
		tD_Temp.RegUser[index].trades = tD_Temp.RegUser[index].trades+1;
	end
end



function mobileSnacksClick(slotID)
	MoneyInputFrame_ClearFocus(mobileSnacksMoneyFrame)
		
	ClickTradeButton(slotID)
	local itemName, itemTexture, itemCount = GetTradePlayerItemInfo(slotID)
	local itemLink = GetTradePlayerItemLink(slotID)

	if ( itemName ) then
		ClickTradeButton(slotID)
		local i=tD_CharDatas.ActualProfile;		
		tD_CharDatas.profile[tD_CharDatas.ActualRack][i][slotID] = {}
		tD_CharDatas.profile[tD_CharDatas.ActualRack][i][slotID].itemLink = itemLink
		tD_CharDatas.profile[tD_CharDatas.ActualRack][i][slotID].itemName = itemName
		tD_CharDatas.profile[tD_CharDatas.ActualRack][i][slotID].itemTexture = itemTexture
		tD_CharDatas.profile[tD_CharDatas.ActualRack][i][slotID].itemCount = itemCount
	else
		tD_CharDatas.profile[tD_CharDatas.ActualRack][tD_CharDatas.ActualProfile][slotID]=nil
	end
	mobileSnacksVerbose(2, "Recieved Item on Slot "..slotID);
	mobileSnacksUpdate()
end


function mobileSnacksUpdate()
	local ActPro=tD_CharDatas.ActualProfile;

	MoneyInputFrame_ClearFocus(mobileSnacksMoneyFrame)
	if (mobileSnacksProfileDDframe) then mobileSnacksProfileDDframe:Hide(); end
	if (mobileSnacksRackDDframe) then mobileSnacksRackDDframe:Hide(); end
	
	
	if (mobileSnacksSettingsChannelDDframe) then mobileSnacksSettingsChannelDDframe:Hide(); end
	for slotID=1,6 do
		local buttonText = getglobal("mobileSnacksItem"..slotID.."Name")
		local itemButton = getglobal("mobileSnacksItem"..slotID.."ItemButton")
		
		if ( tD_CharDatas.profile and tD_CharDatas.profile[tD_CharDatas.ActualRack] and 
			 tD_CharDatas.profile[tD_CharDatas.ActualRack][ActPro] and
		     tD_CharDatas.profile[tD_CharDatas.ActualRack][ActPro][slotID] and 
			 tD_CharDatas.profile[tD_CharDatas.ActualRack][ActPro][slotID].itemName ) then
			local temp = tD_CharDatas.profile[tD_CharDatas.ActualRack][ActPro][slotID];
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
	
	if (tD_Temp.isVisible) then	mobileSnacks:Show()  
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
	
	if (tD_Temp.isEnabled) then	
		mobileSnacksState:SetText(tD_Loc.buttons.enabled)
		mobileSnacksState:LockHighlight();
	else	
		mobileSnacksState:SetText(tD_Loc.buttons.disabled)
		mobileSnacksState:UnlockHighlight();
	end
		
	if (tD_CharDatas.broadcastSlice) then
		if (tD_CharDatas.broadcastSlice < 0) then
			tD_CharDatas.broadcastSlice = 0
		elseif (tD_CharDatas.broadcastSlice > mobileSnacks_MaxBroadcastLength*60) then
			tD_CharDatas.broadcastSlice = mobileSnacks_MaxBroadcastLength*60
		end
	else
		tD_CharDatas.broadcastSlice = math.floor(mobileSnacks_MaxBroadcastLength/2)
	end
	
	if (tD_CharDatas.AutoBroadcast) then
		mobileSnacksSettingsBroadcastTimer:Show();
		mobileSnacksSettingsBroadcastCheck:SetChecked(1);
	else
		mobileSnacksSettingsBroadcastTimer:Hide();
		mobileSnacksSettingsBroadcastCheck:SetChecked(0);
	end
	
	local tmp = tD_CharDatas.ActualProfile;
	if (tD_CharDatas.profile and tD_CharDatas.profile[tD_CharDatas.ActualRack] and tmp and tD_CharDatas.profile[tD_CharDatas.ActualRack][tmp].Charge) then
		MoneyInputFrame_SetCopper(mobileSnacksMoneyFrame, tD_CharDatas.profile[tD_CharDatas.ActualRack][tmp].Charge)
	end
	if (tmp==14) then
		mobileSnacksMoneyLbL:Hide();		mobileSnacksMoneyFrame:Hide();
	else
		mobileSnacksMoneyLbL:Show();		mobileSnacksMoneyFrame:Show();
	end
	
	
	local s = 1
	if (tD_CharDatas.ActualRack) then
		s = mobileSnacksRackColor[tD_CharDatas.ActualRack]
	end
	local r,g,b = 0.8,0.8,0.8;
	if (tD_Temp.isEnabled) then
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
	mobileSnacksVerbose(0,tD_Loc.resetframes)
end



SLASH_TRADE_DISPENSER1 = "/mobileSnacks"
SLASH_TRADE_DISPENSER2 = "/td"
SlashCmdList["TRADE_DISPENSER"] = function(msg)	
	mobileSnacks_SlashCommand(msg)
end


function mobileSnacks_SlashCommand(msg)
	if (not msg) then mobileSnacks_Print(tD_Loc.help) 
	else
		local command=string.lower(msg);
		if (command=="config") then
			tD_Temp.isVisible = not tD_Temp.isVisible;
			mobileSnacksMessages:Hide();
			mobileSnacksUpdate();
			mobileSnacksOSD_OnUpdate();
		elseif (command=="toggle") then
			tD_Temp.isEnabled = not tD_Temp.isEnabled;
			if (tD_Temp.isEnabled) then
				DEFAULT_CHAT_FRAME:AddMessage(tD_Loc.activated)
			else
				DEFAULT_CHAT_FRAME:AddMessage(tD_Loc.deactivated)
			end
			mobileSnacks_Eventhandler();
			mobileSnacksUpdate();
			mobileSnacksOSD_OnUpdate();
		elseif (command=="broadcast") then
			if (tD_Temp.isEnabled) then
				mobileSnacksBroadcastItems()
			else
				DEFAULT_CHAT_FRAME:AddMessage(tD_Loc.OSD.notenabled)
			end
		elseif (command=="osd") then
			tD_CharDatas.OSD.isEnabled = not tD_CharDatas.OSD.isEnabled;
			mobileSnacksUpdate();
			mobileSnacksSettings_OnUpdate();
			mobileSnacksOSD_OnUpdate();
		elseif (command=="about") then mobileSnacks_Print(tD_Loc.about)
		elseif (command=="resetpos") then mobileSnacks_ResetFrames()
		elseif (string.sub(command, 1,7)=="verbose") then
			local temp=tonumber(string.sub(command, 8,10));
			if (not temp) then
				mobileSnacksVerbose(0, tD_Loc.verbose.isset..tD_GlobalDatas.Verbose);
			else 
				tD_GlobalDatas.Verbose=temp;
				mobileSnacksVerbose(0,tD_Loc.verbose.setto..tD_GlobalDatas.Verbose);
			end
		else 	mobileSnacks_Print(tD_Loc.help);
		end		-- no correct command was found
	end
end

	end
end
