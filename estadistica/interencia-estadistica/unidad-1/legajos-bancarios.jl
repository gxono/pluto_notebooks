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

# ╔═╡ 6bd55ed0-3a7b-11f1-8062-63c10cf6b4da
begin
# Recordar hacer un .bat para preinstalar los paquetes antes de la clase.
using Pkg
Pkg.add([
	"Combinatorics", 
	"CairoMakie", 
	"PlutoTeachingTools", 
	"PlutoUI",
	"StatsBase"])

using StatsBase
using Combinatorics
using CairoMakie
using PlutoTeachingTools
using PlutoUI
import PlutoUI: Slider

end

# ╔═╡ 65df9f25-d36c-407f-aa18-f7b807c0061c
md"*Una versión mucho menos detallada (pero sin restricciones para experimentar, ligera y eficiente) es la del fichero* `legajos-bancarios-code.jl`"

# ╔═╡ ed68294f-d48e-4803-9620-8ab0dcff10d6
md"""🔄 *Reiniciar cuaderno* $(@bind reset_nb CounterButton("Reiniciar"))"""

# ╔═╡ 2130a154-f8cd-4330-9dfa-5849c27efd84
begin
	reset_nb
	md"""
	*Por defecto:*
	- *Mostrar los comentarios en todo el código (se puede activar o desactivar individualmente) $(@bind mostrar_comentarios Switch())*
	"""
end

# ╔═╡ 2896d00e-fa9a-4a0d-b7bf-a629a81f49d6
begin
mutable struct Legajo
	tipo::Symbol
end

colores_legajo = (bajo = :green, moderado = :orange, alto = :red)

opciones_poly = (
	strokecolor = :black,
	strokewidth = 4)

opciones_text = (
	align = (:center, :center),
	color = :white,
	font = :bold)

function dibujar_legajos!(ax, legajos; escala = 1, ids = nothing)
    for (i, legajo) in enumerate(legajos)
        poly!(ax, Rect2f(i-1, 0, 1, 1);
			  color = colores_legajo[legajo.tipo],
			  opciones_poly...)
        if ids !== nothing
            text!(ax, i-0.5, 0.5;
				  text = string(ids[legajo]),
				  fontsize = 12 * escala,
				  opciones_text...)
        end
    end
end

#Dibuja una muestra de legajos (contenida en una tupla, ojo!)
# Esto es asi porque decidi que las 2-muestra esten guardadas ahi.
function dibujar_muestra(legajos; escala = 1, ids = nothing, padding = 2)
    n = length(legajos)
    fig = Figure(size = (20n * escala, 20 * escala), figure_padding = padding)
    ax = Axis(fig[1,1], aspect = DataAspect(),
              limits = (0, n, 0, 1), backgroundcolor = :transparent)
    hidedecorations!(ax)
    hidespines!(ax)
    dibujar_legajos!(ax, legajos; escala, ids)
    fig
end

#y un Method para dibujar un solo legajo fuera de un Vector (por pereza)
function dibujar_muestra(legajo::Legajo; escala = 1, ids = nothing, padding = 2)
	dibujar_muestra([legajo]; escala = escala, ids = ids, padding = padding)
end

function es_no_critica(muestra)
	count(l -> l.tipo == :moderado || l.tipo == :alto, muestra) < 2
end

function satisface_xy(muestra, x, y)
	count(l -> l.tipo == :moderado, muestra) == x &&
		count(l -> l.tipo == :alto,  muestra) == y
end

contar_xy(repeticiones, x, y) = count(m -> satisface_xy(m, x, y), repeticiones)

fmt(r, n) = r == 0 ? "0" : "$(r)/$(n)"

PlutoUI.TableOfContents(title = "📚 Contenidos")
end

# ╔═╡ 5571ab4a-9dd7-4964-9d35-d44b33b13385
md"## El problema"

# ╔═╡ 7ebf6710-ed4f-46c6-99f6-0010511aabfc
begin
reset_nb
md"""
Una entidad bancaria está revisando una muestra aleatoria de 2 legajos de préstamos otorgados durante el último mes para una auditoría de calidad. En el lote a auditar hay 12 expedientes con las siguientes calificaciones de riesgo (basadas en la capacidad de pago):

-  $(@bind nriesgo_bajo 	Scrubbable(1:9, default = 5)) de "Riesgo bajo"
-  $(@bind nriesgo_moderado Scrubbable(1:9, default = 4)) de "Riesgo Moderado"
-  $(@bind nriesgo_alto 	Scrubbable(1:9, default = 3)) de "Riesgo Alto"

Si la muestra contiene a lo sumo un expediente de *riesgo moderado* o *alto*, se considera *"no crítica"*.

Determine la probabilidad de que la muestra sea calificada de esa forma.
"""
end

# ╔═╡ 0ee8cd65-a743-440f-80de-c4cc410fcfb2
md"## Los paquetes necesarios"

# ╔═╡ 400fdc8e-3694-4f01-974b-9e0b35b58ca3
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_paquetes Switch(default = mostrar_comentarios))"

# ╔═╡ 1437dae8-cb1c-4a11-b0c9-92bbb0960277
if comentarios_paquetes
	md"""
	```julia
	using StatsBase 	# Habilita el uso de la función `sample`.
	using Combinatorics # Habilita el uso de la función `combinations`.
	```
	"""
else
	md"""
	```julia
	using StatsBase
	using Combinatorics
	```
	"""
end

# ╔═╡ 2953ee77-5d8f-4e4d-b2fa-689ab51dd045
md"## Los legajos"

# ╔═╡ 01b64166-7f66-4c4c-83a9-e9ecfba65166
md"""
Antes de poder empezar a tomar muestras sobre los legajos, será necesario poder construir un objeto `Legajo` de tal forma que pueda diferenciarse, por ejemplo, dos legajos de riesgo bajo distintos.
"""

# ╔═╡ 6af9670e-e666-4f5a-9f6f-4971938cc693
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_structlegajo Switch(default = mostrar_comentarios))"

# ╔═╡ 734a3b9c-00b9-469f-8ddb-c1fd77dcb64a
if comentarios_structlegajo
	md"""
	```julia
	# `mutable struct` permite construir un nuevo tipo de dato en Julia.
	# 	En este caso, es necesario que sea mutable, para que incluso dos
	# 	legajos diferentes con el mismo tipo de riesto sean distinguibles.
	mutable struct Legajo
		# El atributo de tipo de riesto: `bajo`, `moderado`, `alto`
		tipo::Symbol
	end

	# Esto habilita el uso de `Legajo(:bajo)`, `Legajo(:moderado)` o
	# 	`Legajo(:alto)` para definir legajos.
	```
	"""
else
	md"""
	```julia
	mutable struct Legajo
		tipo::Symbol
	end
	```
	"""
