--[[----------------------------------------------------------------------------
AVORION: Mothballing
darkconsole <darkcee.legit@gmail.com>

This script handles the actual mothballing, keeping the ship alive if it does
not have enough mechanics to do so on its own.
----------------------------------------------------------------------------]]--

if(not onServer())
then return end

package.path = package.path
..";data/scripts/lib/?.lua"

include("utility")

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local ConfigOK, Config = pcall(
	include,
	'mods/DccMothballing/Config'
)

if(not ConfigOK)
then
	print("[DccMothballing] Error loading Config.lua - did you copy ConfigDefault.lua?")
else
	if(Config.Debug)
	then printTable(Config) end
end

--------------------------------------------------------------------------------

function initialize()
-- when this script is attached to a ship register for the events we need to
-- look out for.

	-- get the thing we attach to hopefully.
	local Ship = Entity()

	-- when the ship takes damage we want to know about it.
	Ship:registerCallback("onDamaged","OnDamaged")

	return
end

function PrintDebug(Message)
-- print these messages if debug mode is on.

	if(Config.Debug)
	then
		print("[DccMothballing] " .. Message)
	end

	return
end

--------------------------------------------------------------------------------

function OnDamaged(EntityID, Amount, From)
-- when this ship takes damage, heal it back, if it was not damage done by a
-- third party source. this will neutralize the decay the game does when there
-- are no mechanics on board.

	local Ship = Entity(EntityID)

	-- i only care about self inflicted damage, that caused by not having
	-- enough mechanics.

	if(From.number ~= 0)
	then
		return
	end

	-- heal the ship for the amount of damage it took.

	PrintDebug("OnDamaged(): " .. Ship.name .. " -" .. Amount)
	Heal(Ship, Amount)

	return
end

--------------------------------------------------------------------------------

function Heal(Ship, Amount)
-- heal the ship the specified amount.

	-- the heal method currently has no info in the documentation so i took
	-- some stupid guesses and just started throwing data at it until it
	-- worked. the ship size i am sure is pointless it was just an easy valid
	-- vec3 to throw at it. probably suppose to be the targeted block.

	-- laser thinks the index may be the "block index" and the location the
	-- spot on the block where the game might spawn particles or something.
	-- seems about as plausable as any i would guess.

	local Amount = Amount * Config.HealMult
	local CurrHealth = GetHealthPercent(Ship)
	local CurrMech = GetMechPercent(Ship)

	-- only heal if we have the minimum mechanic workforce onboard if the min
	-- value is not zero.

	if(Config.MinMechanics > 0 and CurrMech < Config.MinMechanics)
	then
		PrintDebug("Heal(" .. Ship.name .. ") does not have enough mechanics on board (".. CurrMech .."% < ".. Config.MinMechanics .."%)")
		return
	end

	-- allow the current health to fall to the mechanic performance ratio if
	-- bind is enabled.

	if(Config.BindToMechanics)
	then
		if(CurrHealth > CurrMech)
		then
			PrintDebug("Heal(" .. Ship.name .. ") does not need healing (".. CurrHealth .."% / ".. CurrMech .."%)")
			return
		end
	end

	PrintDebug("Heal(): " .. Ship.name .. " (Health: " .. CurrHealth .. "%, Mechs: " .. CurrMech .. "%) +" .. Amount)
	Ship:heal(Amount, Ship:getPlan().rootIndex, vec3(0,0,0), Ship.id)

	return
end

--------------------------------------------------------------------------------

function GetHealthPercent(Ship)
-- get the ship's current health percentage.

	return (Ship.durability / Ship.maxDurability) * 100
end

function GetMechPercent(Ship)
-- get the ship's current allotment of mechanics.

	-- i do not know why, but the game starts mechs at 20%... so i think this
	-- is the proper math to make it match the ship crew screen.

	return (((Ship.crew.mechanics * Config.MechMult) / Ship.minCrew.mechanics) * 80) + 20
end
