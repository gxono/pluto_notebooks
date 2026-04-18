### A Pluto.jl notebook ###
# v0.20.24

using Markdown
using InteractiveUtils

# ╔═╡ 098e7000-3ad9-11f1-97aa-455c60c90ba2
using StatsBase

# ╔═╡ 48a69060-9a4d-4455-a9fa-07fcc44f9826
using Combinatorics

# ╔═╡ 5e280594-198d-4aaa-8914-8b10a7e22e14
md"## Librerías"

# ╔═╡ f2938e69-bcd4-4a41-b8aa-4844087fe5c6
md"*Una versión mucho más detallada es la del fichero* `legajos-bancarios.jl`"

# ╔═╡ c339aefe-d943-4402-a56c-a74494a5bb43
md"## El objeto \"Legajo\""

# ╔═╡ a9dba008-aa35-4018-97d9-89760f7c98ac
mutable struct Legajo
	tipo::Symbol
end

# ╔═╡ 73b9b380-f2f6-40e8-83aa-55e6d77f6cbc
md"## Los legajos"

# ╔═╡ 965f51e0-d0f0-4bb1-8f7b-dc6f6790c495
riesgos = (bajo = 5, moderado = 4, alto = 3)

# ╔═╡ bcfa91e7-c31a-4c9d-8e22-fafbd4e533b5
legajos = [Legajo(riesgo)
	for (riesgo, cantidad) in pairs(riesgos)
	for _ in 1:cantidad]

# ╔═╡ 7e2282be-b82f-4919-8fce-08c1c0170fc6
md"## Espacio muestral"

# ╔═╡ e21d1ab2-3177-4c8a-94d0-fb4dd4041876
espacio_muestral = combinations(legajos, 2) |> collect

# ╔═╡ 26780aae-1793-4be3-be02-5399db77651d
md"## Las muestras"

# ╔═╡ f34deb34-d49e-47b2-a5a6-8827053e5f18
cantidad_muestras = 10

# ╔═╡ 0b5deb50-3350-443f-be80-f5f23b4400fd
repeticiones = sample(espacio_muestral, cantidad_muestras)

# ╔═╡ 267b7631-7e19-475e-9085-cc1f1cc6b2de
md"## Funciones útiles"

# ╔═╡ cfed243e-4354-456b-8d9d-12d42091fbea
function satisface_xy(observacion, x, y)
	count(l -> l.tipo == :moderado, observacion) == x &&
	count(l -> l.tipo == :alto,  observacion) == y
end

# ╔═╡ c298526d-a8c3-4ae7-951d-19948539f3b8
function contar_xy(repeticiones, x, y)
	return count(m -> satisface_xy(m, x, y), repeticiones)
end

# ╔═╡ 22ef5d2c-6bc5-462b-a7b8-7a3e797f7b85
contar_xy(repeticiones, 1, 0) #riesgo moderado pero no alto.

# ╔═╡ e0b26c31-98c6-49bc-a595-41fd37e27b4c
md"## Frecuencias"

# ╔═╡ 1803922f-8608-47c8-a1bc-f71d63539276
frecuencias_xy = [
	contar_xy(repeticiones, x, y) // length(repeticiones)
	for x in 0:2, y in 0:2]

# ╔═╡ 01cc0cd2-454d-4f5a-8f48-a144402d3d41
Float64.(frecuencias_xy) # Expresión decimal

# ╔═╡ 99f899a0-46d2-4858-aeae-e798595c0594
marginal_x = [sum(frecuencias_xy[x, :]) for x in 1:3]

# ╔═╡ 201cdaa8-abd3-4c5b-821d-13b4a35e3579
marginal_y = [sum(frecuencias_xy[:, y]) for y in 1:3]

# ╔═╡ 06a9107d-910d-4c13-bec6-dc29f39827ce
md"## Sandbox"

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Combinatorics = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
Combinatorics = "~1.1.0"
StatsBase = "~0.34.10"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.6"
manifest_format = "2.0"
project_hash = "a6f8fd6cd46403d406716268e7d6cf1d82526542"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Combinatorics]]
git-tree-sha1 = "c761b00e7755700f9cdf5b02039939d1359330e1"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.1.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.3.0+1"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["OrderedCollections"]
git-tree-sha1 = "e86f4a2805f7f19bec5129bc9150c38208e5dc23"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.19.4"

[[deps.DocStringExtensions]]
git-tree-sha1 = "7442a5dfe1ebb773c29cc2962a8980f47221d76c"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.5"

[[deps.IrrationalConstants]]
git-tree-sha1 = "b2d91fe939cae05960e760110b328288867b5758"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.6"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.12.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "13ca9e2586b89836fd20cccf56e57e2b9ae7f38f"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.29"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.29+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "05868e21324cede2207c6f0f466b4bfef6d5e7ee"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.PtrArrays]]
git-tree-sha1 = "4fbbafbc6251b883f4d2705356f3641f3652a7fe"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.4.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "64d974c2e6fdf07f8155b5b2ca2ffa9069b608d9"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.2"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.12.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "178ed29fd5b2a2cfc3bd31c13375ae925623ff36"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.8.0"

[[deps.StatsBase]]
deps = ["AliasTables", "DataAPI", "DataStructures", "IrrationalConstants", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "aceda6f4e598d331548e04cc6b2124a6148138e3"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.10"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.8.3+2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"
"""

# ╔═╡ Cell order:
# ╟─5e280594-198d-4aaa-8914-8b10a7e22e14
# ╟─f2938e69-bcd4-4a41-b8aa-4844087fe5c6
# ╠═098e7000-3ad9-11f1-97aa-455c60c90ba2
# ╠═48a69060-9a4d-4455-a9fa-07fcc44f9826
# ╟─c339aefe-d943-4402-a56c-a74494a5bb43
# ╠═a9dba008-aa35-4018-97d9-89760f7c98ac
# ╟─73b9b380-f2f6-40e8-83aa-55e6d77f6cbc
# ╠═965f51e0-d0f0-4bb1-8f7b-dc6f6790c495
# ╠═bcfa91e7-c31a-4c9d-8e22-fafbd4e533b5
# ╟─7e2282be-b82f-4919-8fce-08c1c0170fc6
# ╠═e21d1ab2-3177-4c8a-94d0-fb4dd4041876
# ╟─26780aae-1793-4be3-be02-5399db77651d
# ╠═f34deb34-d49e-47b2-a5a6-8827053e5f18
# ╠═0b5deb50-3350-443f-be80-f5f23b4400fd
# ╟─267b7631-7e19-475e-9085-cc1f1cc6b2de
# ╠═cfed243e-4354-456b-8d9d-12d42091fbea
# ╠═c298526d-a8c3-4ae7-951d-19948539f3b8
# ╠═22ef5d2c-6bc5-462b-a7b8-7a3e797f7b85
# ╟─e0b26c31-98c6-49bc-a595-41fd37e27b4c
# ╠═1803922f-8608-47c8-a1bc-f71d63539276
# ╠═01cc0cd2-454d-4f5a-8f48-a144402d3d41
# ╠═99f899a0-46d2-4858-aeae-e798595c0594
# ╠═201cdaa8-abd3-4c5b-821d-13b4a35e3579
# ╟─06a9107d-910d-4c13-bec6-dc29f39827ce
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
