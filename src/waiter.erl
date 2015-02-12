-module(waiter).

%% ====================================================================
%% API functions
%% ====================================================================
-compile(export_all).
-import(timer, [sleep/1]).


start()->
	spawn_link(fun()-> permission() end).

permission()->
    io:format("Waiter waiting for an order!~n"),
	receive
		{Right1, Left1, F1}->
			receive
				{Right2, Left2,F2}->
					if 
						Right1/=Left2->
							if
								Left1/=Right2->
								io:format("GRANTING 2 Philosophers! ~n"),
								F1 ! grant,
								F2 ! grant,
								timetowait();
							true -> 
                                F1 ! grant,
								F2 ! nogrant,
								permission(Right1, Left1, F1)
							end;
					true->
						F1 ! grant,
                        F2 ! nogrant,
                        permission(Right1, Left1, F1)
					end
			after 100->
				F1 ! grant,
				permission(Right1, Left1, F1)
			end
    after 3000 ->
        io:format("No additional orders, waiter is OUT!~n")
	end.

permission(Right1, Left1, F1)->
	receive
		{Right2, Left2, F2} ->
			if 
				Right1/=Left2 ->
					if
						Left1/=Right2 ->
                            F2 ! grant,
							timetowait();
					    true -> 
							F2 ! nogrant,
							permission(Right1, Left1, F1)
							
					end;
                true ->
                    F2 ! nogrant,
                    permission(Right1, Left1, F1)
			end;
		done ->
			permission()
    after 5000 ->
        io:format("Deadlock after 5 seconds in permission/3!")
	end.

timetowait()->
	receive
		done->
			receive
				done->
					io:format("xxxxxxxxxxxxxxxxx Both Philosophers are done Eating xxxxxxxxxxxxxxxxx ~n"),
					permission()
			end;
        {Right1, Left1, F1} ->
            F1 ! nogrant,
            timetowait()
	    after 5000 ->
	        io:format("Missing reply from second philosopher!~n")
	end.

