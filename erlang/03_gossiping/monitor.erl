-module(monitor).

-export([monitor_start/0,monitor_start_link/0,init/1,add/3,show/1]).
-include("monitor.hrl").

monitor_start() ->
  Pid = spawn(monitor, init, [#monitor_data{members=orddict:new(), status=orddict:new()}]),
  Pid.

monitor_start_link() ->
  Pid = spawn_link(monitor, init, [#monitor_data{members=orddict:new(), status=orddict:new()}]),
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

init(MonitorData=#monitor_data{}) ->
  timer:send_interval(10000, self(), {self(), make_ref(), {show}}),
  loop(MonitorData).

loop(MonitorData=#monitor_data{}) ->
  receive
    {Pid, MsgRef, {add, Ip, Member}} ->
      Pid ! {ok, MsgRef},
      NewMembers = orddict:store(Ip, Member, MonitorData#monitor_data.members),
      NewStatus = orddict:store(Ip, #status{}, MonitorData#monitor_data.status),
      loop(MonitorData#monitor_data{members=NewMembers, status=NewStatus});
    {Pid, MsgRef, {show}} ->
      [io:format("X: ~p ~p (~p).~n", [Ip, Member, Status]) || {Ip, Member} <- MonitorData#monitor_data.members, {ok, Status} <- [(orddict:find(Ip, MonitorData#monitor_data.status))]],
      Pid ! {ok, MsgRef},
      loop(MonitorData)
  end.
