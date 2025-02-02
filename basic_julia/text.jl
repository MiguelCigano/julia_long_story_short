using CSV
using DataFrames

# Rutas de los archivos
excel_path = "traducciones.csv"  # Archivo CSV con las traducciones
po_file = "archivo_base_es.po"  # Archivo .po base (español)
output_po_file = "archivo_actualizado_es.po"  # Archivo .po actualizado

# Leer el archivo CSV
data = CSV.read(excel_path, DataFrame)

# Asegúrate de que la primera columna es msgid
msgids = data[:, "msgid"]
translations = data[:, "es"]  # Columna del idioma español

# Función para actualizar un archivo .po
function update_po_file(po_file, output_po_file, msgids, translations)
    # Leer contenido existente del archivo .po (si existe)
    po_content = ""
    if isfile(po_file)
        po_content = read(po_file, String)
    end

    # Abrir el archivo de salida para escribir
    open(output_po_file, "w") do file
        # Escribir el contenido existente
        write(file, po_content)
        
        # Agregar nuevas traducciones
        write(file, "\n# Nuevas traducciones agregadas automáticamente\n")
        for (msgid, msgstr) in zip(msgids, translations)
            write(file, "\nmsgid \"$msgid\"\n")
            write(file, "msgstr \"$msgstr\"\n")
        end
    end
end

# Llamar a la función para actualizar el archivo .po en español
update_po_file(po_file, output_po_file, msgids, translations)

println("¡Archivo .po actualizado para español!")