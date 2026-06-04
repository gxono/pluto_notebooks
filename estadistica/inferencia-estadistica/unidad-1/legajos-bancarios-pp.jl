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

# ╔═╡ 4c1e85d0-3b2a-11f1-bd16-eda20a106e5a
begin
    using Pkg
    Pkg.add([
        "Turing",
        "Distributions",
        "MCMCChains",
        "DataFrames",
        "CairoMakie",
        "PlutoUI",
        "PlutoTeachingTools",
        "StatsBase",
        "Statistics",
        "Random",
    ])

    using Turing
    using Distributions
    using MCMCChains
    using DataFrames
    using CairoMakie
    using PlutoUI
    using PlutoTeachingTools
    using StatsBase
    using Statistics
    using Random
    import PlutoUI: Slider

    PlutoTeachingTools.set_language!(PlutoTeachingTools.get_language("es"))
    PlutoUI.TableOfContents(title = "📚 Contenidos")
end

# ╔═╡ 3c857cc2-02cc-4216-b7b3-9472c6c74a3e
md"*Una versión que aborda el problema desde la combinatoria y el muestreo frecuentista se encuentra en el fichero* `legajos-bancarios.jl`."

# ╔═╡ 8dd8fdbf-7300-49e7-b379-df4f867f61db
md"""🔄 *Reiniciar cuaderno* $(@bind reset_nb CounterButton("Reiniciar"))"""

# ╔═╡ 23e1647f-6f10-44cd-986a-5c0112c4e34e
begin
    reset_nb
    md"""
    *Por defecto:*
    - *Mostrar los comentarios en todo el código $(@bind mostrar_comentarios Switch())*
    """
end

# ╔═╡ f9a4a68e-d446-4ee6-b0bb-bf8ad35d8212
md"## El problema"

# ╔═╡ 8db0d717-79a9-4f97-b0b2-23fe4224f0c7
md"""
Una entidad bancaria está revisando una muestra aleatoria de 2 legajos de préstamos otorgados durante el último mes para una auditoría de calidad. En el lote a auditar hay 12 expedientes con las siguientes calificaciones de riesgo:

- 5 de **Riesgo Bajo**
- 4 de **Riesgo Moderado**
- 3 de **Riesgo Alto**

Si la muestra contiene *a lo sumo un expediente de riesgo moderado o alto*, se la considera **"no crítica"**.

A diferencia del notebook clásico (basado en combinatoria y simulación frecuentista), aquí abordaremos el problema desde la **programación probabilística**: describiremos el proceso generativo como un modelo en `Turing.jl`, calcularemos probabilidades por simulación y, finalmente, haremos **inferencia bayesiana** sobre la composición del lote.
"""

# ╔═╡ ebaa400d-2c21-4935-856a-5b9d6f390789
md"## Los paquetes"

# ╔═╡ ed41711c-61fa-4e3b-8c54-95338582e99a
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_paquetes Switch(default = mostrar_comentarios))"

# ╔═╡ 8f7aac09-9c38-47ef-817a-dd3e3d2a44b8
if comentarios_paquetes
    md"""
    ```julia
    using Turing           # Motor de programación probabilística y MCMC
    using Distributions    # Distribuciones de probabilidad
    using MCMCChains       # Diagnósticos de cadenas MCMC
    using DataFrames       # Para extraer muestras de la cadena como tabla
    using CairoMakie       # Gráficos
    using PlutoUI, PlutoTeachingTools
    using StatsBase, Statistics, Random
    ```
    """
else
    md"""
    ```julia
    using Turing, Distributions, MCMCChains, DataFrames
    using CairoMakie
    using PlutoUI, PlutoTeachingTools
    using StatsBase, Statistics, Random
    ```
    """
end

# ╔═╡ 96216b2c-5556-4840-8851-a09e19a30810
md"## Distribuciones exactas con `Distributions.jl`"

# ╔═╡ ebe56794-9897-4233-83b6-6d378801fd45
md"""
Antes de plantear el modelo probabilístico, conviene conocer la distribución teórica exacta.

Sean:
- ``X``: cantidad de legajos de **riesgo moderado** en la muestra (``X \in \{0, 1, 2\}``)
- ``Y``: cantidad de legajos de **riesgo alto** en la muestra (``Y \in \{0, 1, 2\}``)

Dado que se extrae *sin reemplazo* de un lote de tamaño fijo, la distribución **marginal** de ``X`` es hipergeométrica:

```math
X \sim \text{Hipergeométrica}(\underbrace{K_M = 4}_{\text{moderados}},\; \underbrace{N - K_M = 8}_{\text{no moderados}},\; \underbrace{n = 2}_{\text{muestra}})
```

Y su **distribución conjunta** con ``Y`` está dada por la hipergeométrica multivariada:

```math
P(X = x,\, Y = y) = \frac{\dbinom{4}{x}\dbinom{3}{y}\dbinom{5}{2-x-y}}{\dbinom{12}{2}}, \qquad x + y \leq 2
```
"""