end

# ╔═╡ ad8162fc-c0e8-4337-b2e6-60fe5eb994fd
md"""
Ahora construimos la lista de legajos disponibles: 5 de riesgo bajo, 4 de riesgo moderado y 3 de riesgo alto.
"""

# ╔═╡ 9444125e-5491-4ad4-97ef-4ce9841396fb
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_legajos Switch(default = mostrar_comentarios))"

# ╔═╡ 83c3fb59-105e-4ae8-9926-15ee76f78255
begin
riesgos = (bajo = nriesgo_bajo, 
			   moderado = nriesgo_moderado, 
			   alto = nriesgo_alto)

# "un Legajo de cada riesgo, repetido cantidad veces"
legajos = [Legajo(riesgo)
	for (riesgo, cantidad) in pairs(riesgos)
	for _ in 1:cantidad]

legajos_id = Dict(legajos .=> vcat(
	1:nriesgo_bajo, 1:nriesgo_moderado, 1:nriesgo_alto))

md"""
La salida real de Julia para estos doce legajos es la siguiente:
"""
end

# ╔═╡ 8d56661c-3d94-4439-87af-ce42d0410a26
if comentarios_legajos
	Markdown.parse("""
	```julia
	# En este caso, cada componente de la tupla `riesgos` es un par del tipo
	# 	riesgo = cantidad (interpretado por el lenguaje como (riesgo, cantidad)). 
	# 	En este caso, `riesgo` es de tipo `Symbol`, que será lo que nos servirá
	# 	para el constructor Legajo() (según se definió para el tipo del
	# 	`struct` Legajo).
	riesgos = (bajo = $(riesgos.bajo), moderado = $(riesgos.moderado), alto = $(riesgos.alto))
	
	
	# Esto es "un Legajo de cada riesgo, repetido cantidad veces"
	legajos = [Legajo(riesgo) # El constructor de legajos
		for (riesgo, cantidad) in pairs(riesgos) # para cada item de `riesgos`
		for _ in 1:cantidad] # la cantidad de veces que diga el valor.
	```
	""")
else
	Markdown.parse("""
	```julia
	riesgos = (bajo = $(riesgos.bajo), moderado = $(riesgos.moderado), alto = $(riesgos.alto))
	
	legajos = [Legajo(riesgo)
		for (riesgo, cantidad) in pairs(riesgos)
		for _ in 1:cantidad]
	```
	""")
end

# ╔═╡ d2f23ed1-33cf-4b28-bbdf-c9444e367278
@info legajos

# ╔═╡ cfed5f07-699b-4004-82b2-b6056f2237bd
md"""
Para un lector humano, *a priori*, no es posible distinguir entre, por ejemplo, una muestra que contenga los primeros dos legajos, o una que contenga el primer legajo y el tercero, pues ambos aparecerían como `[Legajo(:bajo), Legajo(:bajo)]`. Aun así, para Julia (dado que los objetos `Legajo` son mutables) esto no será un problema.

Motivado por esto, presentamos una forma diferente de ver estas colecciones:
"""

# ╔═╡ a177bdd2-7a84-49de-b299-ee19402f59ee
dibujar_muestra.(legajos; escala = 1.5, ids = legajos_id)

# ╔═╡ f92b7265-bf6d-4974-8a67-eb65dbc2441c
let
dm = dibujar_muestra
escala = 0.6
padding = 1
md"Ahora sí por ejemplo, todos los objetos $(dm(Legajo(:bajo); escala = escala, padding = padding)) son legajos de riesgo bajo, todos los $(dm(Legajo(:moderado); escala = escala, padding = padding)) son legajos de riesgo moderado y por último, los $(dm(Legajo(:alto); escala = escala, padding = padding)) son legajos de riesgo alto. Así también, es posible identificar dos legajos de riesgo bajo por su numeración. Note entonces que, en la salida gráfica de arriba, dos legajos que han sido construidos con el mismo constructor (como por ejemplo dos `Legajo(:bajo)`) son ahora distinguibles."
end

# ╔═╡ 121242fd-d4b5-44c1-a17b-14b15fdc7d29
md"## El espacio muestral"

# ╔═╡ 8f512bbe-c92b-4cba-9e1e-1e2565266eaf
md"""
Para encontrar el espacio muestral (formado por los $(binomial(sum(values(riesgos)), 2)) posibles resultados distintos del experimento) es necesario recurrir a la función `combinations` del paquete `Combinatorics`.
"""

# ╔═╡ 33053b1b-36a9-4a18-beae-0c41e0922bb9
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_combinations Switch(default = mostrar_comentarios))"

# ╔═╡ 55126cb2-a014-4eb0-b364-9e2224d3e17c
begin
if comentarios_combinations
	md"""
	```julia
	# La función `combinations` calcula las combinaciones de todos los pares de
	# 	legajos. La función `collect` toma el resultado (que es un iterador) y
	# 	lo convierte en un vector. Es equivalente a `collect(combinations(...))`
	espacio_muestral = combinations(legajos, 2) |> collect
	```
	"""
else
	md"""
	```julia
	espacio_muestral = combinations(legajos, 2) |> collect
	```
	"""
end

end

# ╔═╡ 6e369ff8-725b-492d-9d93-fbeb1a44fd70
begin
	espacio_muestral = combinations(legajos, 2) |> collect
	@info espacio_muestral
end

# ╔═╡ 55195a47-23bb-4742-a028-1954eddc2b66
md"Es menester recordar aquí que, por mas que algunas observaciones del espacio muestral parezcan repetidas, se corresponden con legajos distintos. Nuevamente, esto queda mas claro si vemos la salida siguiente."

# ╔═╡ 993fc6c4-3c72-46b8-af81-db287e35b4ae
begin
	espacio_muestral_fig_dic = Dict(
		espacio_muestral .=> dibujar_muestra.(
			espacio_muestral; escala = 1.5, ids = legajos_id))
	
	#Esta hecho asi (en lugar de imprimir directamente dibujar_muestra) mas que nada por rendimiento cuando se calculan las repeticiones de las celdas de mas adelante. Si la muestra es de 2000 ya no es necesario calcular 2000 imagenes, sino que se buscan en este diccionario (solo son 64 posibilidades 😉).
	[espacio_muestral_fig_dic[muestra] for muestra in espacio_muestral]
end

# ╔═╡ 1bd1b2ed-a40d-4677-982d-cc11295da856
md"## Frecuencias según el espacio muestral"

# ╔═╡ 1f3a84df-9d72-4e5d-b58b-dad3ad773470
begin
reset_nb
md"Comencemos, ahora sí, por tomar $(@bind repeticion_n_aux NumberField(default=10)) muestras del espacio muestral. Para ello, usaremos la función `sample` de la librería `StatsBase`."
end

