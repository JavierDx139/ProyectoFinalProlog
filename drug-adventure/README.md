COMO USAR:
- swipl main.pl
- Para inciar el juego debes usar: iniciar. Te da una lista de comandos a usar.
- La función mirar. te dice donde estas, tus estadisticas, a donde puedes ir y si hay enemigos.
- Por ahora al encontrar un enemigo entra al estado de combate, solo se puede atacar. o huir.
- En el (mercado) hay un dealer, se puede interactuar con el con hablar_mercader.
- La puerta del castillo (por ahora el punto final del juego) esta bloqueada por una llave.

1. Diseño de nivel.
Expansión del mundo. Crear mas lugares, conexiones entre zonas y colocar objetos.
Para agregar un lugar nuevo, agregamos relaciones bidireccionales de conectado(_,_) en mundo.pl.
Para poner objetos, en estado.pl, agregamos con objeto_en(_,_).
!!! Logica especial (como lugares secretos con puertas que abren con llaves especiales) o puzzles interactivos.

2. Diseño de combate.
Importante: Posiblemente modificar la funcion atacar. a atacar(rapido), por ejemplo, para adoptar posturas.
Creamos enemigos en estado.pl. (Encargado de crear la batalla final)
Agregamos nuevas armas en jugador.pl.
Creamos nuevas pociones/consumibles en jugador.pl agregando el efecto_consumible.
(En teoria hasta ahora combate.pl ya se encarga de calcular el dano de las armas agregadas aqui)
!!! Daños aleatorios, o probabilidad de hacer mas o menos daño dependiendo de efectos de consumibles especiales.

3. Diseño de economia y progresión.
Para agregar objetos a la tienda, en tienda.pl agregamos el precio(_,_).
Agregamos valores de venta ahi mismo para objetos del mundo.
Puede agregar recompensas especiales para enemigos. (no necesariamente crear los enemigos de una vez, solo la recompensa)
!!! Posible creación de eventos especiales aleatorios que involucren robos o perdida de objetos de alguna forma.

TODO:
- Crea una nueva rama desde la rama drug-adventure con lo que vas a hacer.
ej. git checkout -b feature/combate
- Al terminar alguna funcionalidad importante, y el juego corre sin errores, hacer commit y push a sus ramas.
- Abrir un pull request hacia la rama principal del juego. Llenar esta plantilla de descripcion del PR para revisarlo mas rapido.

Título del PR: [Breve descripción, ej. Agregados subjefes]
Archivos modificados:
- tienda.pl
- jugador.pl
...

Escriban las funciones o hechos que agregaron.

Pruebas realizadas:
Ej: Entré a la tienda con 20 monedas, compré una poción por 10, y el inventario se actualizó correctamente.