-module(philosopher).

%% ====================================================================
%% API functions
%% ====================================================================
-compile(export_all).
-import(random, [uniform/1,request/1]).
-import(timer, [sleep/1]).

start(Hungry, Right, Left, Name, Ctrl,Waiter)->
	{N1,N2,N3} = now(),
	spawn_link(fun()-> 
					   random:seed(N1,N2,N3), 
					   init(Hungry, Right,Left,Name,Ctrl,Waiter) end).


init(0,_,_,Name,Ctrl,Waiter)->
	io:format("------------------ ~s Is full------------------ ~n", [Name]),
	Ctrl ! done;

init(Hungry, Right,Left,Name,Ctrl,Waiter)->
	Gui = gui:start(Name),
	dream(Hungry, Right, Left, Name, Ctrl, Waiter).
	

dream(Hungry, Right, Left, Name, Ctrl, Waiter) ->
	io:format("~s is now asleep. HUNGER=~p ~n", [Name,Hungry]),
    sleep(100, 500),
    order(Hungry, Right, Left, Name, Ctrl, Waiter).
	

sleep(T,D)->
	timer:sleep(T + random:uniform(D)).

order(Hungry, Right, Left, Name, Ctrl, Waiter)->
	Waiter ! {Right, Left, self()},
    %io:format("Requested sticks!~n"),
	receive
		grant->
            %io:format("Accepted ~s requesting sticks!~n", [Name]),
			chopstick:request(Right,Left,300, self()),
			receive
				success -> 
					io:format("~s Has Both Sticks ~n",[Name]),
					eat(Hungry,Right,Left,Name,Ctrl,Waiter);
				no ->
					io:format("~s Was denied eating w Sticks!~n",[Name]),
					order(Hungry,Right,Left,Name,Ctrl,Waiter)
			end;
		nogrant->
            %io:format("Denied! ~s went back to sleep", [Name]),
			dream(Hungry,Right,Left,Name,Ctrl,Waiter)

        after 1000 ->
            io:format("Deadlock after 1 second, no reply from waiter! Trying again~n"),
            order(Hungry, Right, Left, Name, Ctrl, Waiter)
	end.
	

eat(Hungry,Right,Left,Name,Ctrl,Waiter)-> 
	io:format("------------------------ ~s is now eating------------------------ ~n", [Name]),
	sleep(100, 500),
	io:format("~s returned sticks....~n", [Name]),
	chopstick:return(Right),
	chopstick:return(Left),
	Waiter ! done,
	init(Hungry-1,Right,Left,Name,Ctrl,Waiter).