# ╔═╡ b74428e8-4747-43c9-b5d8-91745e2b6fb0
repeticion_n = isnan(repeticion_n_aux) ? 1 : Int(repeticion_n_aux);

# ╔═╡ 1753a6e1-dc5e-495f-9946-effc077e48ab
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_sample Switch(default = mostrar_comentarios))"

# ╔═╡ 90c9d797-e650-4133-9860-7812302e9014
if comentarios_sample #celda de metaprogramacion (!!)
	cadena = """
	```julia
	# La función `sample`, por defecto, devuelve una muestra con repetición
	repeticiones = sample(espacio_muestral, $(repeticion_n))
	```
	"""
	eval(Markdown.parse(cadena))
else
	cadena = """
	```julia
	repeticiones = sample(espacio_muestral, $(repeticion_n))
	```
	"""
	eval(Markdown.parse(cadena))
end

# ╔═╡ a55084f2-bc32-4426-8e13-4cc921dbe3a1
begin
#Esta es la muestra
repeticiones = sample(espacio_muestral, repeticion_n)

#La tabla de frecuencias, para ya tenerla. (esta es la de cada obs. del espacio)
repeticiones_freq = let r = countmap(repeticiones)
	[e => get(r, e, 0) for e in espacio_muestral if haskey(r, e)]
end

#La misma tabla, pero agrupando todos los pares con los mismos tipos (sin importar identidad)
repeticiones_freq_combinada = let
	tipo_counts = Dict{Tuple{Symbol,Symbol}, Int}()
	for obs in repeticiones
		key = (obs[1].tipo, obs[2].tipo)
		tipo_counts[key] = get(tipo_counts, key, 0) + 1
	end
	[espacio_muestral[findfirst(m -> (m[1].tipo, m[2].tipo) == k, espacio_muestral)] => v
	 for (k, v) in sort(collect(tipo_counts), by = first)]
end

#La matrix de frecuencias segun X e Y
conteos_xy = [contar_xy(repeticiones, x, y) for x in 0:2, y in 0:2]

# Matriz de frecuencias
frecuencias_xy = Matrix{Rational}(undef, 3, 3)
for x in 0:2
	for y in 0:2
		frecuencias_xy[x+1, y+1] =
			contar_xy(repeticiones, x, y) // length(repeticiones)
	end
end
end

# ╔═╡ 88a393fe-462c-454a-9184-d5646f4aa1d9
@info repeticiones

# ╔═╡ 48f53ade-5cb7-4c26-bd9c-ff1f52deb15d
[espacio_muestral_fig_dic[muestra] for muestra in repeticiones]

# ╔═╡ 91eeadb8-b2e0-43b5-b77d-5eab21300a75
md"""
## Detectar una observación

Lo siguiente que necesitaremos es una forma de poder contar las frecuencias de las observaciones deseadas para un valor de ``X`` y de ``Y`` adecuado teniendo en cuenta que 
- ``X`` es la cantidad de expedientes de "Riesgo Moderado" seleccionados en la muestra, e
- ``Y`` es la cantidad de expedientes de "Riesgo Alto" seleccionados en la muestra.

Ahora bien, antes de poder contarlos, es necesario poder identificar cuando una muestra de dos expedientes pertenece a un cierto grupo, es decir, si un espediente satisface ``X = x`` e ``Y = y`` para un ``x`` e ``y`` dados. Es por esto, por lo que definiremos la siguiente función:
"""

# ╔═╡ bb2b7c3e-2616-4dd8-ba8c-6785f29a7c98
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_es_xy Switch(default = mostrar_comentarios))"

# ╔═╡ 12a33835-d6b3-4a35-ab93-8414069aeeb1
if comentarios_es_xy
	md"""
	```julia
	# `satisface_xy` recibe una observacion (es decir, una muestra de dos legajos)
	# 	y devuelve `true` si coincide la cantidad de legajos con riesgo medio y
	# 	riesgo alto. En caso contrario, devuelve `false`.
	
	function satisface_xy(observacion, x, y)
		# Cuenta y verifica que la cantidad de legajos de riesgo medio coincida
		# 	con el pasado como argumento (`x`)
		count(l -> l.tipo == :moderado, observacion) == x && # `Y`
		# Cuenta y verifica que la cantidad de legajos de riesgo alto coincida
		# 	con el pasado como argumento (`y`)
		count(l -> l.tipo == :alto,  observacion) == y
	end
	```
	"""
else
	md"""
	```julia
	function satisface_xy(observacion, x, y)
		count(l -> l.tipo == :moderado, observacion) == x &&
		count(l -> l.tipo == :alto,  observacion) == y
	end
	```
	"""
end
	

# ╔═╡ ddd4b15c-6a84-4aea-9c30-ab3d08774947
md"""
Así, pues, si queremos saber si, por ejemplo, el séptimo elemento del vector `repeticiones` (`repeticiones[7]`) tiene un legajo de riesto moderado (``x=1``) y otro de riesgo alto (``y=1``), ejecutamos
```julia
satisface_xy(repeticiones[7], 1, 1)
```
y si queremos saber si no tiene legajo de riesgo moderado (``x=0``), pero tiene uno de riesgo alto (``y=1``), ejecutamos
```julia
satisface_xy(repeticiones[7], 0, 1)
```
"""

# ╔═╡ 0084ebba-63cd-4c50-854b-c77d3dcf4b8b
md"""
```julia
# Otros ejemplos de uso
satisface_xy([Legajo(:bajo),     Legajo(:bajo)],     0, 0)	#🟩🟩 -> true
satisface_xy([Legajo(:bajo), 	 Legajo(:alto)],     1, 0) 	#🟩🟥 -> false
satisface_xy([Legajo(:moderado), Legajo(:moderado)], 2, 0) 	#🟨🟨 -> true
satisface_xy([Legajo(:moderado), Legajo(:alto)],     1, 1)	#🟨🟥 -> true
```
"""

# ╔═╡ bd269e43-69fb-43e3-8ab1-d31cba2f8173
md"""
## Contar las observaciones

Ahora bien, si queremos conocer de **todas las repeticiones**, por ejemplo, cuantas muestras tienen un legajo de riesgo moderado (``x=1``) y ninguno de riesgo alto (``y=0``), entonces podemos ejecutar
"""

# ╔═╡ 90e9f97b-9e5c-42a0-89f5-be404d153098
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_contar_ejemplo Switch(default = mostrar_comentarios))"

