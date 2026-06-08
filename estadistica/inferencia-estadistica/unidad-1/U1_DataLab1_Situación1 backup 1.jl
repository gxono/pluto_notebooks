### A Pluto.jl notebook ###
# v0.20.24

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ cf7433f0-5ee5-4aa9-b35a-d04d8a9c4aeb
begin
# Recordar hacer un .bat para preinstalar los paquetes antes de la clase.
#using Pkg
#Pkg.add([
#	"Combinatorics", 
#	"CairoMakie", 
#	"PlutoTeachingTools", 
#	"PlutoUI",
#	"StatsBase"])

using StatsBase
using Combinatorics
using CairoMakie
using PlutoTeachingTools
using PlutoUI
import PlutoUI: Slider
md"""
# Dependencias del proyecto
"""
end

# ╔═╡ 2896d00e-fa9a-4a0d-b7bf-a629a81f49d6
begin
struct Legajo
	id::Int
	tipo::Symbol
end
	
colores_legajo = (bajo = :green, medio = :orange, alto = :red)
	
opciones_poly = (
	strokecolor = :black, 
	strokewidth = 4)

opciones_text = (
	align = (:center, :center), 
	color = :white, 
	font = :bold)

function dibujar_legajos!(ax, legajos; escala = 1)
    for (i, legajo) in enumerate(legajos)
        poly!(ax, Rect2f(i-1, 0, 1, 1); 
			  color = colores_legajo[legajo.tipo], 
			  opciones_poly...)
        text!(ax, i-0.5, 0.5; 
			  text = string(legajo.id), 
			  fontsize = 12 * escala, 
			  opciones_text...)
    end
end

#Dibuja una muestra de legajos (contenida en una tupla, ojo!)
# Esto es asi porque decidi que las 2-muestra esten guardadas ahi.
function dibujar_muestra(legajos; escala = 1)
    n = length(legajos)
    fig = Figure(size = (20n * escala, 20 * escala), figure_padding = 2)
    ax = Axis(fig[1,1], aspect = DataAspect(),
              limits = (0, n, 0, 1), backgroundcolor = :transparent)
    hidedecorations!(ax)
    hidespines!(ax)
    dibujar_legajos!(ax, legajos; escala = escala)
    fig
end

#y un Method para dibujar un solo legajo fuera de un Vector (por pereza)
dibujar_muestra(legajo::Legajo; escala = 1) = dibujar_muestra([legajo]; escala = escala)



#recibe una muestra de 2, una cantidad de moderado, una cantidad de alto y testea
function es_muestra_xy(legajos, x, y)
	n_medio = 0
	n_alto = 0
	
	for legajo in legajos
		legajo.tipo == :medio ? n_medio += 1 :
		legajo.tipo == :alto ? n_alto += 1 : nothing
	end

	return (x == n_medio) && (y == n_alto)
end

# Cuenta en el vector de repeticiones las apariciones que satisfacen x e y
#x: cantidad moderada
#y: cantidad alta
function crxy(repeticiones, x, y)
	sum(es_muestra_xy.(repeticiones, x, y))
end

function es_no_critica(muestra)
	count(l -> l.tipo == :medio || l.tipo == :alto, muestra) < 2
end

end;

# ╔═╡ 2ce6b9dc-429d-40f0-a030-8de4f5e23823
md"*Una versión mucho menos detallada (pero sin restricciones para experimentar, ligera y eficiente) es la del fichero* `legajos-bancarios-code.jl`"

# ╔═╡ 24276ebf-5d60-4342-8091-f13b02c549f2
md"""🔄 *Reiniciar cuaderno* $(@bind reset_nb CounterButton("Reiniciar"))"""

# ╔═╡ 0719dfbd-0501-40f3-80ee-615615f56fd6
begin
	reset_nb
	md"""
	*Por defecto:*
	- *Mostrar los comentarios en todo el código (se puede activar o desactivar individualmente) $(@bind mostrar_comentarios Switch())*
	"""
end

# ╔═╡ 2953ee77-5d8f-4e4d-b2fa-689ab51dd045
md"""
# U-1: Situación 1
Una entidad bancaria está revisando una muestra aleatoria de 2 legajos de préstamos otorgados durante el último mes para una auditoría de calidad. En el lote a auditar hay 12 expedientes con las siguientes calificaciones de riesgo (basadas en la capacidad de pago):
5 de “Riesgo bajo"
4 de "Riesgo Moderado"
3 de "Riesgo Alto”
Si la muestra contiene a lo sumo un expediente de Riesgo Moderado o Alto, se considera “no crítica”. Determinar la probabilidad de que la muestra sea calificada de esa forma.
"""

# ╔═╡ e644c2fa-8e7b-417f-b539-c9928c4ad5ca
TableOfContents()

# ╔═╡ 9b5a4813-53cf-433f-95b6-124b921798b6
md"## Los expedientes"

# ╔═╡ a177bdd2-7a84-49de-b299-ee19402f59ee
begin
constructor = (bajo = 5, medio = 4, alto = 3)


