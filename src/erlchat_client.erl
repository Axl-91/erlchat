-module(erlchat_client).
-export([init/1]).

init(Sock) ->
    inet:setopts(Sock, [{active, once}]),
    gen_tcp:send(Sock, "Welcome to erlChat!\r\n"),
    gen_tcp:send(Sock, "Nick: "),
    await_nick(Sock).

await_nick(Sock) ->
    receive
        {tcp, Sock, Data} when is_binary(Data) ->
            Nick = string:trim(Data),
            erlchat_room:join(self(), Nick),
            inet:setopts(Sock, [{active, once}]),
            gen_tcp:send(Sock, "\e[2J\e[H"),
            gen_tcp:send(Sock, "Welcome to the main room\n"),
            loop(Sock, Nick);
        {tcp_closed, Sock} ->
            ok
    end.

loop(Sock, Nick) ->
    receive
        {tcp, Sock, Data} when is_binary(Data) ->
            erlchat_room:broadcast(self(), Data),
            inet:setopts(Sock, [{active, once}]),
            loop(Sock, Nick);
        {tcp_closed, Sock} ->
            io:format("Client disconnected:  ~s ~n", [Nick]),
            ok;
        {chat_msg, Msg} ->
            gen_tcp:send(Sock, Msg),
            loop(Sock, Nick)
    end.
