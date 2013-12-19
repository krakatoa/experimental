-module(app_supervisor).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_Args) ->
  {ok,  {{one_for_one, 3, 60},
        [{monitor,
          {monitor, start_link, []},
          permanent, 1000, worker, [monitor]},
         {agent,
          {agent, start_link, []},
          permanent, 1000, worker, [agent]},
         {gossip,
          {gossip, start_link, []},
          permanent, 1000, worker, [gossip]}
        ]}}.
