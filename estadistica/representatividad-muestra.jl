### A Pluto.jl notebook ###
# v0.20.24

using Markdown
using InteractiveUtils

# ╔═╡ c8e9c980-d48c-11f0-913c-f16d46a8dac3
begin
	using Pkg
	paquetes = ["Images", "ImageTransformations"]
	Pkg.add(paquetes)
	
	using Images, ImageTransformations
	
	image_url = "https://i.ytimg.com/vi/AULuSQsNrEM/maxresdefault.jpg"
	image_file = download(image_url)
	image = load(image_file)
	@info string("Dimensión: ", size(image))
	@info string("Cantidad de pixeles: ", prod(size(image)))
end;

# ╔═╡ a275b13b-6e6d-4f15-b7c2-22071427b9db
md"""
# Sobre la representatividad de una muestra

A la hora de recoger datos para obtener conclusiones, la estadística se ve obligada a interactuar con la población objetivo (aquella sobre la cual se realizará la medición). El inconveniente es que, en la mayoría de los casos, no es posible tener acceso a la población completa, ya sea porque es costoso o es imposible, y es por esto por lo que se debe trabajar sobre una muestra, es decir, un subconjunto de esta población. Ahora bien, ¿un mayor número de individuos en una muestra que en otra garantiza de alguna manera que las conclusiones que se obtengan de la primera tengan más fiabilidad que las de la segunda?

La respuesta rápida y sin rodeos es que no. Puede que nos sintamos inclinados a pensar que (salvo por las deudas y alguna que otra cosa) más es mejor. En muchos aspectos es necesario definir qué es eso de lo que se necesita de "más" para que algo sea mejor. Particularmente, que una muestra tenga más tamaño que otra no garantiza que sea mejor. Esto es así porque una muestra, para considerarse como tal, debe poseer las siguientes tres características:
 - Aleatoriedad: Le da el carácter de objetividad a la elección.
 - Representatividad: La muestra debe representar los distintos estamentos de la población.
 - Tamaño suficiente: Se obtiene de acuerdo al tipo de muestreo y al objetivo del estudio

En esta entrada no pretendo enfocarme en los tipos de muestreo, sino que vamos a simular una situación e ilustrar con un ejemplo visual como para mismos tamaños de muestra, la credibilidad de las conclusiones que se pueden tomar están más o menos garantizadas dependiendo de la forma en la que se tome la muestra.

Como algunos sabrán, una imagen digital no es otra cosa que una matriz de colores. A mayor resolución, mayor número de elementos. Así, por ejemplo, una imagen de 800 × 600 pixeles es una matrix 480.000 componentes, donde cada una es un color. Pues bien, supongamos que tenemos una imagen de $(size(image)[1]) × $(size(image)[2]) pixeles.
"""

# ╔═╡ 58014dfa-4908-4ffd-b4ed-16fa6e39a982
begin
	dh = 16; dv = 9
	ih = 780; iv = 140
	factor = [1, 2, 3] # Raíces de factores de incremento. 
	
	@info "Muestra de $(dh * dv) individuos."
	image[iv:(iv + dv-1), ih:(ih + dh-1)]
end

# ╔═╡ 1dbe97f7-3f7a-4efb-92af-b40776643342
md"""
Esto representa una población total de $(prod(size(image))) píxeles. Supongamos que nos interesa conocer la imagen, o características de ella, pero no nos es posible acceder a toda la población, por lo que es necesario recurrir a una muestra. Veamos si una muestra no aleatoria de $(dh * dv) ( $(dh) × $(dv) ) pixeles nos es suficiente para obtener alguna caractéristica.
"""

# ╔═╡ 0e278769-f778-429a-a9ec-90929b720e47
md"""
A partir de ella se deberíamos extraer algunas conclusiones que nos permitieran caracterizar la imagen total. A primera vista, no parece haber un patrón que nos indique algo sobre la imagen. Sí parece haber un cambio de color, pero esto no resulta suficiente para describir la imagen total. Podríamos intentar tomar una muestra aproximadamente cuatro veces mayor y ver qué ocurre. Así, si la población es de $(dh * dv * factor[2]^2) tenemos lo siguiente:
"""

# ╔═╡ 3e907fd1-d308-4a9e-bdba-ab71283dcbea
begin
	@info "Muestra de $(dh * dv * factor[2]^2) individuos."
	image[iv:(iv + dv * factor[2] - 1), ih:(ih + dh * factor[2] - 1)]
end

# ╔═╡ f77c35c4-39ed-41ea-923d-5edc269c0e4b
md"""
Aquí empiezan a aparecer algunas líneas que nos pueden llegar a dar una idea de que se trata de un ojo. La forma que aparecía en la muestra anterior aparece más definida. Pese a esto, sigue saberse de quién se trata, así que vamos a aumentar el tamaño de la muestra una vez más. Para una población de $(dh * dv * factor[3]^2) individuos se tiene:
"""

# ╔═╡ f00ee007-d719-454b-869f-738f99184f10
begin
	@info "Muestra de $(dh * dv * factor[3]^2) individuos."
	image[iv:(iv + dv * factor[3] - 1), ih:(ih + dh * factor[3] - 1)]
