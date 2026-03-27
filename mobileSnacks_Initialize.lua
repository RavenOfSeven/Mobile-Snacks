-- these are used for KeyBindings:
BINDING_HEADER_TRADEDISPENSER=mS_Loc.KeyBindings.header;
BINDING_NAME_TRADEDISPENSER1=mS_Loc.KeyBindings[1];
BINDING_NAME_TRADEDISPENSER2=mS_Loc.KeyBindings[2];
BINDING_NAME_TRADEDISPENSER3=mS_Loc.KeyBindings[3];
BINDING_NAME_TRADEDISPENSER4=mS_Loc.KeyBindings[4];


-- these blocks are used to initialize mobileSnacks. 
if (not mobileSnacksProfileColors) then
	mobileSnacksProfileColors	= {								-- used to colorize the select-profile-buttons
		[1]		= {		["r"] = 1,	["g"] = 1,	["b"] = 1,  	},		-- all classes = white
		[2] 	= {		["r"] = 0.5,["g"] = 0.5,["b"] = 1,		},		-- classes  = light blue
		[3] 	= {		["r"] = 0.5,["g"] = 0.5,["b"] = 1,		},
		[4] 	= {		["r"] = 0.5,["g"] = 0.5,["b"] = 1,		},
		[5] 	= {		["r"] = 0.5,["g"] = 0.5,["b"] = 1,		},
		[6] 	= {		["r"] = 0.5,["g"] = 0.5,["b"] = 1,		},
		[7] 	= {		["r"] = 0.5,["g"] = 0.5,["b"] = 1,		},
		[8] 	= {		["r"] = 0.5,["g"] = 0.5,["b"] = 1,		},
		[9] 	= {		["r"] = 0.5,["g"] = 0.5,["b"] = 1,		},
		[10] 	= {		["r"] = 0.5,["g"] = 0.5,["b"] = 1,		},
		[11] 	= {		["r"] = 1,	["g"] = 0.6,["b"] = 0,		},		-- groups = orange
		[12] 	= {		["r"] = 1,	["g"] = 0.6,["b"] = 0,		},
		[13] 	= {		["r"] = 1,	["g"] = 0.6,["b"] = 0,		},
		[14] 	= {		["r"] = 1,	["g"] = 0,["b"] = 0,		},		-- own usage = red	
	}
end

if (not mobileSnacksRackColor) then 
	mobileSnacksRackColor = {
		[1] =  {
			["text"] = "|cFF00FF00",
			["r"] = 0.65,		["g"]= 1,	["b"] = 0.65,
		},
		[2] = {
			["text"] = "|cFFFFFF33",
			["r"] = 1,		["g"]= 1,	["b"] = 0.33,
		},
		[3] = {
			["text"] = "|cFFFF1100",
			["r"] = 1,		["g"]= 0.7,	["b"] = 0.7,
		},
	}
end


if (not mobileSnacksChannelColors) then 
	mobileSnacksChannelColors = {
		[1] = {		["r"] = 1,  	["g"] = 1,		["b"]=1,		["text"]=mS_Loc.channel.say	},
		[2] = {		["r"] = 1,  	["g"] = 0,		["b"]=0,		["text"]=mS_Loc.channel.yell	},
		[3] = {		["r"] = 1,  	["g"] = 0.5,	["b"]=0,		["text"]=mS_Loc.channel.raid	},
		[4] = {		["r"] = 0.4, 	["g"] = 0.4,	["b"]=1,		["text"]=mS_Loc.channel.party	},
		[5] = {		["r"] = 0.1,  	["g"] = 1,		["b"]=0.1,		["text"]=mS_Loc.channel.guild	},
	}
end

mobileSnacks_MaxBroadcastLength = 30;		-- minutes
mobileSnacks_IsBurningCrusade = false;



if (not mS_Temp) then
	mS_Temp = {}		-- this datafield is used to store all the temporary datas - they should be erased after relog / logout / reloadui
	mS_Temp.Slot = {
		[1]=nil, [2]=nil, [3]=nil, [4]=nil, [5]=nil, [6]=nil
	}
	mS_Temp.Scroll = {	}
	mS_Temp.Scroll.start = 1;
	mS_Temp.RegUser = { 
		[0] = { ["name"]="empty",  ["trades"]=0 }  
	};			
end


if (not mS_GlobalDatas) then 
	mS_GlobalDatas = {}		-- defines an empty datafield
	mS_CharDatas = {}
	mS_CharDatas.OSD={}	
end



