-module(shop).
-export([cost/2]).

cost(oranges, Cost) -> 5 * Cost;
cost(mil, Cost) -> 7 * Cost.
