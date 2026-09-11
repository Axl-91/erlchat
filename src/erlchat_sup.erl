%%%-------------------------------------------------------------------
%% @doc erlchat top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(erlchat_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    SupFlags = #{
        strategy => one_for_all,
        intensity => 0,
        period => 1
    },
    ChildSpecs = [
        #{
            id => erlchat_listener,
            start => {erlchat_listener, start_link, [4000]},
            restart => permanent
         }
    ],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions
