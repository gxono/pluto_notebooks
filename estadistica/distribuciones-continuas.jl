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

# ╔═╡ 8730ee14-2daf-4a9b-9461-693cbd2bdc52
begin
using Pkg
Pkg.add(["Distributions", "StatsPlots", "PlutoUI"])
using Distributions, StatsPlots, PlutoUI
end

# ╔═╡ 8c759a6e-382c-11f1-84e0-c38cddbc3935
md"# Distribuciones continuas"

# ╔═╡ 2add8de8-1822-444a-a1e7-692d58bbeae5
md"## Carga de paquetes"

# ╔═╡ 469ea16e-2cef-48c1-8c6e-32d182cb5a4f
md"## Distribución normal"

# ╔═╡ 90ca68cc-0901-49dc-b5a8-a792fe87fd2f
md"Media (μ): $(@bind mu Slider(-3.0:0.1:3.0, default=0.0, show_value=true))"

# ╔═╡ 72627f6f-4fab-4026-b7fd-0303922c4ef0
md"Desviación estándar (σ): $(@bind sigma Slider(0.5:0.01:3.0, default=1.0, show_value=true))"

# ╔═╡ a44abb2b-0432-4292-81d6-7328aca816f9
md"""
```julia
plot(Normal(μ, σ))
```
"""

# ╔═╡ 929b691c-752c-4764-a1cd-8cb10730c7c3
begin
	StatsPlots.plot(Normal(mu, sigma),
		legend = false,
		xlims = (-5, 5),
		ylims = (0, 1),
		linewidth = 2, 
		fill = true, 
		alpha = 0.3)

	vline!([mu])
end

# ╔═╡ 718080c9-dbff-4d07-bbf8-8f20de797d70
md"## Distribucion Uniforme"

# ╔═╡ 0c0d49eb-77aa-4e24-8eca-377836aa9d87
md"a : $(@bind uniforme_a Slider(-5:0.1:-0.1, default=1.0, show_value=true))"

# ╔═╡ ffd33fe2-f41c-481a-a68b-9a954fbb7ff9
md"b : $(@bind uniforme_b Slider(0.1:0.1:5.0, default=1.0, show_value=true))"

# ╔═╡ d6e0242f-370f-424d-9b77-fe230860f488
begin
plot(Uniform(uniforme_a, uniforme_b), 
	legend = false, 
	xlims = (-6,6), ylims = (0,1),
	linewidth = 2,
	fill = true,
	alpha = 0.3)
vline!([mean(Uniform(uniforme_a, uniforme_b))])
end

# ╔═╡ d70d210c-6088-4de6-aa6e-01bb1491408c
md"## Distribucion Gamma"

# ╔═╡ 05b757e2-ccda-4ff4-9cf7-1bd93ba478b0
md"Alfa (α): $(@bind alpha Slider(0.1:0.1:5.0, default=1.0, show_value=true))"

# ╔═╡ 03d93604-827f-49e2-82f3-94fcdda4c4e2
md"Beta (β): $(@bind beta Slider(0.01:0.01:1.0, default=1.0, show_value=true))"

# ╔═╡ 08468583-f772-47bf-8754-a9eb81e18608
begin
plot(Gamma(alpha, beta), 
	legend = false, 
	xlims = (0,1), ylims = (0, 5),
	linewidth = 2,
	fill = true,
	alpha = 0.3)
vline!([mean(Gamma(alpha, beta))])
end

# ╔═╡ dedc74cf-b944-4e83-89c9-7d8924b37740
md"## Distribucion Beta"

# ╔═╡ e20a8e82-8f10-4f6e-af29-9c5e5a4d801b
md"Alfa (Bα): $(@bind beta_alpha Slider(0.1:0.1:5.0, default=1.0, show_value=true))"

# ╔═╡ 9c632a46-ac05-4710-9506-dc4f99222926
md"Beta (Bβ): $(@bind beta_beta Slider(0.1:0.1:5.0, default=1.0, show_value=true))"