# ╔═╡ f14886d2-9144-4b86-8421-6d58cb5f7e07
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_dist Switch(default = mostrar_comentarios))"

# ╔═╡ c6b9bbcd-8b92-4be3-adf5-76f9e338eaed
if comentarios_dist
    md"""
    ```julia
    # Composición conocida del lote
    K = (bajo = 5, moderado = 4, alto = 3)
    N_total = 12
    n_muestra = 2

    # Hypergeometric(s, f, n): s éxitos en la población, f fracasos, n extracciones
    dist_X = Hypergeometric(K.moderado, N_total - K.moderado, n_muestra)
    dist_Y = Hypergeometric(K.alto,     N_total - K.alto,     n_muestra)

    # P(X = x) para x ∈ {0, 1, 2}
    p_X = [pdf(dist_X, x) for x in 0:n_muestra]
    p_Y = [pdf(dist_Y, y) for y in 0:n_muestra]

    # Función de masa conjunta P(X=x, Y=y)
    function pmf_conjunta(x, y; K, N, n)
        z = n - x - y
        (z < 0 || x > K.moderado || y > K.alto || z > K.bajo) && return 0.0
        binomial(K.moderado, x) * binomial(K.alto, y) * binomial(K.bajo, z) /
            binomial(N, n)
    end
    ```
    """
else
    md"""
    ```julia
    K = (bajo = 5, moderado = 4, alto = 3)
    N_total = 12; n_muestra = 2

    dist_X = Hypergeometric(K.moderado, N_total - K.moderado, n_muestra)
    dist_Y = Hypergeometric(K.alto,     N_total - K.alto,     n_muestra)

    p_X = [pdf(dist_X, x) for x in 0:n_muestra]
    p_Y = [pdf(dist_Y, y) for y in 0:n_muestra]

    function pmf_conjunta(x, y; K, N, n)
        z = n - x - y
        (z < 0 || x > K.moderado || y > K.alto || z > K.bajo) && return 0.0
        binomial(K.moderado, x) * binomial(K.alto, y) * binomial(K.bajo, z) / binomial(N, n)
    end
    ```
    """
end

# ╔═╡ f8fe8639-80fe-4c9c-b457-bf80219fd880
begin
    K = (bajo = 5, moderado = 4, alto = 3)
    N_total = 12
    n_muestra = 2

    dist_X = Hypergeometric(K.moderado, N_total - K.moderado, n_muestra)
    dist_Y = Hypergeometric(K.alto,     N_total - K.alto,     n_muestra)

    p_X = [pdf(dist_X, x) for x in 0:n_muestra]
    p_Y = [pdf(dist_Y, y) for y in 0:n_muestra]

    function pmf_conjunta(x, y; K = K, N = N_total, n = n_muestra)
        z = n - x - y
        (z < 0 || x > K.moderado || y > K.alto || z > K.bajo) && return 0.0
        Float64(binomial(K.moderado, x) * binomial(K.alto, y) * binomial(K.bajo, z)) /
            binomial(N, n)
    end

    P_conjunta = [pmf_conjunta(x, y) for x in 0:2, y in 0:2]

    p_no_critica_exacta = sum(pmf_conjunta(x, y) for x in 0:2, y in 0:2 if x + y <= 1)

    md"""
    La probabilidad exacta de muestra **"no crítica"** ``P(X + Y \leq 1)`` es:

    ```math
    P(X + Y \leq 1) = \frac{10 + 20 + 15}{66} = \frac{45}{66} = \frac{15}{22} \approx 0{,}6818
    ```

    En Julia: **$(round(p_no_critica_exacta, digits = 6))**
    """
end

# ╔═╡ 993d403c-0320-4ab9-8319-49b290fb90ad
let
    fig = Figure(size = (520, 420))
    ax = Axis(fig[1, 1],
        title = "Distribución conjunta exacta P(X, Y)",
        xlabel = "Y — riesgo alto",
        ylabel = "X — riesgo moderado",
        xticks = (0:2, ["Y = 0", "Y = 1", "Y = 2"]),
        yticks = (0:2, ["X = 0", "X = 1", "X = 2"]))

    hm = heatmap!(ax, 0:2, 0:2, P_conjunta; colormap = :Blues)
    Colorbar(fig[1, 2], hm; label = "P(X, Y)")

    for x in 0:2, y in 0:2
        val = P_conjunta[x+1, y+1]
        val == 0.0 && continue
        label = x + y <= 1 ? "★ $(round(val, digits=4))" : "$(round(val, digits=4))"
        text!(ax, y, x;
            text = label,
            align = (:center, :center),
            fontsize = 11, font = :bold,
            color = val > 0.22 ? :white : :black)
    end

    html = repr(MIME"text/html"(), fig)
    HTML("<div style='display:flex; justify-content:center'>$(html)</div>")
end

# ╔═╡ dc97a3bb-25f5-44fa-94c1-cfa4d38f5773
md"""
Las celdas marcadas con ★ corresponden a los eventos del conjunto ``\{X + Y \leq 1\}`` (muestra "no crítica").
"""

