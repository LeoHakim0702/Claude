extends Node

signal card_played(card_data: Resource, targets: Array)
signal damage_dealt(source: Variant, target: Variant, amount: int, damage_type: String)
signal block_gained(entity: Variant, amount: int)
signal turn_started(turn_number: int)
signal turn_ended()
signal player_turn_started()
signal player_turn_ended()
signal enemy_turn_started()
signal enemy_turn_ended()
signal enemy_died(enemy: Variant)
signal combat_won()
signal combat_lost()
signal status_applied(entity: Variant, status_id: String, stacks: int)
signal status_removed(entity: Variant, status_id: String)
signal card_drawn(card_data: Resource)
signal card_discarded(card_data: Resource)
signal card_exhausted(card_data: Resource)
signal energy_changed(current: int, max_energy: int)
signal hp_changed(entity: Variant, current_hp: int, max_hp: int)
signal relic_triggered(relic_id: String, event_name: String)

# Diplomacy signals
signal diplomacy_changed(nation: int, points: int, level: int)
signal diplomacy_level_up(nation: int, new_level: int)

# Map signals
signal map_node_selected(node_id: int, node_type: int)
signal map_generated(act: int)

# Event/Story signals
signal event_started(event_id: String)
signal event_choice_made(event_id: String, choice_index: int)
signal event_completed(event_id: String)

# Relic signals
signal relic_obtained(relic_id: String)
signal relic_removed(relic_id: String)

# Run progression signals
signal act_started(act: int)
signal act_completed(act: int)
signal run_started()
signal run_ended(victory: bool)
signal combat_started()
signal reward_screen_opened()
signal rest_heal(amount: int)

# Base/hub signals
signal base_entered()
signal base_upgrade_purchased(upgrade_id: String)
