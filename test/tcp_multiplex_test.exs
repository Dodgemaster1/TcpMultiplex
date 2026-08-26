defmodule TcpMultiplexTest do
  use ExUnit.Case
  doctest TcpMultiplex

  test "greets the world" do
    assert TcpMultiplex.hello() == :world
  end
end
