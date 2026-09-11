-module(erlchat_listener).
-export([start_link/1, init/1]).

start_link(Port) ->
    Pid = spawn_link(?MODULE, init, [Port]),
    {ok, Pid}.

init(Port) ->
    {ok, LSock} = gen_tcp:listen(Port, [
        binary,
        {packet, line},
        {active, false},
        {reuseaddr, true}
    ]),
    io:format("erlChat listening on port ~p~n", [Port]),
    accept_loop(LSock).

accept_loop(LSock) ->
    {ok, Sock} = gen_tcp:accept(LSock),
    spawn(fun() -> erlchat_client:init(Sock) end),
    accept_loop(LSock).
