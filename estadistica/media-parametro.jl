### A Pluto.jl notebook ###
# v0.20.24

#> [frontmatter]
#> language = "es"
#> title = "Parámetro de la media"
#> date = "2025-12-03"
#> tags = ["estadistica", "media", "parametro"]
#> 
#>     [[frontmatter.author]]
#>     name = "Jonatán Perren"

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

# ╔═╡ a1bcafd9-d612-4387-af87-0b4286bb66dc
begin
	using Pkg;
	paquetes = [
		"Random", "Distributions", "Statistics", "LaTeXStrings",
		"Plots", "CairoMakie", "PlutoUI"
	]

	Pkg.add(paquetes)

	using Random 		# Para controlar la seed.
	using Distributions # Para usar la funcion sample().
	using Statistics 	# Para acceder a la funcion mean().
	using LaTeXStrings 	# Para usar cadenas LaTeX en graficos.
	using CairoMakie 	# Para los gráficos.
	using PlutoUI

	Random.seed!(4)
end;

# ╔═╡ 54f3718f-e542-47ca-bb56-9e36b1eed94b
md"""🔄 *Reiniciar cuaderno* $(@bind reset_nb CounterButton("Reiniciar"))"""

# ╔═╡ b5f66aed-99db-424f-8a37-ad9bb30fdac2
begin
	reset_nb
	md"""
	*Por defecto:*
	- *Mostrar los comentarios en todo el código (se puede activar o desactivar individualmente) $(@bind mostrar_comentarios Switch())*
	"""
end

# ╔═╡ fe6215a7-8e94-4b21-867b-70a1a4614870
md"""
# Descripción del fichero

En este documento se presenta una simulación en Julia cuyo objetivo es analizar el comportamiento de la media muestral como estimador de la media poblacional. Para ello, se genera una población artificial con distribución normal conocida y se extraen múltiples muestras de tamaño fijo, calculando la media de cada una. A partir de estas medias muestrales se estudia su distribución y se construye una sucesión de medias progresivas, que permite observar empíricamente cómo, al aumentar la cantidad de muestras consideradas, el promedio de las medias muestrales se aproxima a la media de la población. El análisis ilustra de manera sencilla y visual la idea de insesgadez de la media muestral y su vínculo con la ley de los grandes números.

# Implementación

Comenzamos cargando las librerías necesarias
"""

# ╔═╡ 8e3f23dc-359e-4174-90a6-de32f4746fe6
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_paquetes Switch(default = mostrar_comentarios))"

# ╔═╡ c0fd21bc-23f5-464e-9cfd-73d2febeed22
if comentarios_paquetes 
	md"""
	```julia
	using Random 		# Para controlar la seed.
	using Distributions # Para usar la funcion sample().
	using Statistics 	# Para acceder a la funcion mean().
	using LaTeXStrings 	# Para usar cadenas LaTeX en graficos.
	using CairoMakie 	# Para los gráficos.
	```
	"""
else
	md"""
	```julia
	using Random
	using Distributions
	using Statistics
	using LaTeXStrings
	using CairoMakie
	```
	"""
end

# ╔═╡ 17323830-d09f-11f0-90a5-435c1d5a0aa2
md"""
```julia
Random.seed!(4)
```
"""

# ╔═╡ a94a2280-730f-4114-8da7-1338ebaf2482
md"""
y las variables que estarán involucradas en nuestro problema: el tamaño de la población, la cantidad de muestras que vamos a extraer, el tamaño de cada muestra y la población simulada, que en este caso seguirá una distribución normal.
"""

# ╔═╡ 7dc005d3-45a8-429f-bd94-4aecbcc5e2dd
begin
tamano_poblacion  = 10000
cantidad_muestras = 2000
tamano_muestra    = 50
poblacion         = 5 .+ randn(tamano_poblacion)
media_poblacional = mean(poblacion)
@info "Media poblacional: $media_poblacional"
end

