%% @author HassanNazar

-module(chopstick).

%% ====================================================================
%% API functions
%% ====================================================================
-compile(export_all).


start() ->
	spawn_link(fun()-> available() end).

available()->
	receive
		{request,From} ->
			From ! available,
			available();
		{taken,From}->
			From ! ok,
			gone();
		quit ->
			ok
	end.

gone()->
	receive
		{request, _} -> gone(); % Hanterar vi alla calls som lagrats i Queue???
		return ->
			available();
		quit ->
			ok
	end.
			

request(StickR,StickL,Timeout, Phil)->
	StickR ! {request,self()},
	StickL ! {request,self()},
	granted(StickR,StickL,Timeout,Phil).

granted(StickR,StickL,Timeout, Phil)->
	receive
		available->	
			receive
				available->
					StickR ! {taken,Phil},
					StickL ! {taken,Phil},
					receive
						ok->
							receive
								ok->
									Phil ! success
							end
					end
				after Timeout->
					Phil ! no
			end
		after Timeout->
			Phil ! no
	end.

return(Stick)->
	Stick ! return.
	

quit(Stick)->
	Stick ! quit.
%% ====================================================================
%% Internal functions
%% ====================================================================
