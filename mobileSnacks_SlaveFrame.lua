function mobileSnacksSlaveOnUpdate()
	local down, up, lag = GetNetStats();
	local LagTimer = floor(lag/1000); 
	if (LagTimer < 0.2) then LagTimer=0.2 end;
	
	if (not mS_Temp.isEnabled) then	return end
	
	if (mS_Temp.broadcastSlice > 0) then
		if (arg1~=nil) then
			mS_Temp.broadcastSlice = mS_Temp.broadcastSlice - arg1
		end
		if (mS_Temp.broadcastSlice < 0) then
			if (UnitAffectingCombat("player")==1) then
				-- player is in combat! mS should not spam its auto-broadcast while fighting some mobs!   (especially bossmobs)     - wait 15sec, and try again!
				mS_Temp.broadcastSlice = 15;
			else
				if (mS_CharDatas.AutoBroadcast) then mobileSnacksBroadcastItems() end
				mS_Temp.broadcastSlice = mS_CharDatas.broadcastSlice
			end
		end
	end
	
	if (arg1~=nil) then
		mS_Temp.timeSlice = mS_Temp.timeSlice - arg1
		
		if (mS_CharDatas.TimelimitCheck and mS_Temp.Countdown) then
			if (mS_Temp.Countdown>0) then 
				mS_Temp.Countdown=mS_Temp.Countdown - arg1; 
				if (math.floor(mS_Temp.Countdown)==11) then
					mobileSnacksMessage("WHISPER", mS_GlobalDatas.whisper[11]);
					mS_Temp.Countdown=mS_Temp.Countdown-1;
				end
				if (math.floor(mS_Temp.Countdown)==0) then
					mS_Temp.Target.Name=nil;
					mS_Temp.tradeState="timeup";
					mobileSnacksVerbose(1,"Timeup, close the trade");
					CloseTrade();
					mS_Temp.Countdown=mS_Temp.Countdown-1;
				end
				--mobileSnacksVerbose(0,"countdown: "..mS_Temp.Countdown);
			end
		end		
	end;
	if (mS_Temp.timeSlice > 0) then 	return end
	
	if (mS_Temp.tradeState == "populate") then
		-- PUT  ITEMS  INTO  THE  TRADE-FRAME
		mS_Temp.timeSlice = LagTimer
		mobileSnacksVerbose(1,"mobileSnacksSlaveOnUpdate: populate")
			
		if (mS_Temp.Slot[mS_Temp.tradeData.slotID]) then
			if (mS_Temp.tradeData.containerLocation == nil) then
				mobileSnacksVerbose(3,"Compile Item "..mS_Temp.tradeData.slotID)
				
				local cID, sID = mobileSnacksCompile(mS_Temp.tradeData.slotID)
				
				if (cID == "deadlink") then
					mobileSnacksVerbose(1,"deadlink")
					mS_Temp.tradeData.containerLocation=nil;
					mS_Temp.timeSlice = LagTimer*4
					mS_Temp.tradeState = "accept"
					mS_Temp.tradeData = false
					return
				elseif (cID==nil) then
					mobileSnacksMessage("WHISPER",mS_GlobalDatas.whisper[4])		-- no items left
					mobileSnacksMessage("SAY",mS_GlobalDatas.whisper[2])
					mS_Temp.timeSlice = LagTimer*4
					mS_Temp.tradeState = "accept"
					mS_Temp.tradeData = true
					return
				else
					mobileSnacksVerbose(2,"mobileSnacksOnUpdate: found container location")
					mS_Temp.tradeData.containerLocation = {}
					mS_Temp.tradeData.containerLocation.cID = cID
					mS_Temp.tradeData.containerLocation.sID = sID
				end
			end
				
			if (mS_Temp.tradeData.containerLocation) then
				local cID = mS_Temp.tradeData.containerLocation.cID
				local sID = mS_Temp.tradeData.containerLocation.sID
				
				local _, itemCount = GetContainerItemInfo(cID, sID)
				PickupContainerItem(cID, sID)
				
				if ( CursorHasItem() ) then
					mobileSnacksVerbose(3,"mobileSnacksSlaveOnUpdate: CursorHasItem()")
					ClickTradeButton(mS_Temp.tradeData.slotID)
					
					if (itemCount ~= mS_Temp.Slot[mS_Temp.tradeData.slotID].itemCount) then
						mobileSnacksMessage("WHISPER",mS_GlobalDatas.whisper[3], "WHISPER")
						mobileSnacksMessage("SAY",mS_GlobalDatas.whisper[2])
						
						mS_Temp.timeSlice = LagTimer*4
						mS_Temp.tradeState = "accept"
						mS_Temp.tradeData = true
						return
					end
					
					mS_Temp.tradeData.slotID = mS_Temp.tradeData.slotID + 1
					mS_Temp.tradeData.containerLocation = nil
					mS_Temp.tradeData.numAttempts = 0
				else
					mS_Temp.tradeData.numAttempts = mS_Temp.tradeData.numAttempts + 1
					if (mS_Temp.tradeData.numAttempts == 32) then
						mobileSnacksVerbose(2,"mobileSnacksOnUpdate: too many attempts")
						mobileSnacksMessage("WHISPER",mS_GlobalDatas.whisper[1]);
						CloseTrade()
						return
					end
				end
			end
		else
			--mobileSnacksVerbose(1,"mobileSnacksSlaveOnUpdate: ID ="..mS_Temp.tradeData.slotID)
			mS_Temp.tradeData.slotID = mS_Temp.tradeData.slotID + 1
			if (mS_Temp.tradeData.slotID >= 7) then
				mS_Temp.tradeState = "accept"
				mS_Temp.timeSlice = LagTimer*4
				mobileSnacksVerbose(1,"mobileSnacksSlaveOnUpdate: DONE")
				mS_Temp.tradeData = false
			end
		end
	elseif (mS_Temp.tradeState == "accept") then
		mS_Temp.timeSlice = 1000
		if (mS_CharDatas.AutoAccept) then mobileSnacksAccept() end
	end
	
