-module(monitor).
-behaviour(gen_server).

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([add_monitor/1, show/1, check/1, check/2]).
-include("monitor.hrl").

start_link() ->
  random:seed(now()),
  gen_server:start_link({local, monitor}, ?MODULE, #monitor_data{members=orddict:new(), status=orddict:new(), messages=orddict:new()}, []).

show(Pid) ->
  gen_server:cast(Pid, show).

add_internal_agent() ->
  gen_server:cast(?MODULE, {add, "127.0.0.1", #member{host="localhost", tag="internal"}}).

add_monitor(Ip) ->
  gen_server:cast(?MODULE, {add, Ip, #member{host=Ip, kind=monitor}}).

gossip(Member, StatusList) ->
  io:format("ToMember: ~p~n", [Member]),
  {ok, Ip} = inet_parse:address(Member),
  Flattened = list_to_binary(io_lib:format("~w", [StatusList])),
  io:format("monitor:gossip ~p~n", [Flattened]),
  gen_server:cast(gossip, {send, Flattened, Ip}).

check(StatusList) ->
  check(StatusList, 1).
check(StatusList, Index) when Index =< length(StatusList) ->
  {Ip, StatusRecord} = lists:nth(Index, StatusList),
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
  StatusList.

only_monitors(Members) ->
  Filtered = orddict:fold(fun(K, Member, Acc) ->
                            io:format("  -~p~n", [Member]),
                            case Member#member.kind of
                              monitor -> orddict:store(K, Member, Acc);
                              _ -> Acc
                            end
                          end, orddict:new(), Members),
  [io:format("Members: ~p~n", [X]) || X <- Filtered],
  Filtered.

init(MonitorData=#monitor_data{}) ->
  erlang:send_after(1000, self(), {internal, show}),
  erlang:send_after(5000, self(), {internal, check}),
  add_internal_agent(),
  {ok, MonitorData}.

handle_call(_Msg, _From, State) ->
  {reply, ok, State}.

handle_cast({add, Ip, Member}, MonitorData) ->
  NewMembers = orddict:store(Ip, Member, MonitorData#monitor_data.members),
  NewStatus = orddict:store(Ip, #status{}, MonitorData#monitor_data.status),
  {noreply, MonitorData#monitor_data{members=NewMembers, status=NewStatus}};
handle_cast(check, MonitorData) ->
  StatusList = check(MonitorData#monitor_data.status),

  OnlyMonitors = only_monitors(MonitorData#monitor_data.members),
  case orddict:size(OnlyMonitors) > 0 of
    true ->
      Position = 1 + erlang:trunc(random:uniform() * length(OnlyMonitors)),
      {_Key, Member} = lists:nth(Position, OnlyMonitors),
      SelectedIp = Member#member.host,
      gossip(SelectedIp, StatusList);
    false -> io:format("-- No monitors --~n")
  end,
  {noreply, MonitorData#monitor_data{status=StatusList}};
handle_cast(show, MonitorData) ->
  {noreply, MonitorData};
handle_cast({heartbeat, Ip}, MonitorData) ->
  {ok, Status} = orddict:find(Ip, MonitorData#monitor_data.status),
  NewStatus = orddict:store(Ip, Status#status{last_heartbeat=os:timestamp()}, MonitorData#monitor_data.status),
  % io:format("Heartbeat from ~p~n", [NewStatus]),
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
