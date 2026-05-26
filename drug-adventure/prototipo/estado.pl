% Declaramos las cosas que cambian en el juego, y como empezamos.
:- dynamic ubicacion/1, ubicacion_anterior/1, estado_juego/1, en_combate_con/1, inventario/1, objeto_en/2, puerta_cerrada/1, jugador/4, enemigo/6, dinero/1, arma_equipada/1, postura_jugador/2.

% Estados iniciales
estado_juego(menu).
ubicacion(plaza).
ubicacion_anterior(plaza). % Para no romper el juego si intentas escapar en el turno 1
inventario([]).
dinero(30).
arma_equipada(ninguna).

% jugador(HP, Max, NivelA, NivelD)
jugador(30, 30, 1, 0).
arma_equipada(ninguna).

% enemigo(Nombre, Ubicacion, HP_Actual, HP_Total, Dmg, Recompensa)
enemigo(ladron, callejon, 5 ,  5, 2, 10).
enemigo(guardia_puerta, entrada_mansion, 10, 10, 3, 10).
enemigo(guardia_cocina, cocina, 10, 10, 3, 10).
enemigo(capo_mayor,sala, 20, 20, 5, 30).
enemigo(pandillero,casa_desgastada, 6, 6, 4, 5).
enemigo(pandillero_entrada, sotano, 6, 6, 4, 5).
enemigo(pandillero_fondo, fondo, 6, 6, 4, 5).
enemigo(pandillero_viajado, distrito_verde, 6,6,3,3).
enemigo(sicario_neon, pista_baile, 7,7,3,10).
enemigo(hacker_neon, servidores, 15, 15, 4, 20).
enemigo(dj_sicario, sala_dj, 8,8,4,10).
    
% Objetos en el mapa
objeto_en(callejon, pocion).
objeto_en(lobby, vino).
objeto_en(esquina_sospechosa, hierba).
objeto_en(sala_dj, tarjeta_servidores).
objeto_en(barra, pocion).

    
% Puertas
puerta_cerrada(castillo).
puerta_cerrada(servidores).
