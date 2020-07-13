extends KinematicBody2D


export (float) var SPEED = 200
export (float) var JUMP_SPEED = 600
export (float) var GRAVITY = 19.6
export (float) var idle_timer = 3.0

export (Array, Vector2) var patrol_points

var velocity : Vector2

var speed_direction : float = 0
var patrol_distance : float = 0

var rng : RandomNumberGenerator


#debug
var marker_debug : PackedScene = preload("res://Scenes/Environment/Marker/Marker.tscn")

var npc_actions  : Dictionary = {
	"attack" 	 : "npc_attack"	,
	"move_left"  : "npc_move_left",
	"move_right" : "npc_move_right",
	"jump"		 : "npc_jump",
}

enum {
	idle,
	move,
	attack_1,
	dead,
	patrol,
	follow
}

var state : int = move
var sub_state : int
var temp_state : int



func _ready():
	randomize()
	rng = RandomNumberGenerator.new()
	rng.randomize()
	$IdleTimer.set_wait_time(idle_timer)
	_patrol()


func _process(delta):
	_handle_input(delta)

func _handle_input(_delta):
	velocity.x = 0
	var slide_modifier = 0
	match state:
		move:
			if Input.is_action_pressed("npc_attack") and is_on_floor():
					$AnimSprite.play("attack")
					temp_state = state
					state = attack_1
					$AttackTimer.start()
					$HitTimer.start()
					return
					
			if Input.is_action_pressed("npc_move_left"):
				speed_direction = -SPEED
				velocity.x = speed_direction
				$AnimSprite.flip_h = true
				$SwordHit.scale.x = -1
				if is_on_floor():
					$AnimSprite.play("run")
					
			if Input.is_action_pressed("npc_move_right"):
				speed_direction = SPEED
				velocity.x = speed_direction
				$AnimSprite.flip_h = false
				$SwordHit.scale.x = 1
				if is_on_floor():
					$AnimSprite.play("run")
					
			if Input.is_action_pressed("npc_jump") && is_on_floor():
				$AnimSprite.play("jump")
				velocity.y = -JUMP_SPEED
			
			
			match sub_state:
				patrol:
					travel_distance(_delta)
	
	
	velocity.y += (GRAVITY - slide_modifier)
	velocity = move_and_slide(velocity, Vector2.UP)


func check_sword_hit() -> void:
	var collider = $SwordHit.get_collider()
	if collider is Player:
		if collider.has_method("dead"):
			collider.dead()
		if collider.is_dead():
			Input.action_release("npc_attack")


func _on_AttackTimer_timeout():
	state = temp_state


func _patrol() -> void:
	sub_state = patrol
	state = move
	patrol_points.shuffle()
	var choosen_point = patrol_points.front()
	var debug_marker = marker_debug.instance()
	var distance_to = global_position.distance_to(Vector2(choosen_point.x, global_position.y))
	while(distance_to < 5.0):
		patrol_points.shuffle()
		choosen_point = patrol_points.front()
		distance_to = global_position.distance_to(Vector2(choosen_point.x, global_position.y))
	patrol_distance = distance_to
	debug_marker.position = Vector2(choosen_point.x, global_position.y)
	get_parent().call_deferred("add_child", debug_marker)
	var patrol_time = distance_to / SPEED
	global_position.linear_interpolate(Vector2(choosen_point.x, global_position.y), patrol_time)
	print("DISTANCE : %s" % distance_to)
	print("INTERPOLATION TIME : %s" % (patrol_time))
	_check_patrol_anim(choosen_point)


func _reset_state() -> void:
	state = idle
	Input.action_release("npc_move_left")
	Input.action_release("npc_move_right")
	Input.action_release("npc_jump")
	Input.action_release("npc_attack")
	$AnimSprite.play("idle")


func _check_patrol_anim(choosen_point) -> void:
	if global_position > choosen_point:
		$AnimSprite.flip_h = true
		Input.action_press("npc_move_left")
	else:
		$AnimSprite.flip_h = false
		Input.action_press("npc_move_right")


func travel_distance(delta):
	if patrol_distance > 0:
		patrol_distance -= SPEED * delta
		print(patrol_distance)
	else:
		_reset_state()
		$IdleTimer.start()



func _on_ScanBox_body_entered(body):
	if body is Player:
		if not body.is_dead():
			Input.action_press("npc_attack")


func _on_ScanBox_body_exited(body):
	if body is Player:
		Input.action_release("npc_attack")


func _on_HitTimer_timeout():
	check_sword_hit()


func _on_IdleTimer_timeout():
	_patrol()
