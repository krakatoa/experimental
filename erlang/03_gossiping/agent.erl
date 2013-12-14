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
  timer:send_interval(1000, self(), {internal, send_heartbeat}),
  loop().

loop() ->
  receive
    {internal, send_heartbeat} ->
      send_heartbeat(),
      loop();
    _ ->
      io:format("received!~n"),
      loop()
  end.

send_heartbeat() ->
  monitor ! {self(), make_ref(), {heartbeat, "127.0.0.1"}}.
