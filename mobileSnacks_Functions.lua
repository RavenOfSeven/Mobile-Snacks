-- LOAD LOCALISATION
if (GetLocale()=="deDE") then
	mobileSnacks_GetGerman()
elseif (GetLocale()=="zhCN") then
	mobileSnacks_GetChinese()
elseif (GetLocale()=="frFR") then
	mobileSnacks_GetFrench()
elseif (GetLocale()=="ruRU") then
	mobileSnacks_GetRussian()
else mobileSnacks_GetEnglish()
end


function mobileSnacksVerbose(level, text)
	local temp=0;
	if (mS_GlobalDatas.Verbose) then	temp = mS_GlobalDatas.Verbose	end
    if (temp>=level) then
		DEFAULT_CHAT_FRAME:AddMessage(mobileSnacks_ProgName..": "..text)
	end
end


function mobileSnacksMessage(channel, message)
	channel = strupper(channel)
	if (channel=="WHISPER") then
		SendChatMessage(message, "WHISPER", mS_Loc[UnitFactionGroup("player")], mS_Temp.Target.Name)
	elseif (channel=="RAID" or channel=="PARTY" or channel=="GUILD" or channel=="YELL" or channel=="SAY") then
		SendChatMessage(message, channel);
	else
		mobileSnacksVerbose(0,"Error: cannot use channel '"..channel.."'") 
	end
end


function mobileSnacksPlaySound(frame)
	if (frame:GetFrameType()=="Button") then
		PlaySound("GAMEGENERICBUTTONPRESS")
	elseif (frame:GetFrameType()=="CheckButton") then
		if ( frame:GetChecked() ) then
			PlaySound("igMainMenuOptionCheckBoxOn");
		else
			PlaySound("igMainMenuOptionCheckBoxOff");
		end
	end
end



function mobileSnacksDrawTooltip(textfield)
	local i=0;
	GameTooltip:AddLine("|cFFFFFFFF"..textfield[i]);
	for i=1,table.getn(textfield) do
		GameTooltip:AddLine(textfield[i]);
	end						
	GameTooltip:Show();	
end

function mobileSnacksSetTooltipPosition(frame,mx,my)
	local lx,ly = frame:GetCenter();
	local px, py = UIParent:GetCenter();
	local pos, korrX, korrY = "ANCHOR_",1,1;
	if (ly>py) then pos=pos.."BOTTOM";             else  korrY=-1; 			end
	if (lx>px) then pos=pos.."LEFT";   korrX=-1;   else  pos=pos.."RIGHT";	end
	GameTooltip:SetOwner(frame,pos,mx*korrX,my*korrY);	
end


function mobileSnacks_Print(textfield)
	table.foreach(textfield, function(k,v) DEFAULT_CHAT_FRAME:AddMessage(v) end)
end

-- Hooked Function to check, if the PLAYER or the CLIENT has initiated the trade!
-- this is triggered BEFORE the event TradeShow gets fired
local OldInitiateTrade = InitiateTrade;
function InitiateTrade(UnitID)
	mobileSnacksVerbose(1,"Trade Started - triggered by hooked Function: InitiateTrade");
	mS_Temp.InitiateTrade=true;
	OldInitiateTrade(UnitID)
end

local OldBeginTrade = BeginTrade;
function BeginTrade()
	mobileSnacksVerbose(1,"Trade Started - triggered by hooked Function: BeginTrade");
	mS_Temp.InitiateTrade=true;
	OldBeginTrade()
end


function mobileSnacksUpdateMoney()
	mS_CharDatas.profile[mS_CharDatas.ActualRack][mS_CharDatas.ActualProfile].Charge = MoneyInputFrame_GetCopper(mobileSnacksMoneyFrame)
end


function mobileSnacksSplitMoney(money)
	local gold = floor(money / (COPPER_PER_GOLD))
	local silver = floor((money - (gold * COPPER_PER_GOLD)) / COPPER_PER_SILVER)
	local copper = mod(money, COPPER_PER_SILVER)
	return gold, silver, copper
end



function mS_isBlocked(a,b,c,d)
	local i,j=1,1;
	for i=1, table.getn(c) do
		if (a==c[i]) then
			for j=1,table.getn(d) do
				if (b==d[j]) then return true  end
			end
		end
	end
	return false
end



