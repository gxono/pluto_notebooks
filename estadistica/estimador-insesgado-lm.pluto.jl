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

# ╔═╡ 96d9684f-1daa-4309-88a8-d8e54666c82d
begin
	using Pkg
	paquetes = [
		"StatsBase", "CairoMakie", "GLM", "DataFrames", 
		"Distributions", "PlutoTeachingTools", "PlutoUI"]
	Pkg.add(paquetes)


	# Las funciones generadas para el Notebook las dejo acá para encontrarlas en
	# 	un solo lugar
	
	using StatsBase
	using CairoMakie
	using GLM
	using DataFrames
	using Distributions
	using PlutoUI
	using PlutoTeachingTools
	using Printf
	
	function generar_poblacion(n, μₓ, σₓ, σₑ)
		# x ~ N(μₓ, σₓ²)
		x = rand(Normal(μₓ, σₓ), n)

		# ε ~ N(0, σₑ²)
		ε = rand(Normal(0, σₑ), n)

		# relación verdadera: Y = 3 + 1 ⋅ X + ε
		y = 3 .+ x + ε

		return DataFrame(; x, ε, y)
	end
end;

# ╔═╡ 0fb9b39c-9fc8-4659-bd31-a53e28ea0035
md"""
# Demostración de la insesgadez del estimador de mínimos cuadrados ordinarios (MCO)
"""

# ╔═╡ c73a95bb-7520-4dd2-a756-2ea4e428f88b
md"""🔄 *Reiniciar cuaderno* $(@bind reset_nb CounterButton("Reiniciar"))"""

# ╔═╡ 7a92b92e-25fc-4fcd-8a3a-510cfe419006
begin
	reset_nb
	md"""
	*Por defecto:*
	- *Mostrar los comentarios en todo el código (se puede activar o desactivar individualmente) $(@bind mostrar_comentarios Switch())*
	"""
end

# ╔═╡ 811a97ae-64d4-4243-afd5-ba322a4472b5
md"""
Este cuaderno usa Julia y Pluto.jl para comprobar que los estimadores MCO son insesgados. Para hacer uso de la interactividad es necesario tener Julia instalado y abrir el cuaderno con Pluto.

Las librerías necesarias para empezar a trabajar son las siguientes:
"""

# ╔═╡ 34c6f27f-c56e-4409-bdf6-d5f543fdff6f
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_paquetes Switch(default = mostrar_comentarios))"

# ╔═╡ d1cbe04e-c09e-48b2-97ca-7eb0dce7e3f6
if comentarios_paquetes 
	md"""
	```julia
	using StatsBase  	# Para usar sample() y tomar muestras.
	using CairoMakie 	# Para los gráficos.
	using GLM 			# Para determinar el modelo de regresión.
	using DataFrames 	# Para trabajar los datos más comodamente.
	using Distributions # Para utilizar la distribucion Normal(μ, σ).
	```
	"""
else
	md"""
	```julia
	using StatsBase
	using CairoMakie
	using GLM
	using DataFrames
	using Distributions
	```
	"""
end

# ╔═╡ 0e524340-6ce7-4405-a1ef-247a675cde9f
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_generar_poblacion Switch(default = mostrar_comentarios))"

# ╔═╡ 563fed55-8802-407c-ac93-85f56c717ea4
if comentarios_generar_poblacion
	md"""
	```julia
	function generar_poblacion(n, μₓ, σₓ, σₑ)		
		# Se toma una muestra aleatoria de tamaño n de una distribución normal 
		# 	con media μₓ y desviación estándar σₓ para generar las abscisas de
		# 	los puntos.
		# x ~ N(μₓ, σₓ²)
		x = rand(Normal(μₓ, σₓ), n)

		# Se toma una muestra aleatoria de tamaño n de una distribución normal
		# 	con media 0 y desviación estándar σₑ para generar los errores respecto
		# 	al modelo.
		# ε ~ N(0, σₑ²)
		ε = rand(Normal(0, σₑ), n)

		# Se construyen los valores de y a través de una expresión lineal.
		# 	`.+` es necesario porque sumaremos un escalar (3) con un vector (x).
		# Relación Verdadera (Poblacional): Y = 3 + 1 ⋅ X + ε
		y = 3 .+ x + ε

		# Devolvemos un marco de datos con las variables generadas. En este caso,
		# 	es necesario el `;` para que las variables del marco usen el mismo nombre
		# 	que las variables que le estamos pasando.
		return DataFrame(; x, ε, y)
	end

	# Generamos un marco de datos llamado `datos` y le asignamos los valores 
	# 	producidos por la función. En este caso, `n`, `μₓ`, `σₓ` y `\epsilon`
	# 	vienen dados por los elementos interactivos de abajo.
	datos = generar_poblacion(n, μₓ, σₓ, σₑ);
	```
	"""
