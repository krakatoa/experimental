-module(agent).
-behaviour(gen_server).

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
% -export([send_heartbeat/1]).
-include("monitor.hrl").

start_link() ->
  gen_server:start_link({local, agent}, ?MODULE, [], []).

% send_heartbeat(Pid) ->
%   gen_server:cast(Pid, {internal, send_heartbeat}).

init([]) ->
  erlang:send_after(1000, self(), {internal, send_heartbeat}),
  {ok, []}.

handle_cast(_Msg, []) ->
  {noreply, []}.

handle_call(terminate, _From, []) ->
  {stop, normal, ok, []}.

handle_info({internal, send_heartbeat}, []) ->
  gen_server:cast(monitor, {heartbeat, "127.0.0.1"}),
  erlang:send_after(1000, self(), {internal, send_heartbeat}),
  {noreply, []};
handle_info(Msg, []) ->
  io:format("Unexpected message: ~p", [Msg]),
  {noreply, []}.

terminate(normal, []) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.
