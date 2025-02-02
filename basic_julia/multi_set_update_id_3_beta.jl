# Leer el archivo base .po y extraer las traducciones
function parse_po_file(po_file_path)
    translations = Dict{String, String}()
    current_msgid = ""
    current_msgstr = ""

    for line in eachline(po_file_path)
        line = strip(line)  # Elimina espacios en blanco al inicio y al final
        if startswith(line, "msgid ")  # Si la línea es un msgid
            current_msgid = strip(line[7:end], ['"'])  # Extrae el texto del msgid
        elseif startswith(line, "msgstr ")  # Si la línea es un msgstr
            current_msgstr = strip(line[8:end], ['"'])  # Extrae el texto del msgstr
            translations[current_msgid] = current_msgstr  # Guarda la traducción en el diccionario
            current_msgid = ""  # Reinicia para la próxima entrada
            current_msgstr = ""
        end
    end

    return translations
end

# Leer el archivo .txt con nuevas traducciones
function read_translations(txt_path)
    msgids = String[]
    msgstrs = String[]
    for line in eachline(txt_path)
        if occursin("=>", line)  # Identifica líneas con la separación "=>"
            msgid, msgstr = split(line, "=>", limit=2)
            push!(msgids, strip(msgid, ['"']))  # Limpia comillas alrededor del msgid
            push!(msgstrs, strip(msgstr, ['"']))  # Limpia comillas alrededor del msgstr
        end
    end
    return msgids, msgstrs
end

# Validar espacios al inicio o final en msgids y msgstrs
function validate_spaces(msgids, msgstrs)
    for (msgid, msgstr) in zip(msgids, msgstrs)
        if startswith(msgid, " ") || endswith(msgid, " ") ||
           startswith(msgstr, " ") || endswith(msgstr, " ")
            println("Aviso: Hay espacios al inicio o al final en: msgid='$msgid', msgstr='$msgstr'")
        end
    end
end

# Rutas de los archivos
txt_path = "multiaccount_scripts/test_multi_julia/traducciones"
input_po_file = "multiaccount_scripts/test_multi_julia/ko_KR.po"
output_po_file = "multiaccount_scripts/test_multi_julia_result/ko_KR_result.po"

# Leer y validar las traducciones desde el .txt
msgids, msgstrs = read_translations(txt_path)
println("\nValidando espacios en las traducciones...\n")
validate_spaces(msgids, msgstrs)

# Leer traducciones existentes del archivo .po
po_translations = parse_po_file(input_po_file)

# Actualizar y escribir el nuevo archivo .po
println("\nActualizando el archivo .po...\n")
open(output_po_file, "w") do file
    # Escribe las traducciones existentes con actualizaciones
    write(file, "# Traducciones actualizadas\n")
    for (msgid, msgstr) in po_translations
        if haskey(Dict(zip(msgids, msgstrs)), msgid)
            # Si la traducción cambió, actualizarla
            new_msgstr = Dict(zip(msgids, msgstrs))[msgid]
            if msgstr != new_msgstr
                println("Actualizando traducción: msgid='$msgid' de '$msgstr' a '$new_msgstr'")
                write(file, "\nmsgid \"$msgid\"\n")
                write(file, "msgstr \"$new_msgstr\"\n")
            else
                # Si no cambió, mantener la traducción original
                write(file, "\nmsgid \"$msgid\"\n")
                write(file, "msgstr \"$msgstr\"\n")
            end
        else
            # Si no está en el .txt, conservar la traducción original
            write(file, "\nmsgid \"$msgid\"\n")
            write(file, "msgstr \"$msgstr\"\n")
        end
    end

    # Agregar nuevas traducciones al final
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
