--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.6) ~  Much Love, Ferib 

]]--

local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 79) then
			local FlatIdent_6AEED = 0;
			while true do
				if (FlatIdent_6AEED == 0) then
					repeatNext = StrToNumber(Sub(byte, 1, 1));
					return "";
				end
			end
		else
			local FlatIdent_76979 = 0;
			local a;
			while true do
				if (FlatIdent_76979 == 0) then
					a = Char(StrToNumber(byte, 16));
					if repeatNext then
						local FlatIdent_5E109 = 0;
						local b;
						while true do
							if (FlatIdent_5E109 == 0) then
								b = Rep(a, repeatNext);
								repeatNext = nil;
								FlatIdent_5E109 = 1;
							end
							if (FlatIdent_5E109 == 1) then
								return b;
							end
						end
					else
						return a;
					end
					break;
				end
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local FlatIdent_69270 = 0;
			local Res;
			while true do
				if (FlatIdent_69270 == 0) then
					Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
					return Res - (Res % 1);
				end
			end
		else
			local Plc = 2 ^ (Start - 1);
			return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local FlatIdent_6D4CB = 0;
		local a;
		local b;
		while true do
			if (FlatIdent_6D4CB == 1) then
				return (b * 256) + a;
			end
			if (FlatIdent_6D4CB == 0) then
				a, b = Byte(ByteString, DIP, DIP + 2);
				DIP = DIP + 2;
				FlatIdent_6D4CB = 1;
			end
		end
	end
	local function gBits32()
		local FlatIdent_15A17 = 0;
		local a;
		local b;
		local c;
		local d;
		while true do
			if (FlatIdent_15A17 == 1) then
				return (d * 16777216) + (c * 65536) + (b * 256) + a;
			end
			if (FlatIdent_15A17 == 0) then
				a, b, c, d = Byte(ByteString, DIP, DIP + 3);
				DIP = DIP + 4;
				FlatIdent_15A17 = 1;
			end
		end
	end
	local function gFloat()
		local FlatIdent_44603 = 0;
		local Left;
		local Right;
		local IsNormal;
		local Mantissa;
		local Exponent;
		local Sign;
		while true do
			if (FlatIdent_44603 == 0) then
				Left = gBits32();
				Right = gBits32();
				FlatIdent_44603 = 1;
			end
			if (2 == FlatIdent_44603) then
				Exponent = gBit(Right, 21, 31);
				Sign = ((gBit(Right, 32) == 1) and -1) or 1;
				FlatIdent_44603 = 3;
			end
			if (FlatIdent_44603 == 3) then
				if (Exponent == 0) then
					if (Mantissa == 0) then
						return Sign * 0;
					else
						Exponent = 1;
						IsNormal = 0;
					end
				elseif (Exponent == 2047) then
					return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
				end
				return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
			end
			if (FlatIdent_44603 == 1) then
				IsNormal = 1;
				Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
				FlatIdent_44603 = 2;
			end
		end
	end
	local function gString(Len)
		local Str;
		if not Len then
			Len = gBits32();
			if (Len == 0) then
				return "";
			end
		end
		Str = Sub(ByteString, DIP, (DIP + Len) - 1);
		DIP = DIP + Len;
		local FStr = {};
		for Idx = 1, #Str do
			FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
		end
		return Concat(FStr);
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local Instrs = {};
		local Functions = {};
		local Lines = {};
		local Chunk = {Instrs,Functions,nil,Lines};
		local ConstCount = gBits32();
		local Consts = {};
		for Idx = 1, ConstCount do
			local FlatIdent_43626 = 0;
			local Type;
			local Cons;
			while true do
				if (FlatIdent_43626 == 1) then
					if (Type == 1) then
						Cons = gBits8() ~= 0;
					elseif (Type == 2) then
						Cons = gFloat();
					elseif (Type == 3) then
						Cons = gString();
					end
					Consts[Idx] = Cons;
					break;
				end
				if (0 == FlatIdent_43626) then
					Type = gBits8();
					Cons = nil;
					FlatIdent_43626 = 1;
				end
			end
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local Descriptor = gBits8();
			if (gBit(Descriptor, 1, 1) == 0) then
				local FlatIdent_8FBAE = 0;
				local Type;
				local Mask;
				local Inst;
				while true do
					if (FlatIdent_8FBAE == 0) then
						Type = gBit(Descriptor, 2, 3);
						Mask = gBit(Descriptor, 4, 6);
						FlatIdent_8FBAE = 1;
					end
					if (FlatIdent_8FBAE == 3) then
						if (gBit(Mask, 3, 3) == 1) then
							Inst[4] = Consts[Inst[4]];
						end
						Instrs[Idx] = Inst;
						break;
					end
					if (FlatIdent_8FBAE == 2) then
						if (gBit(Mask, 1, 1) == 1) then
							Inst[2] = Consts[Inst[2]];
						end
						if (gBit(Mask, 2, 2) == 1) then
							Inst[3] = Consts[Inst[3]];
						end
						FlatIdent_8FBAE = 3;
					end
					if (FlatIdent_8FBAE == 1) then
						Inst = {gBits16(),gBits16(),nil,nil};
						if (Type == 0) then
							local FlatIdent_6E549 = 0;
							while true do
								if (FlatIdent_6E549 == 0) then
									Inst[3] = gBits16();
									Inst[4] = gBits16();
									break;
								end
							end
						elseif (Type == 1) then
							Inst[3] = gBits32();
						elseif (Type == 2) then
							Inst[3] = gBits32() - (2 ^ 16);
						elseif (Type == 3) then
							Inst[3] = gBits32() - (2 ^ 16);
							Inst[4] = gBits16();
						end
						FlatIdent_8FBAE = 2;
					end
				end
			end
		end
		for Idx = 1, gBits32() do
			Functions[Idx - 1] = Deserialize();
		end
		return Chunk;
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				local FlatIdent_60EA1 = 0;
				while true do
					if (FlatIdent_60EA1 == 1) then
						if (Enum <= 20) then
							if (Enum <= 9) then
								if (Enum <= 4) then
									if (Enum <= 1) then
										if (Enum > 0) then
											local Edx;
											local Results, Limit;
											local B;
											local A;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]]();
											VIP = VIP + 1;
											Inst = Instr[VIP];
											do
												return;
											end
										elseif Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									elseif (Enum <= 2) then
										local A = Inst[2];
										Stk[A] = Stk[A]();
									elseif (Enum == 3) then
										local FlatIdent_8F047 = 0;
										local Edx;
										local Results;
										local Limit;
										local B;
										local A;
										while true do
											if (7 == FlatIdent_8F047) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_8F047 = 8;
											end
											if (3 == FlatIdent_8F047) then
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												Top = (Limit + A) - 1;
												Edx = 0;
												FlatIdent_8F047 = 4;
											end
											if (2 == FlatIdent_8F047) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_8F047 = 3;
											end
											if (FlatIdent_8F047 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A]();
												VIP = VIP + 1;
												FlatIdent_8F047 = 6;
											end
											if (FlatIdent_8F047 == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_8F047 = 2;
											end
											if (FlatIdent_8F047 == 6) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_8F047 = 7;
											end
											if (FlatIdent_8F047 == 8) then
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (FlatIdent_8F047 == 0) then
												Edx = nil;
												Results, Limit = nil;
												B = nil;
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_8F047 = 1;
											end
											if (FlatIdent_8F047 == 4) then
												for Idx = A, Top do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
												FlatIdent_8F047 = 5;
											end
										end
									else
										local A;
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									end
								elseif (Enum <= 6) then
									if (Enum > 5) then
										local A = Inst[2];
										local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										local Edx = 0;
										for Idx = A, Top do
											local FlatIdent_99389 = 0;
											while true do
												if (FlatIdent_99389 == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
									else
										local A = Inst[2];
										local Results = {Stk[A](Unpack(Stk, A + 1, Top))};
										local Edx = 0;
										for Idx = A, Inst[4] do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
									end
								elseif (Enum <= 7) then
									local FlatIdent_33DE6 = 0;
									while true do
										if (3 == FlatIdent_33DE6) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_33DE6 = 4;
										end
										if (FlatIdent_33DE6 == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_33DE6 = 2;
										end
										if (FlatIdent_33DE6 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											do
												return;
											end
											break;
										end
										if (2 == FlatIdent_33DE6) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_33DE6 = 3;
										end
										if (FlatIdent_33DE6 == 0) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_33DE6 = 1;
										end
									end
								elseif (Enum > 8) then
									if (Stk[Inst[2]] == Inst[4]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									VIP = Inst[3];
								end
							elseif (Enum <= 14) then
								if (Enum <= 11) then
									if (Enum > 10) then
										Stk[Inst[2]] = Inst[3];
									else
										local A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
									end
								elseif (Enum <= 12) then
									Stk[Inst[2]] = Env[Inst[3]];
								elseif (Enum == 13) then
									local FlatIdent_1E5DB = 0;
									while true do
										if (FlatIdent_1E5DB == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											do
												return;
											end
											break;
										end
										if (FlatIdent_1E5DB == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_1E5DB = 2;
										end
										if (FlatIdent_1E5DB == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_1E5DB = 3;
										end
										if (FlatIdent_1E5DB == 3) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_1E5DB = 4;
										end
										if (FlatIdent_1E5DB == 0) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_1E5DB = 1;
										end
									end
								else
									local B;
									local A;
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
								end
							elseif (Enum <= 17) then
								if (Enum <= 15) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
								elseif (Enum > 16) then
									local FlatIdent_8CEDF = 0;
									local A;
									while true do
										if (FlatIdent_8CEDF == 0) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											break;
										end
									end
								else
									local FlatIdent_7699F = 0;
									local A;
									while true do
										if (FlatIdent_7699F == 0) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
											break;
										end
									end
								end
							elseif (Enum <= 18) then
								local FlatIdent_33EA4 = 0;
								local Results;
								local Edx;
								local Limit;
								local B;
								local A;
								while true do
									if (FlatIdent_33EA4 == 9) then
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_33EA4 == 4) then
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										FlatIdent_33EA4 = 5;
									end
									if (FlatIdent_33EA4 == 7) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results = {Stk[A](Unpack(Stk, A + 1, Top))};
										FlatIdent_33EA4 = 8;
									end
									if (FlatIdent_33EA4 == 0) then
										Results = nil;
										Edx = nil;
										Results, Limit = nil;
										B = nil;
										FlatIdent_33EA4 = 1;
									end
									if (FlatIdent_33EA4 == 5) then
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_33EA4 = 6;
									end
									if (FlatIdent_33EA4 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_33EA4 = 4;
									end
									if (FlatIdent_33EA4 == 1) then
										A = nil;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_33EA4 = 2;
									end
									if (FlatIdent_33EA4 == 2) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_33EA4 = 3;
									end
									if (FlatIdent_33EA4 == 6) then
										Results, Limit = _R(Stk[A](Stk[A + 1]));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										FlatIdent_33EA4 = 7;
									end
									if (FlatIdent_33EA4 == 8) then
										Edx = 0;
										for Idx = A, Inst[4] do
											local FlatIdent_8B7B0 = 0;
											while true do
												if (FlatIdent_8B7B0 == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_33EA4 = 9;
									end
								end
							elseif (Enum == 19) then
								local FlatIdent_2A862 = 0;
								local A;
								local B;
								while true do
									if (FlatIdent_2A862 == 1) then
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										break;
									end
									if (FlatIdent_2A862 == 0) then
										A = Inst[2];
										B = Stk[Inst[3]];
										FlatIdent_2A862 = 1;
									end
								end
							else
								do
									return;
								end
							end
						elseif (Enum <= 30) then
							if (Enum <= 25) then
								if (Enum <= 22) then
									if (Enum > 21) then
										Stk[Inst[2]] = Inst[3] ~= 0;
									else
										local A = Inst[2];
										local Results, Limit = _R(Stk[A](Stk[A + 1]));
										Top = (Limit + A) - 1;
										local Edx = 0;
										for Idx = A, Top do
											local FlatIdent_8B523 = 0;
											while true do
												if (FlatIdent_8B523 == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
									end
								elseif (Enum <= 23) then
									Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
								elseif (Enum > 24) then
									Stk[Inst[2]] = Stk[Inst[3]];
								else
									local FlatIdent_20FB0 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_20FB0 == 7) then
											Stk[Inst[2]] = Inst[3];
											break;
										end
										if (FlatIdent_20FB0 == 4) then
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_20FB0 = 5;
										end
										if (FlatIdent_20FB0 == 5) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_20FB0 = 6;
										end
										if (FlatIdent_20FB0 == 6) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_20FB0 = 7;
										end
										if (0 == FlatIdent_20FB0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Inst[3];
											FlatIdent_20FB0 = 1;
										end
										if (FlatIdent_20FB0 == 3) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_20FB0 = 4;
										end
										if (1 == FlatIdent_20FB0) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_20FB0 = 2;
										end
										if (2 == FlatIdent_20FB0) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_20FB0 = 3;
										end
									end
								end
							elseif (Enum <= 27) then
								if (Enum == 26) then
									local A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
								else
									local Edx;
									local Results, Limit;
									local B;
									local A;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3] ~= 0;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]]();
									VIP = VIP + 1;
									Inst = Instr[VIP];
									do
										return;
									end
								end
							elseif (Enum <= 28) then
								local FlatIdent_466B2 = 0;
								local A;
								while true do
									if (FlatIdent_466B2 == 0) then
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										break;
									end
								end
							elseif (Enum == 29) then
								local FlatIdent_1A54 = 0;
								local Edx;
								local Results;
								local Limit;
								local B;
								local A;
								while true do
									if (FlatIdent_1A54 == 5) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_1A54 = 6;
									end
									if (FlatIdent_1A54 == 2) then
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_1A54 = 3;
									end
									if (FlatIdent_1A54 == 6) then
										Stk[Inst[2]]();
										VIP = VIP + 1;
										Inst = Instr[VIP];
										do
											return;
										end
										break;
									end
									if (FlatIdent_1A54 == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_1A54 = 2;
									end
									if (FlatIdent_1A54 == 0) then
										Edx = nil;
										Results, Limit = nil;
										B = nil;
										A = nil;
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_1A54 = 1;
									end
									if (3 == FlatIdent_1A54) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_1A54 = 4;
									end
									if (FlatIdent_1A54 == 4) then
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										FlatIdent_1A54 = 5;
									end
								end
							else
								local A = Inst[2];
								local C = Inst[4];
								local CB = A + 2;
								local Result = {Stk[A](Stk[A + 1], Stk[CB])};
								for Idx = 1, C do
									Stk[CB + Idx] = Result[Idx];
								end
								local R = Result[1];
								if R then
									local FlatIdent_35C62 = 0;
									while true do
										if (FlatIdent_35C62 == 0) then
											Stk[CB] = R;
											VIP = Inst[3];
											break;
										end
									end
								else
									VIP = VIP + 1;
								end
							end
						elseif (Enum <= 35) then
							if (Enum <= 32) then
								if (Enum > 31) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								else
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								end
							elseif (Enum <= 33) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							elseif (Enum > 34) then
								local FlatIdent_21449 = 0;
								local A;
								while true do
									if (FlatIdent_21449 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_21449 = 4;
									end
									if (FlatIdent_21449 == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_21449 == 0) then
										A = nil;
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_21449 = 1;
									end
									if (FlatIdent_21449 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_21449 = 3;
									end
									if (FlatIdent_21449 == 1) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_21449 = 2;
									end
								end
							else
								local B;
								local A;
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							end
						elseif (Enum <= 38) then
							if (Enum <= 36) then
								Stk[Inst[2]]();
							elseif (Enum > 37) then
								local Results;
								local Edx;
								local Results, Limit;
								local B;
								local A;
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Stk[A + 1]));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results = {Stk[A](Unpack(Stk, A + 1, Top))};
								Edx = 0;
								for Idx = A, Inst[4] do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							elseif (Inst[2] == Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 39) then
							local FlatIdent_5431F = 0;
							local A;
							while true do
								if (FlatIdent_5431F == 0) then
									A = nil;
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									FlatIdent_5431F = 1;
								end
								if (FlatIdent_5431F == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_5431F = 4;
								end
								if (2 == FlatIdent_5431F) then
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]]();
									FlatIdent_5431F = 3;
								end
								if (4 == FlatIdent_5431F) then
									Inst = Instr[VIP];
									VIP = Inst[3];
									break;
								end
								if (FlatIdent_5431F == 1) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_5431F = 2;
								end
							end
						elseif (Enum > 40) then
							for Idx = Inst[2], Inst[3] do
								Stk[Idx] = nil;
							end
						else
							local Edx;
							local Results, Limit;
							local B;
							local A;
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3] ~= 0;
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
							Top = (Limit + A) - 1;
							Edx = 0;
							for Idx = A, Top do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]]();
							VIP = VIP + 1;
							Inst = Instr[VIP];
							do
								return;
							end
						end
						VIP = VIP + 1;
						break;
					end
					if (FlatIdent_60EA1 == 0) then
						Inst = Instr[VIP];
						Enum = Inst[1];
						FlatIdent_60EA1 = 1;
					end
				end
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!2B3O00028O00027O0040026O00F03F03093O004E6577536C6964657203093O0057616C6B53702O656403053O0030202B2030026O006040026O003040026O00084003063O004E657754616203093O00436861726163746572030A3O004E657753656374696F6E03023O004F5003093O004E657742752O746F6E030B3O00536B697020546F20456E64030D3O00546F776572204F662048652O6C030D3O0047657420412O6C204974656D73026O00144003053O004F74686572030C3O004175746F20436C69636B657203083O00416E792047616D65030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403483O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F7848657074632F4B61766F2D55492D4C6962726172792F6D61696E2F736F757263652E6C756103093O004372656174654C6962030A3O005374617475657761726503093O004461726B5468656D6503043O004D61696E03093O004A756D70506F77657203053O0032202B2034025O00407F40026O0049402O033O00466C7903073O006E6F7468696E6703083O004E65774C6162656C03093O005574696C6974696573026O00104003113O004354524C202B20434C49434B203D20545003043O0054502O2103083O00494E46204A554D50030D3O005350414D20535041434542415203063O004F746865727300923O00120B3O00014O0029000100083O0026093O001C000100020004083O001C000100120B000900013O000E2500030010000100090004083O00100001002013000A0006000400120B000C00053O00120B000D00063O00120B000E00073O00120B000F00083O00021700106O000A000A0010000100120B3O00093O0004083O001C000100260900090005000100010004083O00050001002013000A0002000A001222000C000B6O000A000C00024O0005000A3O00202O000A0005000C00122O000C000B6O000A000C00024O0006000A3O00122O000900033O00044O000500010026093O0035000100030004083O0035000100120B000900013O0026090009002B000100010004083O002B0001002013000A0003000C001218000C000D6O000A000C00024O0004000A3O00202O000A0004000E00122O000C000F3O00122O000D00103O000217000E00014O000A000A000E000100120B000900033O0026090009001F000100030004083O001F0001002013000A0004000E00120B000C00113O00120B000D00103O000217000E00024O000A000A000E000100120B3O00023O0004083O003500010004083O001F00010026093O0041000100120004083O0041000100201300090007000C001218000B00136O0009000B00024O000800093O00202O00090008000E00122O000B00143O00122O000C00153O000217000D00034O000A0009000D00010004083O009100010026093O005D000100010004083O005D000100120B000900013O00260900090054000100010004083O0054000100120C000A00163O001203000B00173O00202O000B000B001800122O000D00196O000B000D6O000A3O00024O000A000100024O0001000A3O00202O000A0001001A00122O000B001B3O00122O000C001C4O0011000A000C00022O00190002000A3O00120B000900033O00260900090044000100030004083O00440001002013000A0002000A001223000C001D6O000A000C00024O0003000A3O00124O00033O00044O005D00010004083O004400010026093O0077000100090004083O0077000100120B000900013O0026090009006F000100010004083O006F0001002013000A0006000400120B000C001E3O00120B000D001F3O00120B000E00203O00120B000F00213O000217001000044O000A000A00100001002013000A0006000E00120B000C00223O00120B000D00233O000217000E00054O000A000A000E000100120B000900033O00260900090060000100030004083O00600001002013000A0006002400120B000C00254O000A000A000C000100120B3O00263O0004083O007700010004083O006000010026093O0002000100260004083O0002000100120B000900013O00260900090087000100010004083O00870001002013000A0006000E00120B000C00273O00120B000D00283O000217000E00064O000A000A000E0001002013000A0006000E00120B000C00293O00120B000D002A3O000217000E00074O000A000A000E000100120B000900033O0026090009007A000100030004083O007A0001002013000A0002000A001223000C002B6O000A000C00024O0007000A3O00124O00123O00044O000200010004083O007A00010004083O000200012O00143O00013O00083O00063O0003043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C6179657203093O0043686172616374657203083O0048756D616E6F696403093O0057616C6B53702O656401073O001207000100013O00202O00010001000200202O00010001000300202O00010001000400202O00010001000500102O000100068O00017O000D3O00028O00026O00F03F03093O00436861726163746572030E3O0046696E6446697273744368696C6403103O0048756D616E6F6964522O6F745061727403063O00434672616D6503043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C6179657203093O00576F726B737061636503053O00746F77657203083O0066696E697368657303063O0046696E69736800393O00120B3O00014O0029000100033O0026093O0032000100020004083O003200012O0029000300033O0026090001001D000100020004083O001D000100062O0002003800013O0004083O0038000100062O0003003800013O0004083O0038000100120B000400014O0029000500053O0026090004000D000100010004083O000D000100202100050002000300062O0005003800013O0004083O0038000100201300060005000400120B000800054O001100060008000200062O0006003800013O0004083O0038000100202100060005000500202100070003000600101F0006000600070004083O003800010004083O000D00010004083O0038000100260900010005000100010004083O0005000100120B000400013O0026090004002B000100010004083O002B000100120C000500073O00200F00050005000800202O00020005000900122O000500073O00202O00050005000A00202O00050005000B00202O00050005000C00202O00030005000D00122O000400023O00260900040020000100020004083O0020000100120B000100023O0004083O000500010004083O002000010004083O000500010004083O00380001000E250001000200013O0004083O0002000100120B000100014O0029000200023O00120B3O00023O0004083O000200012O00143O00017O00103O00028O00026O00F03F03053O00706169727303043O0067616D6503113O005265706C69636174656453746F7261676503043O0047656172030E3O0047657444657363656E64616E74732O033O0049734103043O00542O6F6C03053O00436C6F6E6503043O007761697403063O00506172656E7403073O00506C6179657273030B3O004C6F63616C506C6179657203083O004261636B7061636B03073O0044657374726F7900473O00120B3O00013O0026093O002E000100020004083O002E000100120C000100033O001226000200043O00202O00020002000500202O00020002000600202O0002000200074O000200036O00013O000300044O002B000100201300060005000800120B000800094O001100060008000200062O0006002B00013O0004083O002B000100120B000600014O0029000700073O00260900060022000100010004083O0022000100120B000800013O00260900080019000100020004083O0019000100120B000600023O0004083O0022000100260900080015000100010004083O0015000100201300090005000A2O00270009000200024O000700093O00122O0009000B6O00090001000100122O000800023O00044O00150001000E2500020012000100060004083O0012000100120C000800043O002O2000080008000D00202O00080008000E00202O00080008000F00102O0007000C000800044O002B00010004083O0012000100061E0001000B000100020004083O000B00010004083O004600010026093O0001000100010004083O0001000100120C000100033O002O12000200043O00202O00020002000D00202O00020002000E00202O00020002000F00202O0002000200074O000200036O00013O000300044O0040000100201300060005000800120B000800094O001100060008000200062O0006004000013O0004083O004000010020130006000500102O001C00060002000100061E00010039000100020004083O0039000100120C0001000B4O002400010001000100120B3O00023O0004083O000100012O00143O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403213O00682O7470733A2O2F706173746562696E2E636F6D2F7261772F694452786744315400083O00121D3O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00063O0003043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C6179657203093O0043686172616374657203083O0048756D616E6F696403093O004A756D70506F77657201073O001207000100013O00202O00010001000200202O00010001000300202O00010001000400202O00010001000500102O000100068O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403213O00682O7470733A2O2F706173746562696E2E636F6D2F7261772F4B744C4B6362787200093O0012013O00013O00122O000100023O00202O00010001000300122O000300046O000400016O000100049O0000026O000100016O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403213O00682O7470733A2O2F706173746562696E2E636F6D2F7261772F5068714C6A62563900093O0012013O00013O00122O000100023O00202O00010001000300122O000300046O000400016O000100049O0000026O000100016O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403213O00682O7470733A2O2F706173746562696E2E636F6D2F7261772F704479315275304A00093O0012013O00013O00122O000100023O00202O00010001000300122O000300046O000400016O000100049O0000026O000100016O00017O00", GetFEnv(), ...);