-module(test).
-export([start/1]).
-import(shop, [cost/2]).

start(Cost) ->
  [NewCost|Tail] = Cost,
  ParsedCost = list_to_integer(atom_to_list(NewCost)),
  io:format("Hola mundo ~p", [shop:cost(oranges, ParsedCost)]).
