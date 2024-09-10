extends TextureRect

var upgrade = null
func _ready():
	if upgrade:
		$ItemTexture.texture = load(UpgradeDb.UPGRADES[upgrade]["icon"])
