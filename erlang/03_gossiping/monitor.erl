-module(monitor).

-export([monitor_start/0,monitor_start_link/0,init/1,add/3,show/1, check/1, check/2]).
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

gossip(StatusList) ->
  Flattened = list_to_binary(io_lib:format("~w", [StatusList])),
  gossip ! {send, Flattened}.

show(Pid) ->
  Ref = make_ref(),
  Pid ! {self(), Ref, {show}},
  receive
    {ok, Ref} -> io:format("--~n")
  end.

check(StatusList) ->
  check(StatusList, 1).
check(StatusList, Index) when Index =< length(StatusList) ->
  % [NewStatusList, [Ip, timer:now_diff(os:timestamp(), StatusRecord#status.last_heartbeat) / 1000 / 1000]) || {Ip, StatusRecord} <- MonitorData#monitor_data.status, StatusRecord#status.last_heartbeat =/= undefined].
  {Ip, StatusRecord} = lists:nth(Index, StatusList),
  io:format("Will check ~p~n", [Ip]),
  case StatusRecord#status.last_heartbeat =/= undefined of
    true -> ElapsedTime = timer:now_diff(os:timestamp(), StatusRecord#status.last_heartbeat) / 1000 / 1000;
    false -> ElapsedTime = 0
  end,
  case {ElapsedTime > 5, StatusRecord#status.status} of
    {true, down} ->
      check(StatusList, Index + 1);
    {true, up} ->
      NewStatusRecord = StatusRecord#status{status=down},
      NewStatusList = orddict:store(Ip, NewStatusRecord, StatusList),
      check(NewStatusList, Index + 1);
    {false, up} ->
      check(StatusList, Index + 1);
    {false, down} ->
      NewStatusRecord = StatusRecord#status{status=up},
      NewStatusList = orddict:store(Ip, NewStatusRecord, StatusList),
      check(NewStatusList, Index + 1)
  end;
check(StatusList, Index) when Index > length(StatusList) ->
  % io:format("finished~n").
  gossip(StatusList),
  StatusList.

init(MonitorData=#monitor_data{}) ->
  timer:send_interval(1000, self(), {self(), make_ref(), {show}}),
  timer:send_interval(5000, self(), {self(), make_ref(), {check}}),
  loop(MonitorData).

loop(MonitorData=#monitor_data{}) ->
  receive
    {Pid, MsgRef, {add, Ip, Member}} ->
      Pid ! {ok, MsgRef},
      NewMembers = orddict:store(Ip, Member, MonitorData#monitor_data.members),
      NewStatus = orddict:store(Ip, #status{}, MonitorData#monitor_data.status),
      loop(MonitorData#monitor_data{members=NewMembers, status=NewStatus});
    {Pid, MsgRef, {check}} ->
      Pid ! {ok, MsgRef},
      loop(MonitorData#monitor_data{status=check(MonitorData#monitor_data.status)});
    {Pid, MsgRef, {show}} ->
      % [io:format("X: ~p ~p (~p).~n", [Ip, Member, Status]) || {Ip, Member} <- MonitorData#monitor_data.members, {ok, Status} <- [(orddict:find(Ip, MonitorData#monitor_data.status))]],
      [io:format("X: ~p ~p (~p)~n", [Ip, timer:now_diff(os:timestamp(), StatusRecord#status.last_heartbeat) / 1000 / 1000, StatusRecord#status.status]) || {Ip, StatusRecord} <- MonitorData#monitor_data.status, StatusRecord#status.last_heartbeat =/= undefined],
      Pid ! {ok, MsgRef},
      loop(MonitorData);
    {_Pid, _MsgRef, {heartbeat, Ip}} ->
      % {ok, Member} = orddict:find(Ip, MonitorData#monitor_data.members),
      {ok, Status} = orddict:find(Ip, MonitorData#monitor_data.status),
      NewStatus = orddict:store(Ip, Status#status{last_heartbeat=os:timestamp()}, MonitorData#monitor_data.status),
      % timer:now_diff(T2, T1) / 1000 / 1000 % difference in seconds
      io:format("Heartbeat from ~p~n", [NewStatus]),
      loop(MonitorData#monitor_data{status=NewStatus})
  end.
