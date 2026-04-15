### A Pluto.jl notebook ###
# v0.20.24

#> [frontmatter]
#> language = "es"
#> title = "Distribución Conjunta de Probabilidad"
#> date = "2026-04-15"
#> tags = ["estadistica", "probabilidad", "distribucion-conjunta", "covarianza"]
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

# ╔═╡ c0d1e2f3-0001-4abc-8001-000000000001
begin
	using Pkg
	Pkg.add(["CairoMakie", "PlutoUI", "PlutoTeachingTools", "Random", "Statistics", "StatsBase"])
	using CairoMakie, PlutoUI, PlutoTeachingTools
	using Random, Statistics, StatsBase
	set_language!(PlutoTeachingTools.get_language("es"))
	PlutoUI.TableOfContents(title = "📚 Contenidos")
end

# ╔═╡ c0d1e2f3-0002-4abc-8001-000000000002
md"""🔄 *Reiniciar cuaderno* $(@bind reset_nb CounterButton("Reiniciar"))"""

# ╔═╡ c0d1e2f3-0003-4abc-8001-000000000003
begin
	reset_nb
	md"""
	*Por defecto:*
	- *Mostrar los comentarios en todo el código (se puede activar o desactivar individualmente) $(@bind mostrar_comentarios Switch())*
	"""
end

# ╔═╡ c0d1e2f3-0004-4abc-8001-000000000004
md"# Distribución Conjunta de Probabilidad"

# ╔═╡ c0d1e2f3-0005-4abc-8001-000000000005
md"""
## Situación

Una entidad bancaria está revisando una **muestra aleatoria de 2 legajos** de préstamos otorgados durante el último mes para una auditoría de calidad. En el lote a auditar hay **12 expedientes** con las siguientes calificaciones de riesgo:

| Calificación | Cantidad |
|:---|:---:|
| Riesgo Bajo (ingresos estables, garantías sólidas) | **5** |
| Riesgo Moderado (historial crediticio irregular) | **4** |
| Riesgo Alto (atrasos o garantías insuficientes) | **3** |
| **Total** | **12** |

Si la muestra contiene **a lo sumo un expediente de Riesgo Moderado o Alto**, se considera **"no crítica"**. Determinar la probabilidad de que la muestra sea calificada de esa forma.

En esta actividad retomamos la **distribución hipergeométrica** para construir la distribución de probabilidad conjunta de dos variables aleatorias definidas sobre el mismo experimento.
"""

# ╔═╡ c0d1e2f3-0006-4abc-8001-000000000006
md"""
## Variables aleatorias

Definimos dos variables aleatorias sobre el espacio muestral (seleccionar 2 legajos del lote):

- ``X`` = número de expedientes de **Riesgo Moderado** seleccionados → ``X \in \{0, 1, 2\}``
- ``Y`` = número de expedientes de **Riesgo Alto** seleccionados → ``Y \in \{0, 1, 2\}``

Notar que ``X + Y \leq 2``, ya que la muestra tiene tamaño 2. Los expedientes restantes son de Riesgo Bajo.

La condición de muestra **"no crítica"** equivale a ``X + Y \leq 1``.
"""

# ╔═╡ c0d1e2f3-0007-4abc-8001-000000000007
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_params Switch(default = mostrar_comentarios))"

# ╔═╡ c0d1e2f3-0008-4abc-8001-000000000008
if comentarios_params
	md"""
	```julia
	N_bajo     = 5    # Expedientes de Riesgo Bajo en el lote
	N_moderado = 4    # Expedientes de Riesgo Moderado        (variable X)
	N_alto     = 3    # Expedientes de Riesgo Alto 	          (variable Y)
	N_total    = N_bajo + N_moderado + N_alto  # Total: 12 expedientes
	n          = 2    # Tamaño de la muestra a auditar
	```
	"""
else
	md"""
	```julia
	N_bajo     = 5
	N_moderado = 4
	N_alto     = 3
	N_total    = N_bajo + N_moderado + N_alto
	n          = 2
	```
	"""
end

# ╔═╡ c0d1e2f3-0009-4abc-8001-000000000009
begin
	N_bajo     = 5
	N_moderado = 4
	N_alto     = 3
	N_total    = N_bajo + N_moderado + N_alto
	n          = 2
end;

# ╔═╡ c0d1e2f3-0010-4abc-8001-000000000010
md"""
## Distribución conjunta de probabilidad

La probabilidad de que se seleccionen exactamente ``x`` expedientes de Riesgo Moderado e ``y`` de Riesgo Alto (con ``x + y \leq 2``) se calcula eligiendo independientemente de cada subgrupo:

```math
P(X = x, Y = y) = \frac{\dbinom{4}{x}\dbinom{3}{y}\dbinom{5}{2-x-y}}{\dbinom{12}{2}}
```

El denominador es el número de formas de elegir 2 expedientes de 12: ``\dbinom{12}{2} = 66``.

En Julia, `binomial(n, k)` calcula ``\binom{n}{k}`` directamente desde Base, sin paquetes. Usaremos racionales (`//`) para mantener exactitud en todos los cálculos.
"""

