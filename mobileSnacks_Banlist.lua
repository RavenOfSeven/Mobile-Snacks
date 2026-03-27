function mobileSnacks_Banlist_OnShow()
	mobileSnacks_Banlist_Update()
	if (UnitIsPlayer("target") and UnitIsFriend("target", "player")) then
		mobileSnacksBanlistName:SetText(UnitName("target"));
	else
		mobileSnacksBanlistName:SetText("");
	end
	if (GetNumIgnores()>0) then
		local i;
		local New = false;
		for	i=1,GetNumIgnores() do
			local j;
			local found = false;
			for j=1,table.getn(tD_GlobalDatas.Bannlist) do
				if (strlower(tD_GlobalDatas.Bannlist[j])==strlower(GetIgnoreName(i))) then
					found=true;
				end
			end
			if (not found) then New=true end
		end
		if (New) then
			mobileSnacksBanlistImport:Enable();
		else
			mobileSnacksBanlistImport:Disable();
		end
	else
		mobileSnacksBanlistImport:Disable();
	end
	mobileSnacksBanlistAdd:Disable();
	mobileSnacksBanlistRemove:Disable();
	mobileSnacks_Banlist_Edit(mobileSnacksBanlistName);
end


function mobileSnacks_Banlist_Update()
	local H = 0;
	if (mobileSnacksSettings and mobileSnacksSettings:IsVisible()) then
		H = 2+mobileSnacksSettingsText:GetHeight()
	end
	mobileSnacksBanlist:SetHeight(346+H);
	mobileSnacksBanlistScrollBkg:SetHeight(206+H);
	mobileSnacksBanlistScrollBar:SetHeight(206+H);
	tD_Temp.Scroll.maxlines = math.floor((206+H)/12.25);
	if (tD_GlobalDatas.Bannlist) then table.sort(tD_GlobalDatas.Bannlist) end
	mobileSnacks_Banlist_Scroll()
end


function mobileSnacks_Banlist_Scroll()
	if (not tD_Temp.Scroll.maxlines) then return end
	if (not tD_GlobalDatas.Bannlist) then 
		mobileSnacksBanlistScrollText:SetText("");
		mobileSnacksBanlistScrollBar:Hide();
		return 
	end
	tD_Temp.Scroll.start = mobileSnacksBanlistScrollBar:GetValue();
	tD_Temp.Scroll.ende = table.getn(tD_GlobalDatas.Bannlist);
	if (tD_Temp.Scroll.ende > tD_Temp.Scroll.maxlines) then
		mobileSnacksBanlistScrollBar:Show();
		mobileSnacksBanlistScrollBar:SetMinMaxValues(1, table.getn(tD_GlobalDatas.Bannlist)-tD_Temp.Scroll.maxlines+1);		
		tD_Temp.Scroll.ende = tD_Temp.Scroll.start + tD_Temp.Scroll.maxlines-1;
	else
		tD_Temp.Scroll.start=1;
		mobileSnacksBanlistScrollBar:Hide();
	end
	
	local temp="";	
	local i;
	for i = tD_Temp.Scroll.start,tD_Temp.Scroll.ende do
		temp=temp.." \n "..tD_GlobalDatas.Bannlist[i];
	end
	mobileSnacksBanlistScrollText:SetText(temp);
	
end


function mobileSnacks_Banlist_Edit(Editbox)
	if (not Editbox) then return end
	if (not tD_Temp.BanListStatus) then tD_Temp.BanListStatus="inactive"; end
	local name = strlower( Editbox:GetText() );
	string.gsub(name," ","");
	if (strlen(name)<1) then
		mobileSnacksBanlistAdd:Disable();
		mobileSnacksBanlistRemove:Disable();
		tD_Temp.BanListStatus="inactive";
	else
		mobileSnacksBanlistAdd:Enable();
		mobileSnacksBanlistRemove:Disable();
		tD_Temp.BanListStatus="add";
		
		if (tD_GlobalDatas.Bannlist) then 
			local j;
			local found = false;
			for j=1,table.getn(tD_GlobalDatas.Bannlist) do
				if (strlower(tD_GlobalDatas.Bannlist[j])==name) then
					found=true;
				end
			end
			if (found) then
				mobileSnacksBanlistAdd:Disable();
				mobileSnacksBanlistRemove:Enable();
				tD_Temp.BanListStatus="remove";
			end
		end
	end
end


function mobileSnacks_Banlist_Remove(name)
	local j;
	local found = 0;
	for j=1,table.getn(tD_GlobalDatas.Bannlist) do
		if (strlower(tD_GlobalDatas.Bannlist[j])==strlower(name)) then
			found=j;
		end
	end
	if (found>0) then
		table.remove(tD_GlobalDatas.Bannlist,found);
		mobileSnacksVerbose(1,"remove index "..found..": Name="..name);
	else
		mobileSnacksVerbose(1,"Name "..name.."  not found");
	end
	mobileSnacksBanlistName:SetText("");
	mobileSnacksBanlistRemove:Disable();
	mobileSnacksBanlistAdd:Disable();
	tD_Temp.BanListStatus="inactive";
	mobileSnacks_Banlist_Scroll()
end

function mobileSnacks_Banlist_Add(name)
	--mobileSnacksVerbose(0,"Add");
	if (name) then
		table.insert(tD_GlobalDatas.Bannlist,name);
		mobileSnacksVerbose(1,"Added Name "..name.." to Banlist");
	end
	table.sort(tD_GlobalDatas.Bannlist)
	mobileSnacksBanlistRemove:Enable();
	mobileSnacksBanlistAdd:Disable();
	tD_Temp.BanListStatus="remove";
	mobileSnacks_Banlist_Scroll()
end


function mobileSnacks_Banlist_Import()
	if (GetNumIgnores()>0) then
		local i;
		for	i=1,GetNumIgnores() do
			local j;
			local found = false;
			for j=1,table.getn(tD_GlobalDatas.Bannlist) do
				if (strlower(tD_GlobalDatas.Bannlist[j])==strlower(GetIgnoreName(i))) then
					found=true;
				end
			end
			if (not found) then 
				table.insert(tD_GlobalDatas.Bannlist,GetIgnoreName(i));
				mobileSnacksVerbose(1,"Added Name "..GetIgnoreName(i).." to Banlist");
			end
		end
	end
	table.sort(tD_GlobalDatas.Bannlist)	
	mobileSnacksBanlistImport:Disable();
	mobileSnacks_Banlist_Scroll()
end
