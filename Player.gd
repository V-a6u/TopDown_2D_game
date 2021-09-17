extends KinematicBody2D

#stats
var curHp : int = 10
var maxHp : int = 10
var moveSpeed : int = 250
var damage : int = 2

var gold : int = 0

var curLevel : int = 1
var curXp : int = 0
var xpToNextLevel : int = 50
var xpToLevelIncreaseRate : float = 1.2

var interactDist : int = 70
var vel = Vector2()
var facingDir = Vector2()

onready var rayCast : RayCast2D = $RayCast2D
onready var anim = $AnimatedSprite
onready var ui = get_node("/root/MainScene/CanvasLayer/UI")

func _ready():
	ui.update_level_text(curLevel)
	ui.update_health_bar(curHp, maxHp)
	ui.update_xp_bar(curXp, xpToNextLevel)
	ui.update_gold_text(gold)

func _physics_process(delta):
	
	vel = Vector2()
	
	#inputs
	if Input.is_action_pressed("move_down"):
		vel.y += 1
		facingDir = Vector2(0, 1)
	if Input.is_action_pressed("move_up"):
		vel.y -= 1
		facingDir = Vector2(0, -1)
	if Input.is_action_pressed("move_left"):
		vel.x -= 1
		facingDir = Vector2(-1, 0)
	if Input.is_action_pressed("move_right"):
		vel.x += 1
		facingDir = Vector2(1, 0)
		
	#diagnol
	vel = vel.normalized()
	
	#move the player
	move_and_slide(vel * moveSpeed, Vector2.ZERO)
	
	#for playing animation every frame
	manage_animations()

#to play aniation
func play_animation(anim_name):
	if anim.animation != anim_name:
		anim.play(anim_name)
		
func manage_animations():
	if vel.x > 0:
		play_animation("MoveRight")
	elif vel.x < 0:
		play_animation("MoveLeft")
	elif vel.y < 0:
		play_animation("MoveUp")
	elif vel.y > 0:
		play_animation("MoveDown")
	elif facingDir.x == 1:
		play_animation("IdleRight")
	elif facingDir.x == -1:
		play_animation("IdleLeft")
	elif facingDir.y == -1:
		play_animation("IdleUp")
	elif facingDir.y == 1:
		play_animation("IdleDown")

#gold function	
func give_gold(amount):
	gold += amount
	ui.update_gold_text(gold)

#give xp
func give_xp(amount):
	curXp += amount
	
	if curXp >= xpToNextLevel:
		level_up()
		curHp += 10
		ui.update_health_bar(curHp, maxHp)
		
	ui.update_xp_bar(curXp, xpToNextLevel)

#level up		
func level_up():
	var overflowXp = curXp - xpToNextLevel
	
	xpToNextLevel *= xpToLevelIncreaseRate
	curXp = overflowXp
	curLevel += 1
	
	ui.update_level_text(curLevel)
	ui.update_xp_bar(curXp, xpToNextLevel)
	

#take damage
func take_damage(dmgToTake):
	curHp -= dmgToTake
	
	if curHp <= 0:
		die()
	
	ui.update_health_bar(curHp, maxHp)

func die():
	queue_free()
	get_tree().reload_current_scene()


func _process(delta):
	if Input.is_action_just_pressed("interact"):
		try_interact()

#check to see if RayCast is hitting anything		
func try_interact():
	rayCast.cast_to = facingDir * interactDist
	
	if rayCast.is_colliding():
		if rayCast.get_collider() is KinematicBody2D:
			rayCast.get_collider().take_damage(damage)
		elif rayCast.get_collider().has_method("on_interact"):
			rayCast.get_collider().on_interact(self)
			