# ╔═╡ c0d1e2f3-0011-4abc-8001-000000000011
question_box(md"""
**Antes de ver el código:** Calculá a mano ``P(X = 1,\, Y = 1)``.

¿Cuántas formas hay de elegir 1 expediente de Riesgo Moderado, 1 de Riesgo Alto y 0 de Riesgo Bajo del lote? ¿Cuánto vale esa probabilidad como fracción sobre 66?
""")

# ╔═╡ c0d1e2f3-0012-4abc-8001-000000000012
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_prob Switch(default = mostrar_comentarios))"

# ╔═╡ c0d1e2f3-0013-4abc-8001-000000000013
if comentarios_prob
	md"""
	```julia
	\"\"\"
	    prob_conjunta(x, y) -> Rational

	Calcula P(X = x, Y = y) para la distribución conjunta de X (Riesgo Moderado)
	e Y (Riesgo Alto) en una muestra de tamaño `n` tomada sin reposición de un
	lote con `N_moderado`, `N_alto` y `N_bajo` expedientes de cada categoría.

	Devuelve un racional exacto. Retorna `0//1` si la combinación (x, y) es
	imposible (e.g. x + y > n, o se piden más expedientes de los disponibles
	en alguna categoría).
	\"\"\"
	function prob_conjunta(x, y)
	    # `resto` es la cantidad de expedientes de Riesgo Bajo que completan
	    # 	la muestra.
	    resto = n - x - y

	    # Descartamos combinaciones imposibles: resto negativo, o más elegidos que
	    # 	disponibles en alguna categoría.
	    if resto < 0 || x > N_moderado || y > N_alto || resto > N_bajo
	        return 0 // 1
	    end

	    # Numerador: C(N_moderado, x) * C(N_alto, y) * C(N_bajo, resto)
	    # Denominador: C(N_total, n)
	    # Usamos `//` para obtener racionales exactos.
	    return (binomial(N_moderado, x) * 
				binomial(N_alto, y) * 
				binomial(N_bajo, resto)) // 
				binomial(N_total, n)
	end

	# Dominio relevante de X e Y: X × Y = [0, 2] × [0, 2]
	xs    = 0:2
	ys    = 0:2
	tabla = [prob_conjunta(x, y) for x in xs, y in ys]

	# Distribuciones marginales: sumamos la tabla sobre cada variable.
	marginal_X = [sum(tabla[xi, :]) for xi in eachindex(xs)]  # P(X = x)
	marginal_Y = [sum(tabla[:, yi]) for yi in eachindex(ys)]  # P(Y = y)
	```
	"""
else
	md"""
	```julia
	function prob_conjunta(x, y)
	    resto = n - x - y
	    if resto < 0 || x > N_moderado || y > N_alto || resto > N_bajo
	        return 0 // 1
	    end
	    return (binomial(N_moderado, x) *
				binomial(N_alto, y) * 
				binomial(N_bajo, resto)) // 
				binomial(N_total, n)
	end

	xs    = 0:2
	ys    = 0:2
	tabla = [prob_conjunta(x, y) for x in xs, y in ys]

	marginal_X = [sum(tabla[xi, :]) for xi in eachindex(xs)]
	marginal_Y = [sum(tabla[:, yi]) for yi in eachindex(ys)]
	```
	"""
end

# ╔═╡ c0d1e2f3-0014-4abc-8001-000000000014
begin
	function prob_conjunta(x, y)
		resto = n - x - y
		if resto < 0 || x > N_moderado || y > N_alto || resto > N_bajo
			return 0 // 1
		end
		return (binomial(N_moderado, x) * binomial(N_alto, y) * binomial(N_bajo, resto)) // binomial(N_total, n)
	end

	xs    = 0:2
	ys    = 0:2
	tabla = [prob_conjunta(x, y) for x in xs, y in ys]

	marginal_X = [sum(tabla[xi, :]) for xi in eachindex(xs)]
	marginal_Y = [sum(tabla[:, yi]) for yi in eachindex(ys)]
end;

# ╔═╡ c0d1e2f3-0015-4abc-8001-000000000015
question_box(md"""
**Antes de ver la tabla:** ¿puede ocurrir el evento ``X = 2,\, Y = 1``? ¿Por qué?

Verificá tu respuesta en la tabla.
""")