-- this function searches for an Item/Stack of items...   and returns the IDs, if it could be found
function mobileSnacksCompile(slotID)
	if (mS_Temp.Slot[slotID].itemLink == nil) then
		return "deadlink",nil
	end
	
	local configItemLink = mS_Temp.Slot[slotID].itemLink
	local configItemCount = mS_Temp.Slot[slotID].itemCount
	
	if (configItemLink) then mobileSnacksVerbose(1,"mobileSnacksCompile: looking for: "..configItemLink) end
	mobileSnacksVerbose(2,"mobileSnacksCompile: first round")

	-- first we look for complete stacks
	for cID=0,4 do
		mobileSnacksVerbose(3,"mobileSnacksCompile: "..GetContainerNumSlots(cID).." slots in bag "..cID)
		if (GetContainerNumSlots(cID) > 0) then
			for sID=1,GetContainerNumSlots(cID) do
				if (not mS_isBlocked(cID, sID, mS_Temp.BlockedIDs[1], mS_Temp.BlockedIDs[2])) then
					local itemLink = GetContainerItemLink(cID, sID)
					local _, itemCount, itemLocked = GetContainerItemInfo(cID, sID)

					if (mobileSnacksLink(itemLink) == mobileSnacksLink(configItemLink) and not itemLocked) then
						if (itemCount) then mobileSnacksVerbose(2,"mobileSnacksCompile: found item: itemCount: "..itemCount) end
						if (itemCount == configItemCount) then
							mobileSnacksVerbose(3,"mobileSnacksCompile: found in first round in "..cID.."/"..sID)
							return cID, sID
						end
					end
				end
			end
		end
	end
	
	-- there is no complete stack, we have to compile one
	-- first we have to find a free bag slot
	local _cID, _sID = mobileSnacksFreeSlot()
	if (_cID == nil) then
		mobileSnacksVerbose(2,"mobileSnacksCompile: no free slots")
		return nil, nil
	end
	
	mobileSnacksVerbose(2,"mobileSnacksCompile: second round, tmp slot is :".._cID.."/".._sID)
	
	local stackCount = 0
	local stackFound = false
	for cID=0,4 do
		for sID=1,GetContainerNumSlots(cID) do
			if ((cID ~= _cID or sID ~= _sID) and not mS_isBlocked(cID, sID, mS_Temp.BlockedIDs[1], mS_Temp.BlockedIDs[2])) then
				local itemLink = GetContainerItemLink(cID, sID)
				local _, itemCount, itemLocked = GetContainerItemInfo(cID, sID)
			
				if (mobileSnacksLink(itemLink) == mobileSnacksLink(configItemLink) and not itemLocked) then
					stackFound = true
					local missingCount = configItemCount - stackCount
					local splitCount = math.min(missingCount, itemCount)
					mobileSnacksVerbose(3,"mobileSnacksCompile: second round found item: missingCount: "..missingCount..", itemCount: "..itemCount)
					SplitContainerItem(cID, sID, splitCount)
					PickupContainerItem(_cID, _sID)
					
					stackCount = stackCount + splitCount
					mobileSnacksVerbose(3,"mobileSnacksCompile: added "..splitCount.." items to temp stack, now we have "..stackCount)
				
					-- if we have compiled the stack... return
					if (stackCount == configItemCount) then
						mobileSnacksVerbose(2,"mobileSnacksCompile: finished second round")
						return _cID, _sID
					end
				end
			end	
		end
	end
	
	if (stackFound) then
		mobileSnacksVerbose(1,"mobileSnacksCompile: returning temp stack")
		return _cID, _sID
	else
		mobileSnacksVerbose(1,"mobileSnacksCompile: nothing found")
		return nil
	end
end




