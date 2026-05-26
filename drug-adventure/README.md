JUEGO: Drug Adventure

El juego es un rpg explorable por consultas. Tienes un inventario disponible, puedes 'mirar'
lo que hay a tu alrededor, interactuar con objetos del mundo, encontrar peleas que te dan
recompensas, comprar/vender objetos, y equipar cosas que faciliten el juego.

Integrantes:
- Ramirez Macias Ulises Dante
- Reyes Grimaldo Angel Ismael
- Gonzalez Ortega Emanuel
- Díaz Anavia Javier Omar


INSTRUCCIONES:
- Dentro de la carpeta juego, cargar el main con: swipl main.pl
- Una vez cargado el juego, se debe usar 'iniciar.'. Esto también muestra los comandos disponibles.
- La mayor parte del juego se puede explorar con ir(Lugar)., al encontrar peleas puedes atacar. o escapar., obtienes objetos con agarrar(Objeto). y puedes interactuar con ellos con usar(Objeto).

REGLAS DEL JUEGO:
Para moverte entre lugares tienes que estar en una ubicación conectada a donde quieres ir.
Al encontrar un enemigo, inicia una pelea. Durante el estado de combate se bloquean las acciones que no tengan que ver con la pelea.
El combate requiere elejir una postura de ataque y una de defensa, además que es afectado por el arma equipada.
Se pueden usar objetos curativos en cualquier momento, pero usarlos durante el combate consume el turno del jugador y permite al enemigo dar un golpe gratis.
Los enemigos sueltan recompensas al ser derrotados.
Puedes usar las monedas para comprar objetos o para comprar mejoras permanentes de estadísticas.
El inventario tiene un límite de 10 objetos a la vez, puedes tirarlos o venderlos si es necesario.
Existen puertas especiales que requieren objetos especiales para abrirse.
Hay condiciones para ganar el juego, éstas se te dan al encontrar el lugar final.

EXPLICACIÓN DE LAS REGLAS LÓGICAS:
- estado_juego/1:
    Controla en que estado del juego se encuentra el jugador: menu, exploracion, combate o tienda.
    Actúa como un bloqueador de acciones. Por ejemplo, la regla ir(Lugar). fallará y aplicará una sanción al jugador si estado_juego(combate) es verdadero.

- ir/1:
    Permite al jugador moverse de una sección a otra, verificando que exista la conexión, luego verifica si existe el hecho puerta_cerrada(Lugar). Si está cerrada, comprueba que la lista del inventario contenga los objetos necesarios. Usa retract(ubicacion(Actual)) y assert(ubicacion(Lugar)) para actualizar la posición.

- agarrar/1 y tirar/1:
    Mueve objetos entre el lugar actual y el inventario. agarrar(Objeto) utiliza length(Inv, Cantidad) para verificar que no se tengan mas de 10 objetos. tirar(Objeto) utiliza select/3 para encontrar y extraer un objeto especifico de la lista del inventario y reinsertarlo en el lugar que estemos.

- atacar/0:
    Durante la pelea, atacar comienza el ciclo de preparación y ataque del jugador al enemigo. Extrae las estadísticas actuales de jugador/4 y enemigo/6. Utiliza la librería random y formulas en calcular_dano para simular probabilidades de fallo y reducción de daño. Modifica la mini base de datos con NuevoHP_E is HP_E - Dmg_J hasta que la vida del enemigo es menor o igual a 0, disparando la regla victoria_combate/3.

- comprar/1 y mejorar/1:
    Intercambia las monedas en dinero/1 por objetos o incremento de estadísticas modifciando jugador/4. Verifica que el jugador se encuentre en estado_juego(tienda) y que el dinero sea mayor o igual al costo declarado en los hechos precio/2.

EJEMPLO DE SESIÓN DE JUEGO.

En este ejemplo se muere por pura probabilidad:

?- iniciar.
      DRUG ADVENTURE
Comandos disponibles:
 - ir(lugar).
 - mirar.
 - agarrar(objeto) / tirar(objeto).
 - usar(objeto) / equipar(objeto).
 - ver_inventario.
 - abrir_puerta.
 - comprar(objeto) / vender(objeto).
 - atacar. / escapar.
---------------------------------------
---------------------------------------
Estas en: plaza
Lugares disponibles: [callejon,mercado,castillo,entrada_mansion,entrada_neon]
---------------------------------------
Estadisticas => Salud: 30/30 | Dinero: 30 monedas
---------------------------------------
true.

?- ir(castillo).
La puerta del castillo esta fuertemente cerrada. Necesitas 3 fragmentos de llave para entrar.
true.

?- ir(callejon).
Te has movido a: callejon
---------------------------------------
Estas en: callejon
Lugares disponibles: [plaza,centro]
---------------------------------------
Estadisticas => Salud: 30/30 | Dinero: 30 monedas
---------------------------------------
Ves los siguientes objetos aqui: [pocion]
!!! Un ladron te bloquea el paso.
Has comenzado una pelea.
true .

?- agarrar(pocion).
Le diste la espalda al ladron al intentar hacer otra cosa.
Aprovecha tu error para atacarte gratis
El ladron tiene 5/5 HP.
El ladron adopta postura lento y bloquear.
El ladron te impacta haciendo 44 de daño.
HAS MUERTO. Fin del juego.


