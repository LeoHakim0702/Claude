class_name EventDatabase


static func _create_event(
	p_id: String,
	p_name: String,
	p_name_zh: String,
	p_type: int,
	p_act: int,
	p_description: String,
	p_description_zh: String,
	p_choices: Array[Dictionary],
	p_image_hint: String = "",
) -> EventData:
	var event := EventData.new()
	event.id = p_id
	event.event_name = p_name
	event.event_name_zh = p_name_zh
	event.event_type = p_type
	event.act = p_act
	event.description = p_description
	event.description_zh = p_description_zh
	event.choices = p_choices
	event.image_hint = p_image_hint
	return event


# =============================================================================
# ACT 1 EVENTS — Southeast Asia (南洋)
# =============================================================================

static func _act1_events() -> Array[Resource]:
	var events: Array[Resource] = []

	# 1. Storm at Sea
	events.append(_create_event(
		"storm_at_sea", "Storm at Sea", "海上风暴",
		EventData.EventType.RANDOM, 1,
		"A violent storm threatens to damage the fleet. Dark clouds swallow the horizon as waves crash against the hull. The crew looks to you for orders.",
		"一场猛烈的风暴威胁着舰队。乌云吞噬了地平线，巨浪拍打着船体。船员们望向你等待命令。",
		[
			{
				text = "Brave the storm",
				text_zh = "顶风前行",
				effects = [
					{type = "damage", value = 12, variance = 4},
					{type = "gold", value = 15},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "The fleet takes a battering, but you salvage valuable debris from other wrecked vessels.",
				result_text_zh = "舰队受到重创，但你从其他沉船残骸中打捞到了有价值的物资。",
			},
			{
				text = "Seek shelter at a nearby island",
				text_zh = "在附近岛屿避风",
				effects = [
					{type = "heal", value = 5},
					{type = "card", value = "random_common"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "You find a sheltered cove and the crew discovers useful supplies on the island.",
				result_text_zh = "你找到了一处避风港湾，船员们在岛上发现了有用的补给。",
			},
			{
				text = "Sacrifice cargo to lighten the ships",
				text_zh = "抛弃货物减轻船重",
				effects = [
					{type = "gold", value = -20},
					{type = "relic", value = "random", chance = 0.4},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "As cargo sinks, something strange floats to the surface—an artifact from a sunken vessel.",
				result_text_zh = "当货物沉入海中时，一件奇异之物浮出水面——一件来自沉船的宝物。",
			},
		] as Array[Dictionary],
		"ink_wash_storm_waves_fleet"
	))

	# 2. Pirate Ambush
	events.append(_create_event(
		"pirate_ambush", "Pirate Ambush", "海盗伏击",
		EventData.EventType.RANDOM, 1,
		"Pirates lurk in the narrow strait ahead. Their junks emerge from hidden coves, blocking the passage. Their leader signals for parley—or battle.",
		"海盗潜伏在前方的狭窄海峡中。他们的船只从隐蔽的海湾中驶出，封锁了航道。海盗头目示意谈判——或开战。",
		[
			{
				text = "Fight through",
				text_zh = "奋力突围",
				effects = [
					{type = "combat", value = "pirate_skiff"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "You order the fleet into battle formation. The pirates will learn to fear Zheng He's armada.",
				result_text_zh = "你下令舰队进入战斗阵型。海盗们将学会畏惧郑和的舰队。",
			},
			{
				text = "Pay tribute to pass",
				text_zh = "缴纳过路费",
				effects = [
					{type = "gold", value = -25},
				] as Array[Dictionary],
				requirements = {gold_min = 25} as Dictionary,
				result_text = "The pirate captain grins as he accepts your payment. A bitter pill, but the fleet passes unharmed.",
				result_text_zh = "海盗头目笑着收下了钱财。虽然屈辱，但舰队安全通过了。",
			},
			{
				text = "Take a longer route around",
				text_zh = "绕道而行",
				effects = [
					{type = "damage", value = 5},
					{type = "diplomacy", value = 3, nation = "CHAMPA"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "The detour is exhausting but leads past a Champa fishing village. They welcome you warmly.",
				result_text_zh = "绕道十分疲惫，但途经了一个占城渔村。他们热情地欢迎了你们。",
			},
		] as Array[Dictionary],
		"ink_wash_pirate_ships_strait"
	))

	# 3. Champa Port
	events.append(_create_event(
		"champa_port", "Port of Champa", "占城港口",
		EventData.EventType.STORY, 1,
		"The fleet arrives at the ancient port of Champa. Towers of carved sandstone overlook a harbor bustling with merchants from a dozen lands. The Cham king has been informed of your arrival.",
		"舰队抵达古老的占城港口。雕刻精美的砂岩塔楼俯瞰着繁忙的港湾，来自十几个国家的商人在此贸易。占城国王已经得知了你的到来。",
		[
			{
				text = "Trade silk for local goods",
				text_zh = "用丝绸换取当地特产",
				effects = [
					{type = "gold", value = -15},
					{type = "card", value = "random_uncommon"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "The Cham merchants are delighted by your fine silk. In return, they offer rare local treasures.",
				result_text_zh = "占城商人对你的精美丝绸爱不释手。作为回报，他们献上了珍贵的当地宝物。",
			},
			{
				text = "Present gifts to the king",
				text_zh = "向国王献礼",
				effects = [
					{type = "gold", value = -30},
					{type = "diplomacy", value = 8, nation = "CHAMPA"},
				] as Array[Dictionary],
				requirements = {gold_min = 30} as Dictionary,
				result_text = "The Cham king is greatly pleased and declares Zheng He a friend of the kingdom.",
				result_text_zh = "占城国王大为欣喜，宣布郑和为王国之友。",
			},
			{
				text = "Resupply and rest",
				text_zh = "补给休整",
				effects = [
					{type = "heal", value = 10},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "The crew enjoys fresh food and clean water. Spirits are high as you prepare to depart.",
				result_text_zh = "船员们享用了新鲜的食物和清水。准备出发时，士气高涨。",
			},
		] as Array[Dictionary],
		"ink_wash_champa_port_sandstone_towers"
	))

	# 4. Mysterious Island
	events.append(_create_event(
		"mysterious_island", "Mysterious Island", "神秘岛屿",
		EventData.EventType.RANDOM, 1,
		"An uncharted island appears through the mist. Strange bird calls echo from its jungle interior, and an ancient stone archway stands at the shore.",
		"一座未知的岛屿从迷雾中浮现。奇异的鸟鸣从丛林深处传来，岸边矗立着一座古老的石拱门。",
		[
			{
				text = "Explore the island",
				text_zh = "探索岛屿",
				effects = [
					{type = "random_outcome", outcomes = [
						{chance = 0.5, effects = [{type = "relic", value = "random"}]},
						{chance = 0.5, effects = [{type = "damage", value = 10}]},
					]},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "You venture past the archway into the unknown...",
				result_text_zh = "你穿过石拱门，走向未知……",
			},
			{
				text = "Send scouts first",
				text_zh = "先派侦察兵",
				effects = [
					{type = "card", value = "random"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "Your scouts return with useful findings and a strange technique they observed from island wildlife.",
				result_text_zh = "侦察兵带回了有用的发现和他们从岛上野生动物那里观察到的奇特技巧。",
			},
			{
				text = "Sail past",
				text_zh = "绕行驶过",
				effects = [] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "Caution is its own reward. The fleet continues on its charted course.",
				result_text_zh = "谨慎本身就是回报。舰队继续沿着航线前进。",
			},
		] as Array[Dictionary],
		"ink_wash_misty_island_stone_arch"
	))

	# 5. Crew Morale
	events.append(_create_event(
		"crew_morale", "Crew Morale", "船员士气",
		EventData.EventType.RANDOM, 1,
		"The crew grows restless after weeks at sea. Whispers of homesickness spread through the lower decks. Something must be done before discontent festers.",
		"在海上航行数周后，船员们变得焦躁不安。思乡之情在底舱蔓延。必须在不满情绪恶化之前采取行动。",
		[
			{
				text = "Distribute extra rations",
				text_zh = "分发额外口粮",
				effects = [
					{type = "gold", value = -15},
					{type = "remove_card", value = "Curse"},
				] as Array[Dictionary],
				requirements = {gold_min = 15} as Dictionary,
				result_text = "Full bellies ease troubled minds. The dark mood that plagued the crew lifts like morning fog.",
				result_text_zh = "饱餐一顿缓解了忧虑。困扰船员们的阴霾如晨雾般散去。",
			},
			{
				text = "Give an inspiring speech",
				text_zh = "发表鼓舞人心的演讲",
				effects = [
					{type = "buff", value = "strength", amount = 2, duration = "next_combat"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "You remind them of the Emperor's trust and the glory that awaits. The crew roars with renewed purpose.",
				result_text_zh = "你提醒他们皇帝的信任和等待他们的荣耀。船员们重新振奋，高声欢呼。",
			},
			{
				text = "Enforce strict discipline",
				text_zh = "严格执行纪律",
				effects = [
					{type = "card", value = "add_curse"},
					{type = "gold", value = 25},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "Order is restored through iron will, but resentment simmers beneath the surface. At least the work gets done efficiently.",
				result_text_zh = "通过铁腕手段恢复了秩序，但怨恨在暗中酝酿。至少工作效率提高了。",
			},
		] as Array[Dictionary],
		"ink_wash_crew_gathering_deck"
	))

	# 6. Java Spice Market
	events.append(_create_event(
		"java_spice_market", "Java Spice Market", "爪哇香料市场",
		EventData.EventType.RANDOM, 1,
		"The famous spice market of Java beckons with intoxicating aromas. Mountains of cloves, nutmeg, and pepper fill the stalls. Fortunes are made and lost here daily.",
		"爪哇著名的香料市场散发着醉人的芳香。丁香、肉豆蔻和胡椒堆积如山。每天都有人在这里发财或破产。",
		[
			{
				text = "Buy rare spices",
				text_zh = "购买珍稀香料",
				effects = [
					{type = "gold", value = -30},
					{type = "relic", value = "spice_pouch"},
				] as Array[Dictionary],
				requirements = {gold_min = 30} as Dictionary,
				result_text = "You acquire a pouch of the finest spices—worth a king's ransom back in Nanjing.",
				result_text_zh = "你获得了一袋最上等的香料——在南京可值一座金山。",
			},
			{
				text = "Trade porcelain for spices",
				text_zh = "用瓷器换香料",
				effects = [
					{type = "relic_upgrade", value = "porcelain_vase"},
				] as Array[Dictionary],
				requirements = {relic = "porcelain_vase"} as Dictionary,
				result_text = "The Javanese merchant's eyes widen at your porcelain. The resulting trade enhances your collection beyond measure.",
				result_text_zh = "爪哇商人看到你的瓷器两眼放光。这笔交易使你的收藏价值倍增。",
			},
			{
				text = "Just browse the stalls",
				text_zh = "随便逛逛",
				effects = [
					{type = "gold", value = 10},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "You make a few small trades and enjoy the vibrant atmosphere of the market.",
				result_text_zh = "你做了几笔小买卖，享受着市场的热闹气氛。",
			},
		] as Array[Dictionary],
		"ink_wash_java_market_spice_stalls"
	))

	# 7. Palembang Harbor
	events.append(_create_event(
		"palembang_harbor", "Palembang Harbor", "旧港停泊",
		EventData.EventType.STORY, 1,
		"The fleet reaches Palembang, home of a thriving Chinese diaspora. Familiar faces and dialects greet you at the docks. The community elder approaches with news of pirate activity in nearby waters.",
		"舰队抵达旧港，这里是繁荣的华人社区所在地。熟悉的面孔和乡音在码头迎接你。社区长老带来了附近海域海盗活动的消息。",
		[
			{
				text = "Meet the Chinese community",
				text_zh = "拜访华人社区",
				effects = [
					{type = "diplomacy", value = 10, nation = "PALEMBANG"},
					{type = "heal", value = 5},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "The community welcomes you with a feast. Their knowledge of local waters proves invaluable.",
				result_text_zh = "社区以盛宴欢迎你。他们对当地水域的了解非常宝贵。",
			},
			{
				text = "Recruit local sailors",
				text_zh = "招募当地水手",
				effects = [
					{type = "card", value = "rally_crew"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "Several experienced local sailors join your crew, eager to serve the great Admiral.",
				result_text_zh = "几位经验丰富的当地水手加入了你的船队，渴望为伟大的海军统帅效力。",
			},
			{
				text = "Investigate pirate activity",
				text_zh = "调查海盗活动",
				effects = [
					{type = "diplomacy", value = 5, nation = "PALEMBANG"},
					{type = "debuff_enemy", value = "strength", amount = -1, duration = "next_elite"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "Your investigation reveals the pirates' weaknesses. The next elite foe will start weakened.",
				result_text_zh = "调查揭示了海盗的弱点。下一个精英敌人将以虚弱状态开始战斗。",
			},
		] as Array[Dictionary],
		"ink_wash_palembang_harbor_chinese_quarter"
	))

	return events


# =============================================================================
# ACT 2 EVENTS — Indian Ocean (印度洋)
# =============================================================================

static func _act2_events() -> Array[Resource]:
	var events: Array[Resource] = []

	# 8. Malacca Strait
	events.append(_create_event(
		"malacca_strait", "Strait of Malacca", "马六甲海峡",
		EventData.EventType.STORY, 2,
		"The critical passage between East and West. Control of this strait means control of trade itself. The local sultan watches your fleet with a mix of awe and suspicion.",
		"东西方之间的关键通道。控制这条海峡意味着控制贸易本身。当地苏丹以敬畏和猜疑交织的目光注视着你的舰队。",
		[
			{
				text = "Establish a trading post",
				text_zh = "建立贸易站",
				effects = [
					{type = "gold", value = -40},
					{type = "diplomacy", value = 15, nation = "MALACCA"},
				] as Array[Dictionary],
				requirements = {gold_min = 40} as Dictionary,
				result_text = "The trading post becomes a beacon of Chinese commerce. The sultan grants you his favor.",
				result_text_zh = "贸易站成为中国商贸的灯塔。苏丹向你示好。",
			},
			{
				text = "Pay the local toll",
				text_zh = "缴纳当地关税",
				effects = [
					{type = "gold", value = -20},
				] as Array[Dictionary],
				requirements = {gold_min = 20} as Dictionary,
				result_text = "A reasonable price for safe passage through these treacherous waters.",
				result_text_zh = "为安全通过这片凶险水域，这是合理的代价。",
			},
			{
				text = "Force passage through",
				text_zh = "强行通过",
				effects = [
					{type = "combat", value = "malacca_patrol"},
					{type = "diplomacy", value = -5, nation = "MALACCA"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "Your fleet's might makes the point, but you have made an enemy of the sultan.",
				result_text_zh = "舰队的实力说明了一切，但你也得罪了苏丹。",
			},
		] as Array[Dictionary],
		"ink_wash_malacca_strait_ships"
	))

	# 9. Calicut Arrival
	events.append(_create_event(
		"calicut_arrival", "Arrival at Calicut", "古里到达",
		EventData.EventType.STORY, 2,
		"The great port of Calicut, jewel of the Indian Ocean. Spices, textiles, and precious stones flow through its markets. The Zamorin awaits your delegation.",
		"印度洋的明珠——古里大港。香料、丝绸和宝石在其市场中流通。扎莫林等待着你的代表团。",
		[
			{
				text = "Present the Emperor's letter",
				text_zh = "呈递皇帝国书",
				effects = [
					{type = "diplomacy", value = 10, nation = "CALICUT"},
					{type = "relic", value = "silk_bolt"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "The Zamorin is impressed by the Emperor's words. He gifts you a bolt of the finest Calicut silk.",
				result_text_zh = "扎莫林对皇帝的信函印象深刻。他赠予你一匹最上等的古里丝绸。",
			},
			{
				text = "Open free trade",
				text_zh = "开放自由贸易",
				effects = [
					{type = "gold", value = 50},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "Trade flows freely and profitably. Chinese porcelain commands extraordinary prices here.",
				result_text_zh = "贸易自由而有利。中国瓷器在这里能卖出惊人的价格。",
			},
			{
				text = "Request a military alliance",
				text_zh = "请求军事联盟",
				effects = [
					{type = "diplomacy", value = 5, nation = "CALICUT"},
					{type = "card", value = "random_rare_attack"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "The Zamorin agrees to share military knowledge. His warriors teach you a powerful technique.",
				result_text_zh = "扎莫林同意分享军事知识。他的武士们教给你一种强大的技法。",
			},
		] as Array[Dictionary],
		"ink_wash_calicut_palace_harbor"
	))

	# 10. Monsoon Season
	events.append(_create_event(
		"monsoon_season", "Monsoon Season", "季风季节",
		EventData.EventType.RANDOM, 2,
		"The monsoon winds can speed your journey—or destroy it. Experienced sailors read the clouds with furrowed brows. The decision is yours, Admiral.",
		"季风可以加速你的航程——也可以摧毁它。经验丰富的水手们紧锁眉头观察云层。决定权在你手中，统帅。",
		[
			{
				text = "Ride the monsoon winds",
				text_zh = "乘季风而行",
				effects = [
					{type = "skip_nodes", value = 2},
					{type = "damage", value = 10},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "The winds hurl you forward at incredible speed. The fleet takes damage but covers vast distance.",
				result_text_zh = "狂风推动你以惊人的速度前进。舰队虽然受损但跨越了巨大的距离。",
			},
			{
				text = "Wait for calm weather",
				text_zh = "等待天气平息",
				effects = [
					{type = "heal", value = 999},
					{type = "gold", value = -30},
				] as Array[Dictionary],
				requirements = {gold_min = 30} as Dictionary,
				result_text = "Days pass in port. The crew rests fully, but port fees drain your coffers.",
				result_text_zh = "在港口度过了数日。船员们得到了充分休息，但港口费用消耗了你的金库。",
			},
			{
				text = "Study the wind patterns",
				text_zh = "研究风向规律",
				effects = [
					{type = "card", value = "monsoon_wind"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "Hours of careful observation yield a breakthrough in understanding the monsoon cycles.",
				result_text_zh = "数小时的细致观察让你对季风周期有了突破性的认识。",
			},
		] as Array[Dictionary],
		"ink_wash_monsoon_clouds_ocean"
	))

	# 11. Ceylon Gems
	events.append(_create_event(
		"ceylon_gems", "Gems of Ceylon", "锡兰宝石",
		EventData.EventType.RANDOM, 2,
		"The island of gems offers rare treasures. Sapphires, rubies, and cat's eye stones gleam in the merchants' hands. Such wealth could fund the entire voyage.",
		"宝石之岛展示着稀世珍宝。蓝宝石、红宝石和猫眼石在商人手中闪耀。这样的财富足以资助整个航程。",
		[
			{
				text = "Purchase Ceylon gems",
				text_zh = "购买锡兰宝石",
				effects = [
					{type = "gold", value = -50},
					{type = "relic", value = "ceylon_gems"},
				] as Array[Dictionary],
				requirements = {gold_min = 50} as Dictionary,
				result_text = "You acquire a collection of dazzling gems. Their beauty is matched only by their value.",
				result_text_zh = "你获得了一批耀眼的宝石。它们的美丽与价值相得益彰。",
			},
			{
				text = "Trade silk for gems",
				text_zh = "以丝换宝",
				effects = [
					{type = "relic_remove", value = "silk_bolt"},
					{type = "relic", value = "ceylon_gems"},
				] as Array[Dictionary],
				requirements = {relic = "silk_bolt"} as Dictionary,
				result_text = "The gem merchant's eyes light up at your silk. An excellent trade for both parties.",
				result_text_zh = "宝石商人看到你的丝绸两眼放光。对双方来说都是一笔极好的交易。",
			},
			{
				text = "Admire and move on",
				text_zh = "欣赏一番便离去",
				effects = [
					{type = "gold", value = 5},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "You make a few small purchases as souvenirs. The gems are beautiful but your mission calls.",
				result_text_zh = "你买了几件小纪念品。宝石虽美，但使命在召唤。",
			},
		] as Array[Dictionary],
		"ink_wash_ceylon_gem_market"
	))

	# 12. Indian Scholars
	events.append(_create_event(
		"indian_scholars", "Indian Scholars", "印度学者",
		EventData.EventType.RANDOM, 2,
		"Scholars offer to teach advanced navigation techniques. Their knowledge of mathematics and astronomy far surpasses what you have encountered before.",
		"学者们愿意教授先进的航海技术。他们在数学和天文学方面的知识远超你之前所见。",
		[
			{
				text = "Study with them",
				text_zh = "跟随他们学习",
				effects = [
					{type = "upgrade_card", value = "random"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "Their teachings refine your understanding. One of your techniques is elevated to new heights.",
				result_text_zh = "他们的教导提升了你的认知。你的一种技法达到了新的高度。",
			},
			{
				text = "Exchange knowledge mutually",
				text_zh = "互相交流知识",
				effects = [
					{type = "diplomacy", value = 8, nation = "CALICUT"},
					{type = "relic", value = "star_chart"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "A fruitful exchange! They gift you a star chart of remarkable precision, and your shared knowledge deepens ties.",
				result_text_zh = "富有成果的交流！他们赠予你一张精密的星图，共享的知识加深了纽带。",
			},
			{
				text = "Politely decline",
				text_zh = "婉言谢绝",
				effects = [
					{type = "gold", value = 10},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "The scholars understand. They offer a small parting gift as a token of respect.",
				result_text_zh = "学者们表示理解。他们赠送了一份小礼物以表敬意。",
			},
		] as Array[Dictionary],
		"ink_wash_scholars_astronomy_instruments"
	))

	# 13. Merchant Rivalry
	events.append(_create_event(
		"merchant_rivalry", "Merchant Rivalry", "商人竞争",
		EventData.EventType.RANDOM, 2,
		"Arab merchants see you as competition threatening their monopoly on the spice trade. Their leader confronts you at the harbor, flanked by armed guards.",
		"阿拉伯商人视你为威胁其香料贸易垄断地位的竞争对手。他们的首领在武装护卫的簇拥下在港口与你对峙。",
		[
			{
				text = "Negotiate a partnership",
				text_zh = "协商合作",
				effects = [
					{type = "diplomacy", value = 5, nation = "ADEN"},
					{type = "gold", value = 25},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "After tense negotiations, you find common ground. Both sides profit from cooperation.",
				result_text_zh = "经过紧张的谈判，双方找到了共同利益。合作使双方获利。",
			},
			{
				text = "Undersell their goods",
				text_zh = "低价竞争",
				effects = [
					{type = "gold", value = 40},
					{type = "diplomacy", value = -5, nation = "ADEN"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "Your lower prices draw crowds of buyers. The Arab merchants seethe, but your coffers overflow.",
				result_text_zh = "你的低价吸引了大批买家。阿拉伯商人愤怒不已，但你的金库溢满了。",
			},
			{
				text = "Avoid conflict entirely",
				text_zh = "完全避免冲突",
				effects = [] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "You wisely choose to avoid the confrontation. There are larger battles to fight.",
				result_text_zh = "你明智地选择避免对抗。还有更大的战役要打。",
			},
		] as Array[Dictionary],
		"ink_wash_harbor_confrontation_merchants"
	))

	return events


# =============================================================================
# ACT 3 EVENTS — Middle East & Africa (西域非洲)
# =============================================================================

static func _act3_events() -> Array[Resource]:
	var events: Array[Resource] = []

	# 14. Hormuz Palace
	events.append(_create_event(
		"hormuz_palace", "Palace of Hormuz", "霍尔木兹宫殿",
		EventData.EventType.STORY, 3,
		"The Sultan of Hormuz invites you to his magnificent palace. Gold-domed towers rise above gardens of jasmine and rose. A feast has been prepared in your honor.",
		"霍尔木兹苏丹邀请你前往他壮丽的宫殿。金顶塔楼矗立在茉莉花和玫瑰花园之上。一场为你准备的盛宴已经备好。",
		[
			{
				text = "Attend the feast",
				text_zh = "参加宴会",
				effects = [
					{type = "diplomacy", value = 12, nation = "HORMUZ"},
					{type = "heal", value = 15},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "The feast is extraordinary. The sultan and you trade stories late into the night.",
				result_text_zh = "宴会十分盛大。你与苏丹畅谈至深夜。",
			},
			{
				text = "Bring imperial gifts",
				text_zh = "带上皇帝的赏赐",
				effects = [
					{type = "gold", value = -40},
					{type = "diplomacy", value = 20, nation = "HORMUZ"},
					{type = "relic", value = "random_rare"},
				] as Array[Dictionary],
				requirements = {gold_min = 40} as Dictionary,
				result_text = "The sultan is overwhelmed by the Emperor's generosity. He reciprocates with a treasure from his vault.",
				result_text_zh = "苏丹被皇帝的慷慨所感动。他从宝库中取出珍宝回赠。",
			},
			{
				text = "Send an envoy instead",
				text_zh = "派遣使节代行",
				effects = [
					{type = "diplomacy", value = 5, nation = "HORMUZ"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "The envoy handles the meeting diplomatically. Relations are established, if not deepened.",
				result_text_zh = "使节圆满地处理了会面。外交关系已经建立，虽然不算深入。",
			},
		] as Array[Dictionary],
		"ink_wash_hormuz_palace_golden_domes"
	))

	# 15. African Coast
	events.append(_create_event(
		"african_coast", "African Coast", "非洲海岸",
		EventData.EventType.STORY, 3,
		"Strange and wonderful animals roam the African shore. The crew gasps at creatures they have never imagined—tall spotted beasts, striped horses, and enormous grey giants.",
		"奇异而美妙的动物漫步在非洲海岸。船员们看到了他们从未想象过的生物——高大的斑点兽、带条纹的马和巨大的灰色巨兽，不禁惊叹。",
		[
			{
				text = "Capture a giraffe for the Emperor",
				text_zh = "捕获一只长颈鹿献给皇帝",
				effects = [
					{type = "relic", value = "qilin_tribute"},
					{type = "diplomacy", value = 10, nation = "MOGADISHU"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "With local help, you capture a magnificent giraffe—a 'qilin' to present to the Emperor! This will bring great honor.",
				result_text_zh = "在当地人的帮助下，你捕获了一只壮丽的长颈鹿——一只献给皇帝的'麒麟'！这将带来巨大的荣耀。",
			},
			{
				text = "Trade with the locals",
				text_zh = "与当地人贸易",
				effects = [
					{type = "gold", value = 30},
					{type = "diplomacy", value = 5, nation = "MOGADISHU"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "The locals are eager to trade ivory, gold, and exotic pelts for Chinese silk and porcelain.",
				result_text_zh = "当地人急切地用象牙、黄金和珍奇毛皮换取中国丝绸和瓷器。",
			},
			{
				text = "Document the wildlife",
				text_zh = "记录野生动物",
				effects = [
					{type = "relic", value = "navigation_charts"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "Your scholars create detailed illustrations and charts of the coastline. This knowledge will prove invaluable.",
				result_text_zh = "你的学者们绘制了详细的插图和海岸线图。这些知识将被证明是无价的。",
			},
		] as Array[Dictionary],
		"ink_wash_african_coast_giraffe_ships"
	))

	# 16. Desert Oasis
	events.append(_create_event(
		"desert_oasis", "Desert Oasis", "沙漠绿洲",
		EventData.EventType.RANDOM, 3,
		"A caravan leads you to a hidden oasis in the desert. Palm trees sway above crystal-clear pools, and the air smells of dates and honey.",
		"一支驼队带你来到沙漠中一片隐秘的绿洲。棕榈树在清澈的池水上方摇曳，空气中弥漫着椰枣和蜂蜜的香气。",
		[
			{
				text = "Rest at the oasis",
				text_zh = "在绿洲休息",
				effects = [
					{type = "heal", value = 999},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "The cool water and fresh food restore you completely. You feel reborn.",
				result_text_zh = "清凉的水和新鲜的食物使你完全恢复。你感觉焕然一新。",
			},
			{
				text = "Trade with the caravan",
				text_zh = "与驼队贸易",
				effects = [
					{type = "relic", value = "random"},
					{type = "gold", value = -35},
				] as Array[Dictionary],
				requirements = {gold_min = 35} as Dictionary,
				result_text = "The desert traders have traveled far and carry wonders from distant lands.",
				result_text_zh = "沙漠商人走南闯北，携带着来自遥远国度的奇珍异宝。",
			},
			{
				text = "Learn desert secrets",
				text_zh = "学习沙漠奥秘",
				effects = [
					{type = "card", value = "random_rare_power"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "The caravan leader shares ancient wisdom passed down through generations of desert survival.",
				result_text_zh = "驼队首领分享了世代传承的沙漠生存古老智慧。",
			},
		] as Array[Dictionary],
		"ink_wash_desert_oasis_palm_trees"
	))

	# 17. Aden Market
	events.append(_create_event(
		"aden_market", "Market of Aden", "亚丁市场",
		EventData.EventType.RANDOM, 3,
		"The bustling port of Aden, crossroads of trade between Africa, Arabia, and India. The air is thick with the scent of ambergris and frankincense.",
		"繁忙的亚丁港，连接非洲、阿拉伯和印度的贸易十字路口。空气中弥漫着龙涎香和乳香的浓郁气味。",
		[
			{
				text = "Buy ambergris",
				text_zh = "购买龙涎香",
				effects = [
					{type = "gold", value = -45},
					{type = "relic", value = "ambergris"},
				] as Array[Dictionary],
				requirements = {gold_min = 45} as Dictionary,
				result_text = "You acquire a large piece of fine ambergris—one of the most precious substances in the world.",
				result_text_zh = "你获得了一大块上等龙涎香——世界上最珍贵的物质之一。",
			},
			{
				text = "Sell Chinese goods",
				text_zh = "出售中国商品",
				effects = [
					{type = "gold", value = 60},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "Chinese silk, porcelain, and tea fetch extraordinary prices. The merchants cannot get enough.",
				result_text_zh = "中国丝绸、瓷器和茶叶卖出了天价。商人们供不应求。",
			},
			{
				text = "Establish diplomatic ties",
				text_zh = "建立外交关系",
				effects = [
					{type = "diplomacy", value = 15, nation = "ADEN"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "The port authorities welcome formal relations with the Ming court. A new chapter begins.",
				result_text_zh = "港口当局欢迎与明朝建立正式关系。新的篇章开始了。",
			},
		] as Array[Dictionary],
		"ink_wash_aden_port_market_crowds"
	))

	# 18. Mogadishu Court
	events.append(_create_event(
		"mogadishu_court", "Court of Mogadishu", "摩加迪沙朝廷",
		EventData.EventType.STORY, 3,
		"The ruler of Mogadishu requests an audience. His court is grand, decorated with coral and ivory. Warriors line the hall, watching the foreign visitors with curiosity.",
		"摩加迪沙的统治者请求觐见。他的朝廷宏伟壮观，以珊瑚和象牙装饰。武士们列队大厅，好奇地打量着外国来客。",
		[
			{
				text = "Present tribute",
				text_zh = "呈献贡品",
				effects = [
					{type = "gold", value = -30},
					{type = "diplomacy", value = 15, nation = "MOGADISHU"},
				] as Array[Dictionary],
				requirements = {gold_min = 30} as Dictionary,
				result_text = "The ruler is deeply honored by the Emperor's tribute. A strong alliance is forged.",
				result_text_zh = "统治者对皇帝的贡品深感荣幸。一个强大的联盟由此铸就。",
			},
			{
				text = "Propose a trade agreement",
				text_zh = "提议贸易协定",
				effects = [
					{type = "diplomacy", value = 10, nation = "MOGADISHU"},
					{type = "gold_per_combat", value = 20},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "The trade agreement will bring steady income throughout your time in these waters.",
				result_text_zh = "贸易协定将在你停留期间带来稳定的收入。",
			},
			{
				text = "Show military might",
				text_zh = "展示军事力量",
				effects = [
					{type = "diplomacy", value = 5, nation = "MOGADISHU"},
					{type = "diplomacy_conditional", value = -3, nation = "MOGADISHU", condition = "below_friendly"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "A demonstration of your fleet's power. The ruler is impressed, though wary if relations are cold.",
				result_text_zh = "舰队力量的展示。统治者印象深刻，但如果关系冷淡则会心生警惕。",
			},
		] as Array[Dictionary],
		"ink_wash_mogadishu_coral_palace"
	))

	return events


# =============================================================================
# UNIVERSAL EVENTS — Any Act (通用事件)
# =============================================================================

static func _universal_events() -> Array[Resource]:
	var events: Array[Resource] = []

	# 19. Ship Repairs
	events.append(_create_event(
		"ship_repairs", "Ship Repairs", "船只修缮",
		EventData.EventType.REST, 0,
		"The fleet needs maintenance. Barnacles cling to hulls, sails are torn, and the carpenter reports several leaks below deck.",
		"舰队需要维护。船体上附满了藤壶，船帆破损，木匠报告甲板下有几处漏水。",
		[
			{
				text = "Full repairs",
				text_zh = "全面修缮",
				effects = [
					{type = "gold", value = -30},
					{type = "heal", value = 20},
				] as Array[Dictionary],
				requirements = {gold_min = 30} as Dictionary,
				result_text = "The fleet is restored to fighting condition. Every plank replaced, every sail patched.",
				result_text_zh = "舰队恢复了战斗状态。每块船板都已更换，每面帆都已修补。",
			},
			{
				text = "Quick patch job",
				text_zh = "简单修补",
				effects = [
					{type = "gold", value = -10},
					{type = "heal", value = 8},
				] as Array[Dictionary],
				requirements = {gold_min = 10} as Dictionary,
				result_text = "The worst leaks are sealed and the most damaged sails replaced. It will have to do.",
				result_text_zh = "最严重的漏洞已经堵住，最破损的帆已经更换。只能如此了。",
			},
			{
				text = "The crew can handle it",
				text_zh = "让船员自行处理",
				effects = [
					{type = "heal", value = 3},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "The crew does their best with limited resources. Minor improvements are made.",
				result_text_zh = "船员们在有限的资源下尽力而为。做了一些小改进。",
			},
		] as Array[Dictionary],
		"ink_wash_ship_repairs_harbor"
	))

	# 20. Stowaway
	events.append(_create_event(
		"stowaway", "Stowaway Discovered", "偷渡者",
		EventData.EventType.RANDOM, 0,
		"A stowaway is discovered hiding among the cargo barrels. The young person claims to be fleeing hardship and begs for mercy.",
		"一名偷渡者被发现藏在货物桶之间。这个年轻人声称是为了逃离苦难，恳求宽恕。",
		[
			{
				text = "Welcome them as crew",
				text_zh = "欢迎他加入船队",
				effects = [
					{type = "card", value = "random"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "The stowaway proves to have hidden talents. A welcome addition to the fleet.",
				result_text_zh = "偷渡者证明自己身怀绝技。为舰队增添了宝贵的力量。",
			},
			{
				text = "Put them to work",
				text_zh = "让他干活抵偿",
				effects = [
					{type = "gold", value = 15},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "The stowaway works tirelessly to earn their keep. Their labor proves quite productive.",
				result_text_zh = "偷渡者不知疲倦地工作来维持生计。他的劳动非常高效。",
			},
			{
				text = "Return them at the next port",
				text_zh = "在下一个港口送回",
				effects = [
					{type = "diplomacy", value = 3, nation = "CURRENT_ACT"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "Your mercy impresses the local authorities when you return the stowaway safely.",
				result_text_zh = "你安全送回偷渡者的仁慈之举给当地官员留下了深刻印象。",
			},
		] as Array[Dictionary],
		"ink_wash_stowaway_cargo_hold"
	))

	# 21. Star Navigation
	events.append(_create_event(
		"star_navigation", "Star Navigation", "星象导航",
		EventData.EventType.RANDOM, 0,
		"The night sky reveals new paths. Stars blaze with unusual clarity, and the navigator calls you to the deck with excitement in his voice.",
		"夜空展现了新的航路。星辰以异常的清晰度闪耀，领航员激动地请你到甲板上来。",
		[
			{
				text = "Chart a new course",
				text_zh = "开辟新航线",
				effects = [
					{type = "reveal_map", value = "current_act"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "The stars reveal hidden paths and shortcuts. The entire map of this region becomes clear.",
				result_text_zh = "星辰揭示了隐藏的航路和捷径。整个区域的地图变得清晰可见。",
			},
			{
				text = "Study the stars deeply",
				text_zh = "深入研究星象",
				effects = [
					{type = "relic_conditional", value = "star_chart", fallback = "upgrade_card"},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "Hours pass as you study the celestial patterns. The knowledge gained is profound.",
				result_text_zh = "你花了数小时研究星象。获得的知识意义深远。",
			},
			{
				text = "Note observations in the log",
				text_zh = "在航海日志中记录观察",
				effects = [
					{type = "gold", value = 5},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "You record the observations carefully. Every detail may prove useful someday.",
				result_text_zh = "你仔细记录下观察结果。每个细节终有一天可能派上用场。",
			},
		] as Array[Dictionary],
		"ink_wash_night_sky_deck_stars"
	))

	# 22. Treasure Wreck
	events.append(_create_event(
		"treasure_wreck", "Sunken Treasure", "沉船宝藏",
		EventData.EventType.TREASURE, 0,
		"A sunken ship's treasures glitter below the crystal-clear waters. The wreck lies at a reachable depth, but the currents are treacherous.",
		"一艘沉船的宝藏在清澈的水下闪闪发光。沉船位于可达的深度，但水流十分凶险。",
		[
			{
				text = "Dive for treasure personally",
				text_zh = "亲自潜水寻宝",
				effects = [
					{type = "random_outcome", outcomes = [
						{chance = 0.5, effects = [{type = "gold", value = 50}, {type = "relic", value = "random"}]},
						{chance = 0.5, effects = [{type = "damage", value = 12}]},
					]},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "You take the plunge into the unknown depths...",
				result_text_zh = "你纵身跃入未知的深渊……",
			},
			{
				text = "Send experienced divers",
				text_zh = "派遣经验丰富的潜水员",
				effects = [
					{type = "gold", value = 25},
				] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "Your veteran divers bring back a respectable haul from the wreck. Safe and profitable.",
				result_text_zh = "你的老练潜水员从沉船中带回了相当可观的收获。安全又有利可图。",
			},
			{
				text = "Mark the location and move on",
				text_zh = "标记位置继续前进",
				effects = [] as Array[Dictionary],
				requirements = {} as Dictionary,
				result_text = "You note the coordinates on your charts. Perhaps you will return someday.",
				result_text_zh = "你在海图上标注了坐标。也许有朝一日会再来。",
			},
		] as Array[Dictionary],
		"ink_wash_sunken_ship_clear_water"
	))

	return events


# =============================================================================
# PUBLIC API
# =============================================================================

static func get_all_events() -> Array[Resource]:
	var events: Array[Resource] = []
	events.append_array(_act1_events())
	events.append_array(_act2_events())
	events.append_array(_act3_events())
	events.append_array(_universal_events())
	return events


static func get_events_for_act(act: int) -> Array[Resource]:
	var result: Array[Resource] = []
	for event in get_all_events():
		var e: EventData = event as EventData
		if e.act == act or e.act == 0:
			result.append(e)
	return result


static func get_event(id: String) -> Resource:
	for event in get_all_events():
		var e: EventData = event as EventData
		if e.id == id:
			return e
	return null


static func get_random_event(rng: RandomNumberGenerator, act: int) -> Resource:
	var pool := get_events_for_act(act)
	if pool.is_empty():
		return null
	var index := rng.randi_range(0, pool.size() - 1)
	return pool[index]


static func get_story_events_for_act(act: int) -> Array[Resource]:
	var result: Array[Resource] = []
	for event in get_all_events():
		var e: EventData = event as EventData
		if e.event_type == EventData.EventType.STORY and (e.act == act or e.act == 0):
			result.append(e)
	return result