function mobileSnacksTradeControlChecker(mobileSnacksClient)
	if (mobileSnacksClient.Name==nil or mobileSnacksClient.Name=="map-bug") then
		if (WorldMapFrame:IsVisible()) then 
			mobileSnacksVerbose(0,ms_Loc.MapBugMessage);
			ToggleWorldMap(); 
			mobileSnacksVerbose(1, " Map closed to avoid more bugs... ");
		else
			mobileSnacksVerbose(1, " Error: could not collect any Datas... Maybe it was a LAG.   :(");
		end
		return false;
	end
	
	
	if (UnitInRaid("player")) then
		if (UnitInRaid("NPC")) then			mobileSnacksClient.Raid = "IsMember";
		else								mobileSnacksClient.Raid = "NotMember";			end
	else 									
		if (UnitInParty("player")) then
			if (UnitInParty("NPC")) then	mobileSnacksClient.Raid = "IsMember";
			else							mobileSnacksClient.Raid = "NotMember";			end
		else 								mobileSnacksClient.Raid = "SinglePlayer"; 		end
	end
			
	local guildName,  guildRankName,  guildRankIndex = GetGuildInfo("player");
	local guildName2, guildRankName2, guildRankIndex2 = GetGuildInfo("NPC");
		
	if (guildName==guildName2) then
		 mobileSnacksClient.Guild = "IsMember";
	else mobileSnacksClient.Guild = "NotMember"; end
	
	if (mobileSnacksClient.Raid=="IsMember" or mobileSnacksClient.Guild=="IsMember") then mS_Temp.isInsider=true; end
	
	if (mS_CharDatas.ClientInfos) then
		local guildName3 = "";
		if (guildName2~=nil) then guildName3 = "<"..guildName2.."> ";	end
		if (not mobileSnacksClient.Class) then targetClass="" end
		DEFAULT_CHAT_FRAME:AddMessage(mS_Loc.Opposite.." "..mobileSnacksClient.Name.." "..guildName3.." -  "..mobileSnacksClient.Class.." Level "..mobileSnacksClient.Level,1,1,0);
	else
		mobileSnacksVerbose(1,"Clients Name = "..mobileSnacksClient.Name);
		mobileSnacksVerbose(1,"Clients Level = "..mobileSnacksClient.Level);
		mobileSnacksVerbose(1,"Clients Class = "..mobileSnacksClient.Class);
		mobileSnacksVerbose(1,"Group/Party = "..mobileSnacksClient.Raid);
		mobileSnacksVerbose(1,"your Guild = "..mobileSnacksClient.Guild);
	end
	
	if (mS_CharDatas.Raid and mobileSnacksClient.Raid=="NotMember") then 
		if (mS_CharDatas.Guild) then
			if (mobileSnacksClient.Guild=="NotMember") then
				mobileSnacksMessage("WHISPER",mS_GlobalDatas.whisper[8])
				return false;
			end
		else
			mobileSnacksMessage("WHISPER",mS_GlobalDatas.whisper[8])
			return false;
		end
	end
	
	if (mS_CharDatas.LevelCheck and mobileSnacksClient.Level<mS_CharDatas.LevelValue) then 
		mobileSnacksMessage("WHISPER",mS_GlobalDatas.whisper[6])
		return false; 
	end
	
	mobileSnacksClient.Class=mobileSnacksClient.EnglishClass;

	local trades=mobileSnacksClientTrades(mobileSnacksClient.Name);
	if (trades>=1 and trades+1>mS_CharDatas.RegisterValue) then 
		mobileSnacksMessage("WHISPER",mS_GlobalDatas.whisper[9])
		return false
	end
	
	if (mS_CharDatas.BanlistActive and mS_GlobalDatas.Bannlist and table.getn(mS_GlobalDatas.Bannlist)>0) then
		local found=false;
		table.foreach(mS_GlobalDatas.Bannlist, function(k,v) if (strlower(v)==strlower(mobileSnacksClient.Name)) then	found=true;	end; end)
		if (found) then
			mobileSnacksMessage("WHISPER",mS_GlobalDatas.whisper[10])
			return false;
		end
	end
	
	return true;
end



function mobileSnacksClientTrades(name)
	if (not mS_CharDatas.RegisterCheck) then return 0  end
	if (name == "map-bug" ) then return 0  end
	local i=0
	local index=nil;
	while (mS_Temp.RegUser[i]~=nil) do
		if (mS_Temp.RegUser[i].name == name) then
			mobileSnacksVerbose(2,"Registred Player found at index "..i.." is: "..mS_Temp.RegUser[i].name);
			index=i;
		end
		i=i+1;
	end
	
	if (index==nil) then 
		mobileSnacksVerbose(1,name.." not registrated!");
		return 0
	else	
		mobileSnacksVerbose(1,name.." found with "..mS_Temp.RegUser[index].trades.." trades");	
		return mS_Temp.RegUser[index].trades
	end
end




function mobileSnacksAccept()
	mobileSnacksVerbose(1,"mobileSnacksAccept: Triggered")
	if (mS_Temp.tradeCharge and mS_Temp.tradeCharge > 0) then
		local recipientMoney = GetTargetTradeMoney()
		if (recipientMoney >= mS_Temp.tradeCharge) then
			mS_Temp.tradeState = nil
			AcceptTrade()
			
			if (mS_Temp.tradeData) then
				mS_Temp.tradeData = nil
				mS_Temp.isEnabled = false
				mobileSnacksUpdate()
				mobileSnacks_OSD_buttons()
			end
		else
			local gold, silver, copper = mobileSnacksSplitMoney(mS_Temp.tradeCharge)
			mobileSnacksMessage("WHISPER",mS_GlobalDatas.whisper[5].." "..gold.."g "..silver.."s "..copper.."c")
		end
	else
		mS_Temp.tradeState = nil
		AcceptTrade()
		
		if (mS_Temp.tradeData) then
			mS_Temp.tradeData = nil
			mS_Temp.isEnabled = false
			mobileSnacksUpdate()
			mobileSnacks_OSD_buttons()
		end
	end