En este ejemplo se muestra mas sobre como se juega y navega en general.

?- iniciar.
      DRUG ADVENTURE
Comandos disponibles:
 - ir(lugar).
 - mirar.
 - agarrar(objeto) / tirar(objeto).
 - usar(objeto) / equipar(objeto).
 - ver_inventario.
 - abrir_puerta.
 - comprar(objeto) / vender(objeto).
 - atacar. / escapar.
---------------------------------------
---------------------------------------
Estas en: plaza
Lugares disponibles: [callejon,mercado,castillo,entrada_mansion,entrada_neon]
---------------------------------------
Estadisticas => Salud: 30/30 | Dinero: 30 monedas
---------------------------------------
true.

?- ir(callejon).
Te has movido a: callejon
---------------------------------------
Estas en: callejon
Lugares disponibles: [plaza,centro]
---------------------------------------
Estadisticas => Salud: 30/30 | Dinero: 30 monedas
---------------------------------------
Ves los siguientes objetos aqui: [pocion]
!!! Un ladron te bloquea el paso.
Has comenzado una pelea.
true .

?- atacar.
¿Qué postura para atacar usaras? (rapido/lento): rapido.
¿Qué postura para defender usaras? (esquivar/bloquear): |: esquivar.
Has adoptado la postura para atacar: rapido y postura para defender: esquivar
Golpe exitoso. Hiciste 42 de daño.
Has derrotado al ladron.
Encuentras 10 monedas. (Total: 40)
El camino esta despejado.
true.

?- agarrar(pocion).
Has recogido: pocion
true.

?- ver_inventario.
Tu inventario: [pocion]
true.

?- usar(pocion).
Has consumido: pocion
Has recuperado salud. Tu HP ahora es 30/30
true.

?- mirar.
---------------------------------------
Estas en: callejon
Lugares disponibles: [plaza,centro]
---------------------------------------
Estadisticas => Salud: 30/30 | Dinero: 40 monedas
---------------------------------------
true.

?- ir(centro).
Te has movido a: centro
---------------------------------------
Estas en: centro
Lugares disponibles: [callejon,callejon_norte,callejon_este,callejon_oeste]
---------------------------------------
Estadisticas => Salud: 30/30 | Dinero: 40 monedas
---------------------------------------
true.

?- ir(callejon_norte).
Te has movido a: callejon_norte
---------------------------------------
Estas en: callejon_norte
Lugares disponibles: [centro,casa_desgastada]
---------------------------------------
Estadisticas => Salud: 30/30 | Dinero: 40 monedas
---------------------------------------
true.

?- ir(casa_desgastada).
Te has movido a: casa_desgastada
---------------------------------------
Estas en: casa_desgastada
Lugares disponibles: [callejon_norte,sotano]
---------------------------------------
Estadisticas => Salud: 30/30 | Dinero: 40 monedas
---------------------------------------
!!! Un pandillero te bloquea el paso.
Has comenzado una pelea.
true.

?- escapar.
Intentas escapar... (Probabilidad 50%. Sacaste: 62)
Lograste escapar. Corres hacia: callejon_norte
true.

?- mirar.
---------------------------------------
Estas en: callejon_norte
Lugares disponibles: [centro,casa_desgastada]
---------------------------------------
Estadisticas => Salud: 30/30 | Dinero: 40 monedas
---------------------------------------
true.

?- ir(centro).
Te has movido a: centro
---------------------------------------
Estas en: centro
Lugares disponibles: [callejon,callejon_norte,callejon_este,callejon_oeste]
---------------------------------------
Estadisticas => Salud: 30/30 | Dinero: 40 monedas
---------------------------------------
true.

?- ir(callejon).
Te has movido a: callejon
---------------------------------------
Estas en: callejon
Lugares disponibles: [plaza,centro]
---------------------------------------
Estadisticas => Salud: 30/30 | Dinero: 40 monedas
---------------------------------------
true.

?- ir(plaza).
Te has movido a: plaza
---------------------------------------
Estas en: plaza
Lugares disponibles: [callejon,mercado,castillo,entrada_mansion,entrada_neon]
---------------------------------------
Estadisticas => Salud: 30/30 | Dinero: 40 monedas
---------------------------------------
true.

?- ir(mercado).
Te has movido a: mercado
---------------------------------------
Estas en: mercado
Lugares disponibles: [plaza]
---------------------------------------
Estadisticas => Salud: 30/30 | Dinero: 40 monedas
---------------------------------------
true.

?- hablar_mercader.
--- TIENDA ---
Dealer: Echa un vistazo a mis mercancias.
Usa "catalogo." para ver que vendo, "comprar(Objeto).", "mejorar(ataque)", "mejorar(salud)" o "salir_tienda." para irte.
true.

?- catalogo.
--- CATALOGO ---
 - pocion (10 monedas)
 - espada (30 monedas)
 - hierba (15 monedas)
 - cocaso (50 monedas)
 - joyas  (90 monedas)
true.

?- comprar(espada).
Dealer: Aqui tienes tu espada.
true.

?- salir_tienda.
Dealer: Vuelve pronto
Has salido de la tienda y estas de vuelta en la exploracion.
true.

?- ver_inventario.
Tu inventario: [espada]
true.

?- equipar(espada).
Has equipado: espada
true.