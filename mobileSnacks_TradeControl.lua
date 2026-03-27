function mobileSnacks_ResetRegistratedChars()
	--mS_CharDatas.RegisterChars={}; 
	mS_Temp.RegUser = { 
		[0] = { ["name"]="empty",  ["trades"]=0 } 
	};	
	mobileSnacksVerbose(0," TradeList resetted");	
end


function mobileSnacks_TradeControl_Update()
	mobileSnacksTradeControlRaid:SetChecked(mS_CharDatas.Raid)
	mobileSnacksTradeControlGuild:SetChecked(mS_CharDatas.Guild)
	mobileSnacksTradeControlLevel:SetChecked(mS_CharDatas.LevelCheck)
	mobileSnacksTradeControlAccept:SetChecked(mS_CharDatas.AutoAccept)
	mobileSnacksTradeControlLevelMin:SetValue(mS_CharDatas.LevelValue)
	mobileSnacksTradeControlRegister:SetChecked(mS_CharDatas.RegisterCheck)
	mobileSnacksTradeControlRegisterMaxTrades:SetValue(mS_CharDatas.RegisterValue)
	
	if (mS_CharDatas.BanlistActive) then
		mobileSnacksTradeControlBans:SetChecked(1)
		mobileSnacksTradeControlBanlistBtn:Enable()
	else
		mobileSnacksTradeControlBans:SetChecked(0)
		mobileSnacksTradeControlBanlistBtn:Disable()
	end
	
	if ( mS_CharDatas.LevelCheck ) then
		mobileSnacksTradeControlLevelMin:Show()
	else
		mobileSnacksTradeControlLevelMin:Hide()
	end
	
	if (mobileSnacksTradeControlRaid:GetChecked()) then
		mobileSnacksTradeControlGuild:Show()
	else
		mobileSnacksTradeControlGuild:Hide()
	end
	
	if ( mS_CharDatas.RegisterCheck ) then
		mobileSnacksTradeControlRegister:SetChecked(1)
		mobileSnacksTradeControlRegisterMaxTrades:Show()
		mobileSnacksTradeControlRegisterReset:Show()
	else
		mobileSnacksTradeControlRegister:SetChecked(0)
		mobileSnacksTradeControlRegisterMaxTrades:Hide()
		mobileSnacksTradeControlRegisterReset:Hide()
	end
end