else
	md"""
	```julia
	function generar_poblacion(n, μₓ, σₓ, σₑ)		
		x = rand(Normal(μₓ, σₓ), n)
		ε = rand(Normal(0, σₑ), n)
		y = 3 .+ x + ε
		
		return DataFrame(; x, ε, y)
	end

	datos = generar_poblacion(n, μₓ, σₓ, σₑ);
	```
	"""
end

# ╔═╡ f2233810-4de0-43ae-89de-fe134381be9d
md"""
Los siguientes elementos interactivos te permiten modificar los parámetros poblacionales a tu gusto.
"""

# ╔═╡ 18dff3f3-5be8-4e66-899d-911117050dda
begin
	reset_nb
	Columns(
		md"`n` $(@bind n NumberField(1:1000, default=500))",
		md"μₓ $(@bind μₓ PlutoUI.Slider(0:0.1:20, default=10, show_value=true))",
		md"σₓ $(@bind σₓ PlutoUI.Slider(0:0.1:5, default=2.5, show_value=true))",
		md"σₑ $(@bind σₑ PlutoUI.Slider(0:0.1:3, default=1.5, show_value=true))";
		widths = [0.2, 0.26, 0.26, 0.26]
	)
end

# ╔═╡ 7bec2766-6fd7-47ac-b09d-53a1a0ff5662
md"""
Comenzamos el experimento definiendo una **población** de ``N = `` $n **datos** que sigue un modelo de regresión lineal verdadero, aunque desconocido para el investigador:
```math
Y = \beta_0 + \beta_1 X + \varepsilon
```

* La variable independiente, $X$, sigue una distribución normal con media ``\mu =`` $(μₓ) y desviación estándar ``\sigma =`` $(σₓ).
* La componente de error, ``\varepsilon``, sigue una distribución normal centrada en cero: ``\mathcal{N}(0, ``$(σₑ)``)``.
* La relación verdadera que forzamos es ``Y = 3 + 1 \cdot X + \varepsilon``, es decir, ``\beta_0 = 3`` y ``\beta_1 = 1``.

Debido a la naturaleza estocástica del muestreo, es difícil que los coeficientes estimados (``\hat{\beta}_0, \hat{\beta}_1``) sean exactamente ``3`` y ``1`` en una muestra finita.

Para construir nuestra población utilizaremos la siguiente función:
"""

# ╔═╡ 88da92d3-160a-49db-b602-070548b7c5be
md"""
Esta nube de puntos muestra la **dispersión** de nuestra población generada artificialmente. Esta es la "verdad" subyacente que intentaremos estimar.
"""

# ╔═╡ 11d1fbbd-d4d7-43ee-9724-9e90aa691090
begin
	datos = generar_poblacion(n, μₓ, σₓ, σₑ);

	
	let
		fig = Figure(size = (800, 600))
		ejes = Axis(fig[1,1],
				  title = "Dispersión de la población",
				  xlabel = "Variable independiente (x)",
				  ylabel = "Variable dependiente (y)")
		
		scatter!(ejes, datos.x, datos.y,
			  label = "Datos de la población")
		
		axislegend(ejes, position = :rb)
		
		fig
	end
end

# ╔═╡ 22e7cd31-4af1-45a2-bafb-1e9b5c9bf51c
md"""
Ahora ajustamos MCO a nuestra población completa (``N =`` $n datos). Como ``N`` es grande, esta recta se acerca mucho a los parámetros verdaderos (``\beta_0 = 3``, ``\beta_1 = 1``), y la usaremos como referencia en la simulación.
"""

# ╔═╡ d9dd0211-fb04-40ce-92d5-f383f50093fa
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_modelo Switch(default = mostrar_comentarios))"

