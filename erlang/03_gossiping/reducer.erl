-module(reducer).
-export([start/0, start_link/0, reducer/0]).

start() ->
  Pid = spawn(reducer, reducer, []),
  timer:send_interval(10000, Pid, flush),
  Pid.

start_link() ->
  Pid = spawn_link(reducer, reducer, []),
  timer:send_interval(10000, Pid, flush),
  Pid.

reducer() ->
  reducer([]).
reducer(Queue) ->
  receive
    {add, Item} -> 
      io:format("ADD item ~p (count: ~p)~n", [Item, length(Queue)]),
      reducer(Queue++[Item]);
    flush ->
      io:format("--flushing--"),
      reducer([]);
    show ->
      lists:foreach(fun(El) -> io:format("~p~n", [El]) end, Queue),
      reducer(Queue)
  end.