# ╔═╡ 10a7802a-0c26-4722-adbe-de1627ed878a
md"""
En este experimento, la población simulada tiene media verdadera igual a 5, pero la media muestral de la población generada, `media_poblacional`, resulta ser aproximadamente $(round(media_poblacional, digits = 3)). Este será el valor de referencia frente al cual compararemos las medias de las muestras.

A continuación, generamos muchas muestras de la población y calculamos su media. Para ello usamos una comprensión de listas en Julia, que nos permite repetir una misma instrucción varias veces y devolver el resultado en un vector.
"""

# ╔═╡ d6f185f3-a7ff-498a-9a1d-52834dbdea66
begin
media_muestras = [
    mean(sample(poblacion, tamano_muestra, replace = false))
    for _ in 1:cantidad_muestras
]
@info media_muestras
end

# ╔═╡ 4df3b737-4467-4730-9212-45b66c27b91d
md"""
La media de este conjunto la podemos obtener a través de la siguiente instrucción
"""

# ╔═╡ 2f9200ce-44c9-4be2-aca1-1b3b4daf3907
@info mean(media_muestras)

# ╔═╡ 100cdd55-aef8-4e3f-a6bc-89cf3e935229
md"""
El valor `mean(media_muestras)` es el promedio de las medias muestrales. En un experimento de este tipo esperamos que sea cercano a `media_poblacional`, lo que es coherente con que la media muestral sea un estimador insesgado de la media poblacional.

Si exploramos los datos de las medias muestrales, podemos ver cómo se distribuyen alrededor de la media poblacional.
"""

# ╔═╡ 82b04885-d038-4067-8cc9-258fedd62b65
begin
histograma = Figure(size = (800, 450), fontsize = 18) 

ejes = Axis(histograma[1, 1],
			title = "Distribución de las medias muestrales")

hist!(ejes,
	  media_muestras,
	  strokewidth=2,
	  strokecolor = :white,
	  color = :royalblue,
	 label = "Distribución de media muestral")

vlines!(ejes,
	   [mean(media_muestras)],
	   color = :black,
	   linewidth = 4,
	   label = "Media muestral (x̄ = $(round(mean(media_muestras),digits = 5)))")

vlines!(ejes,
	   [media_poblacional],
	   color = :firebrick,
	   linewidth = 4,
	   label = "Media poblacional (μ = $(round(media_poblacional, digits = 5)))")
	
axislegend(ejes, position = :rt, framevisible = true, backgroundcolor = :white)
	
histograma
end

# ╔═╡ 9daf2478-23b4-41b4-b0b2-e20649f559a6
md"""
En el histograma observamos que las medias muestrales se concentran alrededor de $(round(media_poblacional, digits = 3)). La línea vertical marca el valor de la media poblacional. Esto ilustra que, si bien cada media muestral es aleatoria, en promedio se ubican alrededor de la verdadera media de la población.

Ahora queremos analizar cómo se comporta el promedio de las medias muestrales a medida que aumentamos la cantidad de muestras consideradas. Para ello construimos lo que llamaremos una *media progresiva*.

El vector `media_progresiva` se define de la siguiente manera:

- La primera posición contiene la media de la primera muestra.
- La segunda posición contiene el promedio de las medias de las primeras dos muestras.
- La tercera posición contiene el promedio de las medias de las primeras tres muestras.
- Y así sucesivamente, hasta usar todas las muestras disponibles.

En términos matemáticos, si denotamos por ``\bar X_1, \bar X_2, \dots, \bar X_k`` las medias muestrales, definimos la sucesión
```math
M_k = \frac{1}{k}\sum_{i=1}^k \bar X_i.
```

Si la media muestral es un buen estimador, esperamos que ``M_k`` se acerque a la media poblacional a medida que ``k`` crece. Esta idea está vinculada con la ley de los grandes números.

Construimos esta sucesión de manera vectorizada usando `cumsum()` (suma acumulada) y los índices naturales `1:length(media_muestras)`.
"""

# ╔═╡ a9e3d76b-9663-4d2d-b3e6-c35b5ff22634
begin
media_progresiva = cumsum(media_muestras) ./ (1:length(media_muestras))
@info media_progresiva
end