# ╔═╡ 1deef8c7-8431-4f8f-8fd5-e5af10472a36
if comentarios_modelo
	md"""
	```julia
	# Generamos la fórmula que va a seguir nuestro modelo. En nuestro caso, 
	# 	como se trata de una regresión lineal simple que no está forzada a pasar
	# 	por el origen nos basta con `y ~ x`. (Para más información sobre la macro
	# 	@formula, puede consultar la documentación de la dependencia StatsModels.jl)
	formula = @formula(y ~ x)

	# Creamos el objeto `modelo` que no es otra cosa que un ajuste, usando como 
	# 	parámetro:
	# 	1. `LinearModel` para indicar que será un ajuste lineal, 
	# 	2. `formula`, para describir el tipo de modelo lineal y
	# 	3. `datos` que es el marco de datos previamente construido.
	modelo = fit(LinearModel, formula, datos) 
	
	# Ahora estraemos del objeto `modelo` solamente los coeficientes que es lo que
	# 	nos interesa.
	betas = coef(modelo)
	```
	"""
else
	md"""
	```julia
	formula = @formula(y ~ x)

	modelo = fit(LinearModel, formula, datos) 
	betas = coef(modelo)
	```
	"""
end

# ╔═╡ 6c30564a-7716-4101-8be3-cb3cf51181a5
begin
	formula = @formula(y ~ x)

	modelo = fit(LinearModel, formula, datos) 
	betas = coef(modelo)
	
	@printf "modelo de regresión poblacional (N = %d):\nIntercepto (β₀): %.4f\nPendiente (β₁): %.4f" n betas[1] betas[2]
end

# ╔═╡ a1a0704b-1163-4c92-b19d-53cbdbec6e68
begin
	fig2 = Figure(size = (800, 600))
	ejes2 = Axis(fig2[1,1],
			  title = "Modelo de regresión",
			  xlabel = "Predictor (x)",
			  ylabel = "Variable dependiente (y)")
	
	scatter!(ejes2, datos.x, datos.y,
		  label = "Datos población")

	ablines!(ejes2, betas[1], betas[2],
		  label = "Verdadera recta de regresión",
		  color = :orange,
		  linewidth = 3,)
	
	axislegend(ejes2, position = :rb)

	fig2
end

# ╔═╡ 7d6dbfab-0ecb-413c-9579-88755e278d4f
begin
	reset_nb
	Columns(
		md"Cantidad de muestras: $(@bind n_repeticion NumberField(1:10, default=3))",
		md"Tamaño de la muestra: $(@bind n_muestra NumberField(1:50, default=25))"
	)
end

# ╔═╡ 8ecc340c-7420-4acd-9d9f-048335c9ac3b
md"""
## El experimento de la insesgadez

Para entender la insesgadez, necesitamos distinguir entre el **estimador** (la fórmula de MCO) y la **estimación** (el resultado de esa fórmula con una muestra concreta).

Tomemos $n_repeticion **muestras** de $(n_muestra) datos cada una. Cada muestra producirá una **recta muestral** (``\hat{\beta}``) distinta de la recta poblacional.

El gráfico a continuación muestra:
* La población en gris claro.
* La recta poblacional (``\beta``) en gris oscuro.
* Los puntos y la recta de regresión ajustada a cada una de las $n_repeticion muestras, en colores distintos.
"""

# ╔═╡ 9576643c-0b2c-4373-bc94-92e611cb3a69
let	
	betas_muestra = Matrix{Float64}(undef, n_repeticion, 2)
	indices_muestra = Matrix{Int64}(undef, n_repeticion, n_muestra)
	
	for i in 1:n_repeticion
		indices_muestra[i, :] = sample(1:n, min(n_muestra, n), replace=false)
		modelo2 = lm(formula, @view datos[indices_muestra[i, :], :])
		betas_muestra[i, :] = coef(modelo2)
	end

	begin
		fig3 = Figure(size = (800, 600))
		ejes3 = Axis(fig3[1,1],
				  title = "Modelo de regresión",
				  xlabel = "Predictor (x)",
				  ylabel = "Variable dependiente (y)")
		
		scatter!(ejes3, datos.x, datos.y,
				color = (:gray, 0.1),
				label = "Datos observados")

		ablines!(ejes3, betas[1], betas[2],
		  label = "Verdadera recta de regresión",
		  color = (:gray, 0.5),
		  linewidth = 3)
		
		for i in 1:n_repeticion
			scatter!(ejes3,
					 datos.x[indices_muestra[i, :]], 
					 datos.y[indices_muestra[i,:]])

			ablines!(ejes3, betas_muestra[i, 1], betas_muestra[i, 2],
			  label = "Recta de regresión para muestra $i",
			  linewidth = 2)
		end
		
		axislegend(ejes3, position = :rb)
		
		fig3
	end
