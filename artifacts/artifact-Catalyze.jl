# optimal allocation of artifact stats: catalyze

using JuMP, GLPK, Ipopt
using PlotlyJS

##################################
# 激化 (catalyze) 主 C 的圣遗物词条最优化问题——以纳西妲灭净三业为例
##################################

# 已知 T 求最优化词条分配
attack_white = 809
attack_green = 346
b₀ = attack_green / attack_white
master₀ = 806 # 精1专武，双草共鸣
cr₀ = 27.1 / 100
cd₀ = 115.3 / 100
db₀ = 0.466
T = b₀ / 0.05 + cr₀ / 0.033 + cd₀ / 0.066 + master₀ / 20 + db₀ / 0.05


multiplier_attack = 1.651
multiplier_master = 3.302
lv_coef = 1447 # 90级
type_coef = 1.25 # 蔓激化



# # 情况一：精通不到1000，未达到草神天赋2的上限
# m1 = Model()
# set_optimizer(m1, Ipopt.Optimizer)
# @variable(m1, b ≥ 311 / attack_white) # 绿字攻击至少有羽毛的311
# @variable(m1, 0.05 ≤ cr ≤ 0.76) # 角色自带5%暴击率
# @variable(m1, cd ≥ 0.5) # 角色自带50%暴伤
# @variable(m1, 700 ≤ master ≤ 1000) # 角色武器精通+至少一个精通圣遗物+双草共鸣
# @variable(m1, 0 ≤ db ≤ 0.466) # 是否带草伤杯
# @NLconstraint(m1, constraint, b / 0.05 + cr / 0.033 + cd / 0.066 + master / 20 + db / 0.05 ≤ T)
# @NLobjective(m1, Max,
#     (
#         attack_white * (1 + b) * multiplier_attack +
#         master * multiplier_master +
#         lv_coef * type_coef * (1 + 5 * master / (master + 1200))
#     ) *
#     (
#         1 + (cr + (master - 200) * 0.03 / 100) * cd # critical
#     ) *
#     (
#         1 + 0.15 + 0.2 + db + (master - 200) * 0.1 / 100 # bonus
#     )
# )
# optimize!(m1)
# value(b)
# value(cr)
# value(cd)
# value(master)
# value(db)
# objective_value(m1)



# # 情况二：精通超过1000，达到草神天赋2的上限
# m2 = Model()
# set_optimizer(m2, Ipopt.Optimizer)
# @variable(m2, b ≥ 311 / attack_white) # 绿字攻击至少有羽毛的311
# @variable(m2, 0.05 ≤ cr ≤ 0.76) # 角色自带5%暴击率
# @variable(m2, cd ≥ 0.5) # 角色自带50%暴伤
# @variable(m2, 1000 ≤ master) # 角色武器精通+至少一个精通圣遗物+双草共鸣
# @variable(m2, 0 ≤ db ≤ 0.466) # 是否带草伤杯
# @NLconstraint(m2, constraint, b / 0.05 + cr / 0.033 + cd / 0.066 + master / 20 + db / 0.05 ≤ T)
# @NLobjective(m2, Max,
#     (
#         attack_white * (1 + b) * multiplier_attack +
#         master * multiplier_master +
#         lv_coef * type_coef * (1 + 5 * master / (master + 1200))
#     ) *
#     (
#         1 + (cr + 0.24) * cd # critical
#     ) *
#     (
#         1 + 0.15 + 0.2 + db + 0.8 # bonus
#     )
# )
# optimize!(m2)
# value(b)
# value(cr)
# value(cd)
# value(master)
# value(db)
# objective_value(m2)



# 最优化解随 T 的变化
Ts = 75:0.1:115 |> collect # T 的变化范围
bs = similar(Ts)
crs = similar(Ts)
cds = similar(Ts)
masters = similar(Ts)
dbs = similar(Ts)


