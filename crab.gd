extends CharacterBody2D

@export var speed: float = 100.0;
var direction: float = 1.0
@export var damage: int = 1
@export var health: int = 2
@onready var ray_cast = $RayCast2D
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() *delta
		
	if (is_on_wall() and is_hitting_enviroment()) or not ray_cast.is_colliding():
		direction *= -1.0
		ray_cast.position.x *= -1.0
	
	velocity.x = direction * speed
	if direction != 0:
		$AnimatedSprite2D.flip_h = (direction<0)
	$AnimatedSprite2D.play("walk")
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.name == "Player":
			collider.take_damage(damage)
	
func take_damage(amount: int) -> void:
	health -= amount
	if health<=0:
		queue_free()
	else:
		for i in range(3):
			$AnimatedSprite2D.modulate.a = 0.2 
			await get_tree().create_timer(0.05).timeout
			$AnimatedSprite2D.modulate.a = 1.0
			await get_tree().create_timer(0.05).timeout
func is_hitting_enviroment() -> bool:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.name != "Player":
			return true
	return false
