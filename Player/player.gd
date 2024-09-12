extends CharacterBody2D

# Global variables
var movement_speed: float = 60.0
var max_hp: int = 80
var hp: int = 80
var last_movement: Vector2 = Vector2.UP
var time: int = 0 

# Experience
var experience: int = 0
var exp_level: int = 1
var collected_exp = 0


# imports from local nodes
@onready var sprite: Sprite2D = $Sprite2D
@onready var walkTimer: Timer = get_node("%WalkTimer") # use Access with Unique Name on node

# Attacks
var iceSpear: Resource = preload("res://Player/Attack/ice_spear.tscn")
var tornado: Resource = preload("res://Player/Attack/tornado.tscn")
var javelin: Resource = preload("res://Player/Attack/javelin.tscn")

# Attack Nodes
@onready var iceSpearTimer: Timer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer: Timer = get_node("%IceSpearAttackTimer")
@onready var tornadoTimer: Timer = get_node("%TornadoTimer")
@onready var tornadoAttackTimer: Timer = get_node("%TornadoAttackTimer")
@onready var javelinBase: Node2D = get_node("%JavelinBase")

# Ice Spear
var ice_spear_ammo: int = 0
var ice_spear_base_ammo: int = 1
var ice_spear_attack_speed: float = 1.5
var ice_spear_level: int = 0

# Tornado
var tornado_ammo: int = 0
var tornado_base_ammo: int = 1
var tornado_attack_speed: float = 3.0
var tornado_level: int = 0

# Javelin
var javelin_ammo: int = 1
var javelin_level: int = 0

var close_enemies: Array = []

## GUI
@onready var expBar: TextureProgressBar = get_node("%ExperienceBar")
@onready var levelLabel: Label = get_node("%LevelLabel")
# Level up GUI
@onready var levelPanel: Panel = get_node("%LevelUpPanel")
@onready var levelUpLabel: Label = get_node("%LevelUpLabel")
@onready var upgradeOptions: VBoxContainer = get_node("%UpgradeOptions")
@onready var soundLevelUp: AudioStreamPlayer = get_node("%sound_level_up")
@onready var itemOptions: Resource = preload("res://Utility/item_option.tscn")
# Health Bar GUI
@onready var healthBar: TextureProgressBar = get_node("%HealthBar")
# Timer GUI
@onready var timerLabel: Label = get_node("%TimerLabel")
# Collected Items/Upgrades UI
@onready var collectedWeapons: GridContainer = get_node("%CollectedWeapons")
@onready var collectedUpgrades: GridContainer = get_node("%CollectedUpgrades")
@onready var itemContainer: Resource = preload("res://GUI/item_container.tscn")
# Death GUI
@onready var deathPanel: Panel = get_node('%DeathPanel')
@onready var resultLabel: Label = get_node("%ResultLabel")
@onready var soundVictory: AudioStreamPlayer = get_node("%sound_victory")
@onready var soundLose: AudioStreamPlayer = get_node("%sound_lose")

# Upgrades
var collected_upgrades: Array = []
var upgrade_options: Array = []
var armor: float = 0
var speed: int = 0
var spell_cooldown: float = 0
var spell_size: float = 0
var additional_attacks = 0

# Signal Player Death
signal player_death

func _ready() -> void:
	select_first_weapon()
	# proc all attacks
	attack()
	set_exp_bar(experience, calculate_exp_cap())
	# setup health bar
	_on_hurt_box_hurt(0, 0, 0)

func _physics_process(_delta: float) -> void:
	movement()
	
func movement() -> void:
	# Collect movement vector from input (either 0 or 1 for every direction)
	var move: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	# Face player sprite in correct direction
	if move.x > 0:
		sprite.flip_h = true
	elif move.x < 0:
		sprite.flip_h = false
		
	# Walk animation
	# only animate when moving
	if move != Vector2.ZERO:
		# if walk animation timer is done, go to next animation
		if walkTimer.is_stopped():
			# go to next animation (looping)
			sprite.frame = (sprite.frame + 1) % (sprite.hframes)
			# restart walk timer
			walkTimer.start()
		
		# update last movement, rounding brings diagonal unit vector to 1, 1 (instead of .7, .7)
		last_movement = move.round()
	
	# set velocity as the unit vector of move multiplied by the movement speed
	velocity = move.normalized() * movement_speed
	# move and set to slide on collision
	move_and_slide()

