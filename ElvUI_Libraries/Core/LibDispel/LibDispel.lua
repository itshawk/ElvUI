local MAJOR, MINOR = "LibDispel-1.0", 3
assert(LibStub, MAJOR.." requires LibStub")
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

local Retail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local Wrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC

local next = next
local GetCVar, SetCVar = GetCVar, SetCVar
local IsSpellKnownOrOverridesKnown = IsSpellKnownOrOverridesKnown
local IsPlayerSpell = IsPlayerSpell

local DebuffColors = CopyTable(DebuffTypeColor)
lib.DebuffTypeColor = DebuffColors

-- These dont exist in Blizzards color table
DebuffColors.Bleed = { r = 1, g = 0.2, b = 0.6 }
DebuffColors.EnemyNPC = { r = 0.9, g = 0.1, b = 0.1 }
DebuffColors.BadDispel = { r = 0.05, g = 0.85, b = 0.94 }
DebuffColors.Stealable = { r = 0.93, g = 0.91, b = 0.55 }

local DispelList = {} -- List of types the player can dispel
lib.DispelList = DispelList

local BleedList = {} -- Contains spells classified as Bleeds
lib.BleedList = BleedList

local BlockList = {} -- Spells blocked from AuraHighlight
lib.BlockList = BlockList

local BadList = {} -- Spells that backfire when dispelled
lib.BadList = BadList