end


function mobileSnacksFreeSlot()
	for cID=0,4 do
		for sID=1,GetContainerNumSlots(cID) do
			local itemLink = GetContainerItemLink(cID, sID)
			if (itemLink == nil) then
				return cID, sID
			end
		end
	end
	return nil
end

function mobileSnacksLink(itemLink)
	if (itemLink) then
		local _, _, itemID, itemEnchant, randomProperty, uniqueID, itemName = string.find(itemLink, "|Hitem:(%d+):(%d+):(%d+):(%d+)|h[[]([^]]+)[]]|h")
		return tonumber(itemID or 0), tonumber(randomProperty or 0), tonumber(itemEnchant or 0), tonumber(uniqueID or 0), itemName
	else
		return nil
	end
end



function mobileSnacksCompileProfile()
	if (not mS_Temp.Target.Name) then return false end
	local actualID=1;
	local i;
	mS_Temp.tradeCharge = 0;
	local getprofile = {
		["WARRIOR"] = {	[1]=2, [2]=11},
		["ROGUE"]	= { [1]=3, [2]=11},
		["HUNTER"]	= { [1]=4, [2]=12},
		["WARLOCK"]	= { [1]=5, [2]=12},
		["MAGE"]	= { [1]=6, [2]=12},
		["DRUID"]	= { [1]=7, [2]=13},
		["PRIEST"]	= { [1]=8, [2]=13},
		["PALADIN"] = { [1]=9, [2]=13},
		["SHAMAN"]  = { [1]=10, [2]=13}
	};
	mS_Temp.Slot={
		[1]={}, [2]={}, [3]={}, [4]={}, [5]={}, [6]={} 
	};

	mS_Temp.Target.EnglishClass = strupper(mS_Temp.Target.EnglishClass);
	mobileSnacksVerbose(1,"Compile the TradeProfiles: All Classes + "..mS_Temp.Target.EnglishClass.." + "..mS_Loc.profile[ getprofile[mS_Temp.Target.EnglishClass][2] ]);
	
	mS_Temp.tradeCharge = mS_CharDatas.profile[mS_CharDatas.ActualRack][1].Charge;	
	for slotID=1,6 do
		if (mS_CharDatas.profile[mS_CharDatas.ActualRack][1][slotID] and mS_CharDatas.profile[mS_CharDatas.ActualRack][1][slotID].itemName) then
			mS_Temp.Slot[actualID] = mS_CharDatas.profile[mS_CharDatas.ActualRack][1][slotID];
			actualID=actualID+1;
		end
	end
	
	local act=getprofile[mS_Temp.Target.EnglishClass][1];
	mobileSnacksVerbose(2, "looking in Profile "..act.." for items")
	mS_Temp.tradeCharge = mS_Temp.tradeCharge + mS_CharDatas.profile[mS_CharDatas.ActualRack][act].Charge;
	for slotID=1,6 do
		if (actualID<=6) then	
			local profile = mS_CharDatas.profile[mS_CharDatas.ActualRack][act][slotID]
			if ( profile and profile.itemName) then
				mS_Temp.Slot[actualID] = profile;
				actualID=actualID+1;
			end
		end
	end
	
	local act=getprofile[mS_Temp.Target.EnglishClass][2];
	mobileSnacksVerbose(2, "looking in Profile "..act.." for items")
	
	mS_Temp.tradeCharge = mS_Temp.tradeCharge + mS_CharDatas.profile[mS_CharDatas.ActualRack][act].Charge;
	for slotID=1,6 do
		if (actualID<=6) then
			local profile = mS_CharDatas.profile[mS_CharDatas.ActualRack][act][slotID];
			if (profile and profile.itemName) then
				mS_Temp.Slot[actualID] = profile;
				actualID=actualID+1;
			end
		end
	end	
	
	if (mS_CharDatas.Free4Guild and mS_Temp.isInsider) then mS_Temp.tradeCharge=0 end;
	actualID=actualID-1;
	mobileSnacksVerbose(1,"Found "..actualID.." items to trade");
	return actualID;
end
