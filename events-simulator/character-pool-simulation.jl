################################
# MonteCarlo Method
# 通过模拟看平均多少抽出金和出up
################################


using Statistics
using StatsBase
using Plots, StatsPlots



# 单抽出金概率
P = 0.006

# 试验轮数
N = 100000

# 每轮试验中满足条件所需的抽数
n_gold = zeros(Int64, N)
n_up = zeros(Int64, N)


# 进行 N 轮试验
for i in 1:N

    gold = false
    for k in 1:90
        t = rand()
        if k ≤ 73
            t ≤ P && (gold = true)
        else
            t ≤ (P + 0.06 * (k - 73)) && (gold = true)
        end

        if gold == true
            print("$k, ")
            n_gold[i] = k
            break
        end
    end

    up = (rand() < 0.5) ? true : false
    if up == true
        n_up[i] = n_gold[i] # 若出的金就是up，该轮试验结束
    else # 否则（歪了），就要继续抽，直到出现第二个金，大保底必是up
        gold = false
        for k in 1:90
            t = rand()
            if k ≤ 73
                t ≤ P && (gold = true)
            else
                t ≤ (P + 0.06 * (k - 73)) && (gold = true)
            end

            if gold == true
                print(k)
                n_up[i] = n_gold[i] + k
                break
            end
        end
    end

    println(" ")
end


mean(n_gold) # 出金的平均抽数
median(n_gold) # 中位数
mode(n_gold) # 众数
histogram(n_gold)
# density(n_gold)
count(<(74), n_gold) / N # 73抽内出金概率


mean(n_up) # 出up的平均抽数
median(n_up)
mode(n_up)
histogram(n_up)
# density(n_up)
count(≥(150), n_up) / N # 150抽以上出up概率