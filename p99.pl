/* 
prolog 99 problems
*/

:- module(p99,
          [
              my_last/2,
              last_but_one/2,
              element_at/3,
              list_length/2,
              reverse_list/2,
              palindrome/1,
              my_flatten/2,
              compress/2,
              split_same/3,
              pack/2,
              encode/2,
              encode_modified/2,
              repeat/3,
              decode/2,
              encode_direct/2,
              encode_direct1/3,
              dupli/2,
              dupli/3,
              drop/3,
              my_split/4,
              slice/4
                           
              ]).

/*
complete:
2014.10.23
1 ok 2 ok 3 ok 4 ok 5 ok 6 ok 7 ok 8 ok 9 ok 10 ok
11 ok 12 ok 
13 
14 ok 15 ok

2014.10.24
13 ok  16 ok   17 ok  18 ok
13: 传递状态递归

*/
gen_99(99):-write(99).
gen_99(N):-write(N), nl,
           N1 is N + 1,
           gen_99(N1).
/*
P01 (*) Find the last element of a list.
Example:
?- my_last(X,[a,b,c,d]).
X = d
*/
my_last(H, [H]):-!.
my_last(R, [_|T]) :- my_last(R, T), !.

%% P02 (*) Find the last but one element of a list.

last_but_one(R, [R, _]):-!.
last_but_one(R, [_, X|T]) :- last_but_one(R, [X|T]), !.


/*
P03 (*) Find the K'th element of a list.
The first element in the list is number 1.
Example:
?- element_at(X,[a,b,c,d,e],3).
X = c
*/
element_at(H, [H|_], 1):-!.
element_at(R, [_|T], N) :-
    N1 is N - 1,
    element_at(R, T, N1), !.

%% P04 (*) Find the number of elements of a list.
list_length(0, []):-!.
list_length(R, [_|T]) :- 
    list_length(R1, T),
    R is R1 + 1.

%% P05 (*) Reverse a list.

concat([], L, L).
concat([H | T], L, [H | T2]) :- 
    concat(T, L, T2).

reverse_list([], []):-!.
reverse_list([H], [H]):-!.
reverse_list(R, [H|T]) :-
    reverse_list(TR, T),
    concat(TR, [H], R).

/*
P06 (*) Find out whether a list is a palindrome.
A palindrome can be read forward or backward; e.g. [x,a,m,a,x].
*/

palindrome([]).
palindrome([_]):-!.
palindrome([H|T]):-
    my_last(H, T),
    concat(T1, [H], T),
    palindrome(T1), !.

/*
P07 (**) Flatten a nested list structure.
Transform a list, possibly holding lists as elements into a `flat' list by replacing each list with its elements (recursively).

Example:
?- my_flatten([a, [b, [c, d], e]], X).
X = [a, b, c, d, e]

Hint: Use the predefined predicates is_list/1 and append/3
*/

my_flatten([], []):-!.
my_flatten([H|T], [H|TR]) :-
    \+ is_list(H),  % not a list
    my_flatten(T, TR), !.
my_flatten([H|T], R):-
    is_list(H),
    my_flatten(H, HR),
    my_flatten(T, TR),
    append(HR, TR, R), !.

/*
P08 (**) Eliminate consecutive duplicates of list elements.
If a list contains repeated elements they should be replaced with a single copy of the element. The order of the elements should not be changed.

Example:
?- compress([a,a,a,a,b,c,c,a,a,d,e,e,e,e],X).
X = [a,b,c,a,d,e]
*/
compress([], []):-!.
compress([H], [H]):-!.
compress([H, H | T], TR):- 
    compress([H|T], TR), !.
compress([H, K | T], [H|TR]):-
    compress([K|T], TR), !.

/*
P09 (**) Pack consecutive duplicates of list elements into sublists.
If a list contains repeated elements they should be placed in separate sublists.

Example:
?- pack([a,a,a,a,b,c,c,a,a,d,e,e,e,e],X).
X = [[a,a,a,a],[b],[c,c],[a,a],[d],[e,e,e,e]]
*/   


