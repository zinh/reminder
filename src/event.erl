-module(event).
-compile(export_all).

-record(state, {server, name="", to_go=0}).

%%Export function
start(Event, Time) ->
  spawn(?MODULE, init, [self(), Event, Time]).

init(Server, EventName, Time) ->
  loop(#state{server=Server, name=EventName, to_go=normalize(Time)}).

loop(S = #state{server = Server, to_go = [Time | Remain]}) ->
  receive
    {Server, Ref, cancel} ->
      Server ! {Ref, ok}
  after Time*1000 ->
      if Remain =:= [] ->
        Server ! {done, S#state.name};
        Remain =/= [] ->
          loop(S#state{to_go = Remain})
      end
  end.

%%Internal function
normalize(Time) ->
  Limit = 49*24*60*60,
  [Time rem Limit | lists:duplicate(Time div Limit, Limit)].
