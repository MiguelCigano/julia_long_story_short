# Rutas de archivos
txt_path = "multiaccount_scripts/test_multi_julia/traducciones"         # Archivo con msgid y msgstr
input_po_file = "multiaccount_scripts/test_multi_julia/ko_KR.po"  # Archivo base .po
output_po_file = "multiaccount_scripts/test_multi_julia_result/ko_KR_result.po"  # Archivo actualizado .po

# Leer el archivo .txt
function read_translations(txt_path)
    msgids = String[]
    msgstrs = String[]
    for line in eachline(txt_path)
        if occursin("=>", line)
            # Separar msgid y msgstr
            msgid, msgstr = split(line, "=>", limit=2)
            push!(msgids, strip(msgid, ['"']))        # Elimina solo comillas, respeta espacios
            push!(msgstrs, strip(msgstr, ['"']))      # Elimina solo comillas, respeta espacios
        end
    end
    return msgids, msgstrs
end

# Validar espacios al inicio o final
function validate_spaces(msgids, msgstrs)
    for (msgid, msgstr) in zip(msgids, msgstrs)
        if startswith(msgid, " ") || endswith(msgid, " ") || 
           startswith(msgstr, " ") || endswith(msgstr, " ")
            println("")
            println("Aviso: Hay espacios al inicio o al final en: msgid='$msgid', msgstr='$msgstr'")
        end
    end
end

# Obtener msgid y msgstr del archivo .txt
msgids, msgstrs = read_translations(txt_path)

# Validar espacios
println("")
println("Validando espacios en las traducciones...")
println("")
validate_spaces(msgids, msgstrs)

# Leer el archivo base .po
po_translations = Dict{String, String}()
mid = ""
mstr = ""

if isfile(input_po_file)
    for line in eachline(input_po_file)
        if occursin("mid", line)
            # Extraer y limpiar el msgid
            mid = strip(replace(line, "mid \"" => ""))
            mid = strip(replace(mid, "\"" => ""))
        elseif occursin("mstr", line)
            # Extraer y limpiar el msgstr
            mstr = strip(replace(line, "mstr \"" => ""))
            mstr = strip(replace(mstr, "\"" => ""))
            # Añadir al diccionario si ambos msgid y msgstr están definidos
            if mid != "" && mstr != ""
                po_translations[mid] = mstr
            end
        end
    end
end

# Escribir el archivo actualizado
println("Actualizando el archivo .po...")
open(output_po_file, "w") do file
    # Agregar nuevas traducciones o actualizar las existentes
    write(file, "\n# Nuevas traducciones agregadas automáticamente\n")
    
    for (msgid, msgstr) in zip(msgids, msgstrs)
        if haskey(po_translations, msgid)
            # Si msgid existe, verifica si la traducción ha cambiado
            if po_translations[msgid] != msgstr
                println("Actualizando traducción: msgid='$msgid' de '$(po_translations[msgid])' a '$msgstr'")
                write(file, "\nmsgid \"$msgid\"\n")
                write(file, "msgstr \"$msgstr\"\n")
            end
        else
            # Si msgid no existe, simplemente lo agrega
            write(file, "\nmsgid \"$msgid\"\n")
            write(file, "msgstr \"$msgstr\"\n")
        end
    end
end

println("¡Archivo .po actualizado creado con éxito!")