# ╔═╡ 28bb7135-105c-427e-a497-a828f4f9a8da
md"## El modelo generativo con `Turing.jl`"

# ╔═╡ 53c56147-78d0-4c5d-ab9e-8e0cae0c7e4f
md"""
La idea central de la **programación probabilística** es expresar el proceso generativo como un modelo en código. En lugar de derivar probabilidades analíticamente, *describimos cómo se generan los datos* y dejamos que el motor infiera las probabilidades que nos interesan.

Para nuestro problema, el proceso generativo tiene dos etapas:
1. ``X \sim \text{Hipergeométrica}(4, 8, 2)`` — cuántos moderados caen en la muestra.
2. ``Y \mid X \sim \text{Hipergeométrica}(3, 5, 2 - X)`` — cuántos altos caen en los lugares restantes.

En `Turing.jl` esto se expresa con la macro `@model`:
"""

# ╔═╡ f4bcd6a9-44b5-4b08-a386-958daa9c872a
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_modelo Switch(default = mostrar_comentarios))"

# ╔═╡ 163312e1-866e-4209-a4f3-3da2f01971c9
if comentarios_modelo
    md"""
    ```julia
    # `@model` define la función generativa. Las variables marcadas con `~`
    # son aleatorias: declaran tanto la distribución como el nombre del parámetro.
    @model function muestreo_lote(n = 2)
        # X: cantidad de moderados. 4 en el lote, 8 no-moderados, n extracciones.
        X ~ Hypergeometric(4, 8, n)

        # Y: cantidad de altos en los (n - X) lugares restantes.
        # Luego de extraer X moderados, quedan 3 altos y 5 bajos disponibles.
        Y ~ Hypergeometric(3, 5, n - X)
    end
    ```
    """
else
    md"""
    ```julia
    @model function muestreo_lote(n = 2)
        X ~ Hypergeometric(4, 8, n)
        Y ~ Hypergeometric(3, 5, n - X)
    end
    ```
    """
end

# ╔═╡ 80910dd8-05d6-48f4-a191-c79a1825b573
@model function muestreo_lote(n = 2)
    X ~ Hypergeometric(4, 8, n)
    Y ~ Hypergeometric(3, 5, n - X)
end

# ╔═╡ fa9c8834-92cf-4534-9430-5e19fe3c39cb
md"""
Note que el modelo `muestreo_lote` describe exactamente el mismo proceso que la fórmula de la hipergeométrica multivariada: primero se elige cuántos moderados, y luego —dado ese resultado— cuántos altos entre los lugares restantes.

Esta descripción como código tiene una ventaja: puede usarse tanto para **generar datos** (simulación hacia adelante) como para **inferir parámetros** a partir de observaciones (inferencia hacia atrás).
"""

# ╔═╡ 1a0153ca-8299-4ca0-b927-31e6f45e7670
md"## Simulación predictiva (prior predictive)"

# ╔═╡ 229bcc7e-13cf-46d3-9876-f4e691bf5203
md"""
El uso más directo del modelo generativo es la **simulación predictiva a priori** (*prior predictive sampling*): muestreamos del modelo sin ninguna observación, simulando el experimento miles de veces. Las frecuencias relativas convergen a las probabilidades teóricas.

Para ello, simulamos directamente a partir de las distribuciones del modelo:
"""

# ╔═╡ 58308bd1-932f-41d8-a567-27962aa06f62
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_sim Switch(default = mostrar_comentarios))"

# ╔═╡ b444fd43-d913-4007-8149-9de2206ed209
if comentarios_sim
    md"""
    ```julia
    # Esta función replica exactamente las dos líneas del @model:
    # primero muestrea X, luego Y condicionado en X.
    function simular_muestra(n = 2)
        X = rand(Hypergeometric(4, 8, n))
        Y = rand(Hypergeometric(3, 5, n - X))
        (X = X, Y = Y)
    end

    # Repetimos el experimento n_sim veces
    muestras_sim = [simular_muestra() for _ in 1:n_sim]

    # Estimamos la probabilidad del evento de interés
    p_no_critica_sim = mean(m.X + m.Y <= 1 for m in muestras_sim)
    ```
    """
else
    md"""
    ```julia
    function simular_muestra(n = 2)
        X = rand(Hypergeometric(4, 8, n))
        Y = rand(Hypergeometric(3, 5, n - X))
        (X = X, Y = Y)
    end

    muestras_sim = [simular_muestra() for _ in 1:n_sim]
    p_no_critica_sim = mean(m.X + m.Y <= 1 for m in muestras_sim)
    ```
    """
end

# ╔═╡ 4181c552-8d3c-475c-af9c-f7f6ba51b1f5
begin
    reset_nb
    md"Número de simulaciones: $(@bind n_sim Scrubbable(1000:1000:100_000; default = 20_000))"
end

