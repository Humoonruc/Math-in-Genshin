[TOC]

## Damage Rule in Genshin

### 九大乘区

#### 1 attack/health (A/H 区)

该区数值会直接显示在人物面板上，是决定伤害的基础乘区。

计算该区时，多数角色用攻击力，少数角色（如夜兰）用最大生命值，因此该区称为 A/H 区。

```julia
attack = (attack_role + attack_weapon) * (1 + attack_bonus) + attack_fixed
```

> 例：
>
> attack_role = 328 # 90级散兵
>
> attack_weapon = 510 # 90级流浪乐章
>
> attack_bonus = 0.105 + 0.152 + 0.466 + 0.053 + 0.099 + 0.3 # 前5项为圣遗物的百分比攻击词条（俗称“大攻击”），最后一项为散兵 E 染火效果
>
> attack_fixed = 311 + 16 + 31 + 842 # 前4项为圣遗物固定攻击词条（俗称“小攻击”），最后一项为班尼特大招加攻

#### 2 multiplier (M 区)

该区主要由天赋的倍率决定，很少有增幅。该区要与 A 区乘算。

```julia
multiplier = multiplier_skill * (1 + multiplier_bonus)
```

> 例：
>
> skill_multiplier = 2.1133 * 1.3476 # 散兵E后重击，重击倍率*空居·刀风界倍率
>
> skill_bonus = 0

#### 3 independent damage (I 区)

有时还有一些独立攻击，在 A 区与 M 区乘算后额外加在上面。

特别地，激化反应的增伤就是作为 I 区的一部分进入最终计算的。

```julia
attack * multiplier + independent_damage
```

> 例：
>
> independent_damage = 201 # 珐露珊固有天赋2

#### 4 critical (C 区)

双暴乘区。可以证明，$暴击增幅 = 暴击概率 * 暴击伤害加成$

```julia
critical = 1 + cri_pro * cri_bonus
```

> 例：
>
> cri_pro = (24.2 + 6.6 + 3.5 + 31.1 + 20) / 100 # 第一项为散兵自身突破获得，之后四项为圣遗物暴击率，最后一项为散兵 E 染冰效果
>
> cri_bonus = (50 + 55.1 + 20.2 + 21 + 14 + 40) / 100 # 第一项为角色固有，第二项为武器，后面三项为圣遗物，最后一项为6命珐露珊的大招效果

#### 5 damage bonus (B 区)

增伤乘区。

```julia
bonus = 1 + bonus_coef
```

> 例：
>
> bonus_coef = (46.6 + 15 + 40 + 34.2 + 60) / 100 # 所有增伤用加法汇总，分别为风伤杯、楼阁2、楼阁4、珐大招、流浪乐章 buff

#### 6 defense (D 区)

只与角色等级和敌人等级有关，俗称的“等级压制”。

```julia
defense = (lv_player + 100) / (lv_player + 100 + (lv_enemy + 100) * (1 - defense_ignore_coef))
```

> 例：
>
> lv_player = 90
>
> lv_enemy = 90
>
> defense_ignore_coef = 0 # 雷神2命、八重6命，使这一项为正

#### 7 resistance (R 区)

抗性区。

```julia
resistance_coef = resistance_base - resistance_debuff
if resistance_coef < 0
    resistance = 1 - resistance_coef / 2
elseif resistance_coef < 0.75
    resistance = 1 - resistance_coef
else
    resistance = 1 / (1 + 4 * resistance_coef)
end
```

> 例：
>
> resistance_base = 10 / 100 # 很多怪物的基础风抗
>
> resistance_debuff = 30 / 100 # 珐露珊大招的减抗效果

#### 8 element reaction (E 区)

原神中的元素反应有增幅反应、激化反应、剧变反应和结晶反应。

- 增幅反应作为一个独立乘区，以乘法形式进入最终输出的计算。
- 激化反应作为 I 区的一部分参与计算：在 A 区和 M 区乘算的基础上，加算一个激化增伤，最后再乘以 C 区、B 区、D 区和 R 区。
- 剧变反应有自己独立的伤害公式，除了角色等级和精通，只与 R 区有关。
- 结晶反应生成的护盾量与角色等级、精通和护盾强效有关。

它们的共同特点是高度依赖精通，因此 E 区本质上是一个精通乘区。

```julia
reaction = type_coef * (1 + master_bonus + reaction_bonus)
```

> 例：
>
> reaction_bonus = 0.8 # 花神4件套效果
>
>  reaction_bonus = 0.4 # 如雷4件套提升40%感电伤害

##### 8.1 反应类型系数

`type_coef`为固定值