if Retail then
	-- Bad to dispel spells
	BadList[34914] = "Vampiric Touch"		-- horrifies
	BadList[233490] = "Unstable Affliction"	-- silences

	-- Block spells from AuraHighlight
	BlockList[140546] = "Fully Mutated"
	BlockList[136184] = "Thick Bones"
	BlockList[136186] = "Clear Mind"
	BlockList[136182] = "Improved Synapses"
	BlockList[136180] = "Keen Eyesight"
	BlockList[105171] = "Deep Corruption"
	BlockList[108220] = "Deep Corruption"
	BlockList[116095] = "Disable" -- Slow

	-- Bleed spells updated May 25th 2023 by Simpy for Patch 10.1
	--- Combined lists (without duplicates, filter requiring either main or effect bleed):
	---- Apply Aura> Physical DoT:		https://www.wowhead.com/spells/school:0?filter=29;3;0
	---- Apply Aura> Mechanic Bleeding:	https://www.wowhead.com/spells/mechanic:15?filter=109;6;0

	BleedList[703] = "Garrote"
	BleedList[1079] = "Rip"
	BleedList[1943] = "Rupture"
	BleedList[3147] = "Rend Flesh"
	BleedList[5597] = "Serious Wound"
	BleedList[5598] = "Serious Wound"
	BleedList[8818] = "Garrote"
	BleedList[10266] = "Lung Puncture"
	BleedList[11977] = "Rend"
	BleedList[12054] = "Rend"
	BleedList[13318] = "Rend"
	BleedList[13443] = "Rend"
	BleedList[13445] = "Rend"
	BleedList[13738] = "Rend"
	BleedList[14087] = "Rend"
	BleedList[14118] = "Rend"
	BleedList[14331] = "Vicious Rend"
	BleedList[14874] = "Rupture"
	BleedList[14903] = "Rupture"
	BleedList[15583] = "Rupture"
	BleedList[15976] = "Puncture"
	BleedList[16095] = "Vicious Rend"
	BleedList[16393] = "Rend"
	BleedList[16403] = "Rend"
	BleedList[16406] = "Rend"
	BleedList[16509] = "Rend"
	BleedList[17153] = "Rend"
	BleedList[17504] = "Rend"
	BleedList[18075] = "Rend"
	BleedList[18078] = "Rend"
	BleedList[18106] = "Rend"
	BleedList[18200] = "Rend"
	BleedList[18202] = "Rend"
	BleedList[19771] = "Serrated Bite"
	BleedList[21949] = "Rend"
	BleedList[24192] = "Speed Slash"
	BleedList[24331] = "Rake"
	BleedList[24332] = "Rake"
	BleedList[27555] = "Shred"
	BleedList[27556] = "Rake"
	BleedList[27638] = "Rake"
	BleedList[28913] = "Flesh Rot"
	BleedList[29574] = "Rend"
	BleedList[29578] = "Rend"
	BleedList[29583] = "Impale"
	BleedList[29906] = "Ravage"
	BleedList[29935] = "Gaping Maw"
	BleedList[30285] = "Eagle Claw"
	BleedList[30639] = "Carnivorous Bite"
	BleedList[31041] = "Mangle"
	BleedList[31410] = "Coral Cut"
	BleedList[31956] = "Grievous Wound"
	BleedList[32019] = "Gore"
	BleedList[32901] = "Carnivorous Bite"
	BleedList[33865] = "Singe"
	BleedList[33912] = "Rip"
	BleedList[35144] = "Vicious Rend"
	BleedList[35321] = "Gushing Wound"
	BleedList[36023] = "Deathblow"
	BleedList[36054] = "Deathblow"
	BleedList[36332] = "Rake"
	BleedList[36383] = "Carnivorous Bite"
	BleedList[36590] = "Rip"
	BleedList[36617] = "Gaping Maw"
	BleedList[36789] = "Diminish Soul"
	BleedList[36965] = "Rend"
	BleedList[36991] = "Rend"
	BleedList[37066] = "Garrote"
	BleedList[37487] = "Blood Heal"
	BleedList[37662] = "Rend"
	BleedList[37937] = "Flayed Flesh"
	BleedList[37973] = "Coral Cut"
	BleedList[38056] = "Flesh Rip"
	BleedList[38363] = "Gushing Wound"
	BleedList[38772] = "Grievous Wound"
	BleedList[38801] = "Grievous Wound"
	BleedList[38810] = "Gaping Maw"
	BleedList[38848] = "Diminish Soul"
	BleedList[39198] = "Carnivorous Bite"
	BleedList[39215] = "Gushing Wound"
	BleedList[39382] = "Carnivorous Bite"
	BleedList[40199] = "Flesh Rip"
	BleedList[41092] = "Carnivorous Bite"
	BleedList[41932] = "Carnivorous Bite"
	BleedList[42395] = "Lacerating Slash"
	BleedList[42397] = "Rend Flesh"
	BleedList[42658] = "Sic'em!"
	BleedList[43093] = "Grievous Throw"
	BleedList[43104] = "Deep Wound"
	BleedList[43153] = "Lynx Rush"
	BleedList[43246] = "Rend"
	BleedList[43931] = "Rend"
	BleedList[43937] = "Grievous Wound"
	BleedList[48130] = "Gore"
	BleedList[48261] = "Impale"
	BleedList[48286] = "Grievous Slash"
	BleedList[48374] = "Puncture Wound"
	BleedList[48880] = "Rend"
	BleedList[48920] = "Grievous Bite"
	BleedList[49678] = "Flesh Rot"
	BleedList[50729] = "Carnivorous Bite"
	BleedList[50871] = "Savage Rend"
	BleedList[51275] = "Gut Rip"
	BleedList[52401] = "Gut Rip"
	BleedList[52504] = "Lacerate"
	BleedList[52771] = "Wounding Strike"
	BleedList[52873] = "Open Wound"
	BleedList[53317] = "Rend"
	BleedList[53499] = "Rake"
	BleedList[53602] = "Dart"
	BleedList[54668] = "Rake"
	BleedList[54703] = "Rend"
	BleedList[54708] = "Rend"
	BleedList[55102] = "Determined Gore"
	BleedList[55249] = "Whirling Slash"
	BleedList[55250] = "Whirling Slash"
	BleedList[55276] = "Puncture"
	BleedList[55550] = "Jagged Knife"
	BleedList[55604] = "Death Plague"
	BleedList[55622] = "Impale"
	BleedList[55645] = "Death Plague"
	BleedList[57661] = "Rip"
	BleedList[58459] = "Impale"
	BleedList[58517] = "Grievous Wound"
	BleedList[58830] = "Wounding Strike"
	BleedList[58978] = "Impale"
	BleedList[59007] = "Flesh Rot"
	BleedList[59239] = "Rend"
	BleedList[59256] = "Impale"
	BleedList[59262] = "Grievous Wound"
	BleedList[59264] = "Gore"
	BleedList[59268] = "Impale"
	BleedList[59269] = "Carnivorous Bite"
	BleedList[59343] = "Rend"
	BleedList[59349] = "Dart"
	BleedList[59444] = "Determined Gore"
	BleedList[59682] = "Grievous Wound"
	BleedList[59691] = "Rend"
	BleedList[59824] = "Whirling Slash"
	BleedList[59825] = "Whirling Slash"
	BleedList[59826] = "Puncture"
	BleedList[59989] = "Rip"
	BleedList[61164] = "Impale"
	BleedList[61896] = "Lacerate"
	BleedList[62318] = "Barbed Shot"
	BleedList[62331] = "Impale"
	BleedList[62418] = "Impale"
	BleedList[63468] = "Careful Aim"
	BleedList[64374] = "Savage Pounce"
	BleedList[64666] = "Savage Pounce"
	BleedList[65033] = "Constricting Rend"
	BleedList[65406] = "Rake"
	BleedList[66620] = "Old Wounds"
	BleedList[67280] = "Dagger Throw"
	BleedList[69203] = "Vicious Bite"
	BleedList[70278] = "Puncture Wound"
	BleedList[71926] = "Rip"
	BleedList[74846] = "Bleeding Wound"
	BleedList[75160] = "Bloody Rip"
	BleedList[75161] = "Spinning Rake"
	BleedList[75388] = "Rusty Cut"
	BleedList[75930] = "Mangle"
	BleedList[76507] = "Claw Puncture"
	BleedList[76524] = "Grievous Whirl"
	BleedList[76594] = "Rend"
	BleedList[76807] = "Lacerate"
	BleedList[78842] = "Carnivorous Bite"
	BleedList[78859] = "Elementium Spike Shield"
	BleedList[79444] = "Impale"
	BleedList[79828] = "Mangle"
	BleedList[79829] = "Rip"
	BleedList[80028] = "Rock Bore"
	BleedList[80051] = "Grievous Wound"
	BleedList[81043] = "Razor Slice"
	BleedList[81087] = "Puncture Wound"
	BleedList[81568] = "Spinning Slash"
	BleedList[81569] = "Spinning Slash"
	BleedList[81690] = "Scent of Blood"
	BleedList[82753] = "Ritual of Bloodletting"
	BleedList[82766] = "Eye Gouge"
	BleedList[83783] = "Impale"
	BleedList[84642] = "Puncture"
	BleedList[85415] = "Mangle"
	BleedList[87395] = "Serrated Slash"
	BleedList[89212] = "Eagle Claw"
	BleedList[90098] = "Axe to the Head"
	BleedList[91348] = "Tenderize"
	BleedList[93587] = "Ritual of Bloodletting"
	BleedList[93675] = "Mortal Wound"
	BleedList[95334] = "Elementium Spike Shield"
	BleedList[96570] = "Gaping Wound"
	BleedList[97357] = "Gaping Wound"
	BleedList[98282] = "Tiny Rend"
	BleedList[99100] = "Mangle"
	BleedList[102066] = "Flesh Rip"
	BleedList[102925] = "Garrote"
	BleedList[112896] = "Drain Blood"
	BleedList[113344] = "Bloodbath"
	BleedList[113855] = "Bleeding Wound"
	BleedList[114056] = "Bloody Mess"
	BleedList[114860] = "Rend"
	BleedList[114881] = "Hawk Rend"
	BleedList[115767] = "Deep Wounds"
	BleedList[115871] = "Rake"
	BleedList[118146] = "Lacerate"
	BleedList[119840] = "Serrated Blade"
	BleedList[120166] = "Serrated Blade"
	BleedList[120560] = "Rake"
	BleedList[120699] = "Lynx Rush"
	BleedList[121247] = "Impale"
	BleedList[121411] = "Crimson Tempest"
	BleedList[122962] = "Carnivorous Bite"
	BleedList[123422] = "Arterial Bleeding"
	BleedList[123852] = "Gored"
	BleedList[124015] = "Gored"
	BleedList[124341] = "Bloodletting"
	BleedList[124678] = "Hacking Slash"
	BleedList[124800] = "Pinch Limb"
	BleedList[125099] = "Rake"
	BleedList[125206] = "Rend Flesh"
	BleedList[125624] = "Vicious Rend"
	BleedList[126901] = "Mortal Rend"
	BleedList[126912] = "Grievous Whirl"
	BleedList[127872] = "Consume Flesh"
	BleedList[127987] = "Bleeding Bite"
	BleedList[128051] = "Serrated Slash"
	BleedList[128903] = "Garrote"
	BleedList[129463] = "Crane Kick"
	BleedList[129497] = "Pounced"
	BleedList[130191] = "Rake"
	BleedList[130306] = "Ankle Bite"
	BleedList[130785] = "My Eye!"
	BleedList[130897] = "Vicious Bite"
	BleedList[131662] = "Vicious Stabbing"
	BleedList[133074] = "Puncture"
	BleedList[133081] = "Rip"
	BleedList[134691] = "Impale"
	BleedList[135528] = "Bleeding Wound"
	BleedList[135892] = "Razor Slice"
	BleedList[136654] = "Rending Charge"
	BleedList[136753] = "Slashing Talons"
	BleedList[137497] = "Garrote"
	BleedList[138956] = "Dark Bite"
	BleedList[139514] = "Bloodstorm"
	BleedList[140274] = "Vicious Wound"
	BleedList[140275] = "Rend"
	BleedList[140276] = "Rend"
	BleedList[140396] = "Rend"
	BleedList[143198] = "Garrote"
	BleedList[144113] = "Chomp"
	BleedList[144263] = "Rend"
	BleedList[144264] = "Rend"
	BleedList[144304] = "Rend"
	BleedList[144853] = "Carnivorous Bite"
	BleedList[145263] = "Chomp"
	BleedList[145417] = "Rupture"
	BleedList[146556] = "Pierce"
	BleedList[146927] = "Rend"
	BleedList[147396] = "Rake"
	BleedList[148033] = "Grapple"
	BleedList[148375] = "Brutal Hemorrhage"
	BleedList[151475] = "Drain Life"
	BleedList[152357] = "Rend"
	BleedList[152623] = "Rend"
	BleedList[152724] = "Lacerating Strike"
	BleedList[154489] = "Puncturing Horns"
	BleedList[154953] = "Internal Bleeding"
	BleedList[154960] = "Pinned Down"
	BleedList[155065] = "Ripping Claw"
	BleedList[155701] = "Serrated Slash"
	BleedList[155722] = "Rake"
	BleedList[157344] = "Vital Strike"
	BleedList[158150] = "Goring Swipe"
	BleedList[158341] = "Gushing Wounds"
	BleedList[158453] = "Rending Swipe"
	BleedList[158667] = "Warleader's Spear"
	BleedList[159238] = "Shattered Bleed"
	BleedList[161117] = "Puncturing Tusk"
	BleedList[161229] = "Pounce"
	BleedList[161765] = "Iron Axe"
	BleedList[162487] = "Steel Trap"
	BleedList[162921] = "Peck"
	BleedList[162951] = "Lacerating Spines"
	BleedList[163276] = "Shredded Tendons"
	BleedList[164218] = "Double Slash"
	BleedList[164323] = "Precise Strike"
	BleedList[164427] = "Ravage"
	BleedList[165308] = "Gushing Wound"
	BleedList[166185] = "Rending Slash"
	BleedList[166638] = "Gushing Wound"
	BleedList[166639] = "Item - Druid T17 Feral 4P Bonus Proc Driver"
	BleedList[167334] = "Windfang Bite"
	BleedList[167978] = "Jagged Edge"
	BleedList[168392] = "Fangs of the Predator"
	BleedList[169584] = "Serrated Spines"
	BleedList[170367] = "Vicious Throw"
	BleedList[170936] = "Talador Venom"
	BleedList[172019] = "Stingtail Venom"
	BleedList[172035] = "Thrash"
	BleedList[172139] = "Lacerating Bite"
	BleedList[172361] = "Puncturing Strike"
	BleedList[172366] = "Jagged Slash"
	BleedList[172657] = "Serrated Edge"
	BleedList[172889] = "Charging Slash"
	BleedList[173113] = "Hatchet Toss"
	BleedList[173299] = "Rip"
	BleedList[173307] = "Serrated Spear"
	BleedList[173643] = "Drill Fist"
	BleedList[173876] = "Rending Claws"
	BleedList[174423] = "Pinning Spines"
	BleedList[174734] = "Axe to the Face!"
	BleedList[174820] = "Rending Claws"
	BleedList[175014] = "Rupture"
	BleedList[175156] = "Painful Pinch"
	BleedList[175461] = "Sadistic Slice"
	BleedList[175747] = "Big Sharp Nasty Claws"
	BleedList[176147] = "Ignite"
	BleedList[176256] = "Talon Sweep"
	BleedList[176575] = "Consume Flesh"
	BleedList[176695] = "Bone Fragments"
	BleedList[177337] = "Carnivorous Bite"
	BleedList[177422] = "Thrash"
	BleedList[181346] = "Lacerating Swipe"
	BleedList[181533] = "Jagged Blade"
	BleedList[182325] = "Phantasmal Wounds"
	BleedList[182330] = "Coral Cut"
	BleedList[182347] = "Impaling Coral"
	BleedList[182795] = "Primal Mangle"
	BleedList[182846] = "Thrash"
	BleedList[183952] = "Shadow Claws"
	BleedList[184025] = "Rending Claws"
	BleedList[184090] = "Bloody Arc"
	BleedList[184175] = "Primal Rake"
	BleedList[185539] = "Rapid Rupture"
	BleedList[185698] = "Bloody Hack"
	BleedList[185855] = "Lacerate"
	BleedList[186191] = "Bloodletting Slash"
	BleedList[186365] = "Sweeping Blade"
	BleedList[186594] = "Laceration"
	BleedList[186639] = "Big Sharp Nasty Teeth"
	BleedList[186730] = "Exposed Wounds"
	BleedList[187647] = "Bloodletting Pounce"
	BleedList[188353] = "Rip"
	BleedList[189035] = "Barbed Cutlass"
	BleedList[191977] = "Impaling Spear"
	BleedList[192925] = "Blood of the Assassinated"
	BleedList[193092] = "Bloodletting Sweep"
	BleedList[193340] = "Fenri's Bite"
	BleedList[193585] = "Bound"
	BleedList[193639] = "Bone Chomp"
	BleedList[194279] = "Caltrops"
	BleedList[194636] = "Cursed Rend"
	BleedList[194639] = "Rending Claws"
	BleedList[194674] = "Barbed Spear"
	BleedList[195094] = "Coral Slash"
	BleedList[195279] = "Bind"
	BleedList[195506] = "Razorsharp Axe"
	BleedList[196111] = "Jagged Claws"
	BleedList[196189] = "Bloody Talons"
	BleedList[196313] = "Lacerating Talons"
	BleedList[196376] = "Grievous Tear"
	BleedList[196497] = "Ravenous Leap"
	BleedList[197381] = "Exposed Wounds"
	BleedList[199108] = "Frantic Gore"
	BleedList[199146] = "Bucking Charge"
	BleedList[199337] = "Bear Trap"
	BleedList[199847] = "Grievous Wound"
	BleedList[200182] = "Festering Rip"
	BleedList[200620] = "Frantic Rip"
	BleedList[204175] = "Rend"
	BleedList[204968] = "Hemoraging Barbs"
	BleedList[205437] = "Laceration"
	BleedList[207662] = "Nightmare Wounds"
	BleedList[207690] = "Bloodlet"
	BleedList[208470] = "Necrotic Thrash"
	BleedList[208945] = "Mangle"
	BleedList[208946] = "Rip"
	BleedList[209336] = "Mangle"
	BleedList[209667] = "Blade Surge"
	BleedList[209858] = "Necrotic Wound"
	BleedList[210013] = "Bloodletting Slash"
	BleedList[210723] = "Ashamane's Frenzy"
	BleedList[211672] = "Mutilated Flesh"
	BleedList[211846] = "Bloodletting Lunge"
	BleedList[213431] = "Gnawing Eagle"
	BleedList[213537] = "Bloody Pin"
	BleedList[213933] = "Harpoon Swipe"
	BleedList[213990] = "Shard Bore"
	BleedList[214676] = "Razorsharp Teeth"
	BleedList[215442] = "Shred"
	BleedList[215506] = "Jagged Quills"
	BleedList[215537] = "Trauma"
	BleedList[215721] = "Gut Slash"
	BleedList[217023] = "Antler Gore"
	BleedList[217041] = "Shred"
	BleedList[217091] = "Puncturing Stab"
	BleedList[217142] = "Mangle"
	BleedList[217163] = "Rend"
	BleedList[217200] = "Barbed Shot"
	BleedList[217363] = "Ashamane's Frenzy"
	BleedList[217369] = "Rake"
	BleedList[217868] = "Impale"
	BleedList[218506] = "Jagged Slash"
	BleedList[219167] = "Chomp"
	BleedList[219240] = "Bloody Ricochet"
	BleedList[219339] = "Thrash"
	BleedList[219680] = "Impale"
	BleedList[220874] = "Lacerate"
	BleedList[221352] = "Cut the Flank"
	BleedList[221422] = "Vicious Bite"
	BleedList[221759] = "Feathery Stab"
	BleedList[221770] = "Rend Flesh"
	BleedList[222491] = "Gutripper"
	BleedList[223111] = "Rake"
	BleedList[223572] = "Rend"
	BleedList[223954] = "Rake"
	BleedList[224435] = "Ashamane's Rip"
	BleedList[225484] = "Grievous Rip"
	BleedList[225963] = "Bloodthirsty Leap"
	BleedList[227742] = "Garrote"
	BleedList[228275] = "Rend"
	BleedList[228281] = "Rend"
	BleedList[229127] = "Powershot"
	BleedList[229265] = "Garrote"
	BleedList[229923] = "Talon Rend"
	BleedList[230011] = "Cruel Garrote"
	BleedList[231003] = "Barbed Talons"
	BleedList[231998] = "Jagged Abrasion"
	BleedList[232135] = "Bloody Jab"
	BleedList[235832] = "Bloodletting Strike"
	BleedList[237346] = "Rend"
	BleedList[238618] = "Fel Swipe"
	BleedList[240449] = "Grievous Wound"
	BleedList[240539] = "Wild Bite"
	BleedList[240559] = "Grievous Wound"
	BleedList[241070] = "Bloodletting Strike"
	BleedList[241092] = "Rend"
	BleedList[241212] = "Fel Slash"
	BleedList[241465] = "Coral Cut"
	BleedList[241644] = "Mangle"
	BleedList[242376] = "Puncturing Strike"
	BleedList[242828] = "Dire Thrash"
	BleedList[242931] = "Rake"
	BleedList[244040] = "Eskhandar's Rake"
	BleedList[250393] = "Rake"
	BleedList[251332] = "Rip"
	BleedList[253384] = "Slaughter"
	BleedList[253516] = "Hexabite"
	BleedList[254280] = "Jagged Maw"
	BleedList[254575] = "Rend"
	BleedList[254901] = "Blood Frenzy"
	BleedList[255299] = "Bloodletting"
	BleedList[255595] = "Chomp"
	BleedList[256077] = "Gore"
	BleedList[256314] = "Barbed Strike"
	BleedList[256476] = "Rending Whirl"
	BleedList[256715] = "Jagged Maw"
	BleedList[256880] = "Bone Splinter"
	BleedList[256914] = "Barbed Blade"
	BleedList[256965] = "Thorned Barrage"
	BleedList[257036] = "Feral Charge"
	BleedList[257170] = "Savage Tempest"
	BleedList[257250] = "Bramblepelt"
	BleedList[257544] = "Jagged Cut"
	BleedList[257790] = "Gutripper"
	BleedList[257971] = "Leaping Thrash"
	BleedList[258075] = "Itchy Bite"
	BleedList[258143] = "Rending Claws"
	BleedList[258718] = "Scratched!"
	BleedList[258798] = "Razorsharp Teeth"
	BleedList[258825] = "Vampiric Bite"
	BleedList[259220] = "Barbed Net"
	BleedList[259277] = "Kill Command"
	BleedList[259328] = "Gory Whirl"
	BleedList[259382] = "Shell Slash"
	BleedList[259873] = "Rip"
	BleedList[259983] = "Pierce"
	BleedList[260016] = "Itchy Bite"
	BleedList[260025] = "Rending Whirl"
	BleedList[260400] = "Rend"
	BleedList[260563] = "Gnaw"
	BleedList[260582] = "Gushing Wound"
	BleedList[260741] = "Jagged Nettles"
	BleedList[261882] = "Steel Jaw Trap"
	BleedList[262115] = "Deep Wounds"
	BleedList[262143] = "Ravenous Claws"
	BleedList[262557] = "Rake"
	BleedList[262677] = "Keelhaul"
	BleedList[262875] = "Papercut"
	BleedList[263144] = "Talon Slash"
	BleedList[264145] = "Shatter"
	BleedList[264150] = "Shatter"
	BleedList[264210] = "Jagged Mandible"
	BleedList[264556] = "Tearing Strike"
	BleedList[265019] = "Savage Cleave"
	BleedList[265074] = "Rend"
	BleedList[265165] = "Charging Gore"
	BleedList[265232] = "Rend"
	BleedList[265377] = "Hooked Snare"
	BleedList[265533] = "Blood Maw"
	BleedList[265948] = "Denticulated"
	BleedList[266035] = "Bone Splinter"
	BleedList[266191] = "Whirling Axe"
	BleedList[266231] = "Severing Axe"
	BleedList[266505] = "Rending Claw"
	BleedList[267064] = "Bleeding"
	BleedList[267080] = "Blight of G'huun"
	BleedList[267103] = "Blight of G'huun"
	BleedList[267523] = "Cutting Surge"
	BleedList[269576] = "Master Marksman"
	BleedList[270084] = "Axe Barrage"
	BleedList[270139] = "Gore"
	BleedList[270343] = "Internal Bleeding"
	BleedList[270487] = "Severing Blade"
	BleedList[270979] = "Rend and Tear"
	BleedList[271798] = "Click"
	BleedList[272273] = "Rending Cleave"
	BleedList[273436] = "Gore"
	BleedList[273632] = "Gaping Maw"
	BleedList[273900] = "Bramble Swipe"
	BleedList[273909] = "Steelclaw Trap"
	BleedList[274089] = "Rend"
	BleedList[274838] = "Feral Frenzy"
	BleedList[275895] = "Rend of Kimbul"
	BleedList[276868] = "Impale"
	BleedList[277077] = "Big Sharp Nasty Teeth"
	BleedList[277309] = "Jagged Maw"
	BleedList[277431] = "Hunter Toxin"
	BleedList[277517] = "Serrated Slash"
	BleedList[277569] = "Bloodthirsty Rend"
	BleedList[277592] = "Blood Frenzy"
	BleedList[277794] = "Paw Swipe"
	BleedList[278175] = "Bramble Claw"
	BleedList[278570] = "Boils and Sores"
	BleedList[278733] = "Deep Wound"
	BleedList[278866] = "Carve and Spit"
	BleedList[279133] = "Rend"
	BleedList[280286] = "Dagger in the Back"
	BleedList[280321] = "Garrote"
	BleedList[280940] = "Mangle"
	BleedList[281711] = "Cut of Death"
	BleedList[282444] = "Lacerating Claws"
	BleedList[282845] = "Bear Trap"
	BleedList[283419] = "Rend"
	BleedList[283667] = "Rupture"
	BleedList[283668] = "Crimson Tempest"
	BleedList[283700] = "Rake"
	BleedList[283708] = "Rip"
	BleedList[284158] = "Circular Saw"
	BleedList[285875] = "Rending Bite"
	BleedList[286269] = "Mangle"
	BleedList[288091] = "Gushing Wound"
	BleedList[288266] = "Mangle"
	BleedList[288535] = "Rip"
	BleedList[288539] = "Mangle"
	BleedList[289373] = "Lacerating Pounce"
	BleedList[289848] = "Rending Claw"
	BleedList[292348] = "Bloodletting"
	BleedList[292611] = "Rake"
	BleedList[292626] = "Rip"
	BleedList[293670] = "Chainblade"
	BleedList[295008] = "Bloody Cleaver"
	BleedList[295929] = "Rats!"
	BleedList[296777] = "Bleeding Wound"
	BleedList[299474] = "Ripping Slash"
	BleedList[299502] = "Nanoslicer"
	BleedList[300610] = "Fanged Bite"
	BleedList[301712] = "Pounce"
	BleedList[302295] = "Slicing Claw"
	BleedList[302474] = "Phantom Laceration"
	BleedList[303162] = "Carve Flesh"
	BleedList[303215] = "Shell Slash"
	BleedList[308342] = "Bore"
	BleedList[308859] = "Carnivorous Bite"
	BleedList[308891] = "Jagged Chop"
	BleedList[308938] = "Lacerating Swipe"
	BleedList[311122] = "Jagged Wound"
	BleedList[311744] = "Deep Wound"
	BleedList[311748] = "Lacerating Swipe"
	BleedList[313674] = "Jagged Wound"
	BleedList[314160] = "Penetrating Lance"
	BleedList[314533] = "Rend"
	BleedList[314568] = "Deep Wound"
	BleedList[314847] = "Decapitate"
	BleedList[315311] = "Ravage"
	BleedList[315711] = "Serrated Strike"
	BleedList[315805] = "Crippler"
	BleedList[317561] = "Swooping Lunge"
	BleedList[318187] = "Gushing Wound"
	BleedList[319127] = "Gore"
	BleedList[320007] = "Gash"
	BleedList[320147] = "Bleeding"
	BleedList[320200] = "Stitchneedle"
	BleedList[321538] = "Bloodshed"
	BleedList[321807] = "Boneflay"
	BleedList[322796] = "Wicked Gash"
	BleedList[323043] = "Bloodletting"
	BleedList[323406] = "Jagged Gash"
	BleedList[324149] = "Flayed Shot"
	BleedList[324154] = "Dark Stride"
	BleedList[325021] = "Mistveil Tear"
	BleedList[325022] = "Jagged Swipe"
	BleedList[325037] = "Death Chakram"
	BleedList[326298] = "Bleeding Wound"
	BleedList[326586] = "Crimson Flurry"
	BleedList[327258] = "Rend"
	BleedList[327814] = "Wicked Gash"
	BleedList[328287] = "Heart Strike"
	BleedList[328897] = "Exsanguinated"
	BleedList[328910] = "Tantrum"
	BleedList[328940] = "Gore"
	BleedList[329516] = "Swift Slash"
	BleedList[329563] = "Goring Swipe"
	BleedList[329906] = "Carnage"
	BleedList[329986] = "Maul"
	BleedList[329990] = "Craggy Swipe"
	BleedList[330400] = "Bleeding Swipe"
	BleedList[330532] = "Jagged Quarrel"
	BleedList[330632] = "Maul"
	BleedList[331066] = "Bursting Plumage"
	BleedList[331340] = "Plague Swipe"
	BleedList[331415] = "Wicked Gash"
	BleedList[332168] = "Maul"
	BleedList[332610] = "Penetrating Insight"
	BleedList[332678] = "Gushing Wound"
	BleedList[332792] = "Gore"
	BleedList[332835] = "Ruthless Strikes"
	BleedList[332836] = "Chop"
	BleedList[333235] = "Horn Rush"
	BleedList[333478] = "Gut Slice"
	BleedList[333985] = "Culling Strike"
	BleedList[334669] = "Tirnenn Wrath"
	BleedList[334971] = "Jagged Claws"
	BleedList[335105] = "Dinner Time"
	BleedList[336628] = "Eternal Polearm"
	BleedList[336810] = "Ragged Claws"
	BleedList[337729] = "Kerim's Laceration"
	BleedList[337892] = "Gore"
	BleedList[339163] = "Wicked Gash"
	BleedList[339189] = "Chain Bleed"
	BleedList[339453] = "Darksworn Blast"
	BleedList[339789] = "Darksworn Blast"
	BleedList[339975] = "Grievous Strike"
	BleedList[340058] = "Heart Piercer"
	BleedList[340374] = "Bloody Tantrum"
	BleedList[340431] = "Mutilated Flesh"
	BleedList[341435] = "Lunge"
	BleedList[341475] = "Crimson Flurry"
	BleedList[341833] = "Rending Cleave"
	BleedList[341863] = "Bleeding Out"
	BleedList[342250] = "Jagged Swipe"
	BleedList[342464] = "Javelin Flurry"
	BleedList[342675] = "Bone Spear"
	BleedList[343722] = "Crushing Bite"
	BleedList[344312] = "Serrated Edge"
	BleedList[344464] = "Shield Spike"
	BleedList[344993] = "Jagged Swipe"
	BleedList[345548] = "Spare Meat Hook"
	BleedList[346770] = "Grinding Bite"
	BleedList[347716] = "Letter Opener"
	BleedList[347807] = "Barbed Arrow"
	BleedList[348074] = "Assailing Lance"
	BleedList[348385] = "Bloody Cleave"
	BleedList[348726] = "Lethal Shot"
	BleedList[353068] = "Razor Trap"
	BleedList[353466] = "Sadistic Glee"
	BleedList[353919] = "Rury's Sleepy Tantrum"
	BleedList[354334] = "Hook'd!"
	BleedList[355087] = "Piercing Quill"
	BleedList[355416] = "Sharpened Hide"
	BleedList[355832] = "Quickblade"
	BleedList[356445] = "Sharpened Hide"
	BleedList[356620] = "Pouch of Razor Fragments"
	BleedList[356808] = "Spiked"
	BleedList[356925] = "Carnage"
	BleedList[357091] = "Cleave Flesh"
	BleedList[357192] = "Dark Flurry"
	BleedList[357239] = "Cleave Flesh"
	BleedList[357322] = "Night Glaive"
	BleedList[357665] = "Crystalline Flesh"
	BleedList[357827] = "Frantic Rip"
	BleedList[357953] = "Fanged Bite"
	BleedList[358224] = "Jagged Swipe"
	BleedList[359587] = "Bloody Peck"
	BleedList[359981] = "Rend"
	BleedList[360194] = "Deathmark"
	BleedList[360775] = "Puncture"
	BleedList[360826] = "Rupture"
	BleedList[360830] = "Garrote"
	BleedList[361024] = "Thief's Blade"
	BleedList[361049] = "Bleeding Gash"
	BleedList[361756] = "Death Chakram"
	BleedList[362149] = "Ascended Phalanx"
	BleedList[362819] = "Rend"
	BleedList[363830] = "Sickle of the Lion"
	BleedList[363831] = "Bleeding Soul"
	BleedList[365336] = "Rending Bite"
	BleedList[365877] = "Jagged Blade"
	BleedList[366075] = "Bloody Peck"
	BleedList[366275] = "Rending Bite"
	BleedList[366884] = "Ripped Secrets"
	BleedList[367481] = "Bloody Bite"
	BleedList[367521] = "Bone Bolt"
	BleedList[367726] = "Lupine's Slash"
	BleedList[368401] = "Puncture"
	BleedList[368651] = "Vicious Wound"
	BleedList[368701] = "Boon of Harvested Hope"
	BleedList[369408] = "Rending Slash"
	BleedList[369828] = "Chomp"
	BleedList[370742] = "Jagged Strike"
	BleedList[371472] = "Rake"
	BleedList[372224] = "Dragonbone Axe"
	BleedList[372474] = "Bloodletting"
	BleedList[372570] = "Bold Ambush"
	BleedList[372718] = "Earthen Shards"
	BleedList[372796] = "Blazing Rush"
	BleedList[372860] = "Searing Wounds"
	BleedList[373735] = "Dragon Strike"
	BleedList[374135] = "Gore"
	BleedList[374892] = "Gore"
	BleedList[375201] = "Talon Rip"
	BleedList[375416] = "Bleeding"
	BleedList[375803] = "Mammoth Trap"
	BleedList[375893] = "Death Chakram"
	BleedList[376997] = "Savage Peck"
	BleedList[377344] = "Peck"
	BleedList[377609] = "Dragon Rend"
	BleedList[377732] = "Jagged Bite"
	BleedList[378020] = "Gash Frenzy"
	BleedList[381575] = "Lacerate"
	BleedList[381628] = "Internal Bleeding"
	BleedList[381672] = "Mutilated Flesh"
	BleedList[381692] = "Swift Stab"
	BleedList[384134] = "Pierce"
	BleedList[384148] = "Ensnaring Trap"
	BleedList[384473] = "Impale"
	BleedList[384575] = "Crippling Bite"
	BleedList[385042] = "Gushing Wound"
	BleedList[385060] = "Odyn's Fury"
	BleedList[385363] = "Gore"
	BleedList[385511] = "Messy"
	BleedList[385638] = "Razor Fragments"
	BleedList[385834] = "Bloodthirsty Charge"
	BleedList[386116] = "Messy"
	BleedList[386640] = "Tear Flesh"
	BleedList[387205] = "Beak Rend"
	BleedList[387473] = "Big Sharp Teeth"
	BleedList[387809] = "Splatter!"
	BleedList[388301] = "Savage Tear"
	BleedList[388377] = "Rending Slash"
	BleedList[388473] = "Feeding Frenzy"
	BleedList[388539] = "Rend"
	BleedList[388912] = "Severing Slash"
	BleedList[389948] = "Bloodletting"
	BleedList[389949] = "Bloodletting"
	BleedList[390194] = "Rending Slash"
	BleedList[390583] = "Logcutter"
	BleedList[390834] = "Primal Rend"
	BleedList[391098] = "Puncturing Impalement"
	BleedList[391114] = "Cutting Winds"
	BleedList[391140] = "Frenzied Assault"
	BleedList[391308] = "Rending Swoop"
	BleedList[391356] = "Tear"
	BleedList[391725] = "Swooping Dive"
	BleedList[392235] = "Furious Charge"
	BleedList[392236] = "Furious Charge"
	BleedList[392239] = "Gore"
	BleedList[392257] = "Gore"
	BleedList[392332] = "Horn Gore"
	BleedList[392341] = "Mighty Swipe"
	BleedList[392411] = "Beetle Thrust"
	BleedList[392416] = "Beetle Charge"
	BleedList[392841] = "Hungry Chomp"
	BleedList[393444] = "Gushing Wound"
	BleedList[393718] = "Heartpiercer"
	BleedList[393817] = "Hardened Shards"
	BleedList[393820] = "Horn Swing"
	BleedList[394021] = "Mutilated Flesh"
	BleedList[394063] = "Rend"
	BleedList[394371] = "Hit the Mark"
	BleedList[394628] = "Peck"
	BleedList[394647] = "Merciless Gore"
	BleedList[394787] = "Talon Shred"
	BleedList[395832] = "Jagged Cuts"
	BleedList[395939] = "Gore"
	BleedList[396007] = "Vicious Peck"
	BleedList[396348] = "Dismember"
	BleedList[396353] = "Fatal Chomp"
	BleedList[396639] = "Bloody Pounce"
	BleedList[396641] = "Rending Slash"
	BleedList[396675] = "Hemorrhaging Rend"
	BleedList[396716] = "Splinterbark"
	BleedList[397092] = "Impaling Horn"
	BleedList[397112] = "Primal Devastation"
	BleedList[397364] = "Thunderous Roar"
	BleedList[398392] = "Stomp"
	BleedList[398497] = "Rock Needle"
	BleedList[400050] = "Claw Rip"
	BleedList[400941] = "Ragged Slash"
	BleedList[401370] = "Deep Claws"
	BleedList[403589] = "Gushing Wound"
	BleedList[403662] = "Garrote"
	BleedList[403790] = "Vicious Swipe"
	BleedList[404907] = "Rupturing Slash"
	BleedList[404978] = "Devastating Rend"
	BleedList[405233] = "Thrash"
	BleedList[406183] = "Time Slash"
	BleedList[406215] = "Vicious Bite"
	BleedList[406365] = "Rending Charge"
	BleedList[406499] = "Ravening Leaps"
	BleedList[411101] = "Artifact Shards"
	BleedList[411437] = "Brutal Lacerations"
	BleedList[411924] = "Drilljaws"
	BleedList[413131] = "Whirling Dagger"
	BleedList[413136] = "Whirling Dagger"
