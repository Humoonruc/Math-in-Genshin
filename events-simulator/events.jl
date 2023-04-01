## MonteCarlo Method 计算特定事件（组合）发生的次数期望


using Statistics
using Plots, StatsPlots


#######################################################
# 刷圣遗物副本，得到满足条件的圣遗物，所需次数的期望
#######################################################

# 已知 A, B, C, D, E 的单次触发概率, 求次数期望, 满足以下条件：
# A, B 至少发生 1 件，如精通沙和精通杯
# C, D, E 至少发生 2 件，如攻击沙、草伤杯、暴击头
Pa = 0.01
Pb = 0.0025
Pc = 0.0267
Pd = 0.005
Pe = 0.01

# 试验轮数
N = 100000

# 每轮试验中满足条件所需要的触发次数
ns = zeros(Int64, N)

# 进行 N 轮试验
for i in 1:N

    a = 0
    b = 0
    c = 0
    d = 0
    e = 0

    for k in 1:1000 # 最大次数应该不会超过1000
        t = rand()

        if t ≤ Pa
            a = 1
        elseif t ≤ Pa + Pb
            b = 1
        elseif t ≤ Pa + Pb + Pc
            c = 1
        elseif t ≤ Pa + Pb + Pc + Pd
            d = 1
        elseif t ≤ Pa + Pb + Pc + Pd + Pe
            e = 1
        else

        end

        if a + b ≥ 1 && c + d + e ≥ 2
            println(k)
            ns[i] = k
            break
        end
    end

end


mean(ns) # 平均刷多少次秘境能得到所需要的圣遗物
# histogram(ns)
density(ns, legend=false, yaxis="probability",
    title="density of turns") # 次数分布的概率密度
# savefig("./events-simulator/img/density-turn.png")

# savefig("./events-simulator/img/density-up.png")
# 可以看到，密度曲线右侧有一个长长的尾巴
# 所以会有很大的可能，所需的次数远大于 mean() 所求出的期望
# 通俗地说，就是会有相当一部分人脸很黑，例如：
count(>(150), ns) / length(ns) # 高达 24.9% 的可能，需要刷150次以上的秘境，才能得到所需的圣遗物