# ╔═╡ c0d1e2f3-0016-4abc-8001-000000000016
let
	fmt(r) = r == 0 // 1 ? "—" : "$(numerator(r))/$(denominator(r))"
	header = "| ``f(x,y)`` | **Y = 0** | **Y = 1** | **Y = 2** | **P(X = x)** |"
	sep    = "|:---:|:---:|:---:|:---:|:---:|"
	filas  = [
		"| **X = $(x)** | $(fmt(tabla[xi,1])) | $(fmt(tabla[xi,2])) | $(fmt(tabla[xi,3])) | $(fmt(marginal_X[xi])) |"
		for (xi, x) in enumerate(xs)
	]
	pie    = "| **P(Y = y)** | $(fmt(marginal_Y[1])) | $(fmt(marginal_Y[2])) | $(fmt(marginal_Y[3])) | **1** |"

	Markdown.parse("""
	### Tabla de distribución conjunta ``P(X = x,\\, Y = y)``

	$(join([header, sep, filas..., pie], "\n"))

	> Las celdas con — corresponden a combinaciones imposibles (``x + y > 2``).
	""")
end

# ╔═╡ c0d1e2f3-0017-4abc-8001-000000000017
md"""
## Distribuciones marginales

Las **distribuciones marginales** se obtienen sumando la tabla sobre una de las variables. Representan la distribución de cada variable por separado:

```math
P(X = x) = \sum_{y} P(X = x,\, Y = y) \qquad \qquad P(Y = y) = \sum_{x} P(X = x,\, Y = y)
```
"""

# ╔═╡ c0d1e2f3-0018-4abc-8001-000000000018
question_box(md"""
**Reconocimiento de distribución:** ¿Qué distribución de probabilidad reconocés en ``P(X = x)``?

Recordá que elegimos ``n = 2`` expedientes de ``N = 12``, y hay ``K = 4`` de Riesgo Moderado.
""")

# ╔═╡ c0d1e2f3-0019-4abc-8001-000000000019
hint(md"""
Tanto ``P(X = x)`` como ``P(Y = y)`` son distribuciones **Hipergeométricas**:

- ``X \sim \text{Hiper}(N=12,\, K=4,\, n=2)``
- ``Y \sim \text{Hiper}(N=12,\, K=3,\, n=2)``

La fórmula de cada marginal, ``P(X=x) = \dfrac{\binom{K}{x}\binom{N-K}{n-x}}{\binom{N}{n}}``, coincide con sumar la tabla sobre todos los valores de ``y``.
""")

# ╔═╡ c0d1e2f3-0020-4abc-8001-000000000020
let
	fmt(r)  = "$(numerator(r))/$(denominator(r))"
	fmtd(r) = string(round(r |> Float64, digits = 4))

	header = "| **Valor** | **P(X = x)** | decimal | **P(Y = y)** | decimal |"
	sep    = "|:---:|:---:|:---:|:---:|:---:|"
	filas  = [
		"| $(xs[i]) | $(fmt(marginal_X[i])) | $(fmtd(marginal_X[i])) | $(fmt(marginal_Y[i])) | $(fmtd(marginal_Y[i])) |"
		for i in eachindex(xs)
	]

	Markdown.parse(join([header, sep, filas...], "\n"))
end

# ╔═╡ c0d1e2f3-0039-4abc-8001-000000000039
md"""
## Variable W: expedientes de Riesgo Bajo

Definimos una tercera variable de interés:

```math
W = 2 - X - Y
```

``W`` representa la cantidad de expedientes de **Riesgo Bajo** en la muestra. Como ``W`` depende de ``X`` e ``Y``, no hace falta construir una nueva tabla: podemos usar la **linealidad de la esperanza**.

```math
𝔼[W] = 𝔼[2 - X - Y] = 2 - 𝔼[X] - 𝔼[Y]
```
"""

# ╔═╡ c0d1e2f3-0040-4abc-8001-000000000040
question_box(md"""
**Interpretación frecuentista:** Si repitiéramos la auditoría muchísimas veces (tomando una muestra de 2 legajos en cada ocasión), ¿cuántos expedientes de Riesgo Bajo esperarías encontrar en promedio en cada muestra?

Calculá ``𝔼[W] = 2 - 𝔼[X] - 𝔼[Y]`` usando las esperanzas de las marginales.
""")

# ╔═╡ c0d1e2f3-0041-4abc-8001-000000000041
hint(md"""
Para la distribución Hipergeométrica, ``𝔼 = n \cdot K/N``. Entonces:

- ``𝔼[X] = 2 \cdot 4/12 = 2/3``
- ``𝔼[Y] = 2 \cdot 3/12 = 1/2``
- ``𝔼[W] = 2 - 2/3 - 1/2 = 5/6 \approx 0.833``

Esto también coincide con la Hipergeométrica directa de ``W``: ``𝔼[W] = 2 \cdot 5/12 = 5/6``.
""")

# ╔═╡ c0d1e2f3-0042-4abc-8001-000000000042
begin
	E_X  = sum(x * marginal_X[xi] for (xi, x) in enumerate(xs))
	E_Y  = sum(y * marginal_Y[yi] for (yi, y) in enumerate(ys))
	E_W  = 2 - E_X - E_Y
	E_X2 = sum(x^2 * marginal_X[xi] for (xi, x) in enumerate(xs))
	E_Y2 = sum(y^2 * marginal_Y[yi] for (yi, y) in enumerate(ys))
	Var_X = E_X2 - E_X^2
	Var_Y = E_Y2 - E_Y^2
