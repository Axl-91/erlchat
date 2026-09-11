-module(erlchat_sup).
-moduledoc "erlchat top level supervisor.".

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    SupFlags = #{
        strategy => one_for_all,
        intensity => 5,
        period => 10
    },
    ChildSpecs = [
        #{id => erlchat_room,
          start => {erlchat_room, start_link, []},
          restart => permanent},

        #{id => erlchat_listener,
          start => {erlchat_listener, start_link, [4000]},
          restart => permanent}
    ],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions
