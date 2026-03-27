function mobileSnacks_ResetRegistratedChars()
	--tD_CharDatas.RegisterChars={}; 
	tD_Temp.RegUser = { 
		[0] = { ["name"]="empty",  ["trades"]=0 } 
	};	
	mobileSnacksVerbose(0," TradeList resetted");	
end


function mobileSnacks_TradeControl_Update()
	mobileSnacksTradeControlRaid:SetChecked(tD_CharDatas.Raid)
	mobileSnacksTradeControlGuild:SetChecked(tD_CharDatas.Guild)
	mobileSnacksTradeControlLevel:SetChecked(tD_CharDatas.LevelCheck)
	mobileSnacksTradeControlAccept:SetChecked(tD_CharDatas.AutoAccept)
	mobileSnacksTradeControlLevelMin:SetValue(tD_CharDatas.LevelValue)
	mobileSnacksTradeControlRegister:SetChecked(tD_CharDatas.RegisterCheck)
	mobileSnacksTradeControlRegisterMaxTrades:SetValue(tD_CharDatas.RegisterValue)
	
	if (tD_CharDatas.BanlistActive) then
		mobileSnacksTradeControlBans:SetChecked(1)
		mobileSnacksTradeControlBanlistBtn:Enable()
	else
		mobileSnacksTradeControlBans:SetChecked(0)
		mobileSnacksTradeControlBanlistBtn:Disable()
	end
	
	if ( tD_CharDatas.LevelCheck ) then
		mobileSnacksTradeControlLevelMin:Show()
	else
		mobileSnacksTradeControlLevelMin:Hide()
	end
	
	if (mobileSnacksTradeControlRaid:GetChecked()) then
		mobileSnacksTradeControlGuild:Show()
	else
		mobileSnacksTradeControlGuild:Hide()
	end
	
	if ( tD_CharDatas.RegisterCheck ) then
		mobileSnacksTradeControlRegister:SetChecked(1)
		mobileSnacksTradeControlRegisterMaxTrades:Show()
		mobileSnacksTradeControlRegisterReset:Show()
	else
		mobileSnacksTradeControlRegister:SetChecked(0)
		mobileSnacksTradeControlRegisterMaxTrades:Hide()
		mobileSnacksTradeControlRegisterReset:Hide()
	end
end