end;

# ╔═╡ c0d1e2f3-0043-4abc-8001-000000000043
let
	fmt(r::Rational) = "``\\dfrac{$(numerator(r))}{$(denominator(r))}``"
	fmtd(r) = string(round(r |> Float64, digits = 4))

	Markdown.parse("""
	| Variable | Definición | ``\\mathbb{E}`` (exacto) | ``\\mathbb{E}`` (decimal) |
	|:---:|:---|:---:|:---:|
	| ``X`` | Expedientes de Riesgo Moderado | $(fmt(E_X)) | $(fmtd(E_X)) |
	| ``Y`` | Expedientes de Riesgo Alto | $(fmt(E_Y)) | $(fmtd(E_Y)) |
	| ``W = 2-X-Y`` | Expedientes de Riesgo Bajo | $(fmt(E_W)) | $(fmtd(E_W)) |

	**Interpretación frecuentista:** Si la auditoría se repitiera una gran cantidad de veces, en promedio cada muestra de 2 legajos contendría $(fmtd(E_X)) expedientes de Riesgo Moderado, $(fmtd(E_Y)) de Riesgo Alto y $(fmtd(E_W)) de Riesgo Bajo.

	Notar que ``𝔼[X] + 𝔼[Y] + 𝔼[W] = 2``, que es exactamente el tamaño de la muestra. Esto es coherente con la linealidad de la esperanza.
	""")
end

# ╔═╡ c0d1e2f3-0021-4abc-8001-000000000021
md"""
## Varianza de X e Y

La **varianza** mide cuánto se dispersan los valores de la variable alrededor de su media. Nos preguntamos: ¿es muy variable la cantidad de expedientes de Riesgo Moderado en la muestra?

```math
\text{Var}(X) = \mathbb{E}(X^2) - [\mathbb{E}(X)]^2
\qquad \text{donde} \qquad
\mathbb{E}(X^2) = \sum_{x} x^2 \cdot P(X = x)
```
"""

# ╔═╡ c0d1e2f3-0022-4abc-8001-000000000022
question_box(md"""
**¿Es muy variable ``X``?**

Calculá ``\text{Var}(X)`` y ``\sigma_X = \sqrt{\text{Var}(X)}``. Luego interpretá: si la media es ``\mathbb{E}(X) \approx 0.67``, ¿una desviación estándar de cuánto te parece razonable para esta situación?
""")

# ╔═╡ c0d1e2f3-0023-4abc-8001-000000000023
hint(md"""
Para la distribución Hipergeométrica existe una fórmula directa para la varianza:

```math
\text{Var}(X) = n \cdot \frac{K}{N} \cdot \frac{N-K}{N} \cdot \frac{N-n}{N-1}
= 2 \cdot \frac{4}{12} \cdot \frac{8}{12} \cdot \frac{10}{11} = \frac{40}{99}
```

El factor ``\dfrac{N-n}{N-1} = \dfrac{10}{11}`` es la **corrección por población finita**: reduce la varianza porque muestreamos sin reposición de una población pequeña.
""")

# ╔═╡ c0d1e2f3-0024-4abc-8001-000000000024
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_esp Switch(default = mostrar_comentarios))"

# ╔═╡ c0d1e2f3-0025-4abc-8001-000000000025
if comentarios_esp
	md"""
	```julia
	# E(X²) — necesario para calcular la varianza por la fórmula de König-Huygens
	E_X2 = sum(x^2 * marginal_X[xi] for (xi, x) in enumerate(xs))
	E_Y2 = sum(y^2 * marginal_Y[yi] for (yi, y) in enumerate(ys))

	# Var(X) = E(X²) - [E(X)]²
	Var_X = E_X2 - E_X^2
	Var_Y = E_Y2 - E_Y^2
	```
	"""
else
	md"""
	```julia
	E_X2  = sum(x^2 * marginal_X[xi] for (xi, x) in enumerate(xs))
	E_Y2  = sum(y^2 * marginal_Y[yi] for (yi, y) in enumerate(ys))
	Var_X = E_X2 - E_X^2
	Var_Y = E_Y2 - E_Y^2
	```
	"""
end

