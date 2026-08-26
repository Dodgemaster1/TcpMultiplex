set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]

[doc("All command information")]
help:
    @just --list --unsorted

dev:
    mix run --no-halt

prod $MIX_ENV="prod":
    mix run --no-halt

alias ir := interactive_run
interactive_run:
    iex -S mix

alias f := format
format:
    mix format

release:
    mix release --overwrite

bin:
    _build/dev/rel/tcp_multiplex/bin/tcp_multiplex

alias t := test
test:
    mix test

version := `grep -oE 'version:\s*"([^"]+)"' mix.exs | cut -d'"' -f2`

print-version:
    @echo "Current version is: {{version}}"

tag:
    git tag v{{version}}
