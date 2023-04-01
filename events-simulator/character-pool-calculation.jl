################################
# calculate exact probability
# 精确计算出金和出up的抽数期望
################################


## import packages
using Statistics
using StatsBase
using Plots, StatsPlots
pythonplot()



################################
# 出金（5星角色）
################################

# 构建每次抽取出金的概率向量 P_base，相互之间独立
# 前73次固定为 0.6%, 之后每次增加 6%
P_base = ones(73) .* 0.006
for i in 1:16
    push!(P_base, 0.006 + 0.06 * i)
end
push!(P_base, 1)
P_base
plot(P_base, legend=false)


# 计算恰好第某次抽取出金的概率
P_gold = [0.006]
for k in 2:90
    P_gold_k = (1 - sum(P_gold)) * P_base[k]
    # P_gold_k = prod(1 .- P_base[1:k-1]) * P_base[k]
    push!(P_gold, P_gold_k)
end
P_gold


plot(P_gold, legend=false, yaxis="probability", title="get a 5-star character")
# savefig("./events-simulator/img/density-gold.png")


# 出金抽数期望
E_gold = sum([1:90...] .* P_gold)



################################
# 出up 5星角色
################################

# 计算恰好第某次抽取出up的概率
P_up = [0.006 * 0.5] # 单次没歪出up的概率

# 第k抽出up
for k in 2:90
    # 2到90次出up，可能歪也可能不歪
    P_up_wai_j = j -> P_gold[j] * 0.5 * P_gold[k-j] # 第j次歪
    P_up_wai = (1:k-1) .|> P_up_wai_j |> sum
    P_up_notwai = P_gold[k] * 0.5
    P_up_k = P_up_wai + P_up_notwai
    push!(P_up, P_up_k)
end

for k in 91:180
    # 91到180次出up，必歪
    P_up_wai_j = j -> P_gold[j] * 0.5 * P_gold[k-j] # 第j次歪
    P_up_wai = (k-90:90) .|> P_up_wai_j |> sum
    push!(P_up, P_up_wai)
end

P_up
plot(P_up, legend=false, yaxis="probability", title="get up 5-star character")
# savefig("./events-simulator/img/density-up.png")


# 出up抽数期望
E_up = sum([1:180...] .* P_up)