# ╔═╡ c0d1e2f3-0027-4abc-8001-000000000027
let
	fmt(r::Rational) = "``\\dfrac{$(numerator(r))}{$(denominator(r))}``"
	fmtd(r) = string(round(r |> Float64, digits = 4))
	σ_X = round(sqrt(Var_X |> Float64), digits = 4)
	σ_Y = round(sqrt(Var_Y |> Float64), digits = 4)

	Markdown.parse("""
	| | ``\\mathbb{E}`` | ``\\text{Var}`` | ``\\sigma`` |
	|:---:|:---:|:---:|:---:|
	| **X** (Riesgo Moderado) | $(fmt(E_X)) ≈ $(fmtd(E_X)) | $(fmt(Var_X)) ≈ $(fmtd(Var_X)) | ≈ $σ_X |
	| **Y** (Riesgo Alto) | $(fmt(E_Y)) ≈ $(fmtd(E_Y)) | $(fmt(Var_Y)) ≈ $(fmtd(Var_Y)) | ≈ $σ_Y |

	**Interpretación:** La desviación estándar de ``X`` es ``\\sigma_X \\approx $σ_X``. Dado que la media es ``\\mathbb{E}(X) \\approx $(fmtd(E_X))``, los valores de ``X`` (que solo pueden ser 0, 1 o 2) no se alejan demasiado de la media. La variabilidad es moderada.
	""")
end

# ╔═╡ c0d1e2f3-0028-4abc-8001-000000000028
md"""
## Covarianza: ¿cómo varían conjuntamente X e Y?

La **covarianza** mide si las variables tienden a moverse en la misma dirección o en sentidos opuestos:

```math
\text{Cov}(X, Y) = \mathbb{E}(XY) - \mathbb{E}(X) \cdot \mathbb{E}(Y)
\qquad \text{donde} \qquad
\mathbb{E}(XY) = \sum_{x}\sum_{y} xy \cdot P(X = x,\, Y = y)
```

El **coeficiente de correlación lineal** estandariza la covarianza al rango ``[-1, 1]``:

```math
\rho_{XY} = \frac{\text{Cov}(X,Y)}{\sqrt{\text{Var}(X) \cdot \text{Var}(Y)}}
```

### Independencia estadística

``X`` e ``Y`` son **estadísticamente independientes** si y solo si para todo par ``(x, y)``:

```math
P(X = x,\, Y = y) = P(X = x) \cdot P(Y = y)
```
"""

# ╔═╡ c0d1e2f3-0029-4abc-8001-000000000029
question_box(md"""
**Antes de calcular:** ¿la covarianza entre ``X`` e ``Y`` será positiva, negativa o cero?

Pensá en la restricción ``X + Y \leq 2``: si la muestra tiene muchos expedientes de Riesgo Moderado, ¿qué le pasa al espacio disponible para los de Riesgo Alto?
""")

# ╔═╡ c0d1e2f3-0030-4abc-8001-000000000030
hint(md"""
Como ``X + Y \leq 2``, a medida que ``X`` crece, ``Y`` tiene menos margen para tomar valores altos. Esto genera una **covarianza negativa**: cuando una variable tiende a ser alta, la otra tiende a ser baja.

Esta dependencia también implica que ``X`` e ``Y`` **no son independientes**.
""")

# ╔═╡ c0d1e2f3-0031-4abc-8001-000000000031
begin
	E_XY   = sum(x * y * tabla[xi, yi]
		for (xi, x) in enumerate(xs)
		for (yi, y) in enumerate(ys))
	Cov_XY = E_XY - E_X * E_Y
	ρ_XY   = Cov_XY / sqrt(Var_X * Var_Y)
end;

# ╔═╡ c0d1e2f3-0032-4abc-8001-000000000032
let
	fmt(r::Rational) = "``\\dfrac{$(numerator(r))}{$(denominator(r))}``"
	fmtd(r) = string(round(r |> Float64, digits = 4))

	indep = all(
		tabla[xi, yi] == marginal_X[xi] * marginal_Y[yi]
		for xi in eachindex(xs), yi in eachindex(ys)
	)
	concl = indep ?
		"✔ **Son independientes**." :
		"✘ **No son independientes**: existe al menos un par ``(x,y)`` donde ``P(X=x,Y=y) \\neq P(X=x) \\cdot P(Y=y)``."

	Markdown.parse("""
	| | Valor exacto | Decimal |
	|:---|:---:|:---:|
	| ``\\mathbb{E}(XY)`` | $(fmt(E_XY)) | $(fmtd(E_XY)) |
	| ``\\text{Cov}(X,Y)`` | $(fmt(Cov_XY)) | $(fmtd(Cov_XY)) |
	| ``\\rho_{XY}`` | — | $(fmtd(ρ_XY)) |

	**Independencia:** $concl

	**Interpretación:** La covarianza negativa confirma la intuición: en una muestra de tamaño fijo, seleccionar más expedientes de Riesgo Moderado deja menos lugar para los de Riesgo Alto, y viceversa.
	""")
end

# ╔═╡ c0d1e2f3-0033-4abc-8001-000000000033
question_box(md"""
**Verificación manual de independencia:** Tomá el par ``(X=1, Y=1)``.

Calculá ``P(X=1) \cdot P(Y=1)`` con las marginales y compará con ``P(X=1,Y=1)`` de la tabla.

¿Son iguales?
""")