# ╔═╡ 6c2331df-162e-4c80-b956-59b3d8d4c8f8
if comentarios_contar_ejemplo
	md"""
	```julia
	# En este caso, cada muestra contenida en el vector `repeticiones` es asignada
	# 	a la variable temporal `m`, y esta a su vez, pasada como argumento en la
	# 	función `satisface_xy(m, 1, 0)`.
	
	# Esto hace que se cree un vector de `true` y `false` según corresponda. Luego,
	# 	la función `count` cuenta las apariciones de `true` en este nuevo vector, 
	# 	deviendo así la cantidad de elementos que satisfacen las restricciones
	# 	`x` e `y`.
	
	count(m -> satisface_xy(m, 1, 0), repeticiones)
	```
	"""
else
	md"""
	```julia
	count(m -> satisface_xy(m, 1, 0), repeticiones)
	```
	"""
end

# ╔═╡ dac9ee4a-bc63-475e-95ff-52e9a3c3730b
md"""
Para no tener que lidiar recurrentemente con esa expresión, podemos construir una función `contar_xy`.
"""

# ╔═╡ 8c1645b6-82cc-484c-a944-677035cc2dd8
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_contar_xy Switch(default = mostrar_comentarios))"

# ╔═╡ e3438183-da6f-4c55-b540-864028417bef
if comentarios_contar_xy
	md"""
	```julia
	# `contar_xy` cuenta cuántas observaciones del vector `repeticiones`
	# 	satisfacen `X = x` e `Y = y`.
	function contar_xy(repeticiones, x, y)
		return count(m -> satisface_xy(m, x, y), repeticiones)
	end
	```
	"""
else
	md"""
	```julia
	function contar_xy(repeticiones, x, y)
		return count(m -> satisface_xy(m, x, y), repeticiones)
	end
	```
	"""
end

# ╔═╡ 45fa6cf1-f661-4f6e-b27c-03973d7155ce
Markdown.parse("""
```julia
# Ejemplo: Cantidad de muestras de dos legajos con un legajo de riesgo moderado y
# 	ningún legajo de riesgo alto.
contar_xy(repeticiones, 1, 0) #🟨🟩 || 🟩🟨 -> $(contar_xy(repeticiones, 1, 0))

# --- Otros ejemplos
contar_xy(repeticiones, 0, 0) #🟩🟩 -> $(contar_xy(repeticiones, 0, 0))
contar_xy(repeticiones, 0, 2) #🟥🟥 -> $(contar_xy(repeticiones, 0, 2))
```
""")

# ╔═╡ 44422f97-2921-44f0-b314-fd7851d5e800
md"""
## Algunas tablas de frecuencias
"""

# ╔═╡ 9c95884c-9af5-47f6-a63e-803543cd95d5
md"""
La siguiente tabla gráfica muestra la frecuencia de cada muestra de dos legajos, discriminando por el tipo de riesgo y su identificador único (es decir, cuántas veces se repite cada elemento particular del espacio muestral).
"""

# ╔═╡ 172348ff-d7ff-47e1-a459-71069f5d6252
begin
reset_nb
md"👀 *Mostrar tabla gráfica de frecuencias del vector `repeticiones`* $(@bind mostrar_tablafrecuencias_em Switch())"
end

# ╔═╡ 9692cc0a-a5c8-4aab-9981-bdd158bf259c
if mostrar_tablafrecuencias_em
	md"Moderados: $(@bind filtro_moderado Select([\"Cualq.\", \"0\", \"1\", \"2\"])) Altos: $(@bind filtro_alto Select([\"Cualq.\", \"0\", \"1\", \"2\"]))"
end

