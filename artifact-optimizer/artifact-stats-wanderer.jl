# optimal allocation of artifact stats: wanderer

using JuMP, GLPK, Ipopt
using Plots, LaTeXStrings


##################################
# 散兵单人
##################################

attack_white = 1002
attack_green = 1220.8
b = attack_green / attack_white
cr = 76.3 / 100
cd = 163.3 / 100
db = (15 + 46.6 + 40 + 48) / 100 # 沙楼2、风伤杯、沙楼4、专武普攻
T = b / 0.05 + cr / 0.033 + cd / 0.066 + db / 0.05


# 最优化问题的数值解
Ts = 80:0.1:120 |> collect # T 的变化范围
bs = similar(Ts)
crs = similar(Ts)
cds = similar(Ts)
dbs = similar(Ts)

for i in 1:length(Ts)
    m = Model()
    set_optimizer(m, Ipopt.Optimizer)
    @variable(m, b ≥ 311 / attack_white + 0.466) # 羽毛、攻击沙
    @variable(m, 0.05 ≤ cr ≤ 1) # 角色自带5%暴击率
    @variable(m, cd ≥ 0.5) # 角色自带50%暴伤
    @variable(m, 1.03 ≤ db ≤ 1.496) # 是否带风伤杯，伤害加成的上下限  
    @NLconstraint(m, constraint, b / 0.05 + cr / 0.033 + cd / 0.066 + db / 0.05 ≤ Ts[i])
    @NLobjective(m, Max, (1 + b) * (1 + cr * cd) * (1 + db))
    optimize!(m)
    bs[i] = value(b)
    crs[i] = value(cr)
    cds[i] = value(cd)
    dbs[i] = value(db)
end


# plotlyjs()
gr()
plot(Ts, [100 * bs 100 * crs 100 * cds 100 * dbs],
    label=["attack: green/white" "critical rate" "critical damage" "damage bonus"],
    line=(2, reshape([:solid, :dashdot, :dash, :dot], 1, 4)),
    xlabel=L"T", yaxis=L"\%",
    title="optimize artifact stats: wanderer single",
    legend=:outerright)
savefig("./artifact-optimizer/img/artifact-stats-wanderer-single.png")


##############################################
## 该问题的可视化（必带风伤杯，不考虑伤害加成这个变量）
##############################################

using Plots
# pythonplot() # 用于jupyter
plotlyjs()


# plotting surface
b_domain = range(0, step=0.03, length=101)
cr_domain = range(0, step=0.01, length=101)
function output(b, cr)
    return (1 + b) * (1 + 2 * cr^2)
end
p = surface(b_domain, cr_domain, output, c=:viridis)
# 此为 b 和 cr 自由取值(cd 保持为 cr 的两倍)时目标函数的图象


# 约束为一条线，将其绘制出来
T = 95
cr_min = 0.05
cr_margin = cr_min:0.01:1 |> collect
b_margin = @. 0.05(T - 1.016 / 0.05 - 2 * cr_margin / 0.033)
plot!(p,
    b_margin, cr_margin, output.(b_margin, cr_margin),
    label="constraint", c="red", w=2
)


# 这条线上哪一点取得最大值？
function output2(b)
    cr = 0.033 * (T - 1.016 / 0.05 - b / 0.05) / 2
    return (1 + b) * (1 + 2 * cr^2)
end

plot(b_margin, output2.(b_margin))
# 这就是上面立体图沿约束线的竖切剖面



##############################################
## 散珐班组队实战
##############################################

attack_white = 1002 # 精1专武
attack_green = 2779.3 # 千岩、宗室，班尼特放大，散兵起飞染火
b = attack_green / attack_white
cr = 76.3 / 100
cd = 203.3 / 100 # 专武和珐6命
db = (15 + 46.6 + 40 + 34.2 + 48) / 100 # 沙楼2、风伤杯、沙楼4、珐6命大招、专武满层
T = b / 0.05 + cr / 0.033 + cd / 0.066 + db / 0.05


# 最优化问题的数值解
Ts = 120:0.1:170 |> collect # T 的变化范围
bs = similar(Ts)
crs = similar(Ts)
cds = similar(Ts)
dbs = similar(Ts)
outputs = similar(Ts)

for i in 1:length(Ts)
    m = Model()
    set_optimizer(m, Ipopt.Optimizer)
    @variable(m, b ≥ (311 + 857.1) / attack_white + 0.466 + 0.3 + 0.2 + 0.2) # 羽毛、班大招、攻击沙、染火、千岩、宗室
    @variable(m, 0.05 ≤ cr ≤ 1) # 角色自带5%暴击率
    @variable(m, cd ≥ 0.5) # 角色自带50%暴伤
    @variable(m, 1.372 ≤ db ≤ 1.838) # 是否带风伤杯，伤害加成的上下限
    @NLconstraint(m, constraint, b / 0.05 + cr / 0.033 + cd / 0.066 + db / 0.05 ≤ Ts[i])
    @NLobjective(m, Max, (1 + b) * (1 + cr * cd) * (1 + db))
    optimize!(m)
    bs[i] = value(b)
    crs[i] = value(cr)
    cds[i] = value(cd)
    dbs[i] = value(db)
    outputs[i] = objective_value(m)
end


# plotlyjs()
gr()

plot(Ts, [100 * bs 100 * crs 100 * cds 100 * dbs],
    label=["attack: green/white" "critical rate" "critical damage" "damage bonus"],
    xlabel=L"T", yaxis=L"\%",
    title="optimize artifact stats: wanderer team",
    legend=:outerright)
savefig("./artifact-optimizer/img/artifact-stats-wanderer-team.png")




plot(Ts, outputs ./ outputs[261],
    label="", title="output ratio to now", xlabel=L"T")

# 目前百分比攻击、双暴副词条数目为24，其中真正比较有效的双暴副词条只有16.9个
# 如果每个圣遗物双暴歪两次，平均贡献5个双暴词条，则共有25词条，增加了8词条
@show Ts[341] Ts[261];
println("Output increases by ", 100 * (outputs[341] / outputs[261] - 1), "%")
# 可以增加输出 16%，这是可以追求的

# 更理想的情况：每个圣遗物双暴最多歪一次，平均贡献6词条，则共有30词条，比目前增加了13词条
@show Ts[391] Ts[261];
println("Output increases by ", 100 * (outputs[391] / outputs[261] - 1), "%")
# 输出增加 26%，但这已经时可遇而不可求的小概率事件了

# 至于理论上最顶级的圣遗物，双暴全不歪，会有34个双暴词条（暴击头和暴伤头最多只有6个双暴副词条），增加17词条
@show Ts[431] Ts[261];
println("Output increases by ", 100 * (outputs[441] / outputs[261] - 1), "%")
# 输出增加 37%

# 平均而言，一个双暴词条能增加输出：
(exp(log(outputs[441] / outputs[261]) / 18) - 1) * 100
# 即 1.76% 左右
# 平均 10 个词条增加输出
100 * (outputs[361] / outputs[261] - 1)
# 即20%