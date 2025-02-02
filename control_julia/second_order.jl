using Plots

# Definir la función de la parábola
f(x) = x^2  # Función cuadrática

# Generar valores de x
x_values = -10:0.1:10  # Rango de -10 a 10, paso de 0.1

# Calcular los valores correspondientes de y
y_values = f.(x_values)  # Usar el operador punto para aplicar la función a cada elemento

# Graficar la parábola
plot(x_values, y_values, label="y = x^2", xlabel="x", ylabel="y", title="Gráfica de la parábola y = x^2")

# Mostrar la gráfica
savefig("parabola_plot.png")