-module(erlchat_room).
-behaviour(gen_server).

-export([start_link/0, join/2, broadcast/2]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).

%% Public API

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

join(ClientPid, Nick) ->
    gen_server:cast(?MODULE, {join, ClientPid, Nick}).

broadcast(FromPid, Msg) ->
    gen_server:cast(?MODULE, {broadcast, FromPid, Msg}).

%% Callbacks

init([]) ->
    {ok, #{clients => sets:new([{version, 2}])}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast({join, ClientPid, Nick}, State = #{clients := Clients}) ->
    io:format("New client connected: ~p ~n", [Nick]),
    monitor(process, ClientPid),

    NewClients = Clients#{ClientPid => Nick},
    {noreply, State#{clients := NewClients}};

handle_cast({broadcast, FromPid, Msg}, State = #{clients := Clients}) ->
    Nick = maps:get(FromPid, Clients, <<"???">>),
    Line = <<Nick/binary, ": ", Msg/binary>>,

    maps:foreach(
        fun(Pid, _Nick) when is_pid(Pid), Pid =/= FromPid ->
                Pid ! {chat_msg, Line};
           (_Pid, _Nick) -> ok
        end,
        Clients
    ),

    {noreply, State}.

handle_info({'DOWN', _Ref, process, Pid, _Reason}, State = #{clients := Clients}) ->
    NewClients = sets:del_element(Pid, Clients),
    {noreply, State#{clients := NewClients}};

handle_info(_Msg, State) ->
    {noreply, State}.