# ╔═╡ b30ae5bc-f266-4a62-960c-79095a43cbf4
begin
plot(Beta(beta_alpha, beta_beta), 
	legend = false, 
	xlims = (0,1), ylims = (0, 5),
	linewidth = 2,
	fill = true,
	alpha = 0.3)
vline!([mean(Beta(beta_alpha, beta_beta))])
end

# ╔═╡ 66803f5e-ba9f-4454-99c4-9eeeec7aa538
md"## Distribucion exponencial"

# ╔═╡ 0b090ce3-3a18-4094-919c-d75e4b06b0ce
md"Beta (Bβ): $(@bind exponencial_beta Slider(0.01:0.01:1.0, default=1.0, show_value=true))"

# ╔═╡ 260d3ebf-2ec7-40cd-b6b4-5a98f478889d
begin
plot(Exponential(exponencial_beta), 
	legend = false, 
	xlims = (0,1), ylims = (0, 5),
	linewidth = 2,
	fill = true,
	alpha = 0.3)
vline!([mean(Exponential(exponencial_beta))])
end

# ╔═╡ 50906917-fb79-4115-aa6b-d1722677602f
md"## Distribucion χ²"

# ╔═╡ babb6e0c-5676-4f4f-bc9a-9861e53a6313
md"Nu (ν): $(@bind chisq_nu Slider(1:10, default=1, show_value=true))"

# ╔═╡ 1ea1d756-ca02-44ee-a5f5-a1d47d746f17
begin
plot(Chisq(chisq_nu), 
	legend = false, 
	xlims = (0,10), ylims = (0, 0.3),
	linewidth = 2,
	fill = true,
	alpha = 0.3)
vline!([mean(Chisq(chisq_nu))])
end

# ╔═╡ Cell order:
# ╟─8c759a6e-382c-11f1-84e0-c38cddbc3935
# ╟─2add8de8-1822-444a-a1e7-692d58bbeae5
# ╠═8730ee14-2daf-4a9b-9461-693cbd2bdc52
# ╟─469ea16e-2cef-48c1-8c6e-32d182cb5a4f
# ╟─90ca68cc-0901-49dc-b5a8-a792fe87fd2f
# ╟─72627f6f-4fab-4026-b7fd-0303922c4ef0
# ╟─a44abb2b-0432-4292-81d6-7328aca816f9
# ╟─929b691c-752c-4764-a1cd-8cb10730c7c3
# ╟─718080c9-dbff-4d07-bbf8-8f20de797d70
# ╟─0c0d49eb-77aa-4e24-8eca-377836aa9d87
# ╟─ffd33fe2-f41c-481a-a68b-9a954fbb7ff9
# ╟─d6e0242f-370f-424d-9b77-fe230860f488
# ╟─d70d210c-6088-4de6-aa6e-01bb1491408c
# ╟─05b757e2-ccda-4ff4-9cf7-1bd93ba478b0
# ╟─03d93604-827f-49e2-82f3-94fcdda4c4e2
# ╟─08468583-f772-47bf-8754-a9eb81e18608
# ╟─dedc74cf-b944-4e83-89c9-7d8924b37740
# ╟─e20a8e82-8f10-4f6e-af29-9c5e5a4d801b
# ╟─9c632a46-ac05-4710-9506-dc4f99222926
# ╟─b30ae5bc-f266-4a62-960c-79095a43cbf4
# ╟─66803f5e-ba9f-4454-99c4-9eeeec7aa538
# ╟─0b090ce3-3a18-4094-919c-d75e4b06b0ce
# ╟─260d3ebf-2ec7-40cd-b6b4-5a98f478889d
# ╟─50906917-fb79-4115-aa6b-d1722677602f
# ╟─babb6e0c-5676-4f4f-bc9a-9861e53a6313
# ╟─1ea1d756-ca02-44ee-a5f5-a1d47d746f17