# ╔═╡ b4eb2981-8648-404f-951c-02361a6939e5
begin
    reset_nb
    Random.seed!(42)

    function simular_muestra(n = 2)
        X = rand(Hypergeometric(4, 8, n))
        Y = rand(Hypergeometric(3, 5, n - X))
        (X = X, Y = Y)
    end

    muestras_sim = [simular_muestra() for _ in 1:n_sim]
    xs_sim = [m.X for m in muestras_sim]
    ys_sim = [m.Y for m in muestras_sim]
    p_no_critica_sim = mean(m.X + m.Y <= 1 for m in muestras_sim)

    md"""
    Con **$(n_sim)** simulaciones: ``\hat{P}(\text{no crítica}) =`` **$(round(p_no_critica_sim, digits = 5))** (exacta: **$(round(p_no_critica_exacta, digits = 5))**)
    """
end

# ╔═╡ 253418a0-ba99-47d6-bded-9e59243514c9
let
    fig = Figure(size = (700, 300))

    # Distribución de X
    ax1 = Axis(fig[1, 1],
        title = "Distribución de X (moderados)",
        xlabel = "x", ylabel = "frecuencia relativa",
        xticks = 0:2)
    freq_X = [mean(xs_sim .== x) for x in 0:2]
    barplot!(ax1, 0:2, freq_X; color = (:steelblue, 0.7), label = "simulación")
    scatter!(ax1, 0:2, p_X; color = :red, markersize = 12, label = "exacta")
    axislegend(ax1; position = :rt)

    # Distribución de Y
    ax2 = Axis(fig[1, 2],
        title = "Distribución de Y (altos)",
        xlabel = "y", ylabel = "frecuencia relativa",
        xticks = 0:2)
    freq_Y = [mean(ys_sim .== y) for y in 0:2]
    barplot!(ax2, 0:2, freq_Y; color = (:coral, 0.7), label = "simulación")
    scatter!(ax2, 0:2, p_Y; color = :red, markersize = 12, label = "exacta")
    axislegend(ax2; position = :rt)

    # Convergencia
    ax3 = Axis(fig[1, 3],
        title = "Convergencia de P̂(no crítica)",
        xlabel = "n simulaciones", ylabel = "probabilidad estimada")
    ns = 100:100:n_sim
    ps = [mean(xs_sim[1:n] .+ ys_sim[1:n] .<= 1) for n in ns]
    lines!(ax3, ns, ps; color = :steelblue, linewidth = 1.2)
    hlines!(ax3, [p_no_critica_exacta]; color = :red, linewidth = 2,
            linestyle = :dash, label = "exacta")
    axislegend(ax3; position = :rb)

    html = repr(MIME"text/html"(), fig)
    HTML("<div style='display:flex; justify-content:center'>$(html)</div>")
end

# ╔═╡ d1437f86-2867-4fc7-8d5d-eeefbceb5940
md"""
## Inferencia bayesiana: composición desconocida del lote

Hasta aquí usamos el modelo de manera **generativa**: dada la composición conocida del lote, estimamos probabilidades por simulación. Pero la programación probabilística brilla especialmente en el sentido inverso: **dado lo que observamos en la muestra, ¿qué podemos inferir sobre la composición del lote?**

Supongamos ahora que el auditor **no conoce** cuántos legajos de cada tipo hay en el lote. Solo sabe que hay ``N = 12`` en total. Después de revisar la muestra de 2, observa ``X = x`` moderados e ``Y = y`` altos. A partir de esta única observación, ¿qué puede decir sobre ``K_{\text{mod}}`` y ``K_{\text{alto}}``?

El modelo bayesiano tiene la estructura:

```math
K_{\text{mod}} \sim \text{Uniforme}(0, 12), \qquad K_{\text{alto}} \sim \text{Uniforme}(0, 12 - K_{\text{mod}})
```

```math
(X, Y) \mid K_{\text{mod}}, K_{\text{alto}} \sim \text{HipergeométricaMultivariada}
```

Y queremos calcular la distribución **posterior** ``P(K_{\text{mod}}, K_{\text{alto}} \mid X = x, Y = y)``.
"""

# ╔═╡ 3d003f4e-4fad-4c9a-8172-96bc97ed3205
md"### La observación"

# ╔═╡ 4a943ddd-f2ea-44ca-89a6-50b4624fe7e7
begin
    reset_nb
    md"""
    Composición de la muestra observada:

    Moderados ``X``: $(@bind x_obs Slider(0:2; default = 1, show_value = true)) | Altos ``Y``: $(@bind y_obs Slider(0:2; default = 1, show_value = true))
    """
end

# ╔═╡ 2b3fde87-b9e6-4d2e-a825-6ea3f707e876
md"""📌 Muestra observada: ``X =`` **$(x_obs)** moderado(s), ``Y =`` **$(y_obs)** alto(s), **$(2 - x_obs - y_obs)** bajo(s)."""

# ╔═╡ 0be8e76f-88e2-4424-b6bb-9dcd52bd301a
md"### El modelo de inferencia"

# ╔═╡ 6bc51a42-cbb7-4a47-a907-167e5b55067d
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_inf Switch(default = mostrar_comentarios))"

