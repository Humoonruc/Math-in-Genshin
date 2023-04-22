##################################
# optimal allocation of artifact stats：以直伤为例
##################################
using JuMP, GLPK, Ipopt
using Plots, LaTeXStrings


# 例：如何计算 T
attack_green = 897
attack_white = 605
b = attack_green / attack_white
cr = 0.415
cd = 1.106
T = b / 0.05 + cr / 0.033 + cd / 0.066


# 最优化问题的数值解
Ts = 40:0.1:100 |> collect # T 的变化范围
bs = Ts |> length |> zeros
crs = Ts |> length |> zeros
cds = Ts |> length |> zeros

for i in 1:length(Ts)
    m = Model()
    set_optimizer(m, Ipopt.Optimizer)
    @variable(m, b ≥ 0)
    @variable(m, 0.05 ≤ cr ≤ 1) # 角色自带5%暴击率
    @variable(m, cd ≥ 0.5) # 角色自带50%暴伤
    @NLconstraint(m, constraint, b / 0.05 + cr / 0.033 + cd / 0.066 ≤ Ts[i])
    @NLobjective(m, Max, (1 + b) * (1 + cr * cd))
    optimize!(m)
    bs[i] = value(b)
    crs[i] = value(cr)
    cds[i] = value(cd)
end


gr()
plot(Ts, [100 * bs 100 * crs 100 * cds],
    label=["attack: green/white" "critical rate" "critical damage"],
    xlabel=L"T", yaxis=L"\%",
    title="optimal allocation of artifact stats",
    legend=:outerright)
savefig("./artifacts/img/artifact-stats-allocation.png")


##############################################
## 该问题的可视化
##############################################

using Plots
# pythonplot() # 用于jupyter
plotlyjs()


# plotting
b_domain = range(0, step=0.03, length=101)
cr_domain = range(0, step=0.01, length=101)
function damage(b, cr)
    return (1 + b) * (1 + 2 * cr^2)
end
p = surface(b_domain, cr_domain, damage, c=:viridis)


# 约束为一条线，将其绘制出来
cr_min = 0.05
cr_margin = cr_min:0.01:1 |> collect
b_margin = @. 0.05T - 3.03 * cr_margin
plot!(p,
    b_margin, cr_margin, damage.(b_margin, cr_margin),
    label="constraint", c="red", w=2
)


# 这条线上哪一点取得最大值？
function damage(b)
    cr = (0.05T - b) / 3.03
    return (1 + b) * (1 + 2 * cr^2)
end

b_max = 0.05T - 3.03cr_min
bs = 0:0.01:b_max |> collect
damages = damage.(bs)
plot(bs, damages)