end


# ╔═╡ 2060f164-7a5f-4fae-9e6d-4bd86b872db5
begin
	reset_nb
	Columns(
		md"Cantidad de muestras: $(@bind n_repeticionb NumberField(1:200, default=100))",
		md"Tamaño de la muestra: $(@bind n_muestrab NumberField(1:50, default=25))"
	)
end

# ╔═╡ cf78411c-acb2-4c1e-88ef-71e25846209d
md"""
## Entonces, ¿qué es la "insesgadez de MCO"?

La **insesgadez** es una propiedad teórica del estimador (la fórmula), no de la estimación que obtenemos con una sola muestra. Una sola estimación (``\hat\beta``) no puede ser insesgada, al igual que un solo disparo no puede ser insesgado.

Para verificar la propiedad del estimador MCO, debemos simular el proceso **muchas veces**.

El siguiente gráfico repite el experimento $(n_repeticionb) veces, con muestras de $(n_muestrab) puntos cada una. ¿Qué debería observarse si MCO es insesgado?
"""

# ╔═╡ 58e4a5e8-1be0-4d10-ad94-5690a0b7f6e0
begin
	betas_muestra = Matrix{Float64}(undef, n_repeticionb, 2)
	indices_muestra = Matrix{Int64}(undef, n_repeticionb, n_muestrab)
	
	for i in 1:n_repeticionb
		indices_muestra[i,:] = sample(1:n, min(n_muestrab, n), replace=false)
		modelo2 = lm(formula, @view datos[indices_muestra[i,:], :])
		betas_muestra[i,:] = coef(modelo2)
	end

	
	let
		fig3 = Figure(size = (800, 600))
		ejes3 = Axis(fig3[1,1],
				  title = "Modelo de regresión",
				  xlabel = "Predictor (x)",
				  ylabel = "Variable dependiente (y)")
		
		ablines!(ejes3, betas_muestra[:,1], betas_muestra[:,2],
			  label = "Rectas de regresión muestrales",
			  color = :lightgray,
			  linewidth = 1)
		
		ablines!(ejes3, betas[1], betas[2],
			  label = "Verdadera recta de regresión",
			  color = :orange,
			  linewidth = 3)
		
		scatter!(ejes3, datos.x, datos.y,
			  label = "Datos observados")
		
		axislegend(ejes3, position = :rb)
		
		fig3
	end
end

# ╔═╡ 46f4ccd8-25c6-4ab3-9346-b8267f95f24f
md"""
## El resultado y la conclusión

### Demostración visual
Insesgado significa que, si promediamos todas las **rectas muestrales** (las $n_repeticionb rectas grises), el promedio **acierta** a la **recta poblacional** (la naranja).

### La propiedad del estimador
La insesgadez es una **propiedad de la fórmula de MCO** (el rifle), no de la estimación individual que te toca (el disparo).

* El estimador MCO es **justo**; no favorece sistemáticamente ninguna dirección.
* Ante la incertidumbre de qué muestra te tocará, conviene apostar por la fórmula insesgada.

### Más allá de la insesgadez
Para que la estimación sea **precisa**, no basta con la insesgadez; debemos considerar la **varianza** (qué tan dispersas están las rectas muestrales). Menor varianza implica mayor precisión.

La insesgadez no se puede ver en una sola salida de regresión. La propiedad se estudia analizando la **fórmula** matemática.

> **Nota:** la insesgadez de MCO no es incondicional. Depende de supuestos como la exogeneidad del error (``\mathbb{E}[\varepsilon \mid X] = 0``), la homocedasticidad y la ausencia de multicolinealidad perfecta. Cuando se cumplen, MCO es además el estimador lineal insesgado de mínima varianza (teorema de Gauss-Markov).
"""

# ╔═╡ 2a801149-7196-4db1-b06a-9333d1788b23
begin
	reset_nb
	Columns(
		md"Cantidad de muestras: $(@bind n_repeticionc NumberField(1:5000, default=1000))",
		md"Tamaño de la muestra: $(@bind n_muestrac NumberField(1:50, default=25))"
	)
end

# ╔═╡ f9245aaf-e3d4-4f12-824b-6d08b0017c00
md"""
## La aproximación

El siguiente gráfico muestra la **media progresiva** de las estimaciones: después de cada muestra de $(n_muestrac) puntos, se calcula el promedio acumulado de todos los ``\hat\beta`` obtenidos hasta ese momento. Si MCO es insesgado, esa media debería converger a los parámetros verdaderos ``\beta_0 = 3`` y ``\beta_1 = 1`` a medida que crece el número de repeticiones.
"""

