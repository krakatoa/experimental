-module(rotations).
-export([rotations/1, rotations/3]).

rotations(Word) when is_list(Word) ->
  io:format("(length of ~p: ~p)\n", [Word, length(Word)]),
  rotations(Word, [], length(Word));
rotations(Number) when is_integer(Number) ->
  rotations(integer_to_list(Number)).

rotations(Word, Acc, TimesLeft) when TimesLeft > 0 ->

% alternative 1
%  [Head|Tail] = Word,
%% RotatedWord = lists:flatten([Tail|Head]),

% alternative 2
%  [Head|Tail] = Word,
%  RotatedWord = lists:append(Tail, [Head]),

  [Head|Tail] = Word,
  RotatedWord = Tail++[Head],

  io:format("rotated word: ~p\n", [RotatedWord]),

  case exists(RotatedWord, Acc) of
    false -> rotations(RotatedWord, lists:append(Acc, [RotatedWord]), TimesLeft - 1);
    true -> rotations(RotatedWord, Acc, TimesLeft - 1)
  end;
rotations(Word, Acc, 0) ->
  Acc.

exists(El, List) ->
  lists:any(fun(X) -> X == El end, List).
