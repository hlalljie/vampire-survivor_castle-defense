extends ColorRect

@onready var NameLabel: Label = $NameLabel
@onready var DescriptionLabel: Label = $DescriptionLabel
@onready var LevelLabel: Label = $LevelLabel
@onready var ItemIcon: TextureRect = $ColorRect/ItemIcon

var mouse_over: bool = false
var item = null
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

signal selected_upgrade(upgrade)

func _ready() -> void:
	if not item:
		item = "food"
	# connected our selected upgrade signal to the player's upgrade character function
	connect("selected_upgrade", Callable(player, "upgrade_character"))
	# set the option labels that are displayed based on the item
	NameLabel.text = UpgradeDb.UPGRADES[item]["display_name"]
	DescriptionLabel.text = UpgradeDb.UPGRADES[item]["description"]
	LevelLabel.text = UpgradeDb.UPGRADES[item]["level"]
	ItemIcon.texture = load(UpgradeDb.UPGRADES[item]["icon"])

func _input(event):
	# if the user clicks on the item then emit that they have selected that upgrade
	if event.is_action("click"):
		if mouse_over:
			selected_upgrade.emit(item)

func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	mouse_over = false
