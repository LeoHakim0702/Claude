class_name EffectResolver
extends RefCounted

var _deck_manager: DeckManager
var _energy_manager: EnergyManager


func init_resolver(deck_mgr: DeckManager, energy_mgr: EnergyManager) -> void:
	_deck_manager = deck_mgr
	_energy_manager = energy_mgr


func resolve_card(card_data, targets: Array, enemies: Array) -> void:
	for effect: Dictionary in card_data.effects:
		var effect_type: String = effect.get("type", "")
		match effect_type:
			"DAMAGE":
				var base: int = effect.value
				var hits: int = effect.get("hits", 1)
				for i in range(hits):
					for target in targets:
						var final_dmg: int = DamageCalc.calculate_damage(
							base, GameState.player_statuses, target.statuses
						)
						target.take_damage(final_dmg)
						EventBus.damage_dealt.emit(null, target, final_dmg, "card")

			"DAMAGE_ALL":
				var base: int = effect.value
				for enemy in enemies:
					var final_dmg: int = DamageCalc.calculate_damage(
						base, GameState.player_statuses, enemy.statuses
					)
					enemy.take_damage(final_dmg)
					EventBus.damage_dealt.emit(null, enemy, final_dmg, "card")

			"BLOCK":
				var amount: int = effect.value
				var dex: int = GameState.get_status_stacks("dexterity")
				GameState.add_block(amount + dex)

			"APPLY_STATUS":
				var status_id: String = effect.get("status_id", "")
				var stacks: int = effect.value
				var effect_target: String = effect.get("target", "TARGET")
				match effect_target:
					"SELF":
						GameState.apply_status(status_id, stacks)
					"TARGET":
						for t in targets:
							t.apply_status(status_id, stacks)
					"ALL_ENEMIES":
						for e in enemies:
							e.apply_status(status_id, stacks)

			"DRAW":
				_deck_manager.draw_cards(effect.value)

			"GAIN_ENERGY":
				_energy_manager.gain_energy(effect.value)

			"HEAL":
				GameState.modify_hp(effect.value)

			"EXHAUST_SELF":
				pass  # Handled by caller after resolve


func resolve_enemy_effects(effects: Array, enemy, target_is_player: bool) -> void:
	for effect: Dictionary in effects:
		var effect_type: String = effect.get("type", "")
		match effect_type:
			"DAMAGE":
				var base: int = effect.value
				var hits: int = effect.get("hits", 1)
				for i in range(hits):
					var final_dmg: int = DamageCalc.calculate_damage(
						base, enemy.statuses, GameState.player_statuses
					)
					var result: Dictionary = DamageCalc.apply_damage_to_target(
						final_dmg, GameState.player_block, GameState.player_hp
					)
					GameState.player_block = result.remaining_block
					GameState.player_hp = result.remaining_hp
					EventBus.damage_dealt.emit(enemy, null, final_dmg, "enemy")
					EventBus.hp_changed.emit(null, GameState.player_hp, GameState.player_max_hp)

			"BLOCK":
				enemy.add_block(effect.value)

			"APPLY_STATUS":
				var status_id: String = effect.get("status_id", "")
				var stacks: int = effect.value
				var effect_target: String = effect.get("target", "TARGET")
				if effect_target == "SELF":
					enemy.apply_status(status_id, stacks)
				else:
					GameState.apply_status(status_id, stacks)
