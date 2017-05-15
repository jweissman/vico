# vico

* [Homepage](https://rubygems.org/gems/vico)
* [Documentation](http://rubydoc.info/gems/vico/frames)
* [Email](mailto:jweissman1986 at gmail.com)

[![Code Climate GPA](https://codeclimate.com/github//vico/badges/gpa.svg)](https://codeclimate.com/github//vico)

## Description

so there's a WORLD SERVER which holds references to ZONE SERVERS

client connects to WORLD SERVER, is redirected to relevant ZONE SERVER which hosts the interaction

`bin/vico world` -- start a world server
`bin/vico zone --address 1234` -- start a zone server, register with world
`bin/vico text` -- connect to world server via text interface

## Features

## Examples

    require 'vico'

## Requirements

## Install

    $ gem install vico

## Synopsis

    $ vico

## Copyright

Copyright (c) 2017 Joseph Weissman

See {file:LICENSE.txt} for details.
