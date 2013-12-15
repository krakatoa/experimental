-module(app).

-import(monitor, [monitor_start/0, monitor_start_link/0, add/3, show/1]).
-import(agent, [agent_start/0, agent_start_link/0]).
-import(gossip, [gossip_start/0, gossip_start_link/0]).
-export([start/0, start_link/0, init/0, add_agent/2]).
-include("monitor.hrl").

start() ->
  Pid = spawn(?MODULE, init, []),
  Pid.

start_link() ->
  Pid = spawn_link(?MODULE, init, []),
  Pid.

add_agent(Ip, {Host, Tag}) ->
  Member = #member{host=Host,tag=Tag,kind=agent},
  monitor:add(whereis(monitor), Ip, Member).

add_internal_agent() ->
  Member = #member{host="localhost", tag="internal", kind=agent},
  monitor:add(whereis(monitor), "127.0.0.1", Member).

init() ->
  init(undefined, undefined).

init(Monitor, InternalAgent) ->
  process_flag(trap_exit, true),
  case Monitor of
    undefined ->  
      NewMonitor = monitor:monitor_start_link(),
      register(monitor, NewMonitor),
      init(NewMonitor, InternalAgent);
    _ -> io:format("~p~n", [Monitor])
  end,
  case InternalAgent of
    undefined ->
      NewAgent = agent:agent_start_link(),
      add_internal_agent(),
      register(internal_agent, NewAgent),
      init(Monitor, NewAgent);
    _ -> io:format("~p~n", [InternalAgent])
  end,
  Gossip = init_gossip(),
  loop(Monitor, InternalAgent, Gossip).

init_gossip() ->
  Gossip = gossip:gossip_start_link(),
  register(gossip, Gossip),
  Gossip.

loop(Monitor, InternalAgent, Gossip) ->
  receive
    {'EXIT', Monitor, normal} -> ok;
    {'EXIT', Monitor, _} -> init(undefined, InternalAgent);
    {'EXIT', InternalAgent, _} -> init(Monitor, undefined)
  end.