# ╔═╡ 3ba6948f-a5e0-41eb-89ec-bb6b2a90d280
if comentarios_inf
    md"""
    ```julia
    # Función auxiliar: log del coeficiente binomial, con manejo seguro de bordes
    function logbinom(n, k)
        (k < 0 || k > n || n < 0) && return -Inf
        return log(binomial(n, k))
    end

    # El modelo de inferencia tiene los parámetros latentes K_mod y K_alto.
    # `@addlogprob!` permite agregar manualmente la log-verosimilitud cuando
    # la distribución no está disponible como tipo estándar de Distributions.jl.
    @model function composicion_desconocida(x_obs, y_obs, N = 12, n = 2)
        # Priors uniformes discretos sobre la composición del lote
        K_mod  ~ DiscreteUniform(0, N)
        K_alto ~ DiscreteUniform(0, N - K_mod)
        K_bajo  = N - K_mod - K_alto

        z = n - x_obs - y_obs   # bajos en la muestra

        # Log-verosimilitud: hipergeométrica multivariada
        # log P(x_obs, y_obs | K_mod, K_alto) = log C(K_mod, x) + log C(K_alto, y)
        #                                      + log C(K_bajo, z) - log C(N, n)
        Turing.@addlogprob! (
            logbinom(K_mod,  x_obs) +
            logbinom(K_alto, y_obs) +
            logbinom(K_bajo, z)     -
            logbinom(N, n)
        )
    end
    ```
    """
else
    md"""
    ```julia
    function logbinom(n, k)
        (k < 0 || k > n || n < 0) && return -Inf
        return log(binomial(n, k))
    end

    @model function composicion_desconocida(x_obs, y_obs, N = 12, n = 2)
        K_mod  ~ DiscreteUniform(0, N)
        K_alto ~ DiscreteUniform(0, N - K_mod)
        K_bajo  = N - K_mod - K_alto

        z = n - x_obs - y_obs
        Turing.@addlogprob! (
            logbinom(K_mod,  x_obs) +
            logbinom(K_alto, y_obs) +
            logbinom(K_bajo, z)     -
            logbinom(N, n)
        )
    end
    ```
    """
end

# ╔═╡ 9da2d48d-a9ed-4faf-b775-e563234cbf5f
begin
    function logbinom(n, k)
        (k < 0 || k > n || n < 0) && return -Inf
        return log(binomial(n, k))
    end

    @model function composicion_desconocida(x_obs, y_obs, N = 12, n = 2)
        K_mod  ~ DiscreteUniform(0, N)
        K_alto ~ DiscreteUniform(0, N - K_mod)
        K_bajo  = N - K_mod - K_alto

        z = n - x_obs - y_obs
        Turing.@addlogprob! (
            logbinom(K_mod,  x_obs) +
            logbinom(K_alto, y_obs) +
            logbinom(K_bajo, z)     -
            logbinom(N, n)
        )
    end
end

# ╔═╡ 0c625861-e798-435f-97cc-fa502fdd8544
md"### Muestreo MCMC con Metropolis-Hastings"

# ╔═╡ ffbc6962-d0d0-4fcb-922b-cb80b9646ee6
md"""
Para parámetros **discretos** como ``K_{\text{mod}}`` y ``K_{\text{alto}}``, el algoritmo de **Metropolis-Hastings** (`MH()`) es una elección natural. En cada iteración propone un nuevo valor de los parámetros y lo acepta o rechaza según el cociente de verosimilitudes ponderado por el prior.

La distribución estacionaria de la cadena resultante es exactamente la distribución posterior ``P(K_{\text{mod}}, K_{\text{alto}} \mid X = x, Y = y)``.
"""

# ╔═╡ ccbfb5b0-de72-4917-a021-31f7b8526d57
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_mcmc Switch(default = mostrar_comentarios))"

# ╔═╡ 2529fbfe-78a6-4ff2-88ae-8830fca2f750
if comentarios_mcmc
    md"""
    ```julia
    # Instanciamos el modelo con la observación concreta.
    modelo_inf = composicion_desconocida(x_obs, y_obs)

    # `MH()` = Metropolis-Hastings. Para parámetros discretos es el
    # algoritmo más simple y robusto disponible en Turing.
    # `discard_initial`: descartamos las primeras iteraciones (burn-in),
    # que corresponden al período de calentamiento antes de la convergencia.
    cadena_post = sample(modelo_inf, MH(), 60_000;
                         discard_initial = 10_000, progress = false)

    # Extraemos las muestras como un DataFrame para facilitar el análisis
    df_post = DataFrame(cadena_post)
    K_mod_post  = Int.(df_post.K_mod)
    K_alto_post = Int.(df_post.K_alto)
    ```
    """
else
    md"""
    ```julia
    modelo_inf = composicion_desconocida(x_obs, y_obs)
    cadena_post = sample(modelo_inf, MH(), 60_000;
                         discard_initial = 10_000, progress = false)
    df_post = DataFrame(cadena_post)
    K_mod_post  = Int.(df_post.K_mod)
    K_alto_post = Int.(df_post.K_alto)
    ```
    """