## Starts all attacks
func attack() -> void:
	# if there is an ice spear activate
	if ice_spear_level > 0:
		# set up the timer with the wait time
		iceSpearTimer.wait_time = ice_spear_attack_speed * (1 - spell_cooldown)
		# start the timer
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()
	if tornado_level > 0:
		# set up the timer with the wait time
		tornadoTimer.wait_time = tornado_attack_speed * (1 - spell_cooldown)
		# start the timer
		if tornadoTimer.is_stopped():
			tornadoTimer.start()
	if javelin_level > 0:
		spawn_javelin()

## Lowers hp based on damage recieved
func _on_hurt_box_hurt(damage: int, _angle, _knockback) -> void:
	# lowers hp based on damage recieved
	hp -= clamp(damage-armor, 1.0, 99999.0)
	print("hp:", hp)
	healthBar.max_value = max_hp
	healthBar.value = hp	
	if hp <= 0:
		death()

## Gain ammo every time the timer is up
func _on_ice_spear_timer_timeout() -> void:
	ice_spear_ammo += ice_spear_base_ammo + additional_attacks
	iceSpearAttackTimer.start()

## Fire a shot if there is ammo and if the timer is up
func _on_ice_spear_attack_timer_timeout() -> void:
	# check if there is ammo
	if ice_spear_ammo > 0:
		# create an ice spear
		var ice_spear_attack: Area2D = iceSpear.instantiate()
		# set it's position to the player's position
		ice_spear_attack.position = position
		# finds a random target direction
		ice_spear_attack.target = get_random_target()
		# set the level to the current level
		ice_spear_attack.level = ice_spear_level
		# add ice spear to the scene
		add_child(ice_spear_attack)
		# use the ammo
		ice_spear_ammo -= 1
		# fire off more ice spears if ammo exists
		if ice_spear_ammo > 0:
			iceSpearAttackTimer.start()
		else: 
			iceSpearAttackTimer.stop()
			
## Gain ammo every time the timer is up
func _on_tornado_timer_timeout() -> void:
	tornado_ammo += tornado_base_ammo + additional_attacks
	tornadoAttackTimer.start()

## Fire a shot if there is ammo and if the timer is up
func _on_tornado_attack_timer_timeout() -> void:
	# check if there is ammo
	if tornado_ammo > 0:
		# create an ice spear
		var tornado_attack: Area2D = tornado.instantiate()
		# set it's position to the player's position
		tornado_attack.position = position
		# finds a random target direction
		tornado_attack.last_movement = last_movement
		# set the level to the current level
		tornado_attack.level = tornado_level
		# add ice spear to the scene
		add_child(tornado_attack)
		# use the ammo
		tornado_ammo -= 1
		# fire off more ice spears if ammo exists
		if tornado_ammo > 0:
			tornadoAttackTimer.start()
		else: 
			tornadoAttackTimer.stop()
## Spawns as many javelins as there is ammo
func spawn_javelin():
	# create as many javelins as are needed (how much javelin ammo)
	var current_javelin_total: int = javelinBase.get_child_count()
	var calc_spawns: int = (javelin_ammo + additional_attacks) - current_javelin_total
	# continue to spawn javelins as needed
	while calc_spawns > 0:
		var javelin_spawn: Area2D = javelin.instantiate()
		javelin_spawn.global_position = global_position
		javelinBase.add_child(javelin_spawn)
		calc_spawns -= 1
	# update current javelins
	var current_javelins = javelinBase.get_children()
	for jav in current_javelins:
		if jav.has_method("update_javelin"):
			jav.update_javelin()
		
	
# Finds a random target direction from the list of close enemies
func get_random_target() -> Vector2:
	# check if there are any close enemies
	if close_enemies.size() > 0:
		return close_enemies.pick_random().global_position
	# default to up (for now)
	else:
		return Vector2.UP

## Add enemies to close enemies list when they get close
func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	# if not already in the detection area, add it to close enemies
	if not close_enemies.has(body):
		close_enemies.append(body)

