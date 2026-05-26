% Define precios, y sistema de compra y venta.
% Catalogo de objetos de la tienda.
precio(pocion, 10).
precio(espada, 30).
precio(cocaso, 50).
precio(joyas, 90).
precio(hierba, 30).

% Catalogo de precios de venta al mercader
valor_venta(pocion, 5).
valor_venta(espada, 15).
valor_venta(llave, 1).
valor_venta(hierba, 7).
valor_venta(cocaso, 25).
valor_venta(joyas, 50).
valor_venta(collar, 40).

hablar_mercader :-
    estado_juego(exploracion),
    ubicacion(mercado),
    retractall(estado_juego(_)),
    assert(estado_juego(tienda)),
    write('--- TIENDA ---'), nl,
    write('Dealer: Echa un vistazo a mis mercancias.'), nl,
    write('Usa "catalogo." para ver que vendo, "comprar(Objeto).", "mejorar(ataque)", "mejorar(salud)" o "salir_tienda." para irte.'), nl, !.

hablar_mercader :-
    write('No hay ningun mercader aqui.'), nl.

% Ver los objetos a la venta
catalogo :-
    estado_juego(tienda),
    write('--- CATALOGO ---'), nl,
    write(' - pocion (10 monedas)'), nl,
    write(' - espada (30 monedas)'), nl,
    write(' - hierba (15 monedas)'), nl,
    write(' - cocaso (50 monedas)'), nl,
    write(' - joyas  (90 monedas)'), nl, !.
catalogo :-
    write('No estas en una tienda.'), nl.

% Comprar (Solo funciona en estado tienda)
comprar(_) :-
    estado_juego(exploracion),
    write('Debes hablar con un mercader primero usando "hablar_mercader."'), nl, !.
    
comprar(Objeto) :-
    estado_juego(tienda),
    precio(Objeto, Costo),
    dinero(D),
    D >= Costo,
    inventario(Inv),
    length(Inv, Cantidad),
    Cantidad < 10,
    
    NuevoDinero is D - Costo,
    retract(dinero(D)),
    assert(dinero(NuevoDinero)),
    
    retract(inventario(Inv)),
    assert(inventario([Objeto|Inv])),
    write('Dealer: Aqui tienes tu '), write(Objeto), write('.'), nl, !.

% Comandos de progreso en tienda
mejorar(ataque) :-
    estado_juego(tienda),
    dinero(D), D >= 50,
    jugador(HP, Max, NivelA, NivelD),
    NuevoNivelA is NivelA + 1,
    retract(jugador(_, _, _, _)),
    assert(jugador(HP, Max, NuevoNivelA, NivelD)),
    retract(dinero(D)), assert(dinero(D - 50)),
    write('Has subido tu nivel de ataque.'), nl.

mejorar(vida) :-
    estado_juego(tienda),
    dinero(D), D >= 50,
    jugador(HP, Max, NivelA, NivelD),
    NuevoMax is Max + 10,
    retract(jugador(_, _, _, _)),
    assert(jugador(HP, NuevoMax, NivelA, NivelD)),
    retract(dinero(D)), assert(dinero(D - 50)),
    write('Has subido tu vida maxima.'), nl.

comprar(_) :-
    estado_juego(tienda),
    write('Dealer: No tienes suficiente dinero o tus bolsillos estan llenos.'), nl, !.

% Funcion para vender
vender(Objeto) :-
    estado_juego(tienda),
    inventario(Inv),
    member(Objeto, Inv),
    valor_venta(Objeto, Ganancia),
    
    % Quitamos del inventario
    select(Objeto, Inv, NuevoInv),
    retract(inventario(Inv)),
    assert(inventario(NuevoInv)),
    
    % Sumamos el dinero
    dinero(D),
    NuevoDinero is D + Ganancia,
    retract(dinero(D)),
    assert(dinero(NuevoDinero)),
    
    write('Dealer: Aqui tienes '), write(Ganancia), write(' monedas por tu '), write(Objeto), write('."'), nl, !.

vender(_) :-
    estado_juego(tienda),
    write('Dealer: No tienes ese objeto."'), nl, !.

vender(_) :-
    estado_juego(exploracion),
    write('Debes hablar con un dealer primero.'), nl.

% Salir de la tienda
salir_tienda :-
    estado_juego(tienda),
    retractall(estado_juego(_)),
    assert(estado_juego(exploracion)),
    write('Dealer: Vuelve pronto'), nl,
    write('Has salido de la tienda y estas de vuelta en la exploracion.'), nl, !.
salir_tienda :-
    write('No estas en ninguna tienda.'), nl.