end

# ╔═╡ 8cdb44b3-7133-4bfb-a431-b2a7df0aabb0
begin
    reset_nb
    Random.seed!(123)
    modelo_inf = composicion_desconocida(x_obs, y_obs)
    cadena_post = sample(modelo_inf, MH(), 60_000;
                         discard_initial = 10_000, progress = false)
    df_post = DataFrame(cadena_post)
    K_mod_post  = Int.(df_post.K_mod)
    K_alto_post = Int.(df_post.K_alto)
    md"✅ Cadena MCMC generada: **$(length(K_mod_post))** muestras posteriores."
end

# ╔═╡ 034d930a-caf7-4df2-825a-0caa0a64e163
md"### Diagnósticos de la cadena"

# ╔═╡ c472f384-597b-4677-aed0-c622c62658c2
md"""
Antes de interpretar los resultados, verificamos que la cadena haya **convergido**. Los indicadores clave son:
- **``\hat{R}`` (R-hat):** debería ser cercano a 1.0 (idealmente ``< 1.05``). Indica si distintas cadenas exploraron la misma distribución.
- **ESS (Effective Sample Size):** el número efectivo de muestras independientes. Queremos que sea alto relativo al total.
"""

# ╔═╡ 610ee9f8-0912-4cf5-a666-63b618c4c746
@info summarystats(cadena_post)

# ╔═╡ ea960b80-c956-4c90-9ad4-fe0b848cbb37
let
    n_traza = min(2000, length(K_mod_post))
    fig = Figure(size = (700, 280))

    ax1 = Axis(fig[1, 1], title = "Traza de K_mod",
               xlabel = "iteración", ylabel = "K_mod")
    lines!(ax1, 1:n_traza, K_mod_post[1:n_traza]; color = :steelblue, linewidth = 0.7)
    hlines!(ax1, [K.moderado]; color = :red, linestyle = :dash,
            linewidth = 1.5, label = "valor real ($(K.moderado))")
    axislegend(ax1)

    ax2 = Axis(fig[1, 2], title = "Traza de K_alto",
               xlabel = "iteración", ylabel = "K_alto")
    lines!(ax2, 1:n_traza, K_alto_post[1:n_traza]; color = :coral, linewidth = 0.7)
    hlines!(ax2, [K.alto]; color = :red, linestyle = :dash,
            linewidth = 1.5, label = "valor real ($(K.alto))")
    axislegend(ax2)

    html = repr(MIME"text/html"(), fig)
    HTML("<div style='display:flex; justify-content:center'>$(html)</div>")
end

# ╔═╡ 4e2d50c7-abb9-4846-ab0d-d220408df383
md"### Distribución posterior de la composición del lote"

# ╔═╡ 16e8858a-2a1e-44e6-88d6-adc28462ca29
let
    fig = Figure(size = (700, 300))

    ax1 = Axis(fig[1, 1],
        title = "P(K_mod | X=$(x_obs), Y=$(y_obs))",
        xlabel = "K_mod (nº de moderados en el lote)",
        ylabel = "probabilidad posterior")
    freq_km = [mean(K_mod_post .== k) for k in 0:12]
    barplot!(ax1, 0:12, freq_km; color = (:steelblue, 0.75))
    vlines!(ax1, [K.moderado]; color = :red, linestyle = :dash,
            linewidth = 2, label = "valor real ($(K.moderado))")
    axislegend(ax1)

    ax2 = Axis(fig[1, 2],
        title = "P(K_alto | X=$(x_obs), Y=$(y_obs))",
        xlabel = "K_alto (nº de altos en el lote)",
        ylabel = "probabilidad posterior")
    freq_ka = [mean(K_alto_post .== k) for k in 0:12]
    barplot!(ax2, 0:12, freq_ka; color = (:coral, 0.75))
    vlines!(ax2, [K.alto]; color = :red, linestyle = :dash,
            linewidth = 2, label = "valor real ($(K.alto))")
    axislegend(ax2)

    html = repr(MIME"text/html"(), fig)
    HTML("<div style='display:flex; justify-content:center'>$(html)</div>")
end

# ╔═╡ a6ecc322-8d51-41a7-9a4a-853e7312e3c2
let
    fig = Figure(size = (420, 340))
    ax = Axis(fig[1, 1],
        title = "Distribución posterior conjunta\nP(K_mod, K_alto | X=$(x_obs), Y=$(y_obs))",
        xlabel = "K_alto", ylabel = "K_mod")

    # Grilla de frecuencias
    Z = [mean((K_mod_post .== km) .& (K_alto_post .== ka))
         for km in 0:12, ka in 0:12]

    hm = heatmap!(ax, 0:12, 0:12, Z; colormap = :Blues)
    Colorbar(fig[1, 2], hm; label = "P(K_mod, K_alto | datos)")
    scatter!(ax, [K.alto], [K.moderado]; color = :red, markersize = 14,
             marker = :cross, strokewidth = 2, label = "valor real")
    axislegend(ax)

    html = repr(MIME"text/html"(), fig)
    HTML("<div style='display:flex; justify-content:center'>$(html)</div>")