# "un Legajo de cada riesgo, repetido cantidad veces"
legajos = [Legajo(i, riesgo)
			for (riesgo, cantidad) in pairs(constructor)
			for i in 1:cantidad]

@info dibujar_muestra.(legajos; escala = 1.5)
end

# ╔═╡ 5fac0cef-500c-4304-9aab-5978d996129e
md"""
El *espacio muestral* que se genera al tomar una muestra al azar de tamaño 2 y observar los valores de ``X`` e ``Y`` puede verse a continuación"""

# ╔═╡ 993fc6c4-3c72-46b8-af81-db287e35b4ae
begin
	espacio_muestral = combinations(legajos, 2) |> collect
	@info "Espacio muestral:" dibujar_muestra.(espacio_muestral; escala = 1.5)
end

# ╔═╡ 8c5a59a8-6433-4c6f-a66b-6d68c67b30c4
md"""
## Definición de las variables aleatorias:

``X`` = Cantidad de expedientes calificados como *Riesgo Moderado*

``Y`` = Cantidad de expedientes calificados como *Riesgo Alto*    
"""

# ╔═╡ 1bd1b2ed-a40d-4677-982d-cc11295da856
md"*Distribución de frecuencias* al tomar ``K`` muestras aleatorias"

# ╔═╡ 2fee719b-77a1-4f0b-a725-d45e6886cb6f
@bind repeticion_n Slider(1:1000, show_value=true, default=10)

# ╔═╡ a55084f2-bc32-4426-8e13-4cc921dbe3a1
begin
#Esta es la muestra
repeticiones = sample(espacio_muestral, repeticion_n; replace = true)

#La tabla de frecuencias, para ya tenerla. (esta es la de cada obs. del espacio)
repeticiones_freq = let r = countmap(repeticiones)
	[e => get(r, e, 0) for e in espacio_muestral if haskey(r, e)]
end

#La matrix de frecuencias segun X e Y
freqxy = Matrix{Int64}(undef, 3, 3)
for x in 1:3, y in 1:3
	freqxy[x, y] = crxy(repeticiones, x-1, y-1)
end
end;

# ╔═╡ 172348ff-d7ff-47e1-a459-71069f5d6252
md"👀 Mostrar tabla de frecuencias graficas $(@bind mostrar_tablafrecuencias_em Switch())"

# ╔═╡ 9692cc0a-a5c8-4aab-9981-bdd158bf259c
if mostrar_tablafrecuencias_em
	md"Moderados: $(@bind filtro_moderado Select([\"Cualq.\", \"0\", \"1\", \"2\"])) Altos: $(@bind filtro_alto Select([\"Cualq.\", \"0\", \"1\", \"2\"]))"
end

# ╔═╡ 0be96aa0-61ff-4d9a-861a-b9be4a5a1bd9
if mostrar_tablafrecuencias_em
let
    indices_filtrados = findall(repeticiones_freq) do par
        x_ok = filtro_moderado == "Cualq." || count(l -> l.tipo == :medio, par.first) == parse(Int, filtro_moderado)
        y_ok = filtro_alto     == "Cualq." || count(l -> l.tipo == :alto,  par.first) == parse(Int, filtro_alto)
        x_ok && y_ok
    end

    if isempty(indices_filtrados)
        md"*No hay muestras con esos valores.*"
    else
        n_cols = 4
        n = length(indices_filtrados)
        n_filas = ceil(Int, n / n_cols)

        header    = "| " * join(repeat(["Muestra | Frecuencia"], n_cols), " | ") * " |"
        separator = "|" * repeat(":---:|:---:|", n_cols)

        filas = join([
            let indices = [r + c*n_filas for c in 0:n_cols-1 if r + c*n_filas <= n]
                celdas = ["\$(dibujar_muestra(repeticiones_freq[$(indices_filtrados[i])].first)) | \$(repeticiones_freq[$(indices_filtrados[i])].second)"
                          for i in indices]
                celdas = vcat(celdas, repeat([" | "], n_cols - length(indices)))
                "| " * join(celdas, " | ") * " |"
            end
            for r in 1:n_filas
        ], "\n")

        eval(Meta.parse("""
        md\"\"\"
        $header
        $separator
        $filas
        \"\"\""""))
    end
end
end


