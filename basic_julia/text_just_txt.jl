# Rutas de archivos
txt_path = "traducciones.txt"         # Archivo con msgid y msgstr
input_po_file = "archivo_base_es.po"  # Archivo base .po
output_po_file = "archivo_actualizado_es.po"  # Archivo actualizado .po

# Leer el archivo .txt
function read_translations(txt_path)
    msgids = String[]
    msgstrs = String[]
    for line in eachline(txt_path)
        if occursin("=>", line)
            # Separar msgid y msgstr
            msgid, msgstr = split(line, "=>", limit=2)
            push!(msgids, strip(msgid, ['"', ' ']))   # Limpia espacios y comillas
            push!(msgstrs, strip(msgstr, ['"', ' '])) # Limpia espacios y comillas
        end
    end
    return msgids, msgstrs
end

# Obtener msgid y msgstr del archivo .txt
msgids, msgstrs = read_translations(txt_path)

# Leer el archivo base .po
po_content = ""
if isfile(input_po_file)
    po_content = read(input_po_file, String)
end

# Escribir el archivo actualizado
open(output_po_file, "w") do file
    # Escribe el contenido existente
    write(file, po_content)
    
    # Agregar nuevas traducciones
    write(file, "\n# Nuevas traducciones agregadas automáticamente\n")
    for (msgid, msgstr) in zip(msgids, msgstrs)
        write(file, "\nmsgid \"$msgid\"\n")
        write(file, "msgstr \"$msgstr\"\n")
    end
end

println("¡Archivo .po actualizado creado!")