end

# ╔═╡ 7965d759-1647-47c0-a665-e8b9a3abb04c
md"### Probabilidad predictiva posterior de muestra no crítica"

# ╔═╡ d98eecfc-e977-4d62-b809-e26847a83042
md"""
Una vez obtenida la distribución posterior ``P(K_{\text{mod}}, K_{\text{alto}} \mid \text{datos})``, podemos calcular la **probabilidad predictiva posterior** de que una *futura* muestra de 2 legajos sea "no crítica". Para ello, promediamos la probabilidad exacta del evento sobre todos los valores plausibles de la composición del lote, ponderados por la posterior:

```math
P(\text{no crítica} \mid \text{datos}) = \sum_{K_M, K_A} P(\text{no crítica} \mid K_M, K_A)\, P(K_M, K_A \mid \text{datos})
```
"""

# ╔═╡ 8fa80157-4ad1-4126-b49d-36747a5fa197
md"📎 *Mostrar comentarios en el código* $(@bind comentarios_pred Switch(default = mostrar_comentarios))"

# ╔═╡ 7ee1a530-937c-4c56-b208-1af1478e8169
if comentarios_pred
    md"""
    ```julia
    # Para cada composición posible (K_mod, K_alto), calculamos la probabilidad
    # exacta de que la muestra sea no crítica usando la hipergeométrica multivariada.
    function p_no_critica_dado(km, ka, N = 12, n = 2)
        kb = N - km - ka
        kb < 0 && return 0.0
        total = binomial(N, n)
        favorable = sum(
            binomial(km, x) * binomial(ka, y) * binomial(kb, n - x - y)
            for x in 0:min(km, n), y in 0:min(ka, n)
            if x + y <= 1 && n - x - y >= 0 && n - x - y <= kb
        )
        favorable / total
    end

    # La probabilidad predictiva posterior es el promedio MC:
    # E_{K_mod, K_alto ~ posterior}[P(no crítica | K_mod, K_alto)]
    p_predictiva = mean(
        p_no_critica_dado(K_mod_post[i], K_alto_post[i])
        for i in eachindex(K_mod_post)
    )
    ```
    """
else
    md"""
    ```julia
    function p_no_critica_dado(km, ka, N = 12, n = 2)
        kb = N - km - ka
        kb < 0 && return 0.0
        total = binomial(N, n)
        favorable = sum(
            binomial(km, x) * binomial(ka, y) * binomial(kb, n - x - y)
            for x in 0:min(km, n), y in 0:min(ka, n)
            if x + y <= 1 && n - x - y >= 0 && n - x - y <= kb
        )
        favorable / total
    end

    p_predictiva = mean(
        p_no_critica_dado(K_mod_post[i], K_alto_post[i])
        for i in eachindex(K_mod_post)
    )
    ```
    """
end

# ╔═╡ 14c60f8e-ca0a-4740-8936-08446aed103b
begin
    function p_no_critica_dado(km, ka, N = 12, n = 2)
        kb = N - km - ka
        kb < 0 && return 0.0
        total = binomial(N, n)
        favorable = sum(
    		binomial(km, x) * binomial(ka, y) * binomial(kb, n - x - y)
    		for x in 0:min(km, n), y in 0:min(ka, n)
    		if x + y <= 1 && n - x - y >= 0 && n - x - y <= kb;
    		init = 0
		)

        Float64(favorable) / total
    end

    p_predictiva = mean(
        p_no_critica_dado(K_mod_post[i], K_alto_post[i])
        for i in eachindex(K_mod_post)
    )

    md"""
    | Enfoque | Probabilidad P(no crítica) |
    |:---|:---:|
    | **Exacta** (composición conocida: 5B / 4M / 3A) | $(round(p_no_critica_exacta, digits = 5)) |
    | **Simulación generativa** (prior predictive, $(n_sim) muestras) | $(round(p_no_critica_sim, digits = 5)) |
    | **Predictiva posterior** (dado ``X=$(x_obs), Y=$(y_obs)``) | $(round(p_predictiva, digits = 5)) |
    """
end

# ╔═╡ 957bba8e-0af4-4418-8f20-b6da032b68c2
md"""
## Comparación de enfoques

Este notebook ilustró tres usos de las distribuciones de probabilidad y la programación probabilística para el mismo problema:

| Enfoque | Herramienta principal | Cuándo usarlo |
|:---|:---|:---|
| Distribución exacta | `Distributions.jl` | Composición del lote **conocida**, distribución analíticamente tratable |
| Simulación generativa | `Turing.@model` + simulación directa | Cuando la distribución exacta es compleja pero el proceso generativo es claro |
| Inferencia bayesiana | `Turing.@model` + `MH()` + MCMC | Cuando los parámetros del lote son **desconocidos** y queremos inferirlos |

La **programación probabilística** agrega mayor valor cuando:
- La composición del lote es incierta y queremos cuantificar esa incertidumbre.
- El proceso generativo es complejo y las distribuciones exactas son difíciles de derivar.
- Queremos propagar la incertidumbre sobre los parámetros hasta las predicciones finales.

En este problema particular, la distribución exacta es tratable y la inferencia bayesiana con una sola observación deja mucha incertidumbre (como muestran las distribuciones posteriores amplias). Sin embargo, el marco se generaliza directamente a problemas con múltiples muestras, composiciones desconocidas y modelos más ricos.
"""

