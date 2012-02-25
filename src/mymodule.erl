-module(mymodule).

-export([new/0,
         nif_bin_size/2]).

-on_load(init/0).

-define(nif_stub, nif_stub_error(?LINE)).
nif_stub_error(Line) ->
    erlang:nif_error({nif_not_loaded,module,?MODULE,line,Line}).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

init() ->
    PrivDir = case code:priv_dir(?MODULE) of
                  {error, bad_name} ->
                      EbinDir = filename:dirname(code:which(?MODULE)),
                      AppPath = filename:dirname(EbinDir),
                      filename:join(AppPath, "priv");
                  Path ->
                      Path
              end,
    erlang:load_nif(filename:join(PrivDir, erlniftest_drv), 0).

new() ->
    ?nif_stub.

nif_bin_size(_Ref, _IOList) ->
    ?nif_stub.

%% ===================================================================
%% EUnit tests
%% ===================================================================
-ifdef(TEST).

basic_test() ->
    {ok, Ref} = new(),
    ?assertEqual(3, nif_bin_size(Ref, ["bla"])),
    ?assertEqual(3, nif_bin_size(Ref, <<"abc"/utf8>>)),
    ?assertEqual(1, nif_bin_size(Ref, [910275])).



-endif.
