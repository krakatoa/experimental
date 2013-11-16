-module(cli).
-import(commands, [map/1]).
-export([start/0, input/0, run/1]).

start() ->
  commands:start().

input() ->
  Input = io:get_line("$ "),
  run(Input).

split_args(Arg) ->
  Input = string:strip(Arg, both, $\n),
  string:tokens(Input, " ").

run(Arg) when is_atom(Arg) ->
  run(atom_to_list(Arg));
run(String) when is_list(String) ->
  [First|Rest] = split_args(String),
  commands:map(First, Rest).