## Remove enemies from close enemies list when they leave the area
func _on_enemy_detection_area_body_exited(body: Node2D) -> void:
	# if the enemy is still in close enemies, delete it
	if close_enemies.has(body):
		close_enemies.erase(body)

func _on_grab_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		area.target = self


func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_exp(gem_exp)
		

func calculate_exp(gem_exp: int):
	var exp_req = calculate_exp_cap()
	collected_exp += gem_exp
	 # level up
	if experience + collected_exp >= exp_req:
		collected_exp -= exp_req - experience
		experience = 0
		# calculate gain with any leftover experience after leveling
		exp_req = calculate_exp_cap()
		# update player level
		exp_level += 1
		levelUp()
		#calculate_exp(0)
	# add collected experience to our total
	else:
		experience += collected_exp
		collected_exp = 0
	set_exp_bar(experience, exp_req)
		
## Calculate current level's total experience needed
func calculate_exp_cap():
	# bracketed experience caps that carry over previous bracket values
	var exp_cap = exp_level
	if exp_level < 20:
		exp_cap = exp_level * 5
	elif exp_level < 40:
		exp_cap = 95 + (exp_level - 19) * 8
	else:
		exp_cap = 255 + (exp_level - 39) * 12
	return exp_cap
	
func set_exp_bar(set_value = 1, set_max_value = 100):
	expBar.value = set_value
	expBar.max_value = set_max_value
	
func levelUp() -> void:
	# play level up sound
	soundLevelUp.play()
	# update level label
	levelLabel.text = "Level: " + str(exp_level)
	# move level panel into position and show
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel, "position", Vector2(220, 50), .2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	# upgrade options population
	var options_max: int = 3
	for i in range(options_max):
		# create a single option
		var option_choice: ColorRect = itemOptions.instantiate()
		# get a random option 
		option_choice.item = get_random_item()
		upgradeOptions.add_child(option_choice)
	# pause the game until upgrde is selected
	get_tree().paused = true
	
	
