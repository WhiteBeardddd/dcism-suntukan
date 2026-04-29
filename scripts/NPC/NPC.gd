extends Area2D

@export var dialog_lines: Array[String] = [
	"Hey, you seem pretty strong!",
	"Wanna spar?",
	"Wait...",
	"I shouldn't waste my energy before an important battle...",
	"Well, I'll see you at the buffet!"
]

# Updated to match your exact node names from the screenshot!
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D 
@onready var prompt_label: Label = $CanvasLayer/Label

func _ready() -> void:
	# Make sure the label is hidden when the game first starts
	prompt_label.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("advance_dialog"): 
		if get_overlapping_bodies().size() > 0:
			if not DialogManager.is_dialog_active:
				
				# Hide the "Talk" prompt while the dialogue box is open
				prompt_label.hide()
				
				var spawn_position = global_position + Vector2(0, -50)
				DialogManager.start_dialog(spawn_position, dialog_lines)
				
				var player = get_overlapping_bodies()[0]
				sprite.flip_h = player.global_position.x < global_position.x

# Make sure these two functions are connected via the Node panel!
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# Show the prompt when the player gets close
		prompt_label.show()

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		# Hide the prompt when the player walks away
		prompt_label.hide()