# ╔═╡ c0d1e2f3-0034-4abc-8001-000000000034
let
	px1 = marginal_X[2]   # P(X=1)
	py1 = marginal_Y[2]   # P(Y=1)
	pxy = tabla[2, 2]     # P(X=1, Y=1)
	prod_ = px1 * py1

	fmt(r::Rational) = "$(numerator(r))/$(denominator(r))"

	hint(md"""
	``P(X=1) = ``$(fmt(px1)),  ``P(Y=1) = ``$(fmt(py1))

	``P(X=1) \cdot P(Y=1) = ``$(fmt(prod_))  pero  ``P(X=1,Y=1) = ``$(fmt(pxy))

	Como ``$(fmt(prod_)) \neq $(fmt(pxy))``, las variables **no son independientes**.
	""")
end

# ╔═╡ c0d1e2f3-0035-4abc-8001-000000000035
md"""
## Visualización de la distribución conjunta
"""

# ╔═╡ c0d1e2f3-0036-4abc-8001-000000000036
let
	fig = Figure(size = (820, 370), fontsize = 14)

	ax1 = Axis(fig[1, 1],
		title  = "Distribución conjunta P(X=x, Y=y)",
		xlabel = "Y — Riesgo Alto",
		ylabel = "X — Riesgo Moderado",
		xticks = (0:2, ["Y=0", "Y=1", "Y=2"]),
		yticks = (0:2, ["X=0", "X=1", "X=2"]),
	)
	z  = Float64[tabla[xi, yi] for xi in eachindex(xs), yi in eachindex(ys)]
	hm = heatmap!(ax1, 0:2, 0:2, z, colormap = :Blues)
	Colorbar(fig[1, 2], hm, label = "Probabilidad")

	for (xi, x) in enumerate(xs), (yi, y) in enumerate(ys)
		val = tabla[xi, yi]
		if val > 0
			text!(ax1, "$(numerator(val))/$(denominator(val))";
				position = (Float64(y), Float64(x)),
				align    = (:center, :center),
				fontsize = 13,
				color    = val > 17//66 ? :white : :black,
			)
		end
	end

	ax2 = Axis(fig[1, 3],
		title  = "Distribuciones marginales",
		xlabel = "Valor",
		ylabel = "Probabilidad",
	)
	barplot!(ax2, (0:2) .- 0.17, Float64.(marginal_X),
		width = 0.3, color = :steelblue, label = "P(X=x) — Moderado")
	barplot!(ax2, (0:2) .+ 0.17, Float64.(marginal_Y),
		width = 0.3, color = :tomato, label = "P(Y=y) — Alto")
	axislegend(ax2, position = :rt)

	fig
end

# ╔═╡ c0d1e2f3-0050-4abc-8001-000000000050
md"""
## Laboratorio: simulación y regularidad estadística

Hasta ahora calculamos las probabilidades de manera teórica. Ahora vamos a **simular** el experimento muchas veces y verificar empíricamente que las frecuencias relativas se acercan a las probabilidades teóricas a medida que aumentamos el número de repeticiones.

Este fenómeno se conoce como **regularidad estadística** y es la base de la interpretación frecuentista de la probabilidad.
"""

# ╔═╡ c0d1e2f3-0051-4abc-8001-000000000051
begin
	reset_nb
	Columns(
		md"Número de simulaciones: $(@bind n_sim PlutoUI.Slider(10:10:10000, default=1000, show_value=true))"
	)
end

# ╔═╡ c0d1e2f3-0052-4abc-8001-000000000052
question_box(md"""
**Antes de simular:** Si repetimos el experimento 50 veces en lugar de 5000, ¿las frecuencias relativas observadas estarán más cerca o más lejos de las probabilidades teóricas?

Mové el slider y observá cómo cambian las frecuencias.
""")

# ╔═╡ c0d1e2f3-0053-4abc-8001-000000000053
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_lab Switch(default = mostrar_comentarios))"

# ╔═╡ c0d1e2f3-0054-4abc-8001-000000000054
if comentarios_lab
	md"""
	```julia
	Random.seed!(42)  # Fijamos la semilla para reproducibilidad

	# Construimos la población: 5 Bajo (1), 4 Moderado (2), 3 Alto (3)
	poblacion = [fill(1, N_bajo); fill(2, N_moderado); fill(3, N_alto)]

	# Tomamos n_sim muestras de tamaño 2 sin reposición.
	# `sample(a, k, replace=false)` de StatsBase hace el muestreo sin reemplazo.
	muestras = [sample(poblacion, n, replace = false) for _ in 1:n_sim]

	# Contamos X (Moderado=2) e Y (Alto=3) en cada muestra.
	# `count(pred, iter)` devuelve cuántos elementos de `iter` satisfacen `pred`.
	X_sim = [count(==(2), m) for m in muestras]
	Y_sim = [count(==(3), m) for m in muestras]
	```
	"""
else
	md"""
	```julia
	Random.seed!(42)
	poblacion = [fill(1, N_bajo); fill(2, N_moderado); fill(3, N_alto)]
	muestras  = [sample(poblacion, n, replace = false) for _ in 1:n_sim]
	X_sim     = [count(==(2), m) for m in muestras]
	Y_sim     = [count(==(3), m) for m in muestras]
	```
	"""