# 情况一：精通不到1000，未达到草神天赋2的上限
for i in 1:length(Ts)
    m = Model()
    set_optimizer(m, Ipopt.Optimizer)

    @variable(m, b ≥ 311 / attack_white) # 绿字攻击至少有羽毛的311
    @variable(m, 0.05 ≤ cr ≤ 0.76) # 角色自带5%暴击率
    @variable(m, cd ≥ 0.5) # 角色自带50%暴伤
    @variable(m, 700 ≤ master ≤ 1000) # 草神精通+至少一个精通圣遗物+双草共鸣
    @variable(m, 0 ≤ db ≤ 0.466) # 是否带草伤杯

    @NLconstraint(m, constraint, b / 0.05 + cr / 0.033 + cd / 0.066 + master / 20 + db / 0.05 ≤ Ts[i])

    @NLobjective(m, Max,
        (
            attack_white * (1 + b) * multiplier_attack +
            master * multiplier_master +
            lv_coef * type_coef * (1 + 5 * master / (master + 1200))
        ) *
        (
            1 + (cr + (master - 200) * 0.03 / 100) * cd # critical
        ) *
        (
            1 + 0.15+0.2+ db + (master - 200) * 0.1 / 100 # 草套2和专武效果
        )
    )

    optimize!(m)
    bs[i] = value(b)
    crs[i] = value(cr)
    cds[i] = value(cd)
    masters[i] = value(master)
    dbs[i] = value(db)
end


traces = [
    scatter(x=Ts, y=100 * bs, name="attack: green/white %"),
    scatter(x=Ts, y=100 * crs, name="critical rate %"),
    scatter(x=Ts, y=100 * cds, name="critical damage %"),
    scatter(x=Ts, y=100 * dbs, name="damage bonus %"),
    scatter(x=Ts, y=masters, name="master", yaxis="y2")
]
plot(traces,
    Layout(
        title_text="optimal allocation of artifact stats",
        xaxis_title_text="T",
        yaxis_title_text="%",
        # legend=:topright,
        yaxis2=attr(
            title="master",
            overlaying="y",
            side="right"
        )
    )
)


# 情况二：精通超过1000，达到草神天赋2的上限
for i in 1:length(Ts)
    m = Model()
    set_optimizer(m, Ipopt.Optimizer)

    @variable(m, b ≥ 311 / attack_white) # 绿字攻击至少有羽毛的311
    @variable(m, 0.05 ≤ cr ≤ 0.76) # 角色自带5%暴击率
    @variable(m, cd ≥ 0.5) # 角色自带50%暴伤
    @variable(m, 1000 ≤ master) # 草神精通+至少一个精通圣遗物+双草共鸣
    @variable(m, 0 ≤ db ≤ 0.466) # 是否带草伤杯

    @NLconstraint(m, constraint, b / 0.05 + cr / 0.033 + cd / 0.066 + master / 20 + db / 0.05 ≤ Ts[i])

    @NLobjective(m, Max,
        (
            attack_white * (1 + b) * multiplier_attack +
            master * multiplier_master +
            lv_coef * type_coef * (1 + 5 * master / (master + 1200))
        ) *
        (
            1 + (cr + 0.24) * cd # critical
        ) *
        (
            1 + 0.15 + 0.2 + db + 0.8 # 草套2和专武效果
        )
    )

    optimize!(m)
    bs[i] = value(b)
    crs[i] = value(cr)
    cds[i] = value(cd)
    masters[i] = value(master)
    dbs[i] = value(db)
end


traces = [
    scatter(x=Ts, y=100 * bs, name="attack: green/white %"),
    scatter(x=Ts, y=100 * crs, name="critical rate %"),
    scatter(x=Ts, y=100 * cds, name="critical damage %"),
    scatter(x=Ts, y=100 * dbs, name="damage bonus %"),
    scatter(x=Ts, y=masters, name="master", yaxis="y2")
]
plot(traces,
    Layout(
        title_text="optimal allocation of artifact stats",
        xaxis_title_text="T",
        yaxis_title_text="%",
        # legend=:topright,
        yaxis2=attr(
            title="master",
            overlaying="y",
            side="right"
        )
    )
)


# 百分比攻击词条的收益是最低的，最好不要歪攻击
# 两种情况最优的精通值都是1000，所以精通尽量往1000堆
# 草神圣遗物应追求的副词条是精双暴
# T > 87，应带暴击头，精精暴
# T < 81，应带草伤杯，精草精



##################################
# 激化主 C 的圣遗物词条最优化问题——以提纳里为例
##################################


