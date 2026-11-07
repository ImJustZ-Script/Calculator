extends Node2D

@onready var cipher_select: OptionButton = $VBoxContainer/CipherSelect
@onready var input_text: LineEdit = $VBoxContainer/InputText
@onready var key_text: LineEdit = $VBoxContainer/KeyText
@onready var output_text: LineEdit = $VBoxContainer/OutputText
@onready var process_button: Button = $VBoxContainer/ProcessButton

func _ready() -> void:
	cipher_select.clear()
	cipher_select.add_item("Shift Cipher (Caesar)")
	cipher_select.add_item("Substitution (Atbash)")
	cipher_select.add_item("Transposition (Rail Fence)")
	cipher_select.add_item("Vigenère Cipher")
	
	process_button.pressed.connect(_on_process_pressed)
	cipher_select.item_selected.connect(_on_cipher_changed)
	
	# Make output box read-only so users cannot type in it
	output_text.editable = false
	
	input_text.placeholder_text = "Enter message to process..."
	output_text.placeholder_text = "Result will appear here..."
	_on_cipher_changed(0)

func _on_cipher_changed(index: int) -> void:
	match index:
		0:
			key_text.editable = true
			key_text.text = ""
			key_text.placeholder_text = "Enter shift number (e.g. 3)"
		1:
			key_text.editable = false
			key_text.text = ""
			key_text.placeholder_text = "No key needed for Substitution!"
		2:
			key_text.editable = true
			key_text.text = ""
			key_text.placeholder_text = "Enter number of rails (e.g. 3)"
		3:
			key_text.editable = true
			key_text.text = ""
			key_text.placeholder_text = "Enter secret keyword (e.g. KEY)"

func _show_error(err_msg: String) -> void:
	output_text.text = err_msg
	# Wait 2 seconds asynchronously without freezing the engine interface
	await get_tree().create_timer(2.0).timeout
	# If the box still displays this error, reset it to placeholder state
	if output_text.text == err_msg:
		output_text.text = ""

func _on_process_pressed() -> void:
	var message: String = input_text.text
	var key: String = key_text.text
	var selected_cipher: int = cipher_select.selected
	
	if message == "":
		_show_error("Error: Input message required!")
		return

	match selected_cipher:
		0: # Shift Cipher
			if not key.is_valid_int():
				_show_error("Error: Key must be a number!")
				return
			var shift: int = key.to_int()
			output_text.text = shift_cipher(message, shift)
				
		1: # Substitution (Atbash Cipher)
			output_text.text = substitution_cipher(message)
			
		2: # Transposition (Rail Fence Cipher)
			if not key.is_valid_int() or key.to_int() < 2:
				_show_error("Error: Key must be a number >= 2!")
				return
			var rails: int = key.to_int()
			output_text.text = transposition_encrypt(message, rails)
				
		3: # Vigenère Cipher
			if key == "":
				_show_error("Error: Key string required!")
				return
			output_text.text = vigenere_cipher(message, key, false)

# --- CIPHER ALGORITHMS ---

# Shift Cipher strictly shifting letters (A-Z, a-z) within 1-26 alphabet positions
func shift_cipher(text: String, shift: int) -> String:
	var result: String = ""
	for i in range(text.length()):
		var c = text[i]
		# Lowercase letters
		if c >= 'a' and c <= 'z':
			result += String.chr(97 + posmod(c.unicode_at(0) - 97 + shift, 26))
		# Uppercase letters
		elif c >= 'A' and c <= 'Z':
			result += String.chr(65 + posmod(c.unicode_at(0) - 65 + shift, 26))
		# Keep numbers, spaces, and punctuation unchanged
		else:
			result += c
	return result

func substitution_cipher(text: String) -> String:
	var result: String = ""
	for i in range(text.length()):
		var c = text[i]
		if c >= 'a' and c <= 'z':
			result += String.chr(219 - c.unicode_at(0))
		elif c >= 'A' and c <= 'Z':
			result += String.chr(155 - c.unicode_at(0))
		else:
			result += c
	return result

func transposition_encrypt(text: String, rails: int) -> String:
	var fence = []
	for r in range(rails):
		fence.append("")
	var rail = 0
	var direction = 1
	for c in text:
		fence[rail] += c
		rail += direction
		if rail == 0 or rail == rails - 1:
			direction = -direction
	var result = ""
	for r in fence:
		result += r
	return result

func vigenere_cipher(text: String, key: String, decrypt: bool) -> String:
	var result = ""
	var key_index = 0
	key = key.to_upper()
	for i in range(text.length()):
		var c = text[i]
		if c >= 'a' and c <= 'z':
			var shift = key.unicode_at(key_index % key.length()) - 65
			shift = -shift if decrypt else shift
			result += String.chr(97 + posmod(c.unicode_at(0) - 97 + shift, 26))
			key_index += 1
		elif c >= 'A' and c <= 'Z':
			var shift = key.unicode_at(key_index % key.length()) - 65
			shift = -shift if decrypt else shift
			result += String.chr(65 + posmod(c.unicode_at(0) - 65 + shift, 26))
			key_index += 1
		else:
			result += c
	return result