end

# ╔═╡ c0d1e2f3-0055-4abc-8001-000000000055
begin
	Random.seed!(42)
	poblacion = [fill(1, N_bajo); fill(2, N_moderado); fill(3, N_alto)]
	muestras  = [sample(poblacion, n, replace = false) for _ in 1:n_sim]
	X_sim     = [count(==(2), m) for m in muestras]
	Y_sim     = [count(==(3), m) for m in muestras]
end;

# ╔═╡ c0d1e2f3-0056-4abc-8001-000000000056
let
	fmt(r)    = "$(numerator(r))/$(denominator(r))"
	fmtd(x)   = string(round(x, digits = 4))

	header = "| ``(x, y)`` | Teórica | Simulada (n=$(n_sim)) | Diferencia |"
	sep    = "|:---:|:---:|:---:|:---:|"

	pares = [(x, y) for x in 0:2 for y in 0:2 if x + y ≤ 2]
	filas = [
		let
			teo  = tabla[x+1, y+1]
			sim  = count(i -> X_sim[i]==x && Y_sim[i]==y, 1:n_sim) / n_sim
			dif  = abs(sim - Float64(teo))
			"| ``($(x), $(y))`` | $(fmt(teo)) | $(fmtd(sim)) | $(fmtd(dif)) |"
		end
		for (x, y) in pares
	]

	Markdown.parse("""
	### Frecuencias teóricas vs. simuladas

	$(join([header, sep, filas...], "\n"))

	Con ``n_{\\text{sim}} = $(n_sim)`` repeticiones, las frecuencias simuladas $(n_sim >= 1000 ? "se acercan bastante" : "todavía muestran cierta dispersión respecto") a las probabilidades teóricas. Aumentá el número de simulaciones para ver cómo convergen.
	""")
end

# ╔═╡ c0d1e2f3-0057-4abc-8001-000000000057
let
	# Medias progresivas: promedio acumulado de X_sim e Y_sim
	E_X_prog = cumsum(Float64.(X_sim)) ./ (1:n_sim)
	E_Y_prog = cumsum(Float64.(Y_sim)) ./ (1:n_sim)

	fig = Figure(size = (800, 420), fontsize = 14)
	ax  = Axis(fig[1, 1],
		title   = "Convergencia de las medias simuladas (Ley de los Grandes Números)",
		xlabel  = "Número de simulaciones acumuladas",
		ylabel  = "Estimación de la media",
		xgridstyle = :dash,
		ygridstyle = :dash,
		xminorticksvisible = true,
		xminorgridvisible  = true,
	)

	lines!(ax, 1:n_sim, E_X_prog,
		color = (:steelblue, 0.9), linewidth = 2,
		label = "Media simulada de X")
	lines!(ax, 1:n_sim, E_Y_prog,
		color = (:tomato, 0.9), linewidth = 2,
		label = "Media simulada de Y")

	hlines!(ax, [E_X |> Float64],
		color = :steelblue, linestyle = :dash, linewidth = 2,
		label = "𝔼[X] = $(round(E_X |> Float64, digits=4))")
	hlines!(ax, [E_Y |> Float64],
		color = :tomato, linestyle = :dash, linewidth = 2,
		label = "𝔼[Y] = $(round(E_Y |> Float64, digits=4))")

	axislegend(ax, position = :rt, framevisible = true, backgroundcolor = :white)
	fig
end

# ╔═╡ c0d1e2f3-0058-4abc-8001-000000000058
md"""
A medida que aumenta el número de simulaciones, las medias progresivas se estabilizan alrededor de los valores teóricos ``\mathbb{E}(X)`` y ``\mathbb{E}(Y)``. Esto ilustra la **regularidad estadística**: en el largo plazo, el promedio de los resultados observados converge al valor esperado teórico.

Esta idea es la puerta de entrada a la **inferencia estadística**: cuando tomamos una muestra real, los estadísticos que calculamos (medias, proporciones) son estimaciones de los parámetros verdaderos de la población.
"""

# ╔═╡ c0d1e2f3-0037-4abc-8001-000000000037
md"""
## Respuesta: probabilidad de muestra "no crítica"

La muestra es **"no crítica"** si ``X + Y \leq 1``, es decir, si contiene a lo sumo un expediente entre Moderado y Alto. Los casos favorables son:

```math
P(\text{no crítica}) = P(X=0,Y=0) + P(X=0,Y=1) + P(X=1,Y=0)
```
"""

