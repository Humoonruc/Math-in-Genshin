
using JuMP, GLPK, Ipopt
using PlotlyJS

##################################
# 激化 (catalyze) 主 C 的圣遗物词条最优化问题——以纳西妲灭净三业为例
##################################

# 已知 T 求最优化词条分配
attack_white = 753
attack_green = 491.3
b₀ = attack_green / attack_white
master₀ = 852
cr₀ = 58.2 / 100 + (master₀ - 200) * 0.03 / 100
cd₀ = 107.5 / 100
T = b₀ / 0.05 + cr₀ / 0.033 + cd₀ / 0.066 + master₀ / 20


multiplier_attack = 1.651
multiplier_master = 3.302
lv_coef = 1447 # 90级
type_coef = 1.25 # 蔓激化


m = Model()
set_optimizer(m, Ipopt.Optimizer)
@variable(m, b ≥ 311 / attack_white) # 绿字攻击至少有羽毛的311
@variable(m, 0.05 ≤ cr ≤ 1) # 角色自带5%暴击率
@variable(m, cd ≥ 0.5) # 角色自带50%暴伤
@variable(m, master ≥ 400) # 草神精通+一个精通圣遗物+双草共鸣
@NLconstraint(m, constraint, b / 0.05 + cr / 0.033 + cd / 0.066 + master / 20 ≤ T)
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
        1.15 + (master - 200) * 0.1 / 100 # bonus
    )
)
optimize!(m)
value(b)
value(cr)
value(cd)
value(master)
# 可见，圣遗物的攻击词条最好一个都没有；暴击面板偏高、暴伤面板偏低；继续堆精通仍是有益的



# 最优化解随 T 的变化
Ts = 60:0.1:110 |> collect # T 的变化范围
bs = Ts |> length |> zeros
crs = Ts |> length |> zeros
cds = Ts |> length |> zeros
masters = Ts |> length |> zeros

for i in 1:length(Ts)
    m = Model()
    set_optimizer(m, Ipopt.Optimizer)

    @variable(m, b ≥ 311 / attack_white) # 绿字攻击至少有羽毛的311
    @variable(m, 0.05 ≤ cr ≤ 1) # 角色自带5%暴击率
    @variable(m, cd ≥ 0.5) # 角色自带50%暴伤
    @variable(m, master ≥ 400) # 草神精通+一个精通圣遗物+双草共鸣

    @NLconstraint(m, constraint, b / 0.05 + cr / 0.033 + cd / 0.066 + master / 20 ≤ Ts[i])

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
            1.15 + (master - 200) * 0.1 / 100 # bonus
        )
    )

    optimize!(m)
    bs[i] = value(b)
    crs[i] = value(cr)
    cds[i] = value(cd)
    masters[i] = value(master)
end


traces = [
    scatter(x=Ts, y=100 * bs, name="attack: green/white %"),
    scatter(x=Ts, y=100 * crs, name="critical rate %"),
    scatter(x=Ts, y=100 * cds, name="critical damage %"),
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
# 1. 攻击在任何时候都不是有效词条，圣遗物歪攻击越少越好
# 2. T < 88.9 时，最好用歪一点暴伤的三精通圣遗物
# 3. T > 88.9 后，圣遗物最好歪一些暴击率；T > 95 之后，暴击头才是必要的


##################################
# 激化主 C 的圣遗物词条最优化问题——以提纳里为例
##################################


# 已知 T 求最优化词条分配
attack_white = 942
attack_green = 622
b₀ = attack_green / attack_white
master₀ = 547
cr₀ = 79.2 / 100
cd₀ = 112 / 100
T = b₀ / 0.05 + cr₀ / 0.033 + cd₀ / 0.066 + master₀ / 20


multiplier = 122.08 / 100
lv_coef = 1447 # 90级
type_coef = 1.25 # 蔓激化


m = Model()
set_optimizer(m, Ipopt.Optimizer)
@variable(m, b ≥ 311 / attack_white + 0.14) # 绿字攻击至少有羽毛的311和饰金四件套的14%
@variable(m, 0.05 ≤ cr ≤ 1) # 角色自带5%暴击率
@variable(m, cd ≥ 0.5) # 角色自带50%暴伤
@variable(m, master ≥ 467) # 双草共鸣+饰金四件套+精通杯
@NLconstraint(m, constraint, b / 0.05 + cr / 0.033 + cd / 0.066 + master / 20 ≤ T)
@NLobjective(m, Max,
    (
        attack_white * (1 + b) * multiplier +
        lv_coef * type_coef * (1 + 5 * master / (master + 1200))
    ) *
    (
        1 + cr * cd # critical
    ) *
    (
        1 + 0.754 + master * 0.06 / 100 # 诸叶辨通加成
    )
)
optimize!(m)
value(b)
value(cr)
value(cd)
value(master)
# 可见：
# 1. 装备精草暴，圣遗物的攻击副词条和精通副词条最好一个都没有，全歪双暴
# 2. 暴击基本满足需要，暴伤面板严重偏低



# 最优化解随 T 的变化
Ts = 70:0.1:110 |> collect # T 的变化范围
bs = Ts |> length |> zeros
crs = Ts |> length |> zeros
cds = Ts |> length |> zeros
masters = Ts |> length |> zeros

for i in 1:length(Ts)
    m = Model()
    set_optimizer(m, Ipopt.Optimizer)

    @variable(m, b ≥ 311 / attack_white + 0.14) # 绿字攻击至少有羽毛的311和饰金四件套的14%
    @variable(m, 0.05 ≤ cr ≤ 1) # 角色自带5%暴击率
    @variable(m, cd ≥ 0.5) # 角色自带50%暴伤
    @variable(m, master ≥ 467) # 双草共鸣+饰金四件套+精通杯
    @NLconstraint(m, constraint, b / 0.05 + cr / 0.033 + cd / 0.066 + master / 20 ≤ Ts[i])
    @NLobjective(m, Max,
        (
            attack_white * (1 + b) * multiplier +
            lv_coef * type_coef * (1 + 5 * master / (master + 1200))
        ) *
        (
            1 + cr * cd # critical
        ) *
        (
            1 + 0.754 + master * 0.06 / 100 # 诸叶辨通加成
        )
    )

    optimize!(m)
    bs[i] = value(b)
    crs[i] = value(cr)
    cds[i] = value(cd)
    masters[i] = value(master)
end


traces = [
    scatter(x=Ts, y=100 * bs, name="attack: green/white %"),
    scatter(x=Ts, y=100 * crs, name="critical rate %"),
    scatter(x=Ts, y=100 * cds, name="critical damage %"),
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
# 1. 装备精草暴后，对于蔓激化伤害，提纳里的攻击和精通都是严重稀释的（加上草神大精通拐）
# 2. 双暴对提纳里高于一切（特别是暴击），努力往 100/200 以上堆
# 3. （打出蔓激化时）天空之翼和弹弓的差距真的不大！！！