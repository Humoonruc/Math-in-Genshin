## MonteCarlo Method 计算特定事件（组合）发生的次数期望


using DataFrames
using StatsBase
using DataStructures
using Plots, StatsPlots
pythonplot()
ENV["GKS_ENCODING"] = "utf-8"
default(fontfamily="SimHei")


#######################################################
# 刷圣遗物副本，得到特定主词条的圣遗物，所需次数的期望
#######################################################

# 为雷神和夜兰刷绝缘本，花和羽毛不缺，要刷其他部位
# A, B, C 分别代表充能沙、雷伤杯、暴击头，至少出 2 件，
# D, E, F 分别代表生命沙、水伤杯、暴伤头，至少出 2 件，
Pa = 0.01
Pb = 0.005 # 充能沙的概率同精通沙一样低
Pc = 0.01
Pd = 0.0267
Pe = 0.005
Pf = 0.01

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
    f = 0

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
        elseif t ≤ Pa + Pb + Pc + Pd + Pe + Pf
            f = 1
        else
        end

        if a + b + c ≥ 2 && d + e + f ≥ 2
            println(k)
            ns[i] = k
            break
        end
    end

end


mean(ns) # 平均刷多少次秘境能得到所需要的圣遗物
mean(ns) / 9 # 每天全部体力用来刷，需要连续刷多少天
# histogram(ns)
density(ns, legend=false, yaxis="probability",
    title="density of turns") # 次数分布的概率密度
savefig("./events-simulator/img/density-turn.png")

# 可以看到，密度曲线右侧有一个长长的尾巴
# 所以会有很大的可能，所需的次数远大于 mean() 所求出的期望
# 通俗地说，就是会有相当一部分人脸很黑，例如：
count(>(150), ns) / length(ns) # 高达 30% 的可能，需要刷150次以上的秘境，才能得到所需的圣遗物
count(>(250), ns) / length(ns) # 7% 的可能，需要刷250次以上



#######################################################
# 圣遗物主词条已知，得到特定副词条的概率
#######################################################

name = ["hp", "atk", "def", "HP", "ATK", "DEF", "energy", "mastery", "cr", "cd"]
weight = [6, 6, 6, 4, 4, 4, 4, 4, 3, 3]
sub_stats_weights = DataFrame(; name, weight)
println(sub_stats_weights)


"""
main_stat 是圣遗物的主词条
condition 是希望获得的副词条向量
"""
function p_sub_stats(main_stat, condition)
    N = 100000 # 试验轮数
    s = 0

    for n in 1:N
        stats = [main_stat] # 所有主副词条的向量

        # 抽取4个副词条
        for i in 1:4
            not_existed = name -> name ∉ stats # 尚未被抽出的副词条
            pool = subset(sub_stats_weights, :name => ByRow(not_existed))
            sub_stat = sample(pool.name, weights(pool.weight))
            push!(stats, sub_stat)
        end

        if condition ⊆ stats
            s += 1
        end
    end

    return (s / N)
end



# 暴击头出暴伤副词条的概率
main_stat = "cr" # 主词条
condition = ["cr", "cd"] # 想出的副词条
P = p_sub_stats(main_stat, condition) # 暴击头有暴伤副词条的概率为 32%
println(0.01 * P) # 获得双暴暴击头的概率为 0.32%
# 由于对称性，暴伤头有暴击副词条的概率也是 0.32%
# 所以获得绝缘双暴头的概率为 0.64%，平均150次秘境出一个


## 双暴增伤杯概率
main_stat = "dmg_bonus" # 主词条
condition = ["cr", "cd"] # 想出的副词条
P = p_sub_stats(main_stat, condition) # 杯子有双暴副词条的概率为 6.7%
println(0.005 * P) # 在某个秘境获得特定套装、特定元素双暴杯的概率为 0.034%，平均刷3000次秘境才出1个


