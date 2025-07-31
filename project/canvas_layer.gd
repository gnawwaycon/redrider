extends CanvasLayer

@onready var console_label = $RichTextLabel

# This function is now empty
func _ready():
	pass

# This function is the same as before
func log(message):
	var text_message = str(message)
	console_label.text += text_message + "\n"

	if console_label.get_line_count() > 50:
		var all_text = console_label.text
		var first_line_end = all_text.find("\n") + 1
		console_label.text = all_text.substr(first_line_end)

# New: A simple function to clear the text that we can call from anywhere
func clear():
	console_label.text = ""