# ╔═╡ c0d1e2f3-0038-4abc-8001-000000000038
let
	P_no_crit = tabla[1,1] + tabla[1,2] + tabla[2,1]   # (X=0,Y=0) + (X=0,Y=1) + (X=1,Y=0)
	P_crit    = 1 - P_no_crit
	pct_nc    = round(Float64(P_no_crit) * 100, digits = 2)
	pct_c     = round(Float64(P_crit)   * 100, digits = 2)

	fmt(r::Rational) = "$(numerator(r))/$(denominator(r))"

	Markdown.parse("""
	| Evento | Casos favorables | Fracción | Decimal |
	|:---|:---|:---:|:---:|
	| Muestra **no crítica** (``X+Y \\leq 1``) | ``P(0,0) + P(0,1) + P(1,0)`` | ``$(fmt(P_no_crit))`` | $(round(P_no_crit |> Float64, digits=4)) |
	| Muestra **crítica** (``X+Y \\geq 2``) | complemento | ``$(fmt(P_crit))`` | $(round(P_crit |> Float64, digits=4)) |

	**Conclusión:** La probabilidad de que la muestra sea **no crítica** es ``\\dfrac{$(numerator(P_no_crit))}{$(denominator(P_no_crit))} \\approx $pct_nc\\%``.

	Dicho de otro modo, en aproximadamente el $pct_c% de las posibles muestras de 2 legajos habrá 2 expedientes entre Moderado y Alto, lo que dispararía una revisión más exhaustiva.
	""")
end

# ╔═╡ Cell order:
# ╟─c0d1e2f3-0001-4abc-8001-000000000001
# ╟─c0d1e2f3-0002-4abc-8001-000000000002
# ╟─c0d1e2f3-0003-4abc-8001-000000000003
# ╟─c0d1e2f3-0004-4abc-8001-000000000004
# ╟─c0d1e2f3-0005-4abc-8001-000000000005
# ╟─c0d1e2f3-0006-4abc-8001-000000000006
# ╟─c0d1e2f3-0007-4abc-8001-000000000007
# ╟─c0d1e2f3-0008-4abc-8001-000000000008
# ╟─c0d1e2f3-0009-4abc-8001-000000000009
# ╟─c0d1e2f3-0010-4abc-8001-000000000010
# ╟─c0d1e2f3-0011-4abc-8001-000000000011
# ╟─c0d1e2f3-0012-4abc-8001-000000000012
# ╟─c0d1e2f3-0013-4abc-8001-000000000013
# ╟─c0d1e2f3-0014-4abc-8001-000000000014
# ╟─c0d1e2f3-0015-4abc-8001-000000000015
# ╟─c0d1e2f3-0016-4abc-8001-000000000016
# ╟─c0d1e2f3-0017-4abc-8001-000000000017
# ╟─c0d1e2f3-0018-4abc-8001-000000000018
# ╟─c0d1e2f3-0019-4abc-8001-000000000019
# ╟─c0d1e2f3-0020-4abc-8001-000000000020
# ╟─c0d1e2f3-0039-4abc-8001-000000000039
# ╟─c0d1e2f3-0040-4abc-8001-000000000040
# ╟─c0d1e2f3-0041-4abc-8001-000000000041
# ╟─c0d1e2f3-0042-4abc-8001-000000000042
# ╟─c0d1e2f3-0043-4abc-8001-000000000043
# ╟─c0d1e2f3-0021-4abc-8001-000000000021
# ╟─c0d1e2f3-0022-4abc-8001-000000000022
# ╟─c0d1e2f3-0023-4abc-8001-000000000023
# ╟─c0d1e2f3-0024-4abc-8001-000000000024
# ╟─c0d1e2f3-0025-4abc-8001-000000000025
# ╟─c0d1e2f3-0027-4abc-8001-000000000027
# ╟─c0d1e2f3-0028-4abc-8001-000000000028
# ╟─c0d1e2f3-0029-4abc-8001-000000000029
# ╟─c0d1e2f3-0030-4abc-8001-000000000030
# ╟─c0d1e2f3-0031-4abc-8001-000000000031
# ╟─c0d1e2f3-0032-4abc-8001-000000000032
# ╟─c0d1e2f3-0033-4abc-8001-000000000033
# ╟─c0d1e2f3-0034-4abc-8001-000000000034
# ╟─c0d1e2f3-0035-4abc-8001-000000000035
# ╟─c0d1e2f3-0036-4abc-8001-000000000036
# ╟─c0d1e2f3-0050-4abc-8001-000000000050
# ╟─c0d1e2f3-0051-4abc-8001-000000000051
# ╟─c0d1e2f3-0052-4abc-8001-000000000052
# ╟─c0d1e2f3-0053-4abc-8001-000000000053
# ╟─c0d1e2f3-0054-4abc-8001-000000000054
# ╟─c0d1e2f3-0055-4abc-8001-000000000055
# ╟─c0d1e2f3-0056-4abc-8001-000000000056
# ╟─c0d1e2f3-0057-4abc-8001-000000000057
# ╟─c0d1e2f3-0058-4abc-8001-000000000058
# ╟─c0d1e2f3-0037-4abc-8001-000000000037
# ╟─c0d1e2f3-0038-4abc-8001-000000000038