## 雷神双暴充能沙概率
main_stat = "energy" # 主词条
condition = ["cr", "cd"] # 想出的副词条
P = p_sub_stats(main_stat, condition) # 充能沙有双暴副词条的概率为 8.5%
println(0.01 * P) # 在某个秘境获得特定套装、双暴充能沙的概率为 0.085%，平均刷1200次秘境才出1个


## 提纳里双暴精通沙的概率
main_stat = "mastery" # 主词条
condition = ["cr", "cd"] # 想出的副词条
P = p_sub_stats(main_stat, condition) # 充能沙有双暴副词条的概率为 8.4%
println(0.01 * P) # 在某个秘境获得特定套装、双暴精通沙的概率为 0.084%，平均刷1200次秘境才出1个


## 夜兰双暴生命沙的概率
main_stat = "HP" # 主词条
condition = ["cr", "cd"] # 想出的副词条
P = p_sub_stats(main_stat, condition) # 生命沙有双暴副词条的概率为 8.5%
println(0.01 * P) # 在某个秘境获得特定套装、双暴精通沙的概率为 0.085%，平均刷1200次秘境才出1个


## 云堇歪大防御的充能沙的概率
main_stat = "energy" # 主词条
condition = ["DEF"] # 想出的副词条
P = p_sub_stats(main_stat, condition) # 充能沙有大防御副词条的概率为 42%
println(0.01 * P * (0.25^2)) # 至少再强化两次大防御的概率为 0.026%，平均要刷3800次秘境，超过一年！
println(0.01 * P * 0.25^2) # 至少再强化一次大防御的概率为 0.1%，平均要刷1000次秘境，仍要刷100天左右！


## 云堇歪充能的防御沙/杯/头
main_stat = "DEF" # 主词条
condition = ["energy"] # 想出的副词条
P = p_sub_stats(main_stat, condition) # 充能沙有大防御副词条的概率为 42%
println(0.022 * P * (0.25^2)) # 以防御头为例，至少再强化两次充能的概率为 0.057%，平均要刷1750次秘境，即刷183天
println(0.022 * P * 0.25) # 以防御头为例，至少再强化一次充能的概率为 0.23%，平均要刷435次秘境，即刷45天，还是可以接受的
# 防御沙，初始4词条，强化5次充能（一次都不歪），概率为 0.0022%，平均要刷4.6万次，即10年以上……


## 云堇花、羽毛，3个有效副词条（歪充能或大防御，然后再强化两次）
main_stat = "hp" # 主词条
P =
    0.1 * 0.2 * ( # 初始4词条
        p_sub_stats(main_stat, ["energy"]) * (0.25^2) +
        p_sub_stats(main_stat, ["DEF"]) * (0.25^2) +
        p_sub_stats(main_stat, ["energy", "DEF"]) * 10 * 0.5^2 * (1 - 0.5)^3 # 10是组合数C_5^2
    ) +
    0.1 * 0.8 * ( # 初始3词条
        p_sub_stats(main_stat, ["energy"]) * (0.25^2) +
        p_sub_stats(main_stat, ["DEF"]) * (0.25^2) +
        p_sub_stats(main_stat, ["energy", "DEF"]) * 6 * 0.5^2 * (1 - 0.5)^2 # 6是组合数C_4^2
    )
# 3个有效副词条的花、羽毛的概率为1.1%，平均要刷91次秘境，即9.5天，这才是值得追求的



#######################################################
# 模拟双暴分与刷取时间的关系
#######################################################

