using StatsBase, Combinatorics


mutable struct Legajo
	tipo::Symbol
end


riesgos = (🟩 = 5, 🟨 = 4, 🟥 = 3)

legajos = [Legajo(riesgo)
	for (riesgo, cantidad) in pairs(riesgos)
	for _ in 1:cantidad]


espacio_muestral = combinations(legajos, 2) |> collect
espacio_muestral

repeticiones = sample(espacio_muestral, 50)

function satisface_xy(observacion, x, y)
	count(l -> l.tipo == :🟨, observacion) == x &&
	count(l -> l.tipo == :🟥, observacion) == y
end


function contar_xy(repeticiones, x, y)
	return count(m -> satisface_xy(m, x, y), repeticiones)
end


fxy = Matrix{Rational}(undef, 3, 3)

for x in 0:2, y in 0:2
	fxy[x+1, y+1] = contar_xy(repeticiones, x, y) // length(repeticiones)
end

fxy

# Yapa 😉
fmx = [sum(fxy[x, :]) for x in 1:3] # `fmx[2]` devuelve fₓ(1).
fmy = [sum(fxy[:, y]) for y in 1:3]