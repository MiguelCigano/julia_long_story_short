# Rutas de archivos
txt_path = "multiaccount_scripts/test_multi_julia/traducciones"
input_po_file = "multiaccount_scripts/test_multi_julia/ko_KR.po"
output_po_file = "multiaccount_scripts/test_multi_julia_result/ko_KR_result.po"

# Leer archivo .txt
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

function space_validation(msgids, msgstrs)
    for (msgid, msgstr) in zip(msgids, msgstrs)
        if (startswith(msgid, " "))
            println("")
            println("Espacio al inicio de msgid: '$msgid'.")
        end
        if (endswith(msgid, " "))
            println("")
            println("Espacio al final de msgid: '$msgid'.")
        end
        if (startswith(msgstr, " "))
            println("")
            println("Espacio al inicio de msgstr: '$msgstr'.")
        end
        if (endswith(msgstr, " "))
            println("")
            println("Espacio al final de msgstr: '$msgstr'.")
        end
    end
end

msgids, msgstrs = read_translations(txt_path)

println("Validando espacios...")
space_validation(msgids, msgstrs)
println("Validando espacios...")

# Leer archivo base .po
po_content = ""
if (isfile(input_po_file))
    po_content = read(input_po_file, String)
end

println("Actualizando el archivo .po")
open(output_po_file, "w") do file
    write(file, po_content)

    #agregando nuevos ids y sus traducciones
    write(file, "\n# News translations")
    for (msgid, msgstr) in zip(msgids, msgstrs)
        write(file, "\nmsgid \"$msgid\"\n")
        write(file, "msgsrt \"$msgstr\"\n")
    end
end

println("¡Archivo .po actualizado creado con exito!")

        