# ╔═╡ 28e24981-3250-44d1-a829-512d54342f4d
md"""
La función `cumsum(media_muestras)` devuelve un vector donde cada posición contiene la suma de las medias muestrales hasta ese punto. Al dividir cada una de esas sumas acumuladas por el índice correspondiente (`1:length(media_muestras)`), obtenemos el promedio de las medias muestrales hasta ese instante.

Representamos gráficamente la sucesión ``M_k`` y la comparamos con la media poblacional.
"""

# ╔═╡ bfad372b-701a-48f0-9f77-c0c64ebece76
begin
f = Figure(size = (800, 450), fontsize = 18) 

ax = Axis(f[1, 1],
    title = "Convergencia de la Media Progresiva (Ley de los Grandes Números)",
    xlabel = "Número de muestras acumuladas (k)",
    ylabel = "Estimación de la media",
    xgridstyle = :dash, 
    ygridstyle = :dash,
    xminorticksvisible = true,
    xminorgridvisible = true
)

lines!(ax, 1:length(media_progresiva), media_progresiva, 
    color = (:royalblue, 0.9), 
    linewidth = 2,
    label = "Media Muestral Acumulada"
)

hlines!(ax, [media_poblacional], 
    color = :firebrick, 
    linestyle = :dash, 
    linewidth = 2,
    label = "Media Poblacional Verdadera (μ)"
)

axislegend(ax, position = :rt, framevisible = true, backgroundcolor = :white)

f
end

# ╔═╡ f835f41b-eb82-4ba3-9b8d-2986893344af
md"""
En el gráfico se aprecia que la media progresiva comienza con cierta variabilidad, pero se va estabilizando en torno al valor $(round(media_poblacional, digits = 3)) a medida que aumenta el número de muestras consideradas. Esto ilustra empíricamente que:

1. La media muestral se distribuye alrededor de la media poblacional (no presenta sesgo sistemático).
2. A medida que usamos más información (más muestras), el promedio de las medias muestrales se aproxima al valor verdadero de la media de la población, reduciendo la variabilidad.

En conjunto, esta simulación apoya la idea de que la media muestral es un buen estimador de la media poblacional: es insesgado y, al aumentar el tamaño de la muestra o la cantidad de muestras, las estimaciones se concentran cada vez más cerca del valor verdadero.
"""

# ╔═╡ Cell order:
# ╟─a1bcafd9-d612-4387-af87-0b4286bb66dc
# ╟─54f3718f-e542-47ca-bb56-9e36b1eed94b
# ╟─b5f66aed-99db-424f-8a37-ad9bb30fdac2
# ╟─fe6215a7-8e94-4b21-867b-70a1a4614870
# ╟─8e3f23dc-359e-4174-90a6-de32f4746fe6
# ╟─c0fd21bc-23f5-464e-9cfd-73d2febeed22
# ╟─17323830-d09f-11f0-90a5-435c1d5a0aa2
# ╟─a94a2280-730f-4114-8da7-1338ebaf2482
# ╠═7dc005d3-45a8-429f-bd94-4aecbcc5e2dd
# ╟─10a7802a-0c26-4722-adbe-de1627ed878a
# ╠═d6f185f3-a7ff-498a-9a1d-52834dbdea66
# ╟─4df3b737-4467-4730-9212-45b66c27b91d
# ╠═2f9200ce-44c9-4be2-aca1-1b3b4daf3907
# ╟─100cdd55-aef8-4e3f-a6bc-89cf3e935229
# ╟─82b04885-d038-4067-8cc9-258fedd62b65
# ╟─9daf2478-23b4-41b4-b0b2-e20649f559a6
# ╠═a9e3d76b-9663-4d2d-b3e6-c35b5ff22634
# ╟─28e24981-3250-44d1-a829-512d54342f4d
# ╟─bfad372b-701a-48f0-9f77-c0c64ebece76
# ╟─f835f41b-eb82-4ba3-9b8d-2986893344af