# ╔═╡ 0be96aa0-61ff-4d9a-861a-b9be4a5a1bd9
if mostrar_tablafrecuencias_em
let
    x = let f = coalesce(filtro_moderado, "Cualq."); 
	f == "Cualq." ? nothing : parse(Int, f) end
    
	y = let f = coalesce(filtro_alto, "Cualq."); 
	f == "Cualq." ? nothing : parse(Int, f) end

    indices_filtrados = findall(repeticiones_freq) do par
        (isnothing(x) || count(l -> l.tipo == :moderado, par.first) == x) &&
        (isnothing(y) || count(l -> l.tipo == :alto,  par.first) == y)
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
                celdas = ["\$(dibujar_muestra(repeticiones_freq[$(indices_filtrados[i])].first; ids=legajos_id)) | \$(repeticiones_freq[$(indices_filtrados[i])].second)"
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


# ╔═╡ 17571ebe-0b53-413b-810b-3085217a6cc4
md"Mientras que la siguiente tabla muestra las frecuencias según el tipo de riesgo."

# ╔═╡ 5cf18074-86c9-4510-89a5-28fd1480e27c
let
    if isempty(repeticiones_freq_combinada)
        md"*No hay muestras con esos valores.*"
    else
        n_cols = 1
        n = length(repeticiones_freq_combinada)
        n_filas = ceil(Int, n / n_cols)

        header    = "| " * join(repeat(["Muestra | Frecuencia"], n_cols), " | ") * " |"
        separator = "|" * repeat(":---:|:---:|", n_cols)

        filas = join([
            let indices = [r + c*n_filas for c in 0:n_cols-1 if r + c*n_filas <= n]
                celdas = ["\$(dibujar_muestra(repeticiones_freq_combinada[$(i)].first)) | \$(repeticiones_freq_combinada[$(i)].second)"
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

# ╔═╡ dd986e23-b8e7-46f6-8788-32403541ce34
md"""
## Tabla de frecuencias relativas conjuntas
"""

# ╔═╡ 4676e7f4-2d8b-4ea3-923f-be41ddc65f08
md"*@jona: esta parte no la retoqué aun. puede que esté mezclando mucha notacion*"

# ╔═╡ 03ca0f9d-696f-4a42-bc70-992a1cc3f2ce
md"""
Las tablas de frecuencias anteriores muestran con qué frecuencia aparece cada muestra, pero no nos dicen directamente cuál es la probabilidad de que una muestra tenga exactamente ``x`` legajos de riesgo moderado e ``y`` de riesgo alto. Para estimarla, podemos usar la **frecuencia relativa conjunta**: la proporción de veces que ocurrió cada par ``(x, y)`` en las ``n`` repeticiones. Así, si el experimento se repitiera muchas veces, estas frecuencias relativas se aproximarían a las probabilidades teóricas ``P(X = x, Y = y)``.

Para construir la tabla de frecuencias relativas conjuntas ``f(x, y)``,
"""

# ╔═╡ e613aacf-12be-478d-b5e6-738d1ae571e6
let
	header = "| ``f(x,y)`` | **Y = 0** | **Y = 1** | **Y = 2** | **``f_X(x)``** |"
	sep    = "|:---:|:---:|:---:|:---:|:---:|"
	filas  = ["| **X = $(x-1)** | 🤔 | 🤔 | 🤔 | - |"
	          for x in 1:3]
	pie    = "| **``f_Y(y)``** | - | - | - | **1** |"

	Markdown.parse("""
	$(join([header, sep, filas..., pie], "\n"))
	""")
end

# ╔═╡ 84908ed1-ebe6-40a1-a500-93ad9c8a390d
md"""
necesitaremos primero determinar las frecuencias relativas conjuntas (🤔). Determinemoslas y alojemoslas en una matriz.
"""

# ╔═╡ b04e121d-c510-4ee5-a36e-96e7fd36e50e
md"""
## Matriz de frecuencias

La ventaja de utilizar una matriz es que las frecuencias relativas marginales serán mucho más fáciles de calcular. Llamemos a esta matriz `frecuencias_xy`
"""

# ╔═╡ 2920228e-dce4-4a71-ac79-207aca68288a
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_matriz Switch(default = mostrar_comentarios))"

# ╔═╡ 8c1fff38-1f58-41ec-8cfa-f342d9aeb83d
if comentarios_matriz
	md"""
	```julia
	# Prealojamos la matriz de frecuencias conjuntas f(x, y).
	# Será una matriz de `3 × 3` de racionales (x, y ∈ {0, 1, 2}),
	# 	con valores sin definir por ahora.
	frecuencias_xy = Matrix{Rational}(undef, 3, 3)
	
	# Cargamos cada componente con la frecuencia relativa conjunta.
	# `x` es la cantidad de legajos de riesgo **moderado** y
	# `y` la de riesgo **alto** en la observación.
	for x in 0:2   # filas: cantidad de legajos moderados
		for y in 0:2   # columnas: cantidad de legajos altos
			# Índices desplazados en 1 porque Julia indexa desde 1.
			frecuencias_xy[x+1, y+1] =
				contar_xy(repeticiones, x, y) // length(repeticiones)
				# El operador `//` es diferente a `/`, pues trata a los valores como
				# 	fracciones y no intentará redondear las expresiones.
		end
	end
	```
	"""
else
	md"""
	```julia
	frecuencias_xy = Matrix{Rational}(undef, 3, 3)
	
	for x in 0:2
		for y in 0:2
			frecuencias_xy[x+1, y+1] =
				contar_xy(repeticiones, x, y) // length(repeticiones)
		end
	end
	```
	"""
end

# ╔═╡ 9077e4bd-5734-4ecd-a005-710c7c0dfb5c
md"Así, el contenido de `frecuencias_xy` es"

# ╔═╡ 25d67175-5de2-4287-927e-8064c2c5bd89
@info frecuencias_xy

# ╔═╡ 23a00262-ec62-4164-8bb4-32c823cdf5fe
md"Note que, si fuera posible, las expresiones fraccionarias serán simplificadas. Para poder ver las expresiones decimales, podemos usar el constructor `Float64()` y aplicárselo a cada elemento."

# ╔═╡ 765a8db2-3e20-42f2-927d-828833b01525
md"""
```julia
Float64.(frecuencias_xy)
```
"""

# ╔═╡ f845a8e4-022b-48e5-a059-98a7b3c456c7
@info Float64.(frecuencias_xy)

# ╔═╡ 6cb8613e-ec9a-4e81-8722-ce692ae297f8
md"""
Para acceder a una fila o columna entera de la matriz utilizamos `":"` como componente indefinida. Es decir, para acceder a la primera fila usamos
```julia
frecuencias_xy[1, :]
```
mientras que para acceder a la segunda columna usamos 
```julia
frecuencias_xy[:, 2]
```
"""

# ╔═╡ e1f6c304-22a9-41bd-9f5b-d8652d18b2b9
md"""
## Frecuencias marginales

Con esto en mente, si estamos interesados en, por ejemplo, calcular la frecuencia relativa marginal ``f_X(1)``, bastará con sumar todos los elementos de la fila 2, es decir
```julia
sum(frecuencias_xy[2, :])
```
"""

# ╔═╡ 694c5dda-5b1a-400b-b95f-049ea25f1301
@info sum(frecuencias_xy[2, :])

# ╔═╡ cdec28e0-9244-4dea-b6db-f841632442f8
md"""mientras que, para hallar ``f_Y(0)`` usamos
```julia
sum(frecuencias_xy[:, 1])
```
"""

# ╔═╡ 0c11ad7f-6c57-4f62-8f4a-2b39a91e950a
@info sum(frecuencias_xy[:, 1])

# ╔═╡ 40ba7cf1-a283-493e-a673-18d94d438e95
md"Ahora sí, la siguiente es la tabla de frecuencias relativas conjuntas ``f(x, y)``, en donde cada celda se calcula como `contar_xy` dividido la cantidad de repeticiones. Las últimas fila y columna muestran las frecuencias relativas marginales ``f_X(x)`` y ``f_Y(y)``."

# ╔═╡ ce5ff54c-44d3-406f-b5fc-269742ced313
begin
	reset_nb
	md"""Formato: $(@bind formato_tabla Select(["fraccion" => "común denominador", "simplificada" => "expresión simplificada", "decimal" => "expresión decimal"]))"""
end

# ╔═╡ 21cedb47-c1e5-41c2-9729-587a55a98c0e
let
	f = if formato_tabla == "fraccion"
		r -> fmt(r, repeticion_n)
	elseif formato_tabla == "simplificada"
		r -> r == 0 ? "0" : let frac = r // repeticion_n;
			string(numerator(frac)) * "/" * string(denominator(frac))
		end
	else
		r -> r == 0 ? "0.0" : string(round(r / repeticion_n, digits = 4))
	end

	header = "| ``f(x,y)`` | **Y = 0** | **Y = 1** | **Y = 2** | **``f_X(x)``** |"
	sep    = "|:---:|:---:|:---:|:---:|:---:|"
	filas  = ["| **X = $(x-1)** | $(f(conteos_xy[x,1])) | $(f(conteos_xy[x,2])) | $(f(conteos_xy[x,3])) | $(f(sum(conteos_xy[x,:]))) |"
	          for x in 1:3]
	pie    = "| **``f_Y(y)``** | $(f(sum(conteos_xy[:,1]))) | $(f(sum(conteos_xy[:,2]))) | $(f(sum(conteos_xy[:,3]))) | **1** |"

	Markdown.parse("""
	$(join([header, sep, filas..., pie], "\n"))
	""")
end

# ╔═╡ 1d5f3978-31f6-4e4a-885d-a0684684cfe5
let
    fig = Figure(size = (520, 420))
    ax = Axis(fig[1, 1],
        title = "Distribución de frecuencias relativas conjuntas\nen $(repeticion_n) repeticiones",
        xlabel = "Y — cantidad de legajos de riesgo alto",
        ylabel = "X — cantidad de legajos de riesgo moderado",
        xticks = (0:2, ["Y = 0", "Y = 1", "Y = 2"]),
        yticks = (0:2, ["X = 0", "X = 1", "X = 2"]))

    data = Float64.(frecuencias_xy)
    hm = heatmap!(ax, 0:2, 0:2, data; colormap = :Blues)
    Colorbar(fig[1, 2], hm; label = "f(x, y)")

    for x in 0:2, y in 0:2
        val = data[y+1, x+1]
		label = x + y <= 1 ? "★ $(round(val, digits=4))" : "$(round(val, digits=4))"
        text!(ax, y, x;
			text = label,
            align = (:center, :center),
            fontsize = 12,
		  	font = :bold,
            color = val > 0.25 ? :white : :black)
    end

    html_fig = repr(MIME"text/html"(), fig)
    HTML("<div style='display:flex; justify-content:center'>$(html_fig)</div>")
end


# ╔═╡ 44cf7a80-06c9-40aa-9a7c-a8331a74cf0e
md"""
Las celdas marcadas con ★ corresponden a los eventos del conjunto ``\{X + Y \leq 1\}`` (muestra "no crítica").
"""

# ╔═╡ 9110e321-7e78-4e7d-9c2c-22cd1efc3eae
md"## Volviendo a la pregunta inicial"

# ╔═╡ c5c1d0c3-5611-4543-9038-cb588cdbf0fe
md"De la muestra de $repeticion_n de elementos, veamos cuantos corresponden a una muestra no crítica. Para ello, definamos una función que reciba una muestra de dos legajos y determine si es \"no crítica\"."

# ╔═╡ e80ad0f3-b034-4df5-9f26-52a9ae09d8e8
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_es_no_critica Switch(default = mostrar_comentarios))"

# ╔═╡ 1b5bd2e8-ff5c-44c2-8591-d9c9d718a11e
if comentarios_es_no_critica
	md"""
	```julia
	# Toma una `muestra` de dos legajos y cataloga como "critica" (`false`) o 
	# 	"no critica" `true` segun corresponda.
	function es_no_critica(muestra)
		# Cuenta la cantidad de legajos de riesgo moderado o (`||`) alto. Si la
		# 	cantidad es menor que 2 entonces es catalogada como "no critica" (`true`).
		return count(l -> l.tipo == :moderado || l.tipo == :alto, muestra) < 2
	end
	```
	"""
else
	md"""
	```julia
	function es_no_critica(muestra)
		return count(l -> l.tipo == :moderado || l.tipo == :alto, muestra) < 2
	end
	```
	"""
end

# ╔═╡ 34c20ae9-487d-454d-b27e-5fdf6f15e998
md"""
```julia
# Algunos ejemplos de uso
es_no_critica([Legajo(:bajo),     Legajo(:bajo)])		#🟩🟩 -> true
es_no_critica([Legajo(:bajo), 	  Legajo(:alto)]) 	  	#🟩🟥 -> true
es_no_critica([Legajo(:moderado), Legajo(:moderado)]) 	#🟨🟨 -> false
es_no_critica([Legajo(:moderado), Legajo(:alto)])		#🟨🟥 -> false
```
"""

# ╔═╡ 618cd78a-0573-46c3-a83d-ea5b9f901dc5
md"""
Ahora si, para contar la cantidad de muestras no críticas, volvemos a utilizar la función `count` pero esta vez pasando la función `es_no_critica` como primer argumento
"""

# ╔═╡ 2ac27cb5-4de7-49d2-9c8f-ccea4ccdf9c2
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_count_es_no_critica Switch(default = mostrar_comentarios))"

# ╔═╡ 93a9032d-4e51-4c07-ab15-533d992628d6
if comentarios_count_es_no_critica
	md"""
	```julia
	count(es_no_critica, repeticiones)
	
	# Es equivalente a
	count(m -> es_no_critica(m), repeticiones)
	# pero con un solo parámetro no es necesario pasar una función anónima.
	```
	"""
else
	md"""
	```julia
	count(es_no_critica, repeticiones)
	```
	"""
end

# ╔═╡ d8d43619-4f72-466b-90a9-b23e0dc6a289
@info count(es_no_critica, repeticiones)

# ╔═╡ 7f2530aa-a509-439e-97ad-ce6ccbed3f61
let
num = count(es_no_critica, repeticiones)
den = repeticion_n
fraccion = num // den
snum = numerator(fraccion)
sden = denominator(fraccion)
	
texto = """
Entonces, la frecuencia experimental viene dada por
```math
	\\frac{\\#\\text{es\\_no\\_critica}}{\\#\\text{repeticiones}}=\\frac{$num}{$den} = \\frac{$snum}{$sden} = $(Float64(fraccion)).
```
"""

eval(Markdown.parse(texto))
end

# ╔═╡ d1626323-eee4-4122-9946-2d142e719e6b
let
	cum_freq = Vector{Float64}(undef, repeticion_n)
	cum_freq[1] = es_no_critica(repeticiones[1])

	function hipergeometrica(riesgos, x, y)
		return binomial(riesgos.bajo, 2 - x - y) *
			   binomial(riesgos.moderado, x) *
			   binomial(riesgos.alto, y) // 
			   binomial(sum(values(riesgos)), 2)
	end

	frecuencia_verdadera = hipergeometrica(riesgos, 0, 0) + 
						   hipergeometrica(riesgos, 0, 1) + 
						   hipergeometrica(riesgos, 1, 0)

	num::Int64    = numerator(frecuencia_verdadera)
	den::Int64    = denominator(frecuencia_verdadera)
	factor::Int64 = binomial(sum(values(riesgos)), 2) / den
	num *= factor; den *= factor
	label = string(num) * "/" * string(den)
	
	curr_qty::Float64 = cum_freq[1]
	for i in 2:length(repeticiones) #mas eficiente que calcular para cada muestra
		curr_qty = curr_qty + es_no_critica(repeticiones[i])
		cum_freq[i] = curr_qty / i
	end

	fig = Figure(size = (700, 400))
	ax = Axis(fig[1,1],
			xlabel = "Número de muestra tomada",
			ylabel = "Frecuencia relativa",
			title = "Frecuencia relativa de legajos \"no críticos\" por número de muestra")
	
	ylims!(ax, -0.025, 1.025)

	hlines!(ax, frecuencia_verdadera, color = :red, label = "Frecuencia verdadera ($label ≈ $(round(Float64(frecuencia_verdadera), digits = 4)))")
	lines!(ax, eachindex(repeticiones), cum_freq, label = "Frecuencia experimental")

	axislegend(ax, position=:rb)
	
	fig
end

# ╔═╡ ff2c4c85-0271-4a19-a788-da244841cade
md"""
## Código completo
"""

# ╔═╡ c6073ef1-fc7e-49f1-87dd-13df6b1eeeff
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_codigocompleto Switch(default = mostrar_comentarios))"