end

function lib:GetDebuffTypeColor()
	return DebuffColors
end

function lib:GetBleedList()
	return BleedList
end

function lib:GetBadList()
	return BadList
end

function lib:GetBlockList()
	return BlockList
end

function lib:GetMyDispelTypes()
	return DispelList
end

function lib:IsDispellableByMe(debuffType)
	return DispelList[debuffType]
end

do
	local _, myClass = UnitClass("player")
	local WarlockPetSpells = {
		[89808] = "Singe"
	}

	if Retail then
		WarlockPetSpells[132411] = "Singe Magic" -- Grimoire of Sacrifice
	else
		WarlockPetSpells[19505] = "Devour Magic Rank 1"
		WarlockPetSpells[19731] = "Devour Magic Rank 2"
		WarlockPetSpells[19734] = "Devour Magic Rank 3"
		WarlockPetSpells[19736] = "Devour Magic Rank 4"
		WarlockPetSpells[27276] = "Devour Magic Rank 5"
		WarlockPetSpells[27277] = "Devour Magic Rank 6"
		WarlockPetSpells[48011] = "Devour Magic Rank 7"
	end

	local function CheckSpell(spellID, pet)
		return IsSpellKnownOrOverridesKnown(spellID, pet) and true or nil
	end

	local function CheckPetSpells()
		for spellID in next, WarlockPetSpells do
			if CheckSpell(spellID, true) then
				return true
			end
		end
	end

	local function UpdateDispels(_, event, arg1)
		if event == 'CHARACTER_POINTS_CHANGED' and arg1 > 0 then
			return -- Not interested in gained points from leveling
		end

		-- this will fix a problem where spells dont show as existing because they are 'hidden'
		local undoRanks = Wrath and GetCVar('ShowAllSpellRanks') ~= '1' and SetCVar('ShowAllSpellRanks', 1)

		if event == 'UNIT_PET' then
			DispelList.Magic = CheckPetSpells()
		elseif myClass == 'DRUID' then
			local cure = Retail and CheckSpell(88423) -- Nature's Cure
			local corruption = CheckSpell(2782) -- Remove Corruption (retail), Curse (classic)
			DispelList.Magic = cure
			DispelList.Curse = cure or corruption
			DispelList.Poison = cure or (Retail and corruption) or CheckSpell(2893) or CheckSpell(8946) -- Abolish Poison / Cure Poison
		elseif myClass == 'MAGE' then
			DispelList.Curse = CheckSpell(475) -- Remove Curse
		elseif myClass == 'MONK' then
			local mwDetox = CheckSpell(115450) -- Detox (Mistweaver)
			local detox = mwDetox or CheckSpell(218164) -- Detox (Brewmaster or Windwalker)
			DispelList.Magic = mwDetox
			DispelList.Disease = detox
			DispelList.Poison = detox
		elseif myClass == 'PALADIN' then
			local cleanse = CheckSpell(4987) -- Cleanse
			local purify = CheckSpell(1152) -- Purify
			local toxins = cleanse or purify or CheckSpell(213644) -- Cleanse Toxins
			DispelList.Magic = cleanse
			DispelList.Poison = toxins
			DispelList.Disease = toxins
		elseif myClass == 'PRIEST' then
			local dispel = CheckSpell(527) -- Dispel Magic
			DispelList.Magic = dispel or CheckSpell(32375)
			DispelList.Disease = Retail and (IsPlayerSpell(390632) or CheckSpell(213634)) or not Retail and (CheckSpell(552) or CheckSpell(528)) -- Purify Disease / Abolish Disease / Cure Disease
		elseif myClass == 'SHAMAN' then
			local purify = Retail and CheckSpell(77130) -- Purify Spirit
			local cleanse = purify or CheckSpell(51886) -- Cleanse Spirit
			local toxins = Retail and CheckSpell(383013) or CheckSpell(526) -- Poison Cleansing Totem (Retail), Cure Toxins (TBC/Classic)

			DispelList.Magic = purify
			DispelList.Curse = cleanse
			DispelList.Poison = toxins or (not Retail and cleanse)
			DispelList.Disease = not Retail and (cleanse or toxins)
		elseif myClass == 'EVOKER' then
			local naturalize = CheckSpell(360823) -- Naturalize (Preservation)
			local expunge = CheckSpell(365585) -- Expunge (Devastation)
			local cauterizing = CheckSpell(374251) -- Cauterizing Flame

			DispelList.Magic = naturalize
			DispelList.Poison = naturalize or expunge or cauterizing
			DispelList.Disease = cauterizing
			DispelList.Curse = cauterizing
			DispelList.Bleed = cauterizing
		end

		if undoRanks then
			SetCVar('ShowAllSpellRanks', 0)
		end
	end

	local frame = CreateFrame('Frame')
	frame:SetScript('OnEvent', UpdateDispels)
	frame:RegisterEvent('CHARACTER_POINTS_CHANGED')
	frame:RegisterEvent('PLAYER_LOGIN')

	if myClass == 'WARLOCK' then
		frame:RegisterUnitEvent('UNIT_PET', 'player')
	end

	if Wrath then
		frame:RegisterEvent('PLAYER_TALENT_UPDATE')
	elseif Retail then
		frame:RegisterEvent('LEARNED_SPELL_IN_TAB')
		frame:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED', 'player')
	end
end
