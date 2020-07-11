extends KinematicBody2D


export (float) var SPEED = 200
export (float) var JUMP_SPEED = 600
export (float) var GRAVITY = 19.6


enum {
	move,
	attack,
	dead
}

var state : int = move

var velocity : Vector2

func _process(delta):
	_handle_input(delta)
	debug()

func _handle_input(_delta):
	velocity.x = 0
	
	match state:
		attack:
			pass
		move:
			if Input.is_action_just_pressed("attack") and is_on_floor():
					$AnimSprite.play("attack")
					state = attack
					$AttackTimer.start()
					return
			if Input.is_action_pressed("move_left"):
				velocity.x = -SPEED
				$AnimSprite.flip_h = true
				$RayCast2D.scale.x = -1
				if is_on_floor():
					$AnimSprite.play("run")
			if Input.is_action_pressed("move_right"):
				velocity.x = SPEED
				$AnimSprite.flip_h = false
				$RayCast2D.scale.x = 1
				if is_on_floor():
					$AnimSprite.play("run")
			if Input.is_action_pressed("jump") && is_on_floor():
				$AnimSprite.play("jump")
				velocity.y = -JUMP_SPEED
				
			if velocity.x == 0 and is_on_floor():
				$AnimSprite.play("idle")
	
	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, Vector2.UP)



func debug() -> void:
	$CanvasLayer/Panel/RichTextLabel.text = "Player Position : %s \n Camera Position %s" % [position, $Camera2D.position]



func _on_AttackTimer_timeout():
	state = move
