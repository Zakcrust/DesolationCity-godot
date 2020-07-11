extends KinematicBody2D


export (float) var SPEED = 200
export (float) var JUMP_SPEED = 600
export (float) var GRAVITY = 19.6
var WALL_SLIDE_MODIFIER : float = GRAVITY * 0.3
var ROLL_SPEED : float = 0
var is_jumping : bool = false

var speed_direction : float = 0

enum {
	move,
	roll,
	attack_1,
	attack_2,
	attack_3
	dead
}

var state : int = move

var velocity : Vector2

func _process(delta):
	_handle_input(delta)
	

func _handle_input(_delta):
	velocity.x = 0
	var slide_modifier = 0
	match state:
		attack_1:
			if Input.is_action_just_pressed("attack") and is_on_floor():
					$AnimSprite.play("attack_1")
					state = attack_2
					$AttackTimer.stop()
					$AttackTimer.start()
		attack_2:
			if Input.is_action_just_pressed("attack") and is_on_floor():
					$AnimSprite.play("attack_2")
					state = attack_3
					$AttackTimer.stop()
					$AttackTimer.start()
		attack_3:
			pass
		move:
			if Input.is_action_just_pressed("attack") and is_on_floor():
					$AnimSprite.play("attack")
					state = attack_1
					$AttackTimer.start()
					return
					
			if Input.is_action_pressed("move_left"):
				speed_direction = -SPEED
				velocity.x = speed_direction
				$AnimSprite.flip_h = true
				$RayCast2D.scale.x = -1
				if is_on_floor():
					$AnimSprite.play("run")
					
			if Input.is_action_pressed("move_right"):
				speed_direction = SPEED
				velocity.x = speed_direction
				$AnimSprite.flip_h = false
				$RayCast2D.scale.x = 1
				if is_on_floor():
					$AnimSprite.play("run")
					
			if Input.is_action_pressed("jump") && is_on_floor():
				is_jumping = true
				$JumpTimer.start()
				$AnimSprite.play("jump")
				velocity.y = -JUMP_SPEED
			
			if Input.is_action_pressed("roll"):
				ROLL_SPEED = speed_direction
				$RollTimer.start()
				$AnimSprite.play("roll")
				state = roll
				
			if velocity.x == 0 and is_on_floor():
				$AnimSprite.play("idle")
			
			if not is_on_floor() and not is_jumping:
				$AnimSprite.play("fall")
				if is_on_wall():
					slide_modifier = WALL_SLIDE_MODIFIER
					$AnimSprite.play("wall_slide")
				else:
					slide_modifier = 0
			
			
		roll:
			velocity.x = ROLL_SPEED
			
			
	
	velocity.y += (GRAVITY - slide_modifier)
	velocity = move_and_slide(velocity, Vector2.UP)



func _on_AttackTimer_timeout():
	state = move


func _on_JumpTimer_timeout():
	is_jumping = false


func _on_RollTimer_timeout():
	state = move
