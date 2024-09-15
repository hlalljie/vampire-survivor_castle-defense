@tool
extends EditorPlugin

var segment_panel: Control
var current_tilemap_layer: TileMapLayer = null
var is_active = false

func _enter_tree():
    print("Tilemap Segment Editor: Entering tree")
    
    # Create a simple panel for our tool
    segment_panel = create_segment_panel()
    add_control_to_bottom_panel(segment_panel, "Segment Editor")
    
    # Connect to the selection changed signal
    get_editor_interface().get_selection().connect("selection_changed", Callable(self, "_on_selection_changed"))

func _exit_tree():
    print("Tilemap Segment Editor: Exiting tree")
    remove_control_from_bottom_panel(segment_panel)
    segment_panel.queue_free()

func create_segment_panel() -> Control:
    var panel = Control.new()
    var vbox = VBoxContainer.new()
    panel.add_child(vbox)
    
    var activate_button = Button.new()
    activate_button.text = "Activate Segment Tool"
    activate_button.toggle_mode = true
    activate_button.connect("toggled", Callable(self, "_on_activate_button_toggled"))
    vbox.add_child(activate_button)
    
    return panel

func _on_activate_button_toggled(button_pressed):
    is_active = button_pressed
    print("Segment Tool active: ", is_active)

func _on_selection_changed():
    var selected = get_editor_interface().get_selection().get_selected_nodes()
    if selected.size() == 1 and selected[0] is TileMapLayer:
        current_tilemap_layer = selected[0]
        segment_panel.visible = true
        print("TileMapLayer selected: ", current_tilemap_layer)
    else:
        current_tilemap_layer = null
        segment_panel.visible = false
        print("TileMapLayer deselected or multiple nodes selected")

func _forward_canvas_draw_over_viewport(overlay: Control):
    if not is_active or not current_tilemap_layer:
        return
    
    # Draw a custom cursor when the tool is active
    var mouse_pos = overlay.get_local_mouse_position()
    overlay.draw_circle(mouse_pos, 5, Color.RED)

func _forward_canvas_gui_input(event: InputEvent) -> bool:
    if not is_active or not current_tilemap_layer:
        return false

    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        var tile_pos = current_tilemap_layer.local_to_map(event.position)
        print("Selected tile at position: ", tile_pos)
        return true

    return false