# 已知 T 求最优化词条分配
attack_white = 942
attack_green = 477.9
b₀ = attack_green / attack_white
master₀ = 789
cr₀ = 79.2 / 100
cd₀ = 112 / 100
db₀ = 46.6 / 100
T = b₀ / 0.05 + cr₀ / 0.033 + cd₀ / 0.066 + master₀ / 20 + db₀ / 0.05


multiplier = 122.08 / 100
lv_coef = 1447 # 90级
type_coef = 1.25 # 蔓激化


# m = Model()
# set_optimizer(m, Ipopt.Optimizer)
# @variable(m, b ≥ 311 / attack_white + 0.14) # 绿字攻击至少有羽毛的311和饰金四件套的14%
# @variable(m, 0.05 ≤ cr ≤ 1) # 角色自带5%暴击率
# @variable(m, cd ≥ 0.5) # 角色自带50%暴伤
# @variable(m, master ≥ 667) # 双草共鸣+饰金四件套+精通杯+草神大精通拐
# @variable(m, 0 ≤ db ≤ 0.466)
# @NLconstraint(m, constraint, b / 0.05 + cr / 0.033 + cd / 0.066 + master / 20 + db / 0.05 ≤ T)
# @NLobjective(m, Max,
#     (
#         attack_white * (1 + b) * multiplier +
#         lv_coef * type_coef * (1 + 5 * master / (master + 1200))
#     ) *
#     (
#         1 + cr * cd # critical
#     ) *
#     (
#         1 + 0.288 + db + master * 0.06 / 100 # 角色、草伤杯、诸叶辨通加成
#     )
# )
# optimize!(m)
# value(b)
# value(cr)
# value(cd)
# value(master)
# value(db)




# 最优化解随 T 的变化
Ts = 80:0.1:120 |> collect # T 的变化范围
bs = similar(Ts)
crs = similar(Ts)
cds = similar(Ts)
masters = similar(Ts)
dbs = similar(Ts)


for i in 1:length(Ts)
    m = Model()
    set_optimizer(m, Ipopt.Optimizer)

    @variable(m, b ≥ 311 / attack_white + 0.14) # 绿字攻击至少有羽毛的311和饰金四件套的14%
    @variable(m, 0.05 ≤ cr ≤ 1) # 角色自带5%暴击率
    @variable(m, cd ≥ 0.5) # 角色自带50%暴伤
    @variable(m, master ≥ 667) # 双草共鸣+饰金四件套+精通杯+草神大精通拐
    @variable(m, 0 ≤ db ≤ 0.466)
    @NLconstraint(m, constraint, b / 0.05 + cr / 0.033 + cd / 0.066 + master / 20 + db / 0.05 ≤ Ts[i])
    @NLobjective(m, Max,
        (
            attack_white * (1 + b) * multiplier +
            lv_coef * type_coef * (1 + 5 * master / (master + 1200))
        ) *
        (
            1 + cr * cd # critical
        ) *
        (
            1 + 0.288 + db + master * 0.06 / 100 # 诸叶辨通加成
        )
    )

    optimize!(m)
    bs[i] = value(b)
    crs[i] = value(cr)
    cds[i] = value(cd)
    masters[i] = value(master)
    dbs[i] = value(db)
end


traces = [
    scatter(x=Ts, y=100 * bs, name="attack: green/white %"),
    scatter(x=Ts, y=100 * crs, name="critical rate %"),
    scatter(x=Ts, y=100 * cds, name="critical damage %"),
    scatter(x=Ts, y=100 * dbs, name="damage bonus %"),
    scatter(x=Ts, y=masters, name="master", yaxis="y2")
]
plot(traces,
    Layout(
        title_text="optimal allocation of artifact stats",
        xaxis_title_text="T",
        yaxis_title_text="%",
        # legend=:topright,
        yaxis2=attr(
            title="master",
            overlaying="y",
            side="right"
        )
    )
)
# 可见：
# 1. 装备精草暴后，对于蔓激化伤害，提纳里的攻击和精通都是严重稀释的
# 2. 圣遗物的攻击副词条和精通副词条最好一个都没有，全歪双暴
# 3. （打蔓激化时）天空之翼和弹弓的差距真的不大！！！