# ╔═╡ ee380491-4d96-4dd6-8465-8d901730bc5c
if comentarios_codigocompleto
	md"""
	```julia
	using StatsBase 	# Habilita el uso de la función `sample`.
	using Combinatorics # Habilita el uso de la función `combinations`.


	# `mutable struct` permite construir un nuevo tipo de dato en Julia.
	# 	En este caso, es necesario que sea mutable, para que incluso dos
	# 	legajos diferentes con el mismo tipo de riesgo sean distinguibles.
	mutable struct Legajo
		# El atributo de tipo de riesgo: `bajo`, `moderado`, `alto`
		tipo::Symbol
	end

	# Esto habilita el uso de `Legajo(:bajo)`, `Legajo(:moderado)` o
	# 	`Legajo(:alto)` para definir legajos.


	# En este caso, cada componente de la tupla `riesgos` es un par del tipo
	# 	riesgo = cantidad (interpretado por el lenguaje como (riesgo, cantidad)).
	# 	En este caso, `riesgo` es de tipo `Symbol`, que será lo que nos servirá
	# 	para el constructor Legajo() (según se definió para el tipo del
	# 	`struct` Legajo).
	riesgos = (bajo = 5, moderado = 4, alto = 3)

	# Esto es "un Legajo de cada riesgo, repetido cantidad veces"
	legajos = [Legajo(riesgo) # El constructor de legajos
		for (riesgo, cantidad) in pairs(riesgos) # para cada item de `riesgos`
		for _ in 1:cantidad] # la cantidad de veces que diga el valor.


	# La función `combinations` calcula las combinaciones de todos los pares de
	# 	legajos. La función `collect` toma el resultado (que es un iterador) y
	# 	lo convierte en un vector. Es equivalente a `collect(combinations(...))`
	espacio_muestral = combinations(legajos, 2) |> collect


	# La función `sample`, por defecto, devuelve una muestra con repetición.
	repeticiones = sample(espacio_muestral, 10)

	# `satisface_xy` recibe una observacion (es decir, una muestra de dos legajos)
	# 	y devuelve `true` si coincide la cantidad de legajos con riesgo moderado y
	# 	riesgo alto. En caso contrario, devuelve `false`.
	function satisface_xy(observacion, x, y)
		# Cuenta y verifica que la cantidad de legajos de riesgo moderado coincida
		# 	con el pasado como argumento (`x`)
		count(l -> l.tipo == :moderado, observacion) == x &&
		# Cuenta y verifica que la cantidad de legajos de riesgo alto coincida
		# 	con el pasado como argumento (`y`)
		count(l -> l.tipo == :alto,  observacion) == y
	end


	# `contar_xy` cuenta cuántas observaciones del vector `repeticiones`
	# 	satisfacen `X = x` e `Y = y`.
	function contar_xy(repeticiones, x, y)
		return count(m -> satisface_xy(m, x, y), repeticiones)
	end


	# Prealojamos la matriz de frecuencias conjuntas f(x, y).
	# Será una matriz de `3 × 3` de racionales (x, y ∈ {0, 1, 2}),
	# 	con valores sin definir por ahora.
	fxy = Matrix{Rational}(undef, 3, 3)

	# Cargamos cada componente con la frecuencia relativa conjunta.
	# `x` es la cantidad de legajos de riesgo moderado y
	# `y` la de riesgo alto en la observación.
	for x in 0:2   # filas: cantidad de legajos moderados
		for y in 0:2   # columnas: cantidad de legajos altos
			# Índices desplazados en 1 porque Julia indexa desde 1.
			fxy[x+1, y+1] =
				contar_xy(repeticiones, x, y) // length(repeticiones)
				# El operador `//` es diferente a `/`, pues trata a los valores como
				# 	fracciones y no intentará redondear las expresiones.
		end
	end

	
	# Toma una `muestra` de dos legajos y cataloga como "critica" (`false`) o 
	# 	"no critica" `true` segun corresponda.
	function es_no_critica(muestra)
		# Cuenta la cantidad de legajos de riesgo moderado o (`||`) alto. Si la
		# 	cantidad es menor que 2 entonces es catalogada como "no critica" (`true`).
		return count(l -> l.tipo == :moderado || l.tipo == :alto, muestra) < 2
	end

	# Yapa 😉
	fmx = [sum(fxy[x, :]) for x in 1:3] # `fmx[2]` devuelve fₓ(1).
	fmy = [sum(fxy[:, y]) for y in 1:3]
	```
	"""
