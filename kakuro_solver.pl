:- use_module(library(clpfd)).

board_bcells([
    bcell(coordinate(0, 0),  values(nil, nil), lengths(nil, nil)),
    bcell(coordinate(0, 1),  values(nil, nil), lengths(nil, nil)),
    bcell(coordinate(0, 2),  values(nil, 16),  lengths(nil, 5)),
    bcell(coordinate(0, 3),  values(nil, 15),  lengths(nil, 3)),
    bcell(coordinate(0, 4),  values(nil, nil), lengths(nil, nil)),
    bcell(coordinate(0, 5),  values(nil, 20),  lengths(nil, 5)),
    bcell(coordinate(0, 6),  values(nil, 17),  lengths(nil, 2)),
    bcell(coordinate(0, 7),  values(nil, nil), lengths(nil, nil)),
    bcell(coordinate(0, 8),  values(nil, nil), lengths(nil, nil)),
    bcell(coordinate(0, 9),  values(nil, nil), lengths(nil, nil)),
    bcell(coordinate(0, 10), values(nil, 6),   lengths(nil, 3)),
    bcell(coordinate(0, 11), values(nil, 3),   lengths(nil, 2)),

    bcell(coordinate(1, 0),  values(nil, nil), lengths(nil, nil)),
    bcell(coordinate(1, 1),  values(7, 23),    lengths(2, 3)),
    bcell(coordinate(1, 4),  values(16, nil),  lengths(2, nil)),
    bcell(coordinate(1, 7),  values(nil, 16),  lengths(nil, 2)),
    bcell(coordinate(1, 8),  values(nil, nil), lengths(nil, nil)),
    bcell(coordinate(1, 9),  values(4, 10),    lengths(2, 4)),

    bcell(coordinate(2, 0),  values(23, nil),  lengths(3, nil)),
    bcell(coordinate(2, 4),  values(23, 4),    lengths(3, 2)),
    bcell(coordinate(2, 8),  values(6, 4),     lengths(3, 2)),

    bcell(coordinate(3, 0),  values(16, nil),  lengths(5, nil)),
    bcell(coordinate(3, 6),  values(16, 14),   lengths(4, 3)),
    bcell(coordinate(3, 11), values(nil, nil), lengths(nil, nil)),

    bcell(coordinate(4, 0),  values(13, nil),  lengths(2, nil)),
    bcell(coordinate(4, 3),  values(7, 11),    lengths(3, 4)),
    bcell(coordinate(4, 7),  values(3, 34),    lengths(2, 5)),
    bcell(coordinate(4, 10), values(nil, 16),  lengths(nil, 5)),
    bcell(coordinate(4, 11), values(nil, nil), lengths(nil, nil)),

    bcell(coordinate(5, 0),  values(nil, nil), lengths(nil, nil)),
    bcell(coordinate(5, 1),  values(3, nil),   lengths(2, nil)),
    bcell(coordinate(5, 4),  values(7, 17),    lengths(3, 2)),
    bcell(coordinate(5, 8),  values(3, 17),    lengths(2, 2)),
    bcell(coordinate(5, 11), values(nil, 17),  lengths(nil, 3)),

    bcell(coordinate(6, 0),  values(nil, nil), lengths(nil, nil)),
    bcell(coordinate(6, 1),  values(nil, nil), lengths(nil, nil)),
    bcell(coordinate(6, 2),  values(12, 10),   lengths(2, 3)),
    bcell(coordinate(6, 5),  values(23, 17),   lengths(3, 2)),
    bcell(coordinate(6, 9),  values(3, 24),    lengths(2, 3)),

    bcell(coordinate(7, 0),  values(nil, nil), lengths(nil, nil)),
    bcell(coordinate(7, 1),  values(29, 4),    lengths(4, 2)),
    bcell(coordinate(7, 6),  values(34, 16),   lengths(5, 2)),

    bcell(coordinate(8, 0),  values(6, nil),   lengths(3, nil)),
    bcell(coordinate(8, 4),  values(24, nil),  lengths(3, nil)),
    bcell(coordinate(8, 8),  values(23, nil),  lengths(3, nil)),

    bcell(coordinate(9, 0),  values(3, nil),   lengths(2, nil)),
    bcell(coordinate(9, 3),  values(nil, nil), lengths(nil, nil)),
    bcell(coordinate(9, 4),  values(nil, nil), lengths(nil, nil)),
    bcell(coordinate(9, 5),  values(17, nil),  lengths(2, nil)),
    bcell(coordinate(9, 8),  values(10, nil),  lengths(2, nil)),
    bcell(coordinate(9, 11), values(nil, nil), lengths(nil, nil))
]).

row_case(Board, bcell(coordinate(X, Y), values(Vx, _), lengths(Lx, _))) :-
    nth0(X, Board, Row), 
    Start #= Y+1,
    nth0(Start, Row, FirstWCell),

    Target = [FirstWCell|T2],
    length(Target, Lx), 
    Target ins 1..9,
    all_distinct(Target),
    sum(Target, #=, Vx),
    
    length(Residue, Start),
    append(Residue, [FirstWCell|T], Row),
    append([FirstWCell|T2], _T3, [FirstWCell|T]).


column_case(Board, bcell(coordinate(X, Y), values(_, Vy), lengths(_, Ly))) :-
    transpose(Board, TransposeBoard),
    nth0(Y, TransposeBoard, Column),
    Start #= X+1,
    nth0(Start, Column, FirstWCell),

    Target = [FirstWCell|T2],
    length(Target, Ly), 
    Target ins 1..9,
    all_distinct(Target),
    sum(Target, #=, Vy),

    length(Residue, Start),
    append(Residue, [FirstWCell|T], Column),
    append([FirstWCell|T2], _T3, [FirstWCell|T]).

apply_constraint(_, bcell(_, values(nil, nil), _)) :- !.
apply_constraint(Board, bcell(C, values(Vx, nil), L)) :-
    row_case(Board, bcell(C, values(Vx, nil), L)), !.
apply_constraint(Board, bcell(C, values(nil, Vy), L)) :-
    column_case(Board, bcell(C, values(nil, Vy), L)), !.
apply_constraint(Board, bcell(C, values(Vx, Vy), L)) :-
    row_case(Board, bcell(C, values(Vx, nil), L)),
    column_case(Board, bcell(C, values(nil, Vy), L)).

reverse_length(N, L) :- length(L, N).

kakuro(Row, Column, Result) :-
    length(Board, Row), maplist(reverse_length(Column), Board),
    board_bcells(Constraints),
    maplist(apply_constraint(Board), Constraints),
    append(Board, FlatBoard),
    include(fd_var, FlatBoard, Result),
    labeling([ff], Result).
