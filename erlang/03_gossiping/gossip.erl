-module(gossip).
-export([start/0, start_link/0, init/0]).

start() ->
  Pid = spawn(?MODULE, init, []),
  {ok, Pid}.

start_link() ->
  Pid = spawn_link(?MODULE, init, []),
  register(gossip, Pid),
  {ok, Pid}.

init() ->
  timer:send_interval(5000, self(), get),
  loop().

bind_input(Act) ->
  io:format("Will bind as ~p.~n", [Act]),
  {ok, Socket} = case Act of
    "A" -> gen_udp:open(5561, [binary, {active, false}]);
    "B" -> gen_udp:open(5661, [binary, {active, false}])
  end,
  io:format("Binded to ~p.~n", [Socket]),
  Socket.

loop() ->
  loop(undefined, undefined).

loop(InputSocket, Act) ->
  receive
    {start, NewAct} -> 
      loop(bind_input(NewAct), NewAct);
    {send, Data} ->
      case is_port(InputSocket) of
        true ->
          DestinationSocket = case Act of
            "A" -> 5661;
            "B" -> 5561
          end,
          gen_udp:send(InputSocket, {127,0,0,1}, DestinationSocket, Data);
        false -> 0
      end,
      loop(InputSocket, Act);
    get ->
      case is_port(InputSocket) of
        true ->
          {ok, From} = gen_udp:recv(InputSocket, 0),
          io:format("Received: ~p~n", [From]);
        false -> 0
      end,
      loop(InputSocket, Act)
  end.
