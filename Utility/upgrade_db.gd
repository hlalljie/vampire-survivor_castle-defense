extends Node

const ICON_PATH: String = "res://Textures/Items/Upgrades/"
const WEAPON_PATH: String  = "res://Textures/Items/Weapons/"
const UPGRADES = {
	"ice_spear1": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"display_name": "Ice Spear",
		"description": "A spear of ice is thrown at a random enemy",
		"level": "Level: 1",
		"prerequisites": [],
		"type": "weapon"
	},
	"ice_spear2": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"display_name": "Ice Spear",
		"description": "An addition Ice Spear is thrown",
		"level": "Level: 2",
		"prerequisites": ["ice_spear1"],
		"type": "weapon"
	},
	"ice_spear3": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"display_name": "Ice Spear",
		"description": "Ice Spears now pass through another enemy and do + 3 damage",
		"level": "Level: 3",
		"prerequisites": ["ice_spear2"],
		"type": "weapon"
	},
	"ice_spear4": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"display_name": "Ice Spear",
		"description": "An additional 2 Ice Spears are thrown",
		"level": "Level: 4",
		"prerequisites": ["ice_spear3"],
		"type": "weapon"
	},
	"javelin1": {
		"icon": WEAPON_PATH + "javelin_3_new_attack.png",
		"display_name": "Javelin",
		"description": "A magical javelin will follow you attacking enemies in a straight line",
		"level": "Level: 1",
		"prerequisites": [],
		"type": "weapon"
	},
	"javelin2": {
		"icon": WEAPON_PATH + "javelin_3_new_attack.png",
		"display_name": "Javelin",
		"description": "The javelin will now attack an additional enemy per attack",
		"level": "Level: 2",
		"prerequisites": ["javelin1"],
		"type": "weapon"
	},
	"javelin3": {
		"icon": WEAPON_PATH + "javelin_3_new_attack.png",
		"display_name": "Javelin",
		"description": "The javelin will attack another additional enemy per attack",
		"level": "Level: 3",
		"prerequisites": ["javelin2"],
		"type": "weapon"
	},
	"javelin4": {
		"icon": WEAPON_PATH + "javelin_3_new_attack.png",
		"display_name": "Javelin",
		"description": "The javelin now does + 5 damage per attack and causes 20% additional knockback",
		"level": "Level: 4",
		"prerequisites": ["javelin3"],
		"type": "weapon"
	},
	"tornado1": {
		"icon": WEAPON_PATH + "tornado.png",
		"display_name": "Tornado",
		"description": "A tornado is created and random heads somewhere in the players direction",
		"level": "Level: 1",
		"prerequisites": [],
		"type": "weapon"
	},
	"tornado2": {
		"icon": WEAPON_PATH + "tornado.png",
		"display_name": "Tornado",
		"description": "An additional Tornado is created",
		"level": "Level: 2",
		"prerequisites": ["tornado1"],
		"type": "weapon"
	},
	"tornado3": {
		"icon": WEAPON_PATH + "tornado.png",
		"display_name": "Tornado",
		"description": "The Tornado cooldown is reduced by 0.5 seconds",
		"level": "Level: 3",
		"prerequisites": ["tornado2"],
		"type": "weapon"
	},
	"tornado4": {
		"icon": WEAPON_PATH + "tornado.png",
		"display_name": "Tornado",
		"description": "An additional tornado is created and the knockback is increased by 25%",
		"level": "Level: 4",
		"prerequisites": ["tornado3"],
		"type": "weapon"
	},
	"armor1": {
		"icon": ICON_PATH + "helmet_1.png",
		"display_name": "Armor",
		"description": "Reduces Damage By 1 point",
		"level": "Level: 1",
		"prerequisites": [],
		"type": "upgrade"
	},
	"armor2": {
		"icon": ICON_PATH + "helmet_1.png",
		"display_name": "Armor",
		"description": "Reduces Damage By an additional 1 point",
		"level": "Level: 2",
		"prerequisites": ["armor1"],
		"type": "upgrade"
	},
	"armor3": {
		"icon": ICON_PATH + "helmet_1.png",
		"display_name": "Armor",
		"description": "Reduces Damage By an additional 1 point",
		"level": "Level: 3",
		"prerequisites": ["armor2"],
		"type": "upgrade"
	},
	"armor4": {
		"icon": ICON_PATH + "helmet_1.png",
		"display_name": "Armor",
		"description": "Reduces Damage By an additional 1 point",
		"level": "Level: 4",
		"prerequisites": ["armor3"],
		"type": "upgrade"
	},
	"speed1": {
		"icon": ICON_PATH + "boots_4_green.png",
		"display_name": "Speed",
		"description": "Movement Speed Increased by 50% of base speed",
		"level": "Level: 1",
		"prerequisites": [],
		"type": "upgrade"
	},
	"speed2": {
		"icon": ICON_PATH + "boots_4_green.png",
		"display_name": "Speed",
		"description": "Movement Speed Increased by an additional 50% of base speed",
		"level": "Level: 2",
		"prerequisites": ["speed1"],
		"type": "upgrade"
	},
	"speed3": {
		"icon": ICON_PATH + "boots_4_green.png",
		"display_name": "Speed",
		"description": "Movement Speed Increased by an additional 50% of base speed",
		"level": "Level: 3",
		"prerequisites": ["speed2"],
		"type": "upgrade"
	},
	"speed4": {
		"icon": ICON_PATH + "boots_4_green.png",
		"display_name": "Speed",
		"description": "Movement Speed Increased an additional 50% of base speed",
		"level": "Level: 4",
		"prerequisites": ["speed3"],
		"type": "upgrade"
	},
	"tome1": {
		"icon": ICON_PATH + "thick_new.png",
		"display_name": "Tome",
		"description": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 1",
		"prerequisites": [],
		"type": "upgrade"
	},
	"tome2": {
		"icon": ICON_PATH + "thick_new.png",
		"display_name": "Tome",
		"description": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 2",
		"prerequisites": ["tome1"],
		"type": "upgrade"
	},
	"tome3": {
		"icon": ICON_PATH + "thick_new.png",
		"display_name": "Tome",
		"description": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 3",
		"prerequisites": ["tome2"],
		"type": "upgrade"
	},
	"tome4": {
		"icon": ICON_PATH + "thick_new.png",
		"display_name": "Tome",
		"description": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 4",
		"prerequisites": ["tome3"],
		"type": "upgrade"
	},
	"scroll1": {
		"icon": ICON_PATH + "scroll_old.png",
		"display_name": "Scroll",
		"description": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 1",
		"prerequisites": [],
		"type": "upgrade"
	},
	"scroll2": {
		"icon": ICON_PATH + "scroll_old.png",
		"display_name": "Scroll",
		"description": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 2",
		"prerequisites": ["scroll1"],
		"type": "upgrade"
	},
	"scroll3": {
		"icon": ICON_PATH + "scroll_old.png",
		"display_name": "Scroll",
		"description": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 3",
		"prerequisites": ["scroll2"],
		"type": "upgrade"
	},
	"scroll4": {
		"icon": ICON_PATH + "scroll_old.png",
		"display_name": "Scroll",
		"description": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 4",
		"prerequisites": ["scroll3"],
		"type": "upgrade"
	},
	"ring1": {
		"icon": ICON_PATH + "urand_mage.png",
		"display_name": "Ring",
		"description": "Your spells now spawn 1 more additional attack",
		"level": "Level: 1",
		"prerequisites": [],
		"type": "upgrade"
	},
	"ring2": {
		"icon": ICON_PATH + "urand_mage.png",
		"display_name": "Ring",
		"description": "Your spells now spawn an additional attack",
		"level": "Level: 2",
		"prerequisites": ["ring1"],
		"type": "upgrade"
	},
	"food": {
		"icon": ICON_PATH + "chunk.png",
		"display_name": "Food",
		"description": "Heals you for 20 health",
		"level": "N/A",
		"prerequisites": [],
		"type": "item"
	}
}
