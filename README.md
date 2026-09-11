# erlChat


A minimal TCP chat server written in Erlang/OTP. Connect with `nc` (or any raw TCP client) and chat with anyone else connected to the same server.

## Features

- Plain TCP sockets (gen_tcp), no telnet negotiation required
- One lightweight process per connection
- A central gen_server room that tracks connected clients and broadcasts messages
- Nicknames — you're asked for one before joining
- Automatic cleanup on disconnect via process monitors (no manual bookkeeping needed)
- Supervised: the room and the listener restart automatically on crash

## Architecture

```text
erlchat_sup
├── erlchat_room       (gen_server — tracks Pid => Nick, broadcasts messages)
└── erlchat_listener   (accepts TCP connections, spawns one process per client)
        └── erlchat_client  (per-connection process, one per connected user)

Each client is its own Erlang process with no shared mutable state. If one
client crashes or disconnects abruptly, it doesn't affect anyone else — the
room's monitor detects the death and cleans up automatically.
```

## Build

    $ rebar3 compile

## Run

    $ rebar3 shell

By default the server listens on port 4000.

## Connect

In another terminal:

    $ nc localhost 4000

You'll be prompted for a nickname, then anything you type is broadcast to
everyone else connected.