end

# ╔═╡ e8fdcb34-4077-4329-8302-4359701bf82c
md"""
El asunto no ha mejorado mucho, y podría considerarse que el tamaño de muestra es excesivo para tan poca información y no compensa seguir aumentando el tamaño. Pero, ¿qué ocurre si cambiamos el tipo de muestreo? Pues bien, volvamos a la imagen total y tomemos muestra de $(dh * dv) individuos como se hizo la primera vez, pero ahora de manera aleatoria.
"""

# ╔═╡ e1a4e302-b073-4924-912a-d98b7418d78e
begin
	@info "Muestra de $(dh * dv) individuos."
	imresize(image, (dv, dh))
end


# ╔═╡ 23d81fad-2b1b-4ad8-a657-5b97fa3bba3f
md"""
A partir de ahora nos es posible distinguir un relieve más nítido de lo que ocupa la imagen. Si entrecerramos los ojos para que la imagen se vuelva borrosa o nos alejamos de la misma es posible conjeturar que se trata de las siluetas de dos personas. Si tomamos una muestra de igual manera, pero de $(dh * dv * factor[2]^2) individuos y de $(dh * dv * factor[3]^2), como se hizo previamente, se tienen las dos imágenes siguientes:
"""

# ╔═╡ 1410f9ef-0ad9-4181-bbb7-649c897a3942
let
	@info "Muestra de $(dh * dv * factor[2]^2) individuos."
	imresize(image, (dv * factor[2], dh * factor[2]))
end

# ╔═╡ cf7642e7-c9dd-4208-b47e-1c6fa2115477
let
	@info "Muestra de $(dh * dv * factor[3]^2) individuos."
	imresize(image, (dv * factor[3], dh * factor[3]))
end

# ╔═╡ 55002538-9836-4adf-b79d-bf7e67545562
md"""
Algunas o algunos de ustedes seguramente ya con $(dh * dv * factor[2]^2) muestras se hayan dado cuenta de que se trata de Frodo y Gandalf.
"""

# ╔═╡ 270e07f6-f1f1-4dc4-9679-d93f622e29e2
image

# ╔═╡ a6e1dd8c-cba3-4a16-8920-d9862e1193a4
md"""
Las conclusiones a las que accedimos a partir de los primeros $(dh * dv * factor[1]^2) individuos de la muestra aleatoria no estaban alejadas de la realidad. Lo curioso de esto es que las obtuvimos para una población que es aproximadamente $(round(Int, prod(size(image))/(dh * dv))) veces más grande que esta muestra! Una forma de verlo es la siguiente: supongamos que el tamaño de muestra representa un segundo, entonces la población total serían $(round(prod(size(image))/(dh * dv)/60^2, digits = 2)) horas! Basta con un segundo para tener una idea de que ocurre en el transcurso de casi dos horas! Evidentemente nos estamos yendo demasiado del contexto, pero no deja de ser curiosa la proporción. Claro, como ocurre con las muestras, debería tomarse este segundo de una manera poco convencional. Si tomamos un segundo de manera continua nos hallaríamos en el caso de la muestra no aleatoria. En cambio, si tomamos centésimas de segundo distribuidas de manera aleatoria en todo el intervalo de tiempo podríamos garantizar que vamos por buen camino.

A modo de conclusión pregunto: ¿acaso no nos ha dado más información sobre la estructura de la imagen la segunda muestra de $(dh * dv * factor[1]^2) individuos que la primera de $(dh * dv * factor[3]^2) que tenía alrededor de 10 veces más? Pues bien, es ahí donde se evidencian dos cosas:

1. La importancia de elegir un tipo de muestreo acorde a las necesidades y
2. que no es suficiente un tamaño de muestra excesivo para garantizar conclusiones fehacientes.
"""

# ╔═╡ Cell order:
# ╟─a275b13b-6e6d-4f15-b7c2-22071427b9db
# ╠═c8e9c980-d48c-11f0-913c-f16d46a8dac3
# ╟─1dbe97f7-3f7a-4efb-92af-b40776643342
# ╠═58014dfa-4908-4ffd-b4ed-16fa6e39a982
# ╟─0e278769-f778-429a-a9ec-90929b720e47
# ╠═3e907fd1-d308-4a9e-bdba-ab71283dcbea
# ╟─f77c35c4-39ed-41ea-923d-5edc269c0e4b
# ╠═f00ee007-d719-454b-869f-738f99184f10
# ╟─e8fdcb34-4077-4329-8302-4359701bf82c
# ╠═e1a4e302-b073-4924-912a-d98b7418d78e
# ╟─23d81fad-2b1b-4ad8-a657-5b97fa3bba3f
# ╠═1410f9ef-0ad9-4181-bbb7-649c897a3942
# ╠═cf7642e7-c9dd-4208-b47e-1c6fa2115477
# ╟─55002538-9836-4adf-b79d-bf7e67545562
# ╠═270e07f6-f1f1-4dc4-9679-d93f622e29e2
# ╟─a6e1dd8c-cba3-4a16-8920-d9862e1193a4
