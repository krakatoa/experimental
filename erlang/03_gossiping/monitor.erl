-module(monitor).

-record(monitor_data, {members, status}).
-record(member, {host, tag, kind=agent}).
-record(status, {status=up}).

-export([start/0,add/3,loop/1,show/1]).

start() ->
  Pid = spawn(monitor, loop, [#monitor_data{members=orddict:new(), status=orddict:new()}]),
  Pid.

add(Pid, Ip, Member) ->
  Ref = make_ref(),
  Pid ! {self(), Ref, {add, Ip, Member}},
  receive
    {ok, Ref} -> io:format("Adding!~n")
  end.

show(Pid) ->
  Ref = make_ref(),
  Pid ! {self(), Ref, {show}},
  receive
    {ok, Ref} -> io:format("--~n")
  end.

loop(MonitorData=#monitor_data{}) ->
  receive
    {Pid, MsgRef, {add, Ip, Member}} ->
      Pid ! {ok, MsgRef},
      NewMembers = orddict:store(Ip, Member, MonitorData#monitor_data.members),
      loop(MonitorData#monitor_data{members=NewMembers});
    {Pid, MsgRef, {show}} ->
      [io:format("X: ~p ~p.~n", [Ip, Member]) || {Ip, Member} <- MonitorData#monitor_data.members],
      Pid ! {ok, MsgRef},
      loop(MonitorData)
  end.
