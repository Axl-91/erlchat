-module(erlchat_client).
-export([init/1]).

init(Sock) ->
    gen_tcp:send(Sock, "Welcome to erlChat!\r\n"),
    loop(Sock).

loop(Sock) ->
    case gen_tcp:recv(Sock, 0) of
        {ok, Data} when is_binary(Data) ->
            gen_tcp:send(Sock, Data), % echo
            loop(Sock);
        {error, closed} ->
            io:format("Client has been disconnected~n"),
            ok
    end.
