extends CharacterBody2D
@export var Bullet : PackedScene
@export var max_health: int = 5
@export var fall_death_y: float = 500.0
const SPEED = 500.0
const JUMP_VELOCITY = -900.0

var is_shooting = false

var current_health: int = 5
var is_hit = false
func take_damage(amount: int) -> void:
	if is_hit:
		return
		
	current_health -= amount
	if current_health<=0:
		die()
	else:
		is_hit = true
		
		for i in range(5):
			$AnimatedSprite2D.modulate.a = 0.3 
			await get_tree().create_timer(0.1).timeout
			$AnimatedSprite2D.modulate.a = 1.0
			await get_tree().create_timer(0.1).timeout
		
		is_hit = false
		
func shoot() -> void:
	var bullet = Bullet.instantiate()
	
	get_parent().add_child(bullet)
	bullet.global_position = $AnimatedSprite2D/Marker2D.global_position
	if $AnimatedSprite2D.flip_h:
		bullet.rotation = PI
		$AnimatedSprite2D/Marker2D.position.x = -abs($AnimatedSprite2D/Marker2D.position.x)
	else:
		$AnimatedSprite2D/Marker2D.position.x = abs($AnimatedSprite2D/Marker2D.position.x)
		bullet.rotation = 0
	is_shooting = true
	$AnimatedSprite2D.play("shoot")

func update_animation(direction:float) -> void:
	if is_shooting:
		return
		
	if not is_on_floor():
		$AnimatedSprite2D.play("jump")
	elif direction!=0:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("idle")
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("Shoot"):
		shoot()	

	var direction := Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
		$AnimatedSprite2D.flip_h = (direction<0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if global_position.y > fall_death_y:
		die()
		
	move_and_slide()
	update_animation(direction)

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "shoot":
		is_shooting=false

func die()->void:
	get_tree().reload_current_scene()
