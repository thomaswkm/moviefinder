# Catalog

Contiene el flujo de catalogo usado por Home.

El dominio usa `MediaItem` para representar contenido comun a peliculas y series. Los campos especificos se mantienen opcionales para evitar mezclar una entidad `Movie` con datos que solo aplican a series.

La UI de Home consume `MediaItem` y decide que metadata mostrar segun `MediaType`.
