-module(monitor).
-behaviour(gen_server).

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([add/3, show/1, check/1, check/2]).
-include("monitor.hrl").

start_link() ->
  gen_server:start_link({local, monitor}, ?MODULE, #monitor_data{members=orddict:new(), status=orddict:new()}, []).

add(Pid, Ip, Member) ->
  gen_server:call(Pid, {add, Ip, Member}).

show(Pid) ->
  gen_server:cast(Pid, show).

add_agent(Ip, Member=#member{}, MonitorData) ->
  % Member = #member{host=Host,tag=Tag,kind=agent},
  NewMembers = orddict:store(Ip, Member, MonitorData#monitor_data.members),
  NewStatus = orddict:store(Ip, #status{}, MonitorData#monitor_data.status),
  MonitorData#monitor_data{members=NewMembers, status=NewStatus}.

add_internal_agent(MonitorData) ->
  add_agent("127.0.0.1", #member{host="localhost", tag="internal"}, MonitorData).

gossip(StatusList) ->
  Flattened = list_to_binary(io_lib:format("~w", [StatusList])),
  gossip ! {send, Flattened}.

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
  io:format("finished~n"),
  % gossip(StatusList),
  StatusList.

init(MonitorData=#monitor_data{}) ->
  erlang:send_after(1000, self(), {internal, show}),
  erlang:send_after(5000, self(), {internal, check}),
  {ok, add_internal_agent(MonitorData)}.

handle_call({add, Ip, Member}, From, MonitorData) ->
  %NewMembers = orddict:store(Ip, Member, MonitorData#monitor_data.members),
  %NewStatus = orddict:store(Ip, #status{}, MonitorData#monitor_data.status),
  {reply, ok, add_agent(Ip, Member, MonitorData)}.

handle_cast(check, MonitorData) ->
  {noreply, MonitorData#monitor_data{status=check(MonitorData#monitor_data.status)}};
handle_cast(show, MonitorData) ->
  io:format("Will show...~n"),
  % [io:format("X: ~p ~p (~p).~n", [Ip, Member, Status]) || {Ip, Member} <- MonitorData#monitor_data.members, {ok, Status} <- [(orddict:find(Ip, MonitorData#monitor_data.status))]],
  [io:format("X: ~p ~p (~p)~n", [Ip, timer:now_diff(os:timestamp(), StatusRecord#status.last_heartbeat) / 1000 / 1000, StatusRecord#status.status]) || {Ip, StatusRecord} <- MonitorData#monitor_data.status, StatusRecord#status.last_heartbeat =/= undefined],
  {noreply, MonitorData};
handle_cast({heartbeat, Ip}, MonitorData) ->
  {ok, Status} = orddict:find(Ip, MonitorData#monitor_data.status),
  NewStatus = orddict:store(Ip, Status#status{last_heartbeat=os:timestamp()}, MonitorData#monitor_data.status),
  io:format("Heartbeat from ~p~n", [NewStatus]),
  {noreply, MonitorData#monitor_data{status=NewStatus}}.

handle_info({internal, show}, MonitorData) ->
  gen_server:cast(self(), show),
  erlang:send_after(1000, self(), {internal, show}),
  {noreply, MonitorData};
handle_info({internal, check}, MonitorData) ->
  gen_server:cast(self(), check),
  erlang:send_after(5000, self(), {internal, check}),
  {noreply, MonitorData}.

terminate(normal, _MonitorData) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.
