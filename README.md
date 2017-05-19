# vico

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

**register [city/block/zone] [name] [host] [port] [x-position] [y-position]** -- register this connection as a SUBSPACE of the target space, embedded at (x-position, y-position) in the target spaces map (this can be done recursively to create complex distributed structures)

**ping/pong** - a heartbeat check

### EVENTS

EVENTS contain information about the user's surroundings, changes in surroundings or details about other important activity happening in the world.

In general an event containing SURROUNDINGS will provids an [updated/current] local state for a given client, and is intended to be consumed by a particular client; it contains a list of visible PAWNs (with names, locations and a flag indicating whether it is the user -- `you` or not), a MAP and LEGEND, and metadata about the current SPACE (name).

Some events may indicate the client has been *REDIRECTED*. In this case the EVENT will contain details about the new server. Clients may wish to keep a stack of visited servers to be able to implement an 'up' operation (pop the stack and direct back to the last server visited.)

## Description

The architecture involves a WORLD SERVER which holds references to CITY SERVERS.

Client connects to WORLD SERVER, and is flying above the world. When landing, they are directed to registered CITY SERVER which then supports the interaction.

`vico world` -- start a world server

`vico city` -- start a city server

`vico text` -- connect to world server via line-mode interface

`vico screen` -- connect to world server via screen interface (see requirements)

(`vico universe` might run a registry of worlds.)

## Features

  - [x] Flying
  - [x] Link cities to worlds
  - [x] Line-mode client
  - [x] Screen-mode client
  - [x] Persist cities and worlds to database
  - [ ] Reclaim usable territory from the void
  - [ ] Manipulate landscape/terrain
  - [ ] Create entities
  - [ ] Create structure (local sub-space)
  - [ ] Command mode for `screen` client (`:the cmd`)
  - [ ] Model metaphors: neighborhoods, buildings, rooms; filing cabinets (filesystems)
  - [ ] Language/controller extensions (?)

## Requirements

  - Ruby 2.4+
  - Curses (for `vico screen`)

## Install

    $ gem install vico

## Synopsis

Start the world server.

    $ vico world

Start a city server:

    $ vico city

Connect over line-mode interface:

    $ vico text
    ---> Launch text interface to world!
    ---> Text would connect to local world server...
    ---> Client would connect to host localhost...
    Welcome to wannabe_wallaby, joe!
    You are flying over wannabe_wallaby.You see cities among vast forests: hotlanta.
    vico> look
    You are flying over wannabe_wallaby.You see cities among vast forests: hotlanta.
    vico> go hotlanta
    You move to hotlanta at [2, 2]
    vico> go down
    You enter Hotlanta!
    (FOLLOW REDIRECT TO localhost:7070)
    REDIRECT CLIENT TO localhost:7070
    ---> Client would connect to host localhost...
    Welcome to hotlanta, joe!
    You are flying over hotlanta.

Connect over screen interface (curses):

    $ vico screen
    # ....[gif here?]....

## Copyright

Copyright (c) 2017 Joseph Weissman

See {file:LICENSE.txt} for details.
