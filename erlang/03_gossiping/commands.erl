-module(commands).
% -compile(export_all).
-import(reducer, [reducer/0]).
-export([map/2, start/0, spawner/0]).

start() ->
  Pid = spawn(?MODULE, spawner, []),
  Pid.

map(Command, Args) when Command =:= "ADD" ->
  % io:format("A!~n");
  reducer ! {add, Args};
map(Command, _Args) when Command =:= "SHOW" ->
  reducer ! show;
map(Command, _Args) ->
  io:format("wrong command ~p~n", [Command]).

spawner() ->
  process_flag(trap_exit, true),
  Pid = reducer:start_link(),
  register(reducer, Pid),
  receive
    {'EXIT', Pid, normal} -> ok;
    {'EXIT', Pid, _} -> spawner()
  end.