% helper: split_same([a,a,b,b,c], [a,a],[b,b,c]).
split_same([], [], []):-!.
split_same([H], [H], []):-!.
split_same([H, H|T], [H|R1], TR):-
    split_same([H|T], R1, TR), !.
split_same([H, K|T], [H], [K|T]):-!.

pack([], []):-!.
pack([H], [[H]]):-!.
pack(L, [HR | TR]):-
    split_same(L, HR, Rest),
    pack(Rest, TR),!.

/*
P10 (*) Run-length encoding of a list.
Use the result of problem P09 to implement the so-called run-length encoding data compression method. Consecutive duplicates of elements are encoded as terms [N,E] where N is the number of duplicates of the element E.

Example:
?- encode([a,a,a,a,b,c,c,a,a,d,e,e,e,e],X).
X = [[4,a],[1,b],[2,c],[2,a],[1,d][4,e]]
*/
count([], 0):-!.
count([_|T], N) :-
    count(T, N1),
    N is N1 + 1, !.

count_list([], []):-!.
count_list([H|T], [[C, E] | TR]):-
    count(H, C),
    [E|_] = H, 
    count_list(T, TR),
    !.
    
encode([], []):-!.
encode(L, R) :-
    pack(L, LR),
    count_list(LR, R), !.

/*
P11 (*) Modified run-length encoding.
Modify the result of problem P10 in such a way that if an element has no duplicates it is simply copied into the result list. Only elements with duplicates are transferred as [N,E] terms.

Example:
?- encode_modified([a,a,a,a,b,c,c,a,a,d,e,e,e,e],X).
X = [[4,a],b,[2,c],[2,a],d,[4,e]]
*/

count_list2([], []):-!.
count_list2([[H]|T], [H | TR]):-
    count_list2(T, TR), !.
count_list2([H|T], [[C, E] | TR]):-
    count(H, C),
    C > 1,
    [E|_] = H, 
    count_list2(T, TR),
    !.

encode_modified([], []):-!.
encode_modified(L, R):-
    pack(L, LR),
    count_list2(LR, R), !.

/*
P12 (**) Decode a run-length encoded list.
Given a run-length code list generated as specified in problem P11. Construct its uncompressed version.
*/

repeat(X, 1, [X]):-!.
repeat(X, N, [X|T]) :- 
    N > 1,
    N1 is N - 1,
    repeat(X, N1, T), !.

decode([], []) :- !.
decode([[N, E] | T], R):-
    repeat(E, N, EL),
    decode(T, TR),
    append(EL, TR, R), !.
decode([H|T], [H|TR]):-
    decode(T, TR), !.
    
/*
P13 (**) Run-length encoding of a list (direct solution).
Implement the so-called run-length encoding data compression method directly. I.e. don't explicitly create the sublists containing the duplicates, as in problem P09, but only count them. As in problem P11, simplify the result list by replacing the singleton terms [1,X] by X.

Example:
?- encode_direct([a,a,a,a,b,c,c,a,a,d,e,e,e,e],X).
X = [[4,a],b,[2,c],[2,a],d,[4,e]]
*/

encode_direct(L, R):-
    encode_direct1(L, [], R), !.

encode_direct1([], [], []):-!.
encode_direct1([], [1, H], [H]):-!.
encode_direct1([], [N, H], [[N, H]]):-!.

encode_direct1([H|T], [], RT):-
    encode_direct1(T, [1, H], RT), !.

encode_direct1([H|T], [N, H], RT):-
    N1 is N + 1,
    encode_direct1(T, [N1, H], RT), !.

encode_direct1([K|T], [1, H], [H|RT]) :-
    encode_direct1([K|T], [], RT), !.

encode_direct1([K|T], [N, H], [[N, H]|RT]) :- 
    encode_direct1([K|T], [], RT), !.

/*
P14 (*) Duplicate the elements of a list.
Example:
?- dupli([a,b,c,c,d],X).
X = [a,a,b,b,c,c,c,c,d,d]
*/
dupli([], []):-!.
dupli([H|T], [H,H | TR]):-
    dupli(T, TR), !.

