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
master = 1000 # 千精
master_bonus = 16 * master / (master + 2000)
reaction_bonus = 0.8 # 花神4件套效果
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
# 千精久岐忍+草套减抗，一个种子炸3万4