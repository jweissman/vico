# vico

* [Homepage](https://rubygems.org/gems/vico)
* [Documentation](http://rubydoc.info/gems/vico/frames)
* [Email](mailto:jweissman1986 at gmail.com)

[![Code Climate GPA](https://codeclimate.com/github/jweissman/vico/badges/gpa.svg)](https://codeclimate.com/github/jweissman/vico)

> "The criterion and rule of the true is to have made it. Accordingly, our clear and distinct idea of the mind cannot be a criterion of the mind itself, still less of other truths. For while the mind perceives itself, it does not make itself." --Giambattista Vico

## PROTOCOL

VICO (the VOLUMINOUS INFORMATION CITY OMNIVERSE) responds to a text-based PROTOCOL composed of simple textual COMMANDS which trigger EVENTS.

### COMMANDS

**look** — trigger dispatch of a SURROUNDINGS event

**iam [name]** — assign this client a USERNAME

**go [north/south/east/west/down]** -- move client in direction (going 'down' into SUBSPACES may trigger a REDIRECTION event)

**drop** -- remove this client (no response will be sent) -- clients MUST send this

---

**register [city/block/zone] [name] [host] [port] [x-position] [y-position]** -- register this connection as a SUBSPACE of the target space, embedded at (x-position, y-position) in the target spaces map (this can be done recursively to build

**ping/pong** - a heartbeat check

### EVENTS

*SURROUNDINGS* — provide an [updated/current] local state for a given client -- this message is intended to be recieved by a particular client -- it has a list of visible PAWNs (with names, locations and a flag indicating whether it is the user -- `you` or not), a MAP and LEGEND, and metadata about the current SPACE (name)

*REDIRECTED* -- indicate the new server host and port to which the client should now address itself -- before redirecting itself clients may wish to keep a stack of visited servers to be able to implement an 'up' operation (pop the stack and direct back to the last server visited)

## Description

The architecture involves a WORLD SERVER which holds references to ZONE SERVERS.

Client connects to WORLD SERVER, and is flying above the world. When landing, they are directed to registered CITY SERVER which supports the local interaction.

`vico world` -- start a world server

`vico city` -- start a city server

[TODO `vico zone` -- start a zone server, register with city]

`vico text` -- connect to world server via line-mode interface

`vico screen` -- connect to world server via screen interface (see requirements)

(`vico universe` might run a registry of worlds.)

## Features

  - [~] World server
    - [~] Protocol
      - [x] View surroundings
      - [x] Names
      - [~] Movement
        - [x] Flying
        - [ ] Landing
        - [ ] Walking
        - [ ] Driving
    - [ ] Registry for zone servers
  - [~] Line-mode interface
    - [~] Movement
      - [x] Flying (over world)
      - [ ] Landing (into zone)
      - [ ] Walking (around zone)
      - [ ] Driving (between zones...?)
  - [~] Screen-mode interface
    - [~] Movement
      - [x] Flying
      - [ ] Landing
      - [ ] Walking
      - [ ] Driving
    - [ ] Modes
      - [ ] Command mode
      - [ ] Visual mode (select area)
  - [ ] Hail taxi
  - [ ] Summon guide

## Requirements

  - Ruby 2.4+
  - Curses (for `vico screen`)

## Install

    $ gem install vico

## Synopsis

Start the world server.

    $ vico world

Connect over line-mode interface:

    $ vico text
    ---> Launch text interface to world!
    ---> Text would connect to local world server...
    ---> Client would connect to host localhost...

    vico> iam joe
    Welcome to warlike_warthog, joe!

    vico> look
    You are flying over warlike_warthog. You see cities among vast forests. Landmark buildings peek above the canopy. You see 4 people: joe; joe; joe; tim

Connect over screen interface (curses):

    $ vico screen
    # ....

## Copyright

Copyright (c) 2017 Joseph Weissman

See {file:LICENSE.txt} for details.
