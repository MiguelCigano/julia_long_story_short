# Leer el archivo base .po y extraer las traducciones
function parse_po_file(po_file_path)
    translations = Dict{String, String}()
    current_msgid = ""
    current_msgstr = ""
    in_msgid = false
    in_msgstr = false

    for line in eachline(po_file_path)
        line = strip(line)
        if startswith(line, "msgid ")
            current_msgid = strip(line[7:end], ['"'])
            in_msgid = true
            in_msgstr = false
        elseif startswith(line, "msgstr ")
            current_msgstr = strip(line[8:end], ['"'])
            in_msgid = false
            in_msgstr = true
            translations[current_msgid] = current_msgstr
            current_msgid = ""
            current_msgstr = ""
        end
    end

    return translations
end

# Rutas de archivos
txt_path = "multiaccount_scripts/test_multi_julia/traducciones"         # Archivo con msgid y msgstr
input_po_file = "multiaccount_scripts/test_multi_julia/ko_KR.po"  # Archivo base .po
output_po_file = "multiaccount_scripts/test_multi_julia_result/ko_KR_result.po"  # Archivo actualizado .po

# Leer traducciones del archivo .txt
function read_translations(txt_path)
    msgids = String[]
    msgstrs = String[]
    for line in eachline(txt_path)
        if occursin("=>", line)
            msgid, msgstr = split(line, "=>", limit=2)
            push!(msgids, strip(msgid, ['"']))
            push!(msgstrs, strip(msgstr, ['"']))
        end
    end
    return msgids, msgstrs
end

# Validar espacios al inicio o final
function validate_spaces(msgids, msgstrs)
    for (msgid, msgstr) in zip(msgids, msgstrs)
        if startswith(msgid, " ") || endswith(msgid, " ") ||
           startswith(msgstr, " ") || endswith(msgstr, " ")
            println("Aviso: Hay espacios al inicio o al final en: msgid='$msgid', msgstr='$msgstr'")
        end
    end
end

# Obtener traducciones desde el archivo .txt
msgids, msgstrs = read_translations(txt_path)

# Validar espacios
println("Validando espacios en las traducciones...")
validate_spaces(msgids, msgstrs)

# Leer el archivo .po existente
po_translations = parse_po_file(input_po_file)

# Crear un archivo .po actualizado
println("Actualizando el archivo .po...")
open(output_po_file, "w") do file
    # Copiar todas las traducciones existentes
    write(file, "# Traducciones existentes\n")
    for (msgid, msgstr) in po_translations
        if haskey(Dict(zip(msgids, msgstrs)), msgid)
            # Si la traducción cambió, usa la nueva
            new_msgstr = Dict(zip(msgids, msgstrs))[msgid]
            if msgstr != new_msgstr
                println("Actualizando traducción: msgid='$msgid' de '$msgstr' a '$new_msgstr'")
                write(file, "\nmsgid \"$msgid\"\n")
                write(file, "msgstr \"$new_msgstr\"\n")
            else
                # Si no cambió, copia la existente
                write(file, "\nmsgid \"$msgid\"\n")
                write(file, "msgstr \"$msgstr\"\n")
            end
        else
            # Si no está en el .txt, copiar la traducción original
            write(file, "\nmsgid \"$msgid\"\n")
            write(file, "msgstr \"$msgstr\"\n")
        end
    end

    # Agregar nuevas traducciones
    write(file, "\n# Nuevas traducciones\n")
    for (msgid, msgstr) in zip(msgids, msgstrs)
        if !haskey(po_translations, msgid)
            println("Nueva traducción agregada: msgid='$msgid', msgstr='$msgstr'")
            write(file, "\nmsgid \"$msgid\"\n")
            write(file, "msgstr \"$msgstr\"\n")
        end
    end
end

println("¡Archivo .po actualizado creado con éxito!")