# ╔═╡ Cell order:
# ╟─4c1e85d0-3b2a-11f1-bd16-eda20a106e5a
# ╟─3c857cc2-02cc-4216-b7b3-9472c6c74a3e
# ╟─8dd8fdbf-7300-49e7-b379-df4f867f61db
# ╟─23e1647f-6f10-44cd-986a-5c0112c4e34e
# ╟─f9a4a68e-d446-4ee6-b0bb-bf8ad35d8212
# ╟─8db0d717-79a9-4f97-b0b2-23fe4224f0c7
# ╟─ebaa400d-2c21-4935-856a-5b9d6f390789
# ╟─ed41711c-61fa-4e3b-8c54-95338582e99a
# ╟─8f7aac09-9c38-47ef-817a-dd3e3d2a44b8
# ╟─96216b2c-5556-4840-8851-a09e19a30810
# ╟─ebe56794-9897-4233-83b6-6d378801fd45
# ╟─f14886d2-9144-4b86-8421-6d58cb5f7e07
# ╟─c6b9bbcd-8b92-4be3-adf5-76f9e338eaed
# ╟─f8fe8639-80fe-4c9c-b457-bf80219fd880
# ╠═993d403c-0320-4ab9-8319-49b290fb90ad
# ╟─dc97a3bb-25f5-44fa-94c1-cfa4d38f5773
# ╟─28bb7135-105c-427e-a497-a828f4f9a8da
# ╟─53c56147-78d0-4c5d-ab9e-8e0cae0c7e4f
# ╟─f4bcd6a9-44b5-4b08-a386-958daa9c872a
# ╟─163312e1-866e-4209-a4f3-3da2f01971c9
# ╟─80910dd8-05d6-48f4-a191-c79a1825b573
# ╟─fa9c8834-92cf-4534-9430-5e19fe3c39cb
# ╟─1a0153ca-8299-4ca0-b927-31e6f45e7670
# ╟─229bcc7e-13cf-46d3-9876-f4e691bf5203
# ╟─58308bd1-932f-41d8-a567-27962aa06f62
# ╟─b444fd43-d913-4007-8149-9de2206ed209
# ╟─4181c552-8d3c-475c-af9c-f7f6ba51b1f5
# ╟─b4eb2981-8648-404f-951c-02361a6939e5
# ╟─253418a0-ba99-47d6-bded-9e59243514c9
# ╟─d1437f86-2867-4fc7-8d5d-eeefbceb5940
# ╟─3d003f4e-4fad-4c9a-8172-96bc97ed3205
# ╟─4a943ddd-f2ea-44ca-89a6-50b4624fe7e7
# ╟─2b3fde87-b9e6-4d2e-a825-6ea3f707e876
# ╟─0be8e76f-88e2-4424-b6bb-9dcd52bd301a
# ╟─6bc51a42-cbb7-4a47-a907-167e5b55067d
# ╟─3ba6948f-a5e0-41eb-89ec-bb6b2a90d280
# ╟─9da2d48d-a9ed-4faf-b775-e563234cbf5f
# ╟─0c625861-e798-435f-97cc-fa502fdd8544
# ╟─ffbc6962-d0d0-4fcb-922b-cb80b9646ee6
# ╟─ccbfb5b0-de72-4917-a021-31f7b8526d57
# ╟─2529fbfe-78a6-4ff2-88ae-8830fca2f750
# ╟─8cdb44b3-7133-4bfb-a431-b2a7df0aabb0
# ╟─034d930a-caf7-4df2-825a-0caa0a64e163
# ╟─c472f384-597b-4677-aed0-c622c62658c2
# ╟─610ee9f8-0912-4cf5-a666-63b618c4c746
# ╟─ea960b80-c956-4c90-9ad4-fe0b848cbb37
# ╟─4e2d50c7-abb9-4846-ab0d-d220408df383
# ╟─16e8858a-2a1e-44e6-88d6-adc28462ca29
# ╟─a6ecc322-8d51-41a7-9a4a-853e7312e3c2
# ╟─7965d759-1647-47c0-a665-e8b9a3abb04c
# ╟─d98eecfc-e977-4d62-b809-e26847a83042
# ╟─8fa80157-4ad1-4126-b49d-36747a5fa197
# ╟─7ee1a530-937c-4c56-b208-1af1478e8169
# ╟─14c60f8e-ca0a-4740-8936-08446aed103b
# ╟─957bba8e-0af4-4418-8f20-b6da032b68c2