end

function mobileSnacksFindItem(item)
	if ( not item ) then return; end
	item = string.lower(ItemLinkToName(item));
	local link;
	for i = 1,23 do
		link = GetInventoryItemLink("player",i);
		if ( link ) then
			if ( item == string.lower(ItemLinkToName(link)) )then
				return i, nil, GetInventoryItemTexture('player', i), GetInventoryItemCount('player', i);
			end
		end
	end
	local count, bag, slot, texture;
	local totalcount = 0;
	for i = 0,NUM_BAG_FRAMES do
		for j = 1,MAX_CONTAINER_ITEMS do
			link = GetContainerItemLink(i,j);
			if ( link ) then
				if ( item == string.lower(ItemLinkToName(link))) then
					bag, slot = i, j;
					texture, count = GetContainerItemInfo(i,j);
					totalcount = totalcount + count;
				end
			end
		end
	end
	return bag, slot, texture, totalcount;
end

function mobileSnacksBroadcastItems()
	if (mS_Temp.isEnabled) then
		
		local mobileSnacksChannel, temp = mobileSnacksGetChannel();
		local waterBag,waterSlot,waterTexture,waterCount 	= mobileSnacksFindItem("Conjured Crystal Water")
		local foodBag,foodSlot,foodTexture,foodCount 		= mobileSnacksFindItem("Conjured Cinnamon Roll")
		if (tradeItems) then mobileSnacksVerbose(1,"tradeItems: "..tradeItems) end
		
		local x = math.random(1, mS_CharDatas.Random);
		local message="";
		if (strlen(mS_CharDatas.RndText[x])<=2) then
				message=mS_Loc.defaultBroadcast;
		else
			message=mS_CharDatas.RndText[x]
			if (mS_CharDatas.DisplayStockCheck and waterCount > 0) then
				local stockStatus = ""
				if (waterCount+foodCount <= 200) then
					stockStatus = "LOW"
				end
				if (waterCount+foodCount > 200) then
					stockStatus = "MEDIUM"
				end
				if (waterCount+foodCount >= 300) then
					stockStatus = "HIGH"
				end

				local waterMessage 		= waterCount.." waters"
				local foodMessage 		= foodCount.." foods"
				local stockStartmessage	= "[Stock "..stockStatus.." : "
				local stockEndmessage	= "]"
				local separatorMessage	= " / "
				
				if (waterCount > 0 or foodCount > 0) then
					message = message .. " " .. stockStartmessage
				end
				if (waterCount > 0) then
					message = message .. waterMessage
				end
				if (waterCount > 0 and foodCount > 0) then
					message = message .. separatorMessage
				end
				if (foodCount > 0) then
					message = message .. foodMessage
				end
				if (waterCount > 0 or foodCount > 0) then
					message = message .. stockEndmessage
				end
			end
		end
		mobileSnacksMessage(mobileSnacksChannel, message)
	end
end


function mobileSnacksGetChannel()
	local Channel="SAY";
	local ChannelLoc=mS_Loc.channel.say;
	if (mS_CharDatas.ChannelID) then
		if (mS_CharDatas.ChannelID==1) then Channel="SAY";  ChannelLoc=mS_Loc.channel.say  end
		if (mS_CharDatas.ChannelID==2) then Channel="YELL"; ChannelLoc=mS_Loc.channel.yell end
		if (mS_CharDatas.ChannelID==3) then --Channel="RAID"; ChannelLoc=mS_Loc.channel.raid 
			if (UnitInRaid("player")==1) 	 then Channel="RAID"; 		ChannelLoc=mS_Loc.channel.raid
			elseif (GetNumPartyMembers()>=1) then Channel="PARTY";	ChannelLoc=mS_Loc.channel.party
			else Channel="SAY"; 	ChannelLoc=mS_Loc.channel.say	end
		end
		if (mS_CharDatas.ChannelID==4) then --Channel="PARTY"; ChannelLoc=mS_Loc.channel.party 
			if ((GetNumPartyMembers()>=1)) then Channel="PARTY";	ChannelLoc=mS_Loc.channel.party 
			else Channel="SAY";		ChannelLoc=mS_Loc.channel.say end
		end
		if (mS_CharDatas.ChannelID==5) then Channel="GUILD";   ChannelLoc=mS_Loc.channel.guild  end
	end
	return Channel, ChannelLoc;
end


function mobileSnacksStartTimelimiter()
	mobileSnacksVerbose(2,"Countdown started: you've got "..mS_CharDatas.Timelimit.." sec to trade")
	mS_Temp.Countdown=mS_CharDatas.Timelimit+2
end


function mobileSnacks_GetBlockedItems_ForOwnUsage()
	mobileSnacksVerbose(1,"mobileSnacksGetBlockedItems: search items for own usage")
	mS_Temp.BlockedIDs={};
	mS_Temp.BlockedIDs[1]={};
	mS_Temp.BlockedIDs[2]={};
	mS_Temp.Slot=mS_CharDatas.profile[mS_CharDatas.ActualRack][14];
	
	local SlotID, count=0,1;
	for SlotID=1,6 do
		if (mS_Temp.Slot[SlotID] and mS_Temp.Slot[SlotID].itemName) then
			mS_Temp.BlockedIDs[1][count], mS_Temp.BlockedIDs[2][count] = mobileSnacksCompile(SlotID)
			count=count+1;
		end
	end
end

