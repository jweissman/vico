# VICO (VOLUMINOUS INFORMATION CITY OMNIVERSE)

* [Homepage](https://rubygems.org/gems/vico)
* [Documentation](http://rubydoc.info/gems/vico/frames)
* [Email](mailto:jweissman1986 at gmail.com)

[![Code Climate GPA](https://codeclimate.com/github//vico/badges/gpa.svg)](https://codeclimate.com/github//vico)

> "The criterion and rule of the true is to have made it. Accordingly, our clear and distinct idea of the mind cannot be a criterion of the mind itself, still less of other truths. For while the mind perceives itself, it does not make itself." --Giambattista Vico


## PROTOCOL

VICO (the VOLUMINOUS INFORMATION CITY OMNIVERSE) responds to a text-based PROTOCOL composed of simple COMMANDS which trigger EVENTS

### COMMANDS

**look** — trigger dispatch of a SURROUNDINGS event

**iam [name]** — assign this client a USERNAME

### EVENTS

*SURROUNDINGS* — provide an [updated/current] local map

*USERNAME* — indicates a player has changed their name


## Description

The architecture involves a WORLD SERVER which holds references to ZONE SERVERS.

Client connects to WORLD SERVER, and is flying above the world. They are "redirected" to relevant ZONE SERVER which supports the 'local' interaction.

`vico world` -- start a world server
`vico zone` -- start a zone server, register with world
`vico text` -- connect to world server via line-mode interface
`vico screen` -- connect to world server via screen interface (see requirements)

## Features

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
