class_name DamageCalc
extends RefCounted


static func calculate_damage(base_damage: int, attacker_statuses: Dictionary, target_statuses: Dictionary) -> int:
	var damage: int = base_damage

	# Add strength from attacker
	damage += attacker_statuses.get("strength", 0)

	# Weak reduces damage by 25%
	if attacker_statuses.get("weak", 0) > 0:
		damage = int(damage * 0.75)

	# Vulnerable increases damage by 50%
	if target_statuses.get("vulnerable", 0) > 0:
		damage = int(damage * 1.5)

	return max(0, damage)


static func apply_damage_to_target(damage: int, target_block: int, target_hp: int) -> Dictionary:
	var result: Dictionary = {
		"remaining_block": 0,
		"remaining_hp": 0,
		"damage_dealt": 0,
		"block_broken": false,
	}

	if damage <= target_block:
		result.remaining_block = target_block - damage
		result.remaining_hp = target_hp
		result.damage_dealt = 0
		result.block_broken = false
	else:
		var overflow: int = damage - target_block
		result.remaining_block = 0
		result.remaining_hp = max(0, target_hp - overflow)
		result.damage_dealt = overflow
		result.block_broken = target_block > 0

	return result
