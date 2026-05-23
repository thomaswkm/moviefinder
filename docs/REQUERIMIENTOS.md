

| ID | Descripción | Actor Principal |
| ----- | ----- | ----- |
| RF-01 | El sistema debe permitir a los usuarios visualizar el catálogo de películas disponibles dentro de la plataforma. | Usuario |
| RF-02 | El sistema debe permitir buscar películas mediante filtros como nombre, género, plataforma o año. | Usuario |
| RF-03 | El sistema debe mostrar información detallada de una película seleccionada. | Usuario |
| RF-04 | El sistema debe permitir asignar una puntuación a una película. | Usuario autenticado |
| RF-05 | El sistema debe permitir agregar una reseña textual asociada a una valoración. | Usuario autenticado |
| RF-06 | El sistema debe permitir crear listas personalizadas de películas para recomendaciones o seguimiento. | Usuario autenticado |
| RF-07 | El sistema debe mostrar las plataformas de streaming donde se encuentra disponible una película. | Usuario |
| RF-08 | El sistema debe recomendar plataformas de streaming en función de la watchlist del usuario. | Usuario autenticado |

Presentación 2

Opcionales

Presentación 3 final

# **Detalle y Criterios de Aceptación**

## **RF-01 – Visualizar catálogo de películas**

### **Descripción**

El sistema debe mostrar un listado de películas disponibles para consulta por parte del usuario.

### **Entradas**

* Solicitud de acceso al catálogo.

### **Salidas**

* Lista de películas disponibles.

### **Criterios de aceptación**

* El catálogo debe mostrar al menos:  
  * título,  
  * portada,  
  * género,  
  * puntuación promedio.  
* El usuario debe poder navegar entre múltiples resultados.  
* El usuario debe poder scrollear hacia abajo y el sistema debe cargar a medida que scrollea los resultados(lazy loading).


## **RF-02 – Buscar películas**

### **Descripción**

El sistema debe permitir realizar búsquedas de películas mediante texto o filtros.

### **Entradas**

* Nombre de película.  
* Género.  
* Año.

### **Salidas**

* Resultados coincidentes.

### **Criterios de aceptación**

* El sistema debe permitir búsquedas parciales.  
* El sistema debe ignorar diferencias entre mayúsculas y minúsculas.  
* El sistema debe mostrar un mensaje cuando no existan coincidencias.

## **RF-03 – Visualizar detalle de película**

### **Descripción**

El sistema debe permitir visualizar información detallada de una película.

### **Salidas esperadas**

* Sinopsis.  
* Género.  
* Duración.  
* Director.  
* Reparto.  
* Plataformas disponibles.  
* Valoración promedio.

### **Criterios de aceptación**

* La información debe cargarse correctamente al seleccionar una película.  
* Las valoraciones deben reflejar el promedio actualizado.  
* Deben visualizarse las plataformas asociadas.

## **RF-04 – Valorar película**

### **Descripción**

El sistema debe permitir asignar una puntuación a una película.

### **Restricciones**

* Solo usuarios autenticados pueden valorar.

### **Criterios de aceptación**

* La puntuación debe estar dentro de un rango de 1 a 5\.  
* Un usuario no puede registrar múltiples valoraciones activas para la misma película.  
* El promedio general debe actualizarse automáticamente.

## **RF-05 – Agregar reseña**

### **Descripción**

El sistema debe permitir agregar comentarios escritos asociados a una valoración.

### **Criterios de aceptación**

* La reseña debe asociarse a una película y usuario.  
* El sistema debe limitar la longitud máxima de caracteres.  
* El usuario debe poder editar o eliminar su reseña.

## **RF-06 – Crear listas de películas**

### **Descripción**

El sistema debe permitir crear listas personalizadas de películas.

### **Ejemplos**

* “Películas favoritas”  
* “Pendientes por ver”  
* “Recomendaciones de terror”

### **Criterios de aceptación**

* El usuario debe poder:  
  * crear,  
  * editar,  
  * eliminar listas.  
* Una película puede pertenecer a múltiples listas.  
* Las listas deben poder compartirse mediante enlace.

## **RF-07 – Visualizar plataformas disponibles**

### **Descripción**

El sistema debe mostrar en qué plataformas de streaming se encuentra disponible una película.

### **Criterios de aceptación**

* El sistema debe mostrar el nombre de la plataforma.  
* Debe indicarse si la película:  
  * está incluida,  
  * requiere arriendo,  
  * requiere compra.  
* La información debe mantenerse actualizada.

## **RF-08 – Sugerencia de suscripción**

### **Descripción**

El sistema debe analizar la watchlist del usuario y recomendar servicios de streaming convenientes.

### **Ejemplo**

“8 de las 10 películas de tu watchlist están disponibles en Netflix”.

### **Criterios de aceptación**

* El sistema debe calcular coincidencias entre watchlist y catálogo de plataformas.  
* Debe mostrar porcentaje o cantidad de coincidencias.  
* Debe recomendar al menos una plataforma óptima.  
* El cálculo debe actualizarse cuando cambie la watchlist.