"""
计算随机掉落5星圣遗物升满20级后的双暴分
"""
function get_score(main_stat)
    stats = [main_stat]

    # 抽取4个副词条
    for i in 1:4
        not_existed = name -> name ∉ stats # 尚未被抽出的副词条
        pool = subset(sub_stats_weights, :name => ByRow(not_existed))
        sub_stat = sample(pool.name, weights(pool.weight))
        push!(stats, sub_stat)
    end
    sub_stats_pool = deleteat!(stats, 1) # 4个副词条

    # 强化
    origin_number = sample([4, 3], weights([0.2, 0.8])) # 初始副词条数量
    if origin_number == 4 # 初始4词条，可强化5次
        strengthen_stats = sample(sub_stats_pool, 5)
        append!(sub_stats_pool, strengthen_stats)
    else # 初始3词条，可强化4次
        strengthen_stats = sample(sub_stats_pool, 4)
        append!(sub_stats_pool, strengthen_stats)
    end

    # 计算双暴分
    crs = count(stat -> stat == "cr", sub_stats_pool)
    cds = count(stat -> stat == "cd", sub_stats_pool)
    score = sum(sample([5.4, 6.2, 7, 7.8], crs + cds)) # 4档数值等概率出现

    return score
end


## 以刷散兵沙楼4件套（攻风暴）为例

N = 1000 # 模拟 N 位玩家
T = floor(Int64, 180 * 1.065 * 9) # 刷半年可得沙楼圣遗物总数

sum_score_series = zeros(Int64, T)

for n in 1:N

    flower = -1
    plume = -1
    sand = -1
    goblet = -1
    circlet = -1

    score_series = []

    for t in 1:T
        artifact = sample(["flower", "plume", "sand", "goblet", "circlet"]) # 5个部位

        if artifact == "flower"
            score = get_score("hp")
            if score > flower
                flower = score
            end
        elseif artifact == "plume"
            score = get_score("atk")
            if score > plume
                plume = score
            end
        elseif artifact == "sand"
            main_stats = sample(
                ["ATK", "DEF", "HP", "energy", "mastery"],
                weights([5.33, 5.33, 5.33, 2, 2])
            )
            if main_stats == "ATK"
                score = get_score("ATK")
                if score > sand
                    sand = score
                end
            end
        elseif artifact == "goblet"
            main_stats = sample(["anemo_bonus", "others"], weights([1, 19]))
            if main_stats == "anemo_bonus"
                score = get_score("anemo_bonus")
                if score > goblet
                    goblet = score
                end
            end
        elseif artifact == "circlet"
            main_stats = sample(
                ["ATK", "DEF", "HP", "cr", "cd", "healing_bonus", "mastery"],
                weights([4.4, 4.4, 4.4, 2, 2, 2, 0.8])
            )
            if main_stats == "cr"
                score = get_score("cr")
                if score > circlet
                    circlet = score
                end
            end
        end


        # 计算4件套双暴分
        sum_score = -1
        scores = [flower, plume, sand, goblet, circlet]
        if count(score -> score == -1, scores) <= 1 # 凑齐了4件套
            sum_score = sum(deleteat!(sort(scores), 1)) + 40
            # 把词条最少的一件用优秀散件代替，姑且算40双暴分（6个词条以上）
        end
        push!(score_series, sum_score)
        println(n, "-", t)
    end

    if n % 100 == 0
        plot((1:T) ./ (1.065 * 9), score_series, legend=false,
            title="刷沙上楼阁4件套", xaxis="刷取天数", yaxis="双暴分")
        savefig("./events-simulator/img/critical-stats$(Int64(n/100)).png")
    end
    sum_score_series = sum_score_series + score_series
end


avg_score_series = sum_score_series / N # 所有玩家取平均，视为词条数期望的近似值
avg_score_series[500] # 刷50天能到170分，约合25个双暴副词条
avg_score_series[400] # 刷40天能到165分
avg_score_series[300] # 刷一个月有160分
avg_score_series[210] # 刷三周有152分
avg_score_series[150] # 刷半个月有142分
avg_score_series[70] # 刷一周有110分



plot((1:T) ./ (1.065 * 9), avg_score_series, legend=false,
    title="刷沙上楼阁4件套", xaxis="刷取天数", yaxis="双暴分")
savefig("./events-simulator/img/critical-stats.png")
