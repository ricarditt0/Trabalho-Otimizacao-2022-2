using JuMP
using Cbc

function problema_2(nt,C,c,s,t)
    # nt =  numero de tasks
    # C = numero de cores por maquina
    # c = numero de cores que cada tarefa precisa
    # s = tempo de inicio da tarefa
    # t = tempo de fim da tarefa
    # nm = numero de maquinas total
    nm = nt
    t_max = maximum(t)
    model = Model(Cbc.Optimizer)
    set_optimizer_attribute(model, "seconds", 60.0*60*2)
    set_optimizer_attribute(model, "logLevel", 1)
    @variable(model, x1[0:nm-1], Bin)
    @variable(model, x2[0:nm-1], Bin)
    @variable(model, z[0:nm-1])
    @variable(model, y[0:nm-1, 0:nt-1], Bin)
    @objective(model, Min, sum(x2[i] for i in 0:nm-1))
 
    #cada tarefa atribuida a uma maquina
    @constraint(model, [j in 0:nt-1], sum(y[i,j] for i in 0:nm-1) == 1)

    #restrição usada para contar numero de maquinas usadas        
    @constraint(model, [i in 0:nm-1], sum(y[i,j] for j in 0:nt-1) == z[i])            
    @constraint(model, [i in 0:nm-1], z[i] <= x2[i]*C)
    @constraint(model, [i in 0:nm-1], z[i] + x1[i]*C <= C)
    @constraint(model, [i in 0:nm-1], x1[i] + x2[i] == 1)

    #restrição de numero de cores usados por unidade de tempo
    @constraint(model, [i in 0:nm-1, k in 0:t_max], sum(c[j+1]*y[i,j]*(s[j+1] <= k <= t[j+1] ? 1 : 0) for j in 0:nt-1) <= C)

    #numero de cores utilizados por uma tarefa deve ser menor que C
    @constraint(model, [i in 1:nt], c[i] <= C)
    optimize!(model)
    @show value.(x2) objective_value(model)
end


function main()
    n = 0
    C = 0
    c = []
    s = []
    t = []

    f = open("instancia_200_100_1.dat", "r")
    line = readline(f)
    temp = split(line,"\t")
    n = parse(Int64,temp[1])
    C = parse(Int64,temp[2])
    for line in readlines(f)       
        temp = split(line,"\t")         
        append!(c,parse(Int64,temp[4]))
        append!(s,parse(Int64,temp[2]))
        append!(t,parse(Int64,temp[3]))
    end
    close(f)
    problema_2(n,C,c,s,t)
end
main()