/*
P15 (**) Duplicate the elements of a list a given number of times.
Example:
?- dupli([a,b,c],3,X).
X = [a,a,a,b,b,b,c,c,c]

What are the results of the goal:
?- dupli(X,3,Y).
*/
dupli([], _, []):-!.
dupli(_, 0, []):-!.
dupli([H|T], N, R):-
    repeat(H, N, HR),
    dupli(T, N, TR),
    append(HR, TR, R), !.
    
/*
P16 (**) Drop every N'th element from a list.
Example:
?- drop([a,b,c,d,e,f,g,h,i,k],3,X).
X = [a,b,d,e,g,h,k]
*/

drop(L, N, R) :- drop1(N, L, N, R).
    
drop1(_, [], _, []):-!.
drop1(ON, [_|T], 1, R):-
        drop1(ON, T, ON, R), !.

drop1(ON, [H|T], N, [H|TR]):-
    N1 is N - 1,
    drop1(ON, T, N1, TR), !.

/*
P17 (*) Split a list into two parts; the length of the first part is given.
Do not use any predefined predicates.

Example:
?- split([a,b,c,d,e,f,g,h,i,k],3,L1,L2).
L1 = [a,b,c]
L2 = [d,e,f,g,h,i,k]
*/
my_split([], _, [], []):-!.

my_split(L, 0, [], L):-!.
my_split([H|T], N, [H|R1], TR):-
    N1 is N - 1,
    my_split(T, N1, R1, TR), !.
 
/*
P18 (**) Extract a slice from a list.
Given two indices, I and K, the slice is the list containing the elements between the I'th and K'th element of the original list (both limits included). Start counting the elements with 1.

Example:
?- slice([a,b,c,d,e,f,g,h,i,k],3,7,L).
X = [c,d,e,f,g]
*/
slice([], _, _, []):-!.

slice([H|_], 1, 1, [H]):-!.
slice([H|T], 1, N, [H|RT]):-
    N > 1,
    N1 is N - 1,
    slice(T, 1, N1, RT), !.

slice([_|T], S, N, RT):-
    S > 1,
    S1 is S - 1,
    N1 is N - 1,
    slice(T, S1, N1, RT), !.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
:- begin_tests(p99).
%18
test(slice) :- slice([], 1,3,[]).
test(slice) :- slice([a,b], 1,3,[a,b]).
test(slice) :- slice([a,b,c,d,e,f], 1,1,[a]).
test(slice) :- slice([a,b,c,d,e,f], 1,3,[a,b,c]).
test(slice) :- slice([a,b,c,d,e,f,g,h,i,j,k], 3,7,[c,d,e,f,g]).


%17
test(my_split):-my_split([], 3, [], []).
test(my_split):-my_split([a], 1, [a], []).
test(my_split):-my_split([a], 3, [a], []).
test(my_split):-my_split([a,b,c,d], 3, [a,b,c], [d]).
test(my_split):-my_split([a,b,c,d,e,f,g,h,i,j,k], 3, [a,b,c], [d,e,f,g,h,i,j,k]).

%16
test(drop) :- drop([], 3, []).
test(drop) :- drop([a,b,c], 1, []).
test(drop) :- drop([a,b,c,d,e,f,g], 2, [a,c,e,g]).
test(drop) :- drop([a,b,c,d,e,f,g,h], 2, [a,c,e,g]).
test(drop) :- drop([a,b,c,d,e,f,g,h,i,k],3, [a,b,d,e,g,h,k]).

%15
test(dupliN) :- dupli([], 10, []).
test(dupliN) :- dupli([a], 1, [a]).
test(dupliN) :- dupli([a,b], 1, [a,b]).
test(dupliN) :- dupli([a,b], 2, [a,a, b, b]).
test(dupliN) :- dupli([a,b], 3, [a,a,a,b,b,b]).
test(dupliN) :- dupli([a,b], 0, []).

%14
test(dupli) :- dupli([], []).
test(dupli) :- dupli([a], [a,a]).
test(dupli) :- dupli([a,b], [a,a,b,b]).