# ╔═╡ 64d046b3-3a93-4bc0-b869-694c7dbbe0ef
let
	betas_muestra = Matrix{Float64}(undef, n_repeticionc, 2) 
	indices_muestra = Matrix{Int64}(undef, n_repeticionc, n_muestrac)
	
	for i in 1:n_repeticionc
		indices_muestra[i,:] = sample(1:n, min(n_muestrac, n), replace=false)
		modelo = lm(formula, @view datos[indices_muestra[i,:], :])
		betas_muestra[i,:] = coef(modelo)
	end
		
	beta_progresivo = cumsum(betas_muestra, dims = 1) ./ (1:n_repeticionc)
	
	fig = Figure(size = (800, 600)) 
	
	eje_beta0 = Axis(fig[1,1],
			  title = "Tendencia de β̂₀",
			  xlabel = "Cantidad de muestras",
			  ylabel = "Media de la estimación")
	eje_beta1 = Axis(fig[2,1],
			  title = "Tendencia de β̂₁",
			  xlabel = "Cantidad de muestras",
			  ylabel = "Media de la estimación")
	
	lines!(eje_beta0, 1:n_repeticionc, beta_progresivo[:,1],
		  label = "Media progresiva de β̂₀",
		  color = :black)
	hlines!(eje_beta0, betas[1],
		   label = "β₀ = $(round(betas[1], digits = 2))",
		   linewidth = 2)
	
	lines!(eje_beta1, 1:n_repeticionc, beta_progresivo[:,2],
		  label="Media progresiva de β̂₁",
		  color = :black)
	hlines!(eje_beta1, betas[2],
		   label = "β₁ = $(round(betas[2], digits = 2))",
		   linewidth = 2)

	axislegend(eje_beta0, position = :rb)
	axislegend(eje_beta1, position = :rb)
	
	fig
end

# ╔═╡ Cell order:
# ╟─0fb9b39c-9fc8-4659-bd31-a53e28ea0035
# ╟─96d9684f-1daa-4309-88a8-d8e54666c82d
# ╟─c73a95bb-7520-4dd2-a756-2ea4e428f88b
# ╟─7a92b92e-25fc-4fcd-8a3a-510cfe419006
# ╟─811a97ae-64d4-4243-afd5-ba322a4472b5
# ╟─34c6f27f-c56e-4409-bdf6-d5f543fdff6f
# ╟─d1cbe04e-c09e-48b2-97ca-7eb0dce7e3f6
# ╟─7bec2766-6fd7-47ac-b09d-53a1a0ff5662
# ╟─0e524340-6ce7-4405-a1ef-247a675cde9f
# ╟─563fed55-8802-407c-ac93-85f56c717ea4
# ╟─f2233810-4de0-43ae-89de-fe134381be9d
# ╟─18dff3f3-5be8-4e66-899d-911117050dda
# ╟─88da92d3-160a-49db-b602-070548b7c5be
# ╟─11d1fbbd-d4d7-43ee-9724-9e90aa691090
# ╟─22e7cd31-4af1-45a2-bafb-1e9b5c9bf51c
# ╟─d9dd0211-fb04-40ce-92d5-f383f50093fa
# ╟─1deef8c7-8431-4f8f-8fd5-e5af10472a36
# ╟─6c30564a-7716-4101-8be3-cb3cf51181a5
# ╟─a1a0704b-1163-4c92-b19d-53cbdbec6e68
# ╟─8ecc340c-7420-4acd-9d9f-048335c9ac3b
# ╟─7d6dbfab-0ecb-413c-9579-88755e278d4f
# ╟─9576643c-0b2c-4373-bc94-92e611cb3a69
# ╟─cf78411c-acb2-4c1e-88ef-71e25846209d
# ╟─2060f164-7a5f-4fae-9e6d-4bd86b872db5
# ╟─58e4a5e8-1be0-4d10-ad94-5690a0b7f6e0
# ╟─46f4ccd8-25c6-4ab3-9346-b8267f95f24f
# ╟─f9245aaf-e3d4-4f12-824b-6d08b0017c00
# ╟─2a801149-7196-4db1-b06a-9333d1788b23
# ╟─64d046b3-3a93-4bc0-b869-694c7dbbe0ef