## Allows the player to select a weapon at the beginning
func select_first_weapon() -> void:
	# change level up label to say Select First Weapon
	levelUpLabel.text = "Select First Weapon"
	# move level panel into position and show
	var tween: Tween = levelPanel.create_tween()
	tween.tween_property(levelPanel, "position", Vector2(220, 50), .2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	# upgrade options population
	var options_max: int = 3
	for i in range(options_max):
		# create a single option
		var option_choice: ColorRect = itemOptions.instantiate()
		# get a random option 
		option_choice.item = get_random_item(["weapon"])
		upgradeOptions.add_child(option_choice)
	# pause the game until upgrade is selected
	get_tree().paused = true

## Upgrades the character with the selected upgrade
func upgrade_character(upgrade):
	match upgrade:
		"ice_spear1":
			ice_spear_level = 1
			ice_spear_base_ammo += 1
		"ice_spear2":
			ice_spear_level = 2
			ice_spear_base_ammo += 1
		"ice_spear3":
			ice_spear_level = 3
		"ice_spear4":
			ice_spear_level = 4
			ice_spear_base_ammo += 2
		"tornado1":
			tornado_level = 1
			tornado_base_ammo += 1
		"tornado2":
			tornado_level = 2
			tornado_base_ammo += 1
		"tornado3":
			tornado_level = 3
			tornado_attack_speed -= 0.5
		"tornado4":
			tornado_level = 4
			tornado_base_ammo += 1
		"javelin1":
			javelin_level = 1
			javelin_ammo = 1
		"javelin2":
			javelin_level = 2
		"javelin3":
			javelin_level = 3
		"javelin4":
			javelin_level = 4
		"armor1","armor2","armor3","armor4":
			armor += 1
		"speed1","speed2","speed3","speed4":
			movement_speed += 20.0
		"tome1","tome2","tome3","tome4":
			spell_size += 0.10
		"scroll1","scroll2","scroll3","scroll4":
			spell_cooldown += 0.05
		"ring1","ring2":
			additional_attacks += 1
		"food":
			hp += 20
			hp = clamp(hp,0,max_hp)
	# add upgrade to gui for collected upgrades 
	adjust_gui_collection(upgrade)
	#call attack script to refresh everything
	attack()
	# delete all the options
	var option_children: Array = upgradeOptions.get_children()
	for child in option_children:
		child.queue_free()
	# empty the options list
	upgrade_options.clear()
	# collect the upgrade
	collected_upgrades.append(upgrade)
	# hide the level up panel
	levelPanel.visible = false
	levelPanel.position = Vector2(800, 50)
	# change level lable back to level up (for select first weapon
	levelUpLabel.text = "Level Up!"
	# unpause the game
	get_tree().paused = false
	# recalculate how much experience is left
	calculate_exp(0)
	
## Gets a random option one at a time
# TODO: optimize this to get all random items needed
func get_random_item(only_types: Array = []) -> String:
	var db_list: Array = []
	for upgrade in UpgradeDb.UPGRADES:
		# if already collected, no need to check
		if upgrade in collected_upgrades:
			continue
		# if already in the options, no need to check
		if upgrade in upgrade_options:
			continue
		# don't pick food
		if UpgradeDb.UPGRADES[upgrade]["type"] == "item": 
			continue
		# if only certain types are included, check if the upgrade is one of the included types
		if not only_types.is_empty():
			if UpgradeDb.UPGRADES[upgrade]["type"] not in only_types:
				continue
		# if there are no prereqs it can be added to potential options
		if UpgradeDb.UPGRADES[upgrade]["prerequisites"].is_empty():
			db_list.append(upgrade)
		# if there are prereqs, add to list if prereqs are filled
		else:
			var prereq_filled: bool = true
			for prereq in UpgradeDb.UPGRADES[upgrade]["prerequisites"]:
				if prereq not in collected_upgrades:
					prereq_filled = false
					break
			if prereq_filled:
				db_list.append(upgrade) 
	
	# pick a random choice from the valid upgrade options
	if not db_list.is_empty():
		var random_item: String = db_list.pick_random()
		upgrade_options.append(random_item)
		return random_item
	return ""

## Changes the timer time based on time from the enemy spawner
func change_time(new_time: int = 0):
	# set our player's time to be the new time
	time = new_time
	# get minutes and second from overall time
	@warning_ignore("integer_division")
	var minutes: int = int(time / 60)
	var seconds: int = time % 60
	# convert to 00:00 format (double digit minutes and seconds)
	var minute_str: String = "%02d" %minutes
	var second_str: String = "%02d" %seconds
	# dipplay time in the UI
	timerLabel.text = minute_str + ":" + second_str
	
func adjust_gui_collection(upgrade) -> void:
	
	# get the upgrade's display name and type
	var upgraded_display_name: String = UpgradeDb.UPGRADES[upgrade]["display_name"]
	var upgrade_type: String = UpgradeDb.UPGRADES[upgrade]["type"]
	# skip items like food
	if upgrade_type == "item":
		return
	# find the already collected display names
	var collected_display_names: Array = []
	for collected_upgrade in collected_upgrades:
		collected_display_names.append(UpgradeDb.UPGRADES[collected_upgrade]["display_name"])
	# Add upgrade to upgrade UI if it's not already there
	if not upgraded_display_name in collected_display_names:
		# create a new item container
		var new_item: TextureRect = itemContainer.instantiate()
		# set the item's upgrade value to retirieve the correct icon
		new_item.upgrade = upgrade
		# find the type to put in the correct UI subelement (weapon or upgrade)
		match upgrade_type:
			"weapon":
				collectedWeapons.add_child(new_item)
			"upgrade":
				collectedUpgrades.add_child(new_item)

## Handles player death
func death():
	# show the death panel
	deathPanel.visible = true
	# send death signal
	player_death.emit()
	#pause the game
	get_tree().paused = true
	# move death panel into position
	var tween: Tween = deathPanel.create_tween()
	tween.tween_property(deathPanel, "position", Vector2(220, 50), 3.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	# Decide if winner of loser vased on the time they survived
	if time >= 350:
		resultLabel.text = "You Win!"
		soundVictory.play()
	else:
		resultLabel.text = "You Lose"
		soundLose.play()
	
func _on_menu_button_click_end() -> void:
	get_tree().paused = false
	var _level: Error = get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")
