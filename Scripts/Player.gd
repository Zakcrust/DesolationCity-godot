extends KinematicBody2D

class_name Player


export (float) var SPEED = 200
export (float) var JUMP_SPEED = 600
export (float) var GRAVITY = 19.6
var WALL_SLIDE_MODIFIER : float = GRAVITY * 0.9
var ROLL_SPEED : float = 0

var is_jumping : bool = false
var is_blocking : bool = true
var can_roll : bool = true
var is_dead : bool = false

var speed_direction : float = 0

enum {
	move,
	block,
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
	_debug()

func _handle_input(_delta):
	velocity.x = 0
	var slide_modifier = 0
	velocity.y += (GRAVITY - slide_modifier)
	
	
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
			
			if Input.is_action_pressed("roll") and is_on_floor() and can_roll and velocity.x != 0:
				ROLL_SPEED = speed_direction
				$RollTimer.start()
				$RollCooldown.start()
				$AnimSprite.play("roll")
				can_roll = false
				state = roll
			
			if Input.is_action_pressed("block"):
				is_blocking = true
				$AnimSprite.play("block")
				state = block
			
			if velocity.x == 0 and is_on_floor():
				$AnimSprite.play("idle")
			
			if not is_on_floor() and not is_jumping:
				$AnimSprite.play("fall")
#				if is_on_wall():
#					slide_modifier = WALL_SLIDE_MODIFIER
#					$AnimSprite.play("wall_slide")
#				else:
#					slide_modifier = 0
		roll:
			velocity.x = ROLL_SPEED
		
		block:
			if Input.is_action_just_pressed("attack") and is_on_floor():
					$AnimSprite.play("attack")
					state = attack_1
					$AttackTimer.start()
					return
				
			if Input.is_action_just_pressed("move_left"):
				$AnimSprite.flip_h = true
				$RayCast2D.scale.x = -1
			
			if Input.is_action_just_pressed("move_right"):
				$AnimSprite.flip_h = false
				$RayCast2D.scale.x = 1
			
			if Input.is_action_pressed("block"):
				is_blocking = true
				$AnimSprite.play("block")
				
			if not is_on_floor() and not is_jumping:
				$AnimSprite.play("fall")
			
			if Input.is_action_just_released("block"):
				$AnimSprite.play("idle")
				state = move
				is_blocking = false
				
				
		dead:
			velocity.y = 0
		
		
	velocity = move_and_slide(velocity, Vector2.UP)


func dead() -> void:
	state = dead
	is_dead = true
	$CollisionShape2D.disabled = true
	$AnimSprite.play("dead")


func is_dead() -> bool:
	return is_dead




func _debug() -> void:
	var debug_text : String = ""
	debug_text += "State : %s \n" % _get_debug_state(state)
	debug_text += "Is Jumping : %s \n" % is_jumping
	debug_text += "Is Blocking : %s \n" % is_blocking
	debug_text += "Can roll : %s \n" % can_roll
	$CanvasLayer/Debug/Text.text = debug_text
	pass


func _get_debug_state(state) -> String:
	var result : String
	match state:
		move:
			result = "move"
		attack_1:
			result = "attack_1"
		attack_2:
			result = "attack_2"
		attack_3:
			result = "attack_3"
		roll:
			result = "roll"
		dead:
			result = "dead"
		block:
			result = "block"
			
			
	return result



func _on_AttackTimer_timeout():
	state = move


func _on_JumpTimer_timeout():
	is_jumping = false


func _on_RollTimer_timeout():
	state = move


func _on_RollCooldown_timeout():
	can_roll = true
