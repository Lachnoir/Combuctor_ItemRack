
local CombuctorSet = Combuctor:GetModule("Sets")

local L={}

L["All"] = "All"
L["None"] = "None"
L["ItemRack"] = "ItemRack"
L["Weapon"] = select(1,GetAuctionItemClasses())
L["Armor"] = select(2,GetAuctionItemClasses())

-- return an new anonymous comparison function that will filter based on the the supplied set name
-- assumes an empyty filter matches any set, a nil filter matches no sets, and a non empty filter matches a specifc set
function makeIsSet(filter)
	return function(player, bagType, name, link, quality, level, ilvl, type, subType, stackCount, equipLoc)
		local id = string.match( link or "", "item:(.+):%-?%d+" ) or 0

		if ( 0 == id ) then return false end

		for setname, set in pairs( ItemRackUser.Sets ) do
			for _, setitem in pairs( set.equip ) do
				if (id == setitem and string.sub( setname, 1, 1 ) ~= "~" ) then
					if ( nil == filter ) then
						return false
					elseif ( "" == filter or setname == filter ) then
						return true
					end
				end
			end
		end

		if ( nil == filter and (type == L["Weapon"] or type == L["Armor"] )) then
			-- for nil filters, if we havent found a set, make sure the item type is weapon or armor
			return true
		else
			-- whatever it was, we dont want it...
			return false
		end
	end
end

-- seeing some odd behaviour with the rules...
--    supplying a rule to the "ItemRack" root set seems to interfere with the processing of the "None" subset
--    removing the rule from the root set seems to work around the problem, but there must be at least one subset selected in the UI
CombuctorSet:Register(L["ItemRack"], "Interface/Icons/INV_Gauntlets_15")
CombuctorSet:RegisterSubSet(L["All"], L["ItemRack"],nil, makeIsSet(""))
CombuctorSet:RegisterSubSet(L["None"], L["ItemRack"],nil, makeIsSet(nil))

-- add sub-sets for each of the user defined gear sets...
for k,_ in pairs( ItemRackUser.Sets ) do
	if string.sub( k, 1, 1 ) ~= "~" then
		CombuctorSet:RegisterSubSet(k, L["ItemRack"], nil, makeIsSet(k))
	end
end