| 反应类型   | 类别 | type_coef | 伤害类型（计算相应抗性） |
| ---------- | ---- | --------- | ------------------------ |
| 水底火蒸发 | 增幅 | 1.5       | 火                       |
| 火底水蒸发 | 增幅 | 2         | 水                       |
| 火底冰融化 | 增幅 | 1.5       | 冰                       |
| 冰底火融化 | 增幅 | 2         | 火                       |
| 超导       | 剧变 | 0.5       | 冰                       |
| 扩散       | 剧变 | 0.6       | 被扩散元素的类型         |
| 碎冰       | 剧变 | 1.5       | 物理                     |
| 超载       | 剧变 | 2         | 火                       |
| 感电       | 剧变 | 1.2 * 2   | 雷                       |
| 原绽放     | 剧变 | 2         | 草                       |
| 超/烈绽放  | 剧变 | 3         | 草                       |
| 燃烧       | 剧变 | 0.25 * 4  | 火，每秒触发4次          |
| 蔓激化     | 激化 | 1.25      | 草                       |
| 超激化     | 激化 | 1.15      | 雷                       |

##### 8.2 精通加成

`master_bonus`的计算公式与反应类型有关

- 增幅反应：`master_bonus = 2.78 * master / (master + 1400)`，100点精通将带来18.5%的增幅反应加成
- 聚变反应：`master_bonus = 16 * master / (master + 2000)`，100点精通将带来76.2%的聚变反应加成
- 激化反应：`master_bonus = 5 * master / (1200 + master)`，100点精通将带来38.5%的激化反应加成
- 结晶反应：`master_bonus = 4.44 * master / (1400 + master)`

#### 9  player level (L 区)

对于剧变反应和激化反应，伤害不仅与精通有关，还同触发反应的角色的等级有关。每个等级都有固定的反应系数，可以被划分为一个独立乘区。

```julia
lv_coef # 剧变、激化反应的等级系数
```

> 例：超绽放
>
> lv_coef = 1447 # 90级时

类似的，结晶反应也有每个等级对应的护盾系数。

```julia
shield_lv_coef # 结晶反应的等级系数
```



### 最终输出公式

#### 纯伤

涉及 A/H 区、M 区、I 区、C 区、B 区、D 区、R 区

```julia
output = (attack * multiplier + independent_damage) * critical * bonus * defense * resistance
```

#### 增幅反应

在纯伤的基础上乘以 E 区，可以看到精通项`1 + master_bonus`是直接乘算到最终输出的，因此要打增幅反应的话，精通也是比较重要的。

```julia
output = (attack * multiplier + independent_damage) * critical * bonus * defense * resistance * reaction
```

#### 剧变反应

只涉及 L 区、E 区、R 区，因此只需要关注等级、精通、减抗即可，这就是种门好养成的原因。

```julia
output = lv_coef * reaction * resistance
```

#### 激化反应

激化反应不同于增幅反应的乘算，也不同于剧变反应的独立伤害，而是在 A 区和 M 区乘算的基础上，加算一个激化增伤（作为 I 区的一部分），最后再乘以 C 区、B 区、D 区和 R 区。

```julia
output = (attack * multiplier + lv_coef * reaction) * critical * bonus * defense * resistance
```

激化附加的独立伤害只与等级和精通有关，却能和双暴、加伤区乘算。由于**激化伤害往往远高于`攻击*倍率`，因此激化大C的攻击力、技能倍率是不太重要的（技能不需要升太高级，武器的白字不重要，也不需要班尼特、千岩、宗室、讨龙这种攻击拐），堆高人物等级、精通、双暴、增伤、减抗才更有效（精通拐变得很有用，可以让激化 C 的圣遗物堆更多双暴）**。

#### 结晶反应

```julia
护盾量 = shield_lv_coef * (1 + master_bonus) * (1 + 护盾强效)
```


### 说明

- A/H 区：
  - 一个攻击词条（攻击5.8%），在攻击已经堆得足够高的条件下（如攻击沙、宗室、千岩、双火、班尼特）会稀释，此后不如堆双暴词条，增强 C 区
  - 比较特殊的是夜兰，E和Q以生命值为基准，不易吃到加成，因此生命沙和若水生命词条的价值极高（若水同时加成A区、C区、B区，综合提升极大）
- C 区：每个圣遗物标准词条，暴击以 3.9% 为单位，暴伤以 7.8% 为单位，百分比攻击以 5.8% 为单位
- B 区不易吃到加成（一般只有元素杯和圣遗物2件套效果），所以价值很高（绝弦、行秋天赋等）
- D 区的加成非常少见、不易被稀释，因此雷神2命和神子6命的价值极高
- R 区：怪抗性越高，减抗区越重要