else
	md"""
	```julia
	using StatsBase, Combinatorics
	
	
	mutable struct Legajo
		tipo::Symbol
	end
	
	
	riesgos = (bajo = 5, moderado = 4, alto = 3)
	
	legajos = [Legajo(riesgo)
		for (riesgo, cantidad) in pairs(riesgos)
		for _ in 1:cantidad]
	
	
	espacio_muestral = combinations(legajos, 2) |> collect
	
	
	repeticiones = sample(espacio_muestral, 10)
	
	function satisface_xy(observacion, x, y)
		count(l -> l.tipo == :moderado, observacion) == x &&
		count(l -> l.tipo == :alto,  observacion) == y
	end
	
	
	function contar_xy(repeticiones, x, y)
		return count(m -> satisface_xy(m, x, y), repeticiones)
	end
	
	
	fxy = Matrix{Rational}(undef, 3, 3)
	
	for x in 0:2, y in 0:2
		fxy[x+1, y+1] = contar_xy(repeticiones, x, y) // length(repeticiones)
	end

	
	function es_no_critica(muestra)
		return count(l -> l.tipo == :moderado || l.tipo == :alto, muestra) < 2
	end
	
	# Yapa 😉
	fmx = [sum(fxy[x, :]) for x in 1:3] # `fmx[2]` devuelve fₓ(1).
	fmy = [sum(fxy[:, y]) for y in 1:3]
	```
	"""
end