# ╔═╡ 21cedb47-c1e5-41c2-9729-587a55a98c0e
begin 
	# 1. Definición de la función de formato
	fmt(r) = r == 0 ? "0" : "$(r)/$(repeticion_n)"
	
	# 2. Cálculo de la suma solicitada y comparación
	# (0,0) -> [1,1], (0,1) -> [1,2], (1,0) -> [2,1]
	suma_absoluta = freqxy[1,1] + freqxy[1,2] + freqxy[2,1]
	valor_suma = suma_absoluta / repeticion_n
	referencia = 45 / 66
	
	# Determinamos el símbolo de comparación
	simbolo = if valor_suma > referencia
		">"
	elseif valor_suma < referencia
		"<"
	else
		"="
	end

	# 3. Estructura de la tabla
	header = "| ``f(X,Y)`` | ``Y = 0`` | ``Y = 1`` | ``Y = 2`` | ``P(X = x)`` |"
	sep    = "|:---:|:---:|:---:|:---:|:---:|"
	filas  = [
		"| ``X = $(x-1)`` | $(fmt(freqxy[x, 1])) | $(fmt(freqxy[x, 2])) | $(fmt(freqxy[x, 3])) | $(fmt(sum(freqxy[x, :]))) |"
		for x in 1:3
	]
	pie    = "| ``P(Y = y)`` | $(fmt(sum(freqxy[:, 1]))) | $(fmt(sum(freqxy[:, 2]))) | $(fmt(sum(freqxy[:, 3]))) | ``1`` |"

	# 4. Renderizado final con Markdown
	Markdown.parse("""
	## Tabla de distribución de frecuencias conjunta ``P(X = x, Y = y)``

	$(join([header, sep, filas..., pie], "\n"))

	---
	- Resultado del cálculo de probabilidad empírica: La suma ``f(0,0) + f(0,1) + f(1,0)`` es ``$(fmt(suma_absoluta)) \\approx $(round(valor_suma, digits=4))``.
	
	- Valor de probabilidad teórica ``≈ 0.6818``
	""")
end

# ╔═╡ d55da34e-c1f6-4f5b-b894-1ca7ca3eff80
md"""
## Tabla de distribución conjunta de probabilidad

| ``f(X,Y)`` | ``Y=0`` | ``Y=1`` | ``Y=2`` | ``P(X = x)`` |
| :--- | :---: | :---: | :---: | :---: |
| ``X=0`` | $10/66$ | $15/66$ | $3/66$ | **$28/66$** |
| ``X=1`` | $20/66$ | $12/66$ | $0$ | **$32/66$** |
| ``X=2`` | $6/66$ | $0$ | $0$ | **$6/66$** |
| ``P(Y = y)`` | $36/66$ | $27/66$ | $3/66$ | $66/66$ |
"""

# ╔═╡ ba812b29-e0b4-40d6-be41-9e71fed7c434
let
	cum_freq = Vector{Float64}(undef, repeticion_n)
	cum_freq[1] = es_no_critica(repeticiones[1])

	curr_qty::Float64 = cum_freq[1]
	for i in 2:length(repeticiones) #mas eficiente que calcular para cada muestra
		curr_qty = curr_qty + es_no_critica(repeticiones[i])
		cum_freq[i] = curr_qty / i
	end

	frecuencia_verdadera = 45//66

	num::Int64    = numerator(frecuencia_verdadera)
	den::Int64    = denominator(frecuencia_verdadera)
	
	
	fig = Figure(size = (700, 400))
	ax = Axis(fig[1,1],
			xlabel = "Número de muestra tomada",
			ylabel = "Frecuencia relativa",
			title = "Frecuencia relativa de legajos \"no críticos\" por número de muestra")

	hlines!(ax, frecuencia_verdadera, color = :red, label = "Frecuencia verdadera (≈ 0.6818)")
	lines!(ax, eachindex(repeticiones), cum_freq, label = "Frecuencia experimental")

	axislegend(ax, position=:rb)

	fig
end

# ╔═╡ Cell order:
# ╟─2896d00e-fa9a-4a0d-b7bf-a629a81f49d6
# ╟─2ce6b9dc-429d-40f0-a030-8de4f5e23823
# ╟─24276ebf-5d60-4342-8091-f13b02c549f2
# ╟─0719dfbd-0501-40f3-80ee-615615f56fd6
# ╟─2953ee77-5d8f-4e4d-b2fa-689ab51dd045
# ╟─e644c2fa-8e7b-417f-b539-c9928c4ad5ca
# ╟─9b5a4813-53cf-433f-95b6-124b921798b6
# ╟─a177bdd2-7a84-49de-b299-ee19402f59ee
# ╟─5fac0cef-500c-4304-9aab-5978d996129e
# ╟─993fc6c4-3c72-46b8-af81-db287e35b4ae
# ╟─8c5a59a8-6433-4c6f-a66b-6d68c67b30c4
# ╟─1bd1b2ed-a40d-4677-982d-cc11295da856
# ╟─2fee719b-77a1-4f0b-a725-d45e6886cb6f
# ╠═a55084f2-bc32-4426-8e13-4cc921dbe3a1
# ╟─172348ff-d7ff-47e1-a459-71069f5d6252
# ╟─9692cc0a-a5c8-4aab-9981-bdd158bf259c
# ╟─0be96aa0-61ff-4d9a-861a-b9be4a5a1bd9
# ╟─21cedb47-c1e5-41c2-9729-587a55a98c0e
# ╟─d55da34e-c1f6-4f5b-b894-1ca7ca3eff80
# ╟─ba812b29-e0b4-40d6-be41-9e71fed7c434
# ╠═cf7433f0-5ee5-4aa9-b35a-d04d8a9c4aeb