%13
test(encode_direct) :- encode_direct([], []).
test(encode_direct) :- encode_direct([a], [a]).
test(encode_direct) :- encode_direct([a,a,b], [[2,a], b]).
test(encode_direct) :- encode_direct([a,a,a,a,b,c,c,a,a,d,e,e,e,e],
                                     [[4,a],b,[2,c],[2,a],d,[4,e]]
                                    ).


%12
test(decode) :- decode([], []).
test(decode) :- decode([a], [a]).
test(decode) :- decode([[2,a], b], [a,a,b]).
test(decode) :- decode([[4,a],b,[2,c],[2,a],d,[4,e]],
                       [a,a,a,a,b,c,c,a,a,d,e,e,e,e]).


%11
test(encode_modified) :- encode_modified([], []).
test(encode_modified) :- encode_modified([a], [a]).
test(encode_modified) :- encode_modified([a,a,b], [[2,a], b]).
test(encode_modified)
:- encode_modified([a,a,a,a,b,c,c,a,a,d,e,e,e,e],
                   [[4,a],b,[2,c],[2,a],d,[4,e]]
                  ).

%10
test(encode) :- encode([], []).
test(encode) :- encode([a], [[1,a]]).
test(encode) :- encode([a,a], [[2,a]]).
test(encode) :- encode([a,b], [[1,a],[1,b]]).
test(encode) :- encode([a,a,a,a,b,c,c,a,a,d,e,e,e,e], 
                       [[4,a],[1,b],[2,c],[2,a],[1,d],[4,e]]).

% 9
test(split_same) :- split_same([], [], []).
test(split_same) :- split_same([a], [a], []).
test(split_same) :- split_same([a,b], [a], [b]).
test(split_same) :- split_same([a,a, b], [a, a], [b]).
test(split_same) :- split_same([a,a, b,b], [a, a], [b,b]).

test(pack) :- pack([], []).
test(pack) :- pack([a], [[a]]).
test(pack) :- pack([a, a], [[a, a]]).
test(pack) :- pack([a, a, b], [[a, a], [b]]).
test(pack) :- pack([a, a, b, b], [[a, a], [b, b]]).
test(pack) :- pack([a,a,a,a,b,c,c,a,a,d,e,e,e,e], [[a,a,a,a],[b],[c,c],[a,a],[d],[e,e,e,e]]).

% 8
test(compress) :- compress([], []).
test(compress) :- compress([a], [a]).
test(compress) :- compress([a, b], [a, b]).
test(compress) :- compress([a, a, b, b], [a, b]).
test(compress) :- compress([a, a, b, b, a], [a, b, a]).


% 7
test(my_flatten) :- my_flatten([], []).
test(my_flatten) :- my_flatten([a], [a]).
test(my_flatten) :- my_flatten([a, b], [a, b]).
test(my_flatten) :- my_flatten([a, [b]], [a, b]).
test(my_flatten) :- my_flatten([a, [b], c], [a, b, c]).
test(my_flatten) :- my_flatten([a, [b, [c]], d], [a, b, c, d]).

% 6
test(palindrome) :- palindrome([]).
test(palindrome) :- palindrome([a]).
test(palindrome) :- palindrome([x,a,m,a,x]).

% 5
test(reverse_list) :- reverse_list([], []).
test(reverse_list) :- reverse_list([1], [1]).
test(reverse_list) :- reverse_list([1,2], [2, 1]).
test(reverse_list) :- reverse_list([1,2,3], [3, 2, 1]).

% 4
test(list_length) :- list_length(0, []).
test(list_length) :- list_length(1, [a]).
test(list_length) :- list_length(3, [a, b, c]).

% 3
test(element_at) :- element_at(a, [a], 1).
test(element_at) :- element_at(b, [a, b], 2).
test(element_at) :- element_at(c, [a,b,c], 3).
test(element_at) :- element_at(c, [a,b,c,d,e], 3).

% 2
test(last_but_one) :- last_but_one(1, [1, 2]).
test(last_but_one) :- last_but_one(2, [1, 2, 3]).

% 1
test(my_last) :- my_last(a, [a]).
test(my_last) :- my_last(d, [a,b,c,d]).


:- end_tests(p99).
