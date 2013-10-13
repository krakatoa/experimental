-module(circular).
-import(rotations, [rotations/1, rotations/3]).
-export([start/1]).

start(Arg) when is_atom(Arg) ->
  start(atom_to_list(Arg));
start(String) when is_list(String) ->
  io:format("Will rotate string: ~p\n", [String]),
  rotations:rotations(String);
start(Number) when is_integer(Number) ->
  io:format("Will rotate number: ~p\n", [Number]),
  rotations:rotations(Number).