# ╔═╡ Cell order:
# ╟─6bd55ed0-3a7b-11f1-8062-63c10cf6b4da
# ╟─65df9f25-d36c-407f-aa18-f7b807c0061c
# ╟─ed68294f-d48e-4803-9620-8ab0dcff10d6
# ╟─2130a154-f8cd-4330-9dfa-5849c27efd84
# ╟─2896d00e-fa9a-4a0d-b7bf-a629a81f49d6
# ╟─5571ab4a-9dd7-4964-9d35-d44b33b13385
# ╟─7ebf6710-ed4f-46c6-99f6-0010511aabfc
# ╟─0ee8cd65-a743-440f-80de-c4cc410fcfb2
# ╟─400fdc8e-3694-4f01-974b-9e0b35b58ca3
# ╟─1437dae8-cb1c-4a11-b0c9-92bbb0960277
# ╟─2953ee77-5d8f-4e4d-b2fa-689ab51dd045
# ╟─01b64166-7f66-4c4c-83a9-e9ecfba65166
# ╟─6af9670e-e666-4f5a-9f6f-4971938cc693
# ╟─734a3b9c-00b9-469f-8ddb-c1fd77dcb64a
# ╟─ad8162fc-c0e8-4337-b2e6-60fe5eb994fd
# ╟─9444125e-5491-4ad4-97ef-4ce9841396fb
# ╟─8d56661c-3d94-4439-87af-ce42d0410a26
# ╟─83c3fb59-105e-4ae8-9926-15ee76f78255
# ╟─d2f23ed1-33cf-4b28-bbdf-c9444e367278
# ╟─cfed5f07-699b-4004-82b2-b6056f2237bd
# ╟─a177bdd2-7a84-49de-b299-ee19402f59ee
# ╟─f92b7265-bf6d-4974-8a67-eb65dbc2441c
# ╟─121242fd-d4b5-44c1-a17b-14b15fdc7d29
# ╟─8f512bbe-c92b-4cba-9e1e-1e2565266eaf
# ╟─33053b1b-36a9-4a18-beae-0c41e0922bb9
# ╟─55126cb2-a014-4eb0-b364-9e2224d3e17c
# ╟─6e369ff8-725b-492d-9d93-fbeb1a44fd70
# ╟─55195a47-23bb-4742-a028-1954eddc2b66
# ╟─993fc6c4-3c72-46b8-af81-db287e35b4ae
# ╟─1bd1b2ed-a40d-4677-982d-cc11295da856
# ╟─1f3a84df-9d72-4e5d-b58b-dad3ad773470
# ╟─b74428e8-4747-43c9-b5d8-91745e2b6fb0
# ╟─1753a6e1-dc5e-495f-9946-effc077e48ab
# ╟─90c9d797-e650-4133-9860-7812302e9014
# ╟─88a393fe-462c-454a-9184-d5646f4aa1d9
# ╟─a55084f2-bc32-4426-8e13-4cc921dbe3a1
# ╟─48f53ade-5cb7-4c26-bd9c-ff1f52deb15d
# ╟─91eeadb8-b2e0-43b5-b77d-5eab21300a75
# ╟─bb2b7c3e-2616-4dd8-ba8c-6785f29a7c98
# ╟─12a33835-d6b3-4a35-ab93-8414069aeeb1
# ╟─ddd4b15c-6a84-4aea-9c30-ab3d08774947
# ╟─0084ebba-63cd-4c50-854b-c77d3dcf4b8b
# ╟─bd269e43-69fb-43e3-8ab1-d31cba2f8173
# ╟─90e9f97b-9e5c-42a0-89f5-be404d153098
# ╟─6c2331df-162e-4c80-b956-59b3d8d4c8f8
# ╟─dac9ee4a-bc63-475e-95ff-52e9a3c3730b
# ╟─8c1645b6-82cc-484c-a944-677035cc2dd8
# ╟─e3438183-da6f-4c55-b540-864028417bef
# ╟─45fa6cf1-f661-4f6e-b27c-03973d7155ce
# ╟─44422f97-2921-44f0-b314-fd7851d5e800
# ╟─9c95884c-9af5-47f6-a63e-803543cd95d5
# ╟─172348ff-d7ff-47e1-a459-71069f5d6252
# ╟─9692cc0a-a5c8-4aab-9981-bdd158bf259c
# ╟─0be96aa0-61ff-4d9a-861a-b9be4a5a1bd9
# ╟─17571ebe-0b53-413b-810b-3085217a6cc4
# ╟─5cf18074-86c9-4510-89a5-28fd1480e27c
# ╟─dd986e23-b8e7-46f6-8788-32403541ce34
# ╟─4676e7f4-2d8b-4ea3-923f-be41ddc65f08
# ╟─03ca0f9d-696f-4a42-bc70-992a1cc3f2ce
# ╟─e613aacf-12be-478d-b5e6-738d1ae571e6
# ╟─84908ed1-ebe6-40a1-a500-93ad9c8a390d
# ╟─b04e121d-c510-4ee5-a36e-96e7fd36e50e
# ╟─2920228e-dce4-4a71-ac79-207aca68288a
# ╟─8c1fff38-1f58-41ec-8cfa-f342d9aeb83d
# ╟─9077e4bd-5734-4ecd-a005-710c7c0dfb5c
# ╟─25d67175-5de2-4287-927e-8064c2c5bd89
# ╟─23a00262-ec62-4164-8bb4-32c823cdf5fe
# ╟─765a8db2-3e20-42f2-927d-828833b01525
# ╟─f845a8e4-022b-48e5-a059-98a7b3c456c7
# ╟─6cb8613e-ec9a-4e81-8722-ce692ae297f8
# ╟─e1f6c304-22a9-41bd-9f5b-d8652d18b2b9
# ╟─694c5dda-5b1a-400b-b95f-049ea25f1301
# ╟─cdec28e0-9244-4dea-b6db-f841632442f8
# ╟─0c11ad7f-6c57-4f62-8f4a-2b39a91e950a
# ╟─40ba7cf1-a283-493e-a673-18d94d438e95
# ╟─ce5ff54c-44d3-406f-b5fc-269742ced313
# ╟─21cedb47-c1e5-41c2-9729-587a55a98c0e
# ╟─1d5f3978-31f6-4e4a-885d-a0684684cfe5
# ╟─44cf7a80-06c9-40aa-9a7c-a8331a74cf0e
# ╟─9110e321-7e78-4e7d-9c2c-22cd1efc3eae
# ╟─c5c1d0c3-5611-4543-9038-cb588cdbf0fe
# ╟─e80ad0f3-b034-4df5-9f26-52a9ae09d8e8
# ╟─1b5bd2e8-ff5c-44c2-8591-d9c9d718a11e
# ╟─34c20ae9-487d-454d-b27e-5fdf6f15e998
# ╟─618cd78a-0573-46c3-a83d-ea5b9f901dc5
# ╟─2ac27cb5-4de7-49d2-9c8f-ccea4ccdf9c2
# ╟─93a9032d-4e51-4c07-ab15-533d992628d6
# ╟─d8d43619-4f72-466b-90a9-b23e0dc6a289
# ╟─7f2530aa-a509-439e-97ad-ce6ccbed3f61
# ╟─d1626323-eee4-4122-9946-2d142e719e6b
# ╟─ff2c4c85-0271-4a19-a788-da244841cade
# ╟─c6073ef1-fc7e-49f1-87dd-13df6b1eeeff
# ╟─ee380491-4d96-4dd6-8465-8d901730bc5c