function mobileSnacks_OnVariablesLoaded()
	local mS_Name=UnitName("player").." of "..GetRealmName();
	if (mS_Datas~=nil) then
		if (mS_Datas[mS_Name]~=nil) then
			mS_CharDatas = mS_Datas[mS_Name];
			mS_Datas[mS_Name]=nil;
		end
		if (mS_Datas.Verbose~=nil) then 
			mS_GlobalDatas.Verbose = mS_Datas.Verbose;
			mS_Datas.Verbose=nil;
		end
		if (mS_Datas.Bannlist~=nil) then 
			mS_GlobalDatas.Bannlist = mS_Datas.Bannlist;
			mS_Datas.Bannlist=nil;
		end
		if (mS_Datas.whisper~=nil) then 
			mS_GlobalDatas.whisper = mS_Datas.whisper;
			mS_Datas.whisper=nil;
		end
	end
	if (mS_GlobalDatas.dataVersion ~= configDataVersion) then mS_GlobalDatas.dataVersion=configDataVersion; end
	if (not mS_GlobalDatas.Verbose) then mS_GlobalDatas.Verbose=0 end
	if (not mS_GlobalDatas.Bannlist) then mS_GlobalDatas.Bannlist = { } end
	
	if (mS_CharDatas.profile and mS_CharDatas.profile[1] and mS_CharDatas.profile[1]["Charge"]) then
		local i, temp;
		temp = {}
		for i=1,13 do
			temp[i] = {
				["Charge"] = 0,
				[1] = {}, [2] = {},  [3]= {},  [4]={}, [5]={}, [6]={}
			}
		end	
		mS_CharDatas.profile = {
			[1] = mS_CharDatas.profile,
			[2] = temp,
			[3] = temp,
		}
	end
	if (mS_CharDatas.profile and not mS_CharDatas.profile[1][13]) then
		mS_CharDatas.profile[1][14] = {
				["Charge"] = 0,
				[1] = {}, [2] = {},  [3]= {},  [4]={}, [5]={}, [6]={}
			};
		mS_CharDatas.profile[2][14]=mS_CharDatas.profile[1][14];
		mS_CharDatas.profile[3][14]=mS_CharDatas.profile[1][14];
		
		local i=0;
		for i=1,3 do
			mS_CharDatas.profile[i][13]=mS_CharDatas.profile[i][12]
			mS_CharDatas.profile[i][12]=mS_CharDatas.profile[i][11]
			mS_CharDatas.profile[i][11]=mS_CharDatas.profile[i][10]
			mS_CharDatas.profile[i][10]=mS_CharDatas.profile[i][9]
		end
	end
	
		
	if (mS_CharDatas.OSD.g==nil) then
		mS_CharDatas = {}			
		-- set DEFAULT settings
		
		mS_CharDatas.ChannelID=1;
		mS_CharDatas.OSD = {
			["scale"]		= 1,
			["alpha"]		= 1,
			["r"]			= 0,
			["g"]			= 0,
			["b"]			= 0,
			["isEnabled"]	= true,
			["border"]		= true,
			["horiz"]		= false,
			["locked"]		= false,
		};
		mS_CharDatas.TimelimitCheck=true;
		mS_CharDatas.DisplayStockCheck=true;
		mS_CharDatas.Timelimit = 20;
		mS_CharDatas.BanlistActive=false;
		mS_CharDatas.Raid=true;
		mS_CharDatas.Guild=true;
		mS_CharDatas.Free4Guild=true;
		mS_CharDatas.AutoAccept=true;
		mS_CharDatas.ClientInfos=true;
		mS_CharDatas.LevelCheck=true;
		mS_CharDatas.LevelValue=55;
		mS_CharDatas.RegisterCheck=true;
		mS_CharDatas.RegisterValue=1;
		mS_CharDatas.broadcastSlice=math.floor(mobileSnacks_MaxBroadcastLength/2)*60;
		mS_CharDatas.Random=1;
		mS_CharDatas.ActualProfile=1;
		mS_CharDatas.profile = {};
		local i,j;
		for j=1,3 do
			mS_CharDatas.profile[j]={}
			for i=1,14 do
				mS_CharDatas.profile[j][i] = {
					["Charge"] = 0,
					[1] = {}, [2] = {},  [3]= {},  [4]={}, [5]={}, [6]={}
				}
			end			
		end
		
		mS_CharDatas.RndText = {
			[1] = mS_Loc.Broadcast[1],		[2] = mS_Loc.Broadcast[2],
			[3] = mS_Loc.Broadcast[3],		[4] = mS_Loc.Broadcast[4],
			[5] = mS_Loc.Broadcast[4],		[6] = mS_Loc.Broadcast[4],
			[7] = mS_Loc.Broadcast[4],		[8] = mS_Loc.Broadcast[4],
		};
	end
	--for users with Version 0.60 - 0.70
	if (not mS_CharDatas.TimelimitCheck or not mS_CharDatas.Timelimit) then
		mS_CharDatas.TimelimitCheck=false;
		mS_CharDatas.Timelimit = 25;
		mS_CharDatas.BanlistActive=false;
	end
	if (not mS_CharDatas.ActualRack) then mS_CharDatas.ActualRack=1 end
	
	mobileSnacksSettingsOSDscale:SetValue(mS_CharDatas.OSD.scale);
	mobileSnacksSettingsOSDCheck:SetChecked(mS_CharDatas.OSD.isEnabled);
	mobileSnacksSettingsOSDborder:SetChecked(mS_CharDatas.OSD.border);
	mobileSnacksSettingsOSDhoriz:SetChecked(mS_CharDatas.OSD.horiz);
	mobileSnacksSettingsRandom:SetValue(mS_CharDatas.Random);
	mS_CharDatas.OnBroadcastText=nil;
	
	mS_Temp.isEnabled = false;
	mobileSnacksUpdate();
	mobileSnacksSettings_OnUpdate();
	mobileSnacksOSD_OnUpdate();
	mobileSnacks_TradeControl_Update();
	mobileSnacks_EditBoxUpdate();		

	if (not mS_GlobalDatas.whisper) then
		mS_GlobalDatas.whisper={};
		local i;
		for i=1,11 do
			mS_GlobalDatas.whisper[i]=mS_Loc.whisper[i].default;
		end
	end
	if (mS_CharDatas.SoundCheck==nil) then mS_CharDatas.SoundCheck=true end
	if (mS_CharDatas.DisplayStockCheck==nil) then mS_CharDatas.DisplayStockCheck=true end
end
	