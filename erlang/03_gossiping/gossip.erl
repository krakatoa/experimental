-module(gossip).
-behaviour(gen_server).

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([initialize/2]).

start_link() ->
  gen_server:start_link({local, gossip}, ?MODULE, [], []).

init([]) ->
  % timer:send_interval(5000, self(), get).
  erlang:send_after(5000, self(), {internal, get}),
  {ok, {}}.

bind_input(Act) ->
  io:format("Will bind inbound as ~p.~n", [Act]),
  {ok, Socket} = case Act of
    "A" -> gen_udp:open(5561, [binary, {active, false}]);
    "B" -> gen_udp:open(5661, [binary, {active, false}])
  end,
  io:format("Binded to ~p.~n", [Socket]),
  Socket.

initialize(Pid, Act) ->
  gen_server:cast(Pid, {start, Act}).

handle_call(Msg, _From, State) ->
  io:format("Unexpected message: ~p~n", [Msg]),
  {noreply, State}.

handle_cast({start, Act}, State) ->
  {noreply, {bind_input(Act), Act}};
handle_cast({send, Data}, {}) ->
  io:format("--could not send right now--~n"),
  {noreply, {}};
handle_cast({send, Data}, {InputSocket, Act}) ->
  io:format("gossip:handle_cast~n"),
  DestinationSocket = case Act of
    "A" -> 5661;
    "B" -> 5561
  end,
  io:format("try to send ~p to ~p.~n", [Data, DestinationSocket]),
  gen_udp:send(InputSocket, {127,0,0,1}, DestinationSocket, Data),
  % gen_udp:close(Socket),
  {noreply, {InputSocket, Act}}.

handle_info({internal, get}, {}) ->
  erlang:send_after(5000, self(), {internal, get}),
  {noreply, {}};
handle_info({internal, get}, State) ->
  {InputSocket, _Act} = State,
  case is_port(InputSocket) of
    true ->
      case gen_udp:recv(InputSocket, 0, 1000) of
        {ok, From} -> io:format("Received: ~p~n", [From]);
        {error, timeout} -> io:format("timeouted!~n")
      end;
    false -> 0
  end,
  erlang:send_after(5000, self(), {internal, get}),
  {noreply, State};
handle_info(Msg, State) ->
  io:format("Gossip received unexpected message: ~p~n", [Msg]),
  {noreply, State}.

terminate(normal, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.
