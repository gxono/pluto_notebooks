### A Pluto.jl notebook ###
# v0.20.24

using Markdown
using InteractiveUtils

# ╔═╡ 58c3d4e2-e5ed-450a-90d5-6b2ae76bc4af
using StatsBase, CairoMakie

# ╔═╡ 164630ee-3b4f-11f1-87c0-99e3b320d60e
costo = 1_000_000

# ╔═╡ 5f215139-aff8-49e2-84aa-666409cdcd7f
probabilidad = 0.12

# ╔═╡ 5423fc8d-8008-4644-a8ca-0311f259894c
repeticiones_n = 7500

# ╔═╡ 175c1776-2b06-43a9-ae5a-02a6193119fb
begin
repeticiones_n; #solo para que actualice esta celda

# Prealojar vector de `repeticiones_n` cantidad de enteros sin definir.
repeticiones_necesarias = Vector{Int64}(undef, repeticiones_n)

# Repetir el experimento desde 1 hasta `repeticiones_n` donde `i` es el actual
for i in 1:repeticiones_n
	cantidad_presentacion = 1 #<- inicialmente una presentacion
	
	while rand() > probabilidad #rand() devuelve entre 0 y 1
		# Mientras rand() sea mayor que la probabilidad, habrá que presentar
		# 	de nuevo
		cantidad_presentacion += 1 #aumenta la cantidad en 1.
	end

	# Cuando rand() ≤ 0.12, se aprueba, y guardamos la cantidad de repeticiones
	# 	del experimento numero `i`.
	repeticiones_necesarias[i] = cantidad_presentacion
end
	
@info "Repeticiones necesarias hasta aceptar:" repeticiones_necesarias

end

# ╔═╡ 46dd0755-e8cd-4b68-9b20-e065e6ad176f
let
	fig = Figure(size = (700, 400))
	ax = Axis(fig[1,1], 
			xlabel = "Repetición", 
			ylabel = "Frecuencia",
			title = "Frecuencia del número de repeticiones necesarias para que la propuesta sea aceptada.")

	hist!(ax, repeticiones_necesarias, bins = 25)
	
	fig
end

# ╔═╡ f1fa3cc2-2e34-472b-a3b4-c43cf79c0280
let
	media_acumulada = cumsum(repeticiones_necesarias) ./ (1:repeticiones_n)
	expr_dec = string(round(1/probabilidad, digits=2))
	
	fig = Figure(size = (700, 400))
	ax = Axis(fig[1,1], xlabel = "Número de repetición")
	
	lines!(ax, 1:repeticiones_n, media_acumulada)
	hlines!(ax, 1/probabilidad, color = :red, label = "𝔼[X] = 1/$(string(probabilidad)) ≈ $expr_dec")

	axislegend(ax)
	fig
end

# ╔═╡ Cell order:
# ╠═58c3d4e2-e5ed-450a-90d5-6b2ae76bc4af
# ╠═164630ee-3b4f-11f1-87c0-99e3b320d60e
# ╠═5f215139-aff8-49e2-84aa-666409cdcd7f
# ╠═5423fc8d-8008-4644-a8ca-0311f259894c
# ╠═175c1776-2b06-43a9-ae5a-02a6193119fb
# ╟─46dd0755-e8cd-4b68-9b20-e065e6ad176f
# ╟─f1fa3cc2-2e34-472b-a3b4-c43cf79c0280
