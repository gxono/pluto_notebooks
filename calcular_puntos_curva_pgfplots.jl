using Contour
using Printf


function area_indices(pts::Matrix{Float64}, idx_start::Int, idx_end::Int)
    s = 0.0

    @inbounds for i in idx_start:(idx_end-1)
        s += pts[i, 1] * pts[i+1, 2] - pts[i+1, 1] * pts[i, 2]
    end

    @inbounds s += pts[idx_end, 1] * pts[idx_start, 2] - pts[idx_start, 1] * pts[idx_end, 2]

    return abs(s * 0.5)
end



function puntosEn(f::Function, x::AbstractVector, y::AbstractVector)
    z = [f(xi, yi) for xi in x, yi in y]
    cnt = Contour.contour(x, y, z, 0.0)
    lista_puntos = Vector{Matrix{Float64}}()

    for line in Contour.lines(cnt)
        xs, ys = coordinates(line)
        push!(lista_puntos, hcat(xs, ys))
    end

    if !isempty(lista_puntos)
        println("Puntos en el primer contorno: ", size(lista_puntos[1], 1))
    end

    return lista_puntos
end



function samplesEn(PUNTOS::Vector{Matrix{Float64}}, errMax::Float64=0.01)
    SAMPLES = Vector{Matrix{Float64}}()
    n_total = length(PUNTOS)

    for (i, pts) in enumerate(PUNTOS)
        push!(SAMPLES, samplesAt_opt(pts, errMax, i, n_total))
    end
    return SAMPLES
end



function samplesAt_opt(pts::Matrix{Float64}, errMax::Float64, m_actual::Int, m_total::Int)
    nPuntos = size(pts, 1)
    pos = 1

    output_buffer = Vector{Float64}()
    sizehint!(output_buffer, nPuntos)

    push!(output_buffer, pts[1, 1])
    push!(output_buffer, pts[1, 2])

    while pos < nPuntos
        dx = 2
        while (pos + dx < nPuntos) && (area_indices(pts, pos, pos + dx) <= errMax)
            dx += 1
        end

        idx_final = pos + dx
        if idx_final >= nPuntos
            push!(output_buffer, pts[nPuntos, 1])
            push!(output_buffer, pts[nPuntos, 2])
            break
        else
            idx_save = pos + dx - 1
            push!(output_buffer, pts[idx_save, 1])
            push!(output_buffer, pts[idx_save, 2])
            pos = idx_save
        end
    end

    n_out = length(output_buffer) ÷ 2
    mat_out = reshape(output_buffer, 2, n_out)'

    final_mat = Matrix{Float64}(mat_out)

    println("Muestra [$m_actual|$m_total]: $(nPuntos) -> $(n_out) puntos.")
    return final_mat
end

function getAddplotCode(SAMPLES, nCifras=3)
    buf = IOBuffer()

    write(buf, "______________________________________________________________\n")
    write(buf, "----------------------[pgfplots code]-------------------------\n\n")

    for lista in SAMPLES
        nSamples = size(lista, 1)
        write(buf, "\\addplot+[smooth] coordinates {")
        for i in 1:nSamples
            x_str = string(round(lista[i, 1], digits=nCifras))
            y_str = string(round(lista[i, 2], digits=nCifras))
            write(buf, "($x_str,$y_str)")
        end
        write(buf, "};\n\n")
    end

    write(buf, "______________________________________________________________\n")

    print(String(take!(buf)))
end

#------------------------------------------------------------------------------
# Ejecución
#------------------------------------------------------------------------------

f(x, y) = y - (15*x^4-15*x^2)

const N = 10000
x = range(-2, 2, length=N)
y = range(-4, 4, length=N)

println("Generando contornos y simplificando...")
@time begin
    DOTS = puntosEn(f, x, y)
    SAM = samplesEn(DOTS, 0.005)
end

getAddplotCode(SAM, 3)

