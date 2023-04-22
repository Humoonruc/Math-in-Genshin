################################
## 例1：计算散兵开E后的一次重击输出
################################

# A/H 区
attack_role = 328
attack_weapon = 510
attack_bonus = (10.5 + 15.2 + 46.6 + 5.3 + 9.9 + 30) / 100 # 最后一项为散兵飞起来染火
attack_fixed = 311 + 16 + 31 + 842 # 最后一项为班尼特大招
attack = (attack_role + attack_weapon) * (1 + attack_bonus) + attack_fixed


# M 区
multiplier_skill = (211.33 / 100) * (134.76 / 100) # 散兵E后重击
multiplier_bonus = 0
multiplier = multiplier_skill * (1 + multiplier_bonus)


# I 区
independent_damage = 201 # 珐露珊固有天赋2


# C 区
cri_pro = (24.2 + 6.6 + 3.5 + 31.1 + 20) / 100 # 最后一项为染冰
cri_bonus = (50 + 55.1 + 20.2 + 21 + 14 + 40) / 100 # 最后一项为珐6命效果
critical = 1 + cri_pro * cri_bonus


# B 区
bonus_coef = (46.6 + 15 + 40 + 34.2 + 60) / 100 # 加法汇总，分别为风伤杯、楼阁2、楼阁4、珐大招、流浪乐章buff
bonus = 1 + bonus_coef


# D 区
defense_ignore_coef = 0
lv_player = 90
lv_enemy = 90
defense = (lv_player + 100) / (lv_player + 100 + (lv_enemy + 100) * (1 - defense_ignore_coef))


# R 区
resistance_base = 10 / 100
resistance_debuff = 30 / 100 # 珐露珊大招
resistance_coef = resistance_base - resistance_debuff
if resistance_coef < 0
    resistance = 1 - resistance_coef / 2
elseif resistance_coef < 0.75
    resistance = 1 - resistance_coef
else
    resistance = 1 / (1 + 4 * resistance_coef)
end


# output
output = (attack * multiplier + independent_damage) * critical * bonus * defense * resistance
# 90级散兵吃珐露珊、班尼特的拐，开E后一次重击期望伤害3万9



################################
## 例2：计算久岐忍的一次超绽放输出
################################

# L 区
lv_coef = 1447 # 90级


# E 区
type_coef = 3 # 超绽放
master = 945 + 100 # 精1板砖精精精久岐忍，吃满双草共鸣
master_bonus = 16 * master / (master + 2000)
reaction_bonus = 0.8 # 花神4件套满层效果
reaction = type_coef * (1 + master_bonus + reaction_bonus)


# R 区
resistance_base = 10 / 100
resistance_debuff = 30 / 100 # 草套减抗
resistance_coef = resistance_base - resistance_debuff
if resistance_coef < 0
    resistance = 1 - resistance_coef / 2
elseif resistance_coef < 0.75
    resistance = 1 - resistance_coef
else
    resistance = 1 / (1 + 4 * resistance_coef)
end


# output
output = lv_coef * reaction * resistance



################################
## 例3：计算雷神E超激化伤害
################################

# A 区
attack = 1380.4

# M 区
multiplier = 67.2 / 100

# L 区
lv_coef = 1446.88 # 90级

# E 区
type_coef = 1.15 # 超激化
master = 1037
master_bonus = 5 * master / (master + 1200)
reaction_bonus = 0
reaction = type_coef * (1 + master_bonus + reaction_bonus)

# C 区
cr = 14.3 / 100
cd = 109.9 / 100
critical = 1 + cr * cd


# B 区
bonus_coef = (12.8) / 100
bonus = 1 + bonus_coef


# D 区
defense_ignore_coef = 0
lv_player = 90
lv_enemy = 90
defense = (lv_player + 100) / (lv_player + 100 + (lv_enemy + 100) * (1 - defense_ignore_coef))


# R 区
resistance_base = 10 / 100
resistance_debuff = 0 / 100
resistance_coef = resistance_base - resistance_debuff
if resistance_coef < 0
    resistance = 1 - resistance_coef / 2
elseif resistance_coef < 0.75
    resistance = 1 - resistance_coef
else
    resistance = 1 / (1 + 4 * resistance_coef)
end


# output
output = (attack * multiplier + lv_coef * reaction) * critical * bonus * defense * resistance



################################
## 例4：计算草神E蔓激化伤害
################################

# A 区
attack = 1244.3

# M 区
multiplier_ATK = 165.12 / 100
multiplier_master = 330.24 / 100

# L 区
lv_coef = 1446.88 # 90级

# E 区
type_coef = 1.25 # 蔓激化
master = 852
master_bonus = 5 * master / (master + 1200)
reaction_bonus = 0
reaction = type_coef * (1 + master_bonus + reaction_bonus)

# C 区
cr = 58.2 / 100 + (master - 200) * 0.03 / 100
cd = 107.5 / 100
critical = 1 + cr * cd

# B 区
bonus_coef = 15 / 100 + (master - 200) * 0.1 / 100
bonus = 1 + bonus_coef

# D 区
defense_ignore_coef = 0
lv_player = 90
lv_enemy = 90
defense = (lv_player + 100) / (lv_player + 100 + (lv_enemy + 100) * (1 - defense_ignore_coef))

# R 区
resistance_base = 10 / 100 # 大部分小怪的草抗与其他抗性一样为10
resistance_debuff = 30 / 100
resistance_coef = resistance_base - resistance_debuff
if resistance_coef < 0
    resistance = 1 - resistance_coef / 2
elseif resistance_coef < 0.75
    resistance = 1 - resistance_coef
else
    resistance = 1 / (1 + 4 * resistance_coef)
end

# output
# 无蔓激化伤害
output1 = (attack * multiplier_ATK + master * multiplier_master) * critical * bonus * defense * resistance
# 触发蔓激化伤害
output2 = (attack * multiplier_ATK + master * multiplier_master + lv_coef * reaction) * critical * bonus * defense * resistance