-module(agent).

-export([agent_start/0, agent_start_link/0, init/0]).
-include("monitor.hrl").

agent_start() ->
  Pid = spawn(?MODULE, init, []),
  Pid.

agent_start_link() ->
  Pid = spawn_link(?MODULE, init, []),
  Pid.

init() ->
  loop().

loop() ->
  receive
    _ -> io:format("received!~n")
  end.
