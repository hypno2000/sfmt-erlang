%% @author Kenji Rikitake <kenji.rikitake@acm.org>
%% @author Mutsuo Saito
%% @author Makoto Matsumoto
%% @author Dan Gudmundsson
%% @doc SIMD-oriented Fast Mersenne Twister (SFMT) EUnit testing functions.
%% The module provides EUnit testing functions for the sfmt86243 module functions.
%% (for period ((2^86243) - 1))
%% @reference <a href="http://github.com/jj1bdx/sfmt-erlang">GitHub page
%% for sfmt-erlang</a>
%% @copyright 2010-2011 Kenji Rikitake and Kyoto University.
%% Copyright (c) 2006, 2007 Mutsuo Saito, Makoto Matsumoto and
%% Hiroshima University.

%% Copyright (c) 2010-2011 Kenji Rikitake and Kyoto University. All rights
%% reserved.
%%
%% Copyright (c) 2006,2007 Mutsuo Saito, Makoto Matsumoto and Hiroshima
%% University. All rights reserved.
%%
%% Redistribution and use in source and binary forms, with or without
%% modification, are permitted provided that the following conditions are
%% met:
%%
%%     * Redistributions of source code must retain the above copyright
%%       notice, this list of conditions and the following disclaimer.
%%     * Redistributions in binary form must reproduce the above
%%       copyright notice, this list of conditions and the following
%%       disclaimer in the documentation and/or other materials provided
%%       with the distribution.
%%     * Neither the names of the Hiroshima University and the Kyoto
%%       University nor the names of its contributors may be used to
%%       endorse or promote products derived from this software without
%%       specific prior written permission.
%%
%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
%% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
%% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
%% A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
%% OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
%% SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
%% LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
%% DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
%% THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
%% (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
%% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-module(sfmt86243_tests).

-export([
	 test_speed/0,
	 test_short_speed/0
	 ]).

test_speed_rand_rec1(0, _, _) ->
    ok;
test_speed_rand_rec1(X, Q, I) ->
    {_, I2} = sfmt86243:gen_rand_list32(Q, I),
    test_speed_rand_rec1(X - 1, Q, I2).

test_speed_rand(P, Q) ->
    statistics(runtime),
    I = sfmt86243:init_gen_rand(1234),
    ok = test_speed_rand_rec1(P, Q, I),
    {_, T} = statistics(runtime),
    T.

test_speed_sfmt_uniform_rec1(Acc, 0, _, _, _) ->
    lists:reverse(Acc),
    ok;
test_speed_sfmt_uniform_rec1(Acc, X, 0, R, I) ->
    lists:reverse(Acc),
    test_speed_sfmt_uniform_rec1([], X - 1, R, R, I);
test_speed_sfmt_uniform_rec1(Acc, X, Q, R, I) ->
    {F, I2} = sfmt86243:uniform_s(I),
    test_speed_sfmt_uniform_rec1([F|Acc], X, Q - 1, R, I2).

test_speed_sfmt_uniform(P, Q) ->
    statistics(runtime),
    I = sfmt86243:seed(),
    ok = test_speed_sfmt_uniform_rec1([], P, Q, Q, I),
    {_, T} = statistics(runtime),
    T.

test_speed_orig_uniform_rec1(Acc, 0, _, _, _) ->
    lists:reverse(Acc),
    ok;
test_speed_orig_uniform_rec1(Acc, X, 0, R, I) ->
    lists:reverse(Acc),
    test_speed_orig_uniform_rec1([], X - 1, R, R, I);
test_speed_orig_uniform_rec1(Acc, X, Q, R, I) ->
    {F, I2} = random:uniform_s(I),
    test_speed_orig_uniform_rec1([F|Acc], X, Q - 1, R, I2).

test_speed_orig_uniform(P, Q) ->
    statistics(runtime),
    I = random:seed(),
    ok = test_speed_orig_uniform_rec1([], P, Q, Q, I),
    {_, T} = statistics(runtime),
    T.

test_speed_rand_max_rec1(Acc, 0, _, _, _) ->
    lists:reverse(Acc),
    ok;
test_speed_rand_max_rec1(Acc, X, 0, R, I) ->
    lists:reverse(Acc),
    test_speed_rand_max_rec1([], X - 1, R, R, I);
test_speed_rand_max_rec1(Acc, X, Q, R, I) ->
    {F, I2} = sfmt86243:gen_rand32_max(10000, I),
    test_speed_rand_max_rec1([F|Acc], X, Q - 1, R, I2).

test_speed_rand_max(P, Q) ->
    statistics(runtime),
    I = sfmt86243:init_gen_rand(1234),
    ok = test_speed_rand_max_rec1([], P, Q, Q, I),
    {_, T} = statistics(runtime),
    T.

test_speed_orig_uniform_n_rec1(Acc, 0, _, _, _) ->
    lists:reverse(Acc),
    ok;
test_speed_orig_uniform_n_rec1(Acc, X, 0, R, I) ->
    lists:reverse(Acc),
    test_speed_orig_uniform_n_rec1([], X - 1, R, R, I);
test_speed_orig_uniform_n_rec1(Acc, X, Q, R, I) ->
    {F, I2} = random:uniform_s(10000, I),
    test_speed_orig_uniform_n_rec1([F|Acc], X, Q - 1, R, I2).

test_speed_orig_uniform_n(P, Q) ->
    statistics(runtime),
    I = random:seed(),
    ok = test_speed_orig_uniform_n_rec1([], P, Q, Q, I),
    {_, T} = statistics(runtime),
    T.

%% @doc running speed test for 100 times of
%% 100000 calls for sfmt86243:gen_rand32/1, sfmt86243:uniform_s/1,
%% random:uniform_s/1, sfmt86243:gen_rand32_max/2, and random:uniform_s/2.

test_speed() ->
    io:format("{rand, sfmt_uniform, orig_uniform, rand_max, orig_uniform_n}~n~p~n",
	      [{test_speed_rand(100, 100000),
		test_speed_sfmt_uniform(100, 100000),
		test_speed_orig_uniform(100, 100000),
	        test_speed_rand_max(100, 100000),
		test_speed_orig_uniform_n(100, 100000)}
	      ]).

%% @doc running speed test for 10 times of
%% 10000 calls for sfmt:gen_rand32/1, sfmt:uniform_s/1,
%% random:uniform_s/1, sfmt:gen_rand32_max/2, and random:uniform_s/2.

test_short_speed() ->
    io:format("{rand, sfmt_uniform, orig_uniform, rand_max, orig_uniform_n}~n~p~n",
	      [{test_speed_rand(10, 10000),
		test_speed_sfmt_uniform(10, 10000),
		test_speed_orig_uniform(10, 10000),
	        test_speed_rand_max(10, 10000),
		test_speed_orig_uniform_n(10, 10000)}
	      ]).

%% EUnit test functions

-ifdef(TEST).

-include_lib("eunit/include/eunit.hrl").

%% @doc gen_rand32 and gen_rand_float API tests

gen_rand_tests() ->
    I0 = sfmt86243:init_gen_rand(1234),
    {N1, I1} = sfmt86243:gen_rand32(I0),
    ?assert(is_integer(N1)),
    {N2, _I2} = sfmt86243:gen_rand32(I1),
    ?assert(is_integer(N2)),
    {F3, I3} = sfmt86243:gen_rand_float(I0),
    ?assert(is_float(F3)),
    {F4, _I4} = sfmt86243:gen_rand_float(I3),
    ?assert(is_float(F4)),
    {Outarray0, _I5} = sfmt86243:gen_rand_list_float(10, I0),
    ?assert(is_float(hd(Outarray0))),
    ?assertMatch(10, length(Outarray0)),
    {N6, I6} = sfmt86243:gen_rand32_max(10000, I0),
    ?assert(is_integer(N6)),
    ?assert(N6 < 10000),
    {N7, _I7} = sfmt86243:gen_rand32_max(10000, I6),
    ?assert(is_integer(N7)),
    ?assert(N7 < 10000).
    
test_rec1(0, Acc, RS) ->
     {lists:reverse(Acc), RS};
test_rec1(I, Acc, RS) ->
     {Val, RS2} = sfmt86243:gen_rand32(RS),
     test_rec1(I - 1, [Val | Acc], RS2).

%% @doc  Value tests of the first 10000 random numbers 
%%       initialized by init_gen_rand/1 by gen_rand_list32/2.

value_tests_1() ->
    {Refrand, _Refarray} = test_refval(),
    Int1 = sfmt86243:init_gen_rand(1234),
    {Outarray1, Int2} = sfmt86243:gen_rand_list32(10000, Int1),
    ?assertEqual(Refrand, lists:reverse(
			    lists:nthtail(10000 - length(Refrand),
					  lists:reverse(Outarray1)))),
    {Outarray2, _Int3} = sfmt86243:gen_rand_list32(10000, Int2),
    {Outarray3, RS4} = test_rec1(10000, [], {[], Int1}),
    ?assertEqual(Outarray3, Outarray1),
    {Outarray4, _RS5} = test_rec1(10000, [], RS4),
    ?assertEqual(Outarray4, Outarray2).

%% @doc  Value tests of the first 10000 random numbers 
%%       initialized by init_by_list32/1 by gen_rand_list32/2.

value_tests_2() ->
    {_Refrand, Refarray} = test_refval(),
    Int1 = sfmt86243:init_by_list32([16#1234, 16#5678, 16#9abc, 16#def0]),
    {Outarray1, Int2} = sfmt86243:gen_rand_list32(10000, Int1),
    ?assertEqual(Refarray,
		 lists:reverse(
		   lists:nthtail(10000 - length(Refarray),
				 lists:reverse(Outarray1)))),
    {Outarray2, _Int3} = sfmt86243:gen_rand_list32(10000, Int2),
    {Outarray3, RS4} = test_rec1(10000, [], {[], Int1}),
    ?assertEqual(Outarray3, Outarray1),
    {Outarray4, _RS5} = test_rec1(10000, [], RS4),
    ?assertEqual(Outarray4, Outarray2).

%% @doc simple testing function as used in EUnit

simple_test_() -> 
    [
     ?_assertMatch(ok, gen_rand_tests()),
     ?_assertMatch(ok, value_tests_1()),
     ?_assertMatch(ok, value_tests_2())
    ].

%% @doc test value definitions (as in SFMT.86243.out.txt)

test_refval() ->
    %% values taken from SFMT.86243.out.txt of SFMT-1.3.3
    Refrand = [
	       729010956,4245516629,2851064434,363057815,4150273260,
	       802798522,976169071,3393068005,3351056475,2112374092,
	       2951503395,75264394,3725198372,3171075061,4054667720,
	       1970282238,2826304822,103324300,1192438872,1645653767,
	       3276917106,1837939138,3134877800,2607296330,1268482729,
	       2287079542,1979339044,1955581610,881350673,1823446539,
	       4048330951,3240075473,118504416,129971735,3591962661,
	       2091536776,4274939420,1863737156,1265039931,2781464376,
	       910720625,1800307101,2661350362,1662715020,763261808,
	       4190901248,3240306562,4071392780,3521238710,2216729195,
	       2681794184,3704686067,1371630197,1425644030,3214704688,
	       3409026067,3890926247,1877897829,1214572652,4100786555,
	       2136104558,1577549957,3713059767,687516317,3474974503,
	       3987985113,256501997,4031868903,2957819669,2516381723,
	       3710683262,3903566687,1802116397,3447346253,817250261,
	       2174395407,1157688427,833430586,1326443572,3317666696,
	       1989394575,177775310,1326133551,1740093500,1606094052,
	       3953810581,1161317742,3840154932,239393099,1758212452,
	       2875981548,1246818203,2828412702,1043079420,3689339235,
	       3952173912,2266523411,2097168210,2424942254,1977723931,
	       3191248427,1141148931,2159755709,3163859128,1963754045,
	       3039521849,2267589370,654469580,3596215250,2001266227,
	       2863096384,3634136799,679081172,3343228716,3934885515,
	       3107771246,1617014000,1084059423,3412393079,414885861,
	       3240116095,3392583127,3068401547,2344996209,3082244636,
	       2191607617,2883406675,4215546335,3911079206,4057967123,
	       283341933,1825707351,2761341934,2745563273,2411202686,
	       2245672085,3028564336,2067237660,1262025285,2431187699,
	       3343572994,4168260037,1982927877,4031455885,1056162342,
	       1972927344,754392849,2230139411,2079936925,3743828108,
	       4126556308,3575289489,2452908300,3518576153,3043225427,
	       708606088,1678373786,1034219615,2970746029,1701232684,
	       2201103679,4046337686,2670360177,1398398336,1434766889,
	       386371989,1626226263,492400945,481950391,1460878895,
	       2628214666,32289354,725695154,2364791700,4147904097,
	       1330666671,951572257,4071746789,3472089248,1024391664,
	       2870237847,2220169758,1458643991,830628738,4203519645,
	       2158683768,3709772869,404705230,3939314002,1103584614,
	       4126061147,1901021337,2461209386,2595029040,1891531232,
	       3316358683,2334074771,1903339503,63429741,836860961,
	       3923685094,3891307686,4283600816,1560907700,1700586486,
	       4027428226,389182566,3670491119,3043511022,3298652151,
	       1549588263,360800661,1032595419,2181736673,2391118495,
	       3215035908,3641500686,2981094278,1462339155,3669218017,
	       747623658,1310489742,1661043588,2163895602,3922398827,
	       2279556901,1656918269,2674387238,2446094403,1095853624,
	       2009826539,2956799056,2308543818,1400656324,1067418943,
	       3509245063,2691006827,3696168052,3639848521,2704738475,
	       3657965231,3531869387,3213091703,1230098623,1764041643,
	       1318921975,305982504,3180433163,2730063134,3742799449,
	       2317197147,197078888,839071640,888019515,2229014632,
	       2173551210,2144468959,3091463255,664070932,1307118288,
	       2053036022,2738928606,1699931212,1060293457,3942095912,
	       776198701,505412647,3493765645,829893884,4218593896,
	       3859797268,1277761100,3078428845,3060646271,1279588255,
	       509968865,2429696176,1638741938,2735497608,3118275229,
	       2973402167,1796599314,2822753828,3074430055,2972512995,
	       2243015695,3479222174,1242301285,2866876508,2293528727,
	       3936735978,3668861260,1082401638,4107997703,3134202231,
	       2831454223,3621360765,1943611588,2772460896,4185398010,
	       1004507088,4018759773,3821877289,2389953204,3886463573,
	       3373595801,2492703200,647435995,3664523778,3980639492,
	       4100788114,1445534383,3480168898,405585975,4271719706,
	       3448968408,2238517786,1669484731,2123645126,3453964614,
	       2617074879,13995529,1381016801,2528612293,1331221517,
	       1477363636,3926557641,2237361776,2346477954,53455005,
	       1071265630,3265780151,2766486889,3726613115,2531736866,
	       2910433974,3595223566,4275493813,3209923272,497970084,
	       855160633,2425828858,57729569,2398339897,268041903,
	       3734888826,91235453,2345061755,3595316747,685652234,
	       3531007132,4090360456,3341498190,383924394,4030577791,
	       2456025320,1998244838,482407387,2944560147,3955236550,
	       4008437911,2464349259,455158039,490555617,840706181,
	       2978647503,1804206358,1025005403,2142837153,2309021659,
	       1847609206,3518581333,108081811,992944563,3498090648,
	       2994051750,2991940712,758795200,1448280814,888276860,
	       3470929408,3145149528,483815082,2823832788,3764323061,
	       2144188577,3670832015,344906016,1874881610,1082160472,
	       203711731,3254093292,365574161,911275170,615087091,
	       1242348040,1330138764,3638990628,3672526066,3004026353,
	       2175177269,3340195954,3911004560,956880536,312377411,
	       280838375,2864682921,1832506819,1775787578,3016957190,
	       186310818,3483990367,4159255940,2651833909,1283932244,
	       1512006886,2103626414,209688809,2652161551,2461547664,
	       2620510199,645182508,2058247389,1394959005,136956934,
	       1155807397,3701803893,184596033,3688850764,3581259789,
	       2834785331,1720826765,1135293870,4197167465,2837977447,
	       2845229313,3654632919,1743103177,583096433,1844273856,
	       3880118263,2210301412,558291137,3162955681,1733939067,
	       3740476151,1579067969,2141789151,3677512135,1483341249,
	       956880446,4250192148,2637623631,1493912249,2537223037,
	       3246604399,2895045064,3475724970,1857821732,1466989523,
	       4158684710,905806571,3016878587,875032262,1058447535,
	       1475580338,3045563026,4024347645,3809538152,361863533,
	       3955301503,3836208842,69482559,2249036788,3129568965,
	       1200753,2391268154,3511230203,1768492378,4116779442,
	       293792430,1667422872,4264595309,2534933783,701873615,
	       1757791677,448307575,4007528520,4007513845,2779548099,
	       1560781623,550777012,2698938147,801405929,2927098133,
	       3730253117,1260454516,2603372086,1157755133,3432365810,
	       407480530,1294231974,3297404415,2612149380,738197407,
	       3892088373,2341602773,7592194,348342543,3342111872,
	       3521969406,2734056325,751069145,3972010741,3899949399,
	       3155733721,2549441157,2809118078,1492263425,2607114222,
	       2515464697,367700352,818293454,3477949309,1762073966,
	       2657244603,3213965552,1001612746,1036362360,2271269021,
	       98908859,939819937,843394200,3968314675,830345119,
	       2821766013,4142088541,2744143338,3818660546,3323527541,
	       1470664619,3674784285,3895701971,1060102331,4141523920,
	       2492162101,2353153078,1132385908,1838838398,1627034847,
	       748395117,1949555789,954483925,1968656545,1987154068,
	       2818175581,2775828346,499336891,2028392560,1470060285,
	       2518056657,1654542697,3345563418,552345174,4189901821,
	       3780872161,3853103084,4234929235,536089383,3103678518,
	       718238933,1331331083,1435090206,1889684288,1462774461,
	       1537819088,2572325365,370331116,2725029072,756922289,
	       3608759848,3948633836,3789181628,3327241266,1635558909,
	       2211726424,1587643204,2077448904,3373812985,4051582185,
	       3132370070,377711482,992004943,1003802471,2493164736,
	       1781250968,4148826668,812982322,2276021433,2081555884,
	       2861351479,421702633,3094615582,2065430361,1294405142,
	       1470055929,1065051109,3422154346,510532463,584484083,
	       1605964174,2978459459,4062994652,592525574,2816167511,
	       3806542768,1839580221,2366229748,2809729394,2086631212,
	       3886315615,4120460884,3363911317,3866152539,924199459,
	       3918265448,3675032787,2103485162,3570626418,4205051978,
	       1229346744,1483779908,2994240418,1296460692,969956593,
	       3107695883,2748959663,4044113738,767194251,3288615551,
	       3625423774,1102298349,2726790491,3919602997,3876653085,
	       752097278,1272297311,1424989193,3485650104,2708742514,
	       2209576765,231814313,3769493048,1519951132,3005702085,
	       492505731,315603780,1521149790,1836206806,8923089,
	       3849311358,3856139290,1006598280,2442103768,3740655309,
	       3110544479,2326773515,2912274838,3955847546,1102953895,
	       2795144531,2664788818,1297485889,2975844926,471418468,
	       3364065649,2457504318,1390435412,130517954,776248116,
	       3225796107,1551933429,1515865777,2058126181,1068451002,
	       1905363428,4084892408,960467460,1484204142,3857504453,
	       947683105,636184077,2958017175,4247848375,588168350,
	       1377797941,1593939803,714732730,4127411544,3144714541,
	       310200065,1153028864,630717440,474192919,583394638,
	       2206060302,2051227633,3356470620,206793455,299622012,
	       547759498,518154368,1287476184,1668907344,2398107896,
	       2261319555,3052930212,1275920809,2265433157,2970292714,
	       4198496198,298206029,1923974956,4021416493,3291131619,
	       2732097473,1841884448,3698918219,1937141518,3891483873,
	       3442683595,2094678316,721967122,2002904374,1541332768,
	       1886968642,2151165910,2472474128,3972590168,378327601,
	       4082985483,1992757200,3844461420,3483041022,1455851379,
	       498308106,3258630228,1977086874,598580485,2802264261,
	       2824852478,2687114899,1815099863,1255085601,2542289479,
	       3748141675,3290276363,2189933079,1654265127,2803680420,
	       4248276931,1243875867,2241173763,3038297380,1597301639,
	       2190196158,2496219619,2119114031,2403493446,1102203512,
	       1460097018,584419755,4059382205,2374358877,1476960232,
	       1383481623,3449132780,2111366846,3411377385,3872603731,
	       1399408425,3203153665,1083384435,201295826,1427860254,
	       4081776486,320259891,3924338797,2864392125,3495053400,
	       2999890342,995543149,3213994701,1339779519,258066582,
	       1819748230,3257648050,1305483209,1240684732,2691672352,
	       1713056899,2164157758,1778642761,3162455645,447994277,
	       1335690983,2151511043,1381539085,3196339150,1674815487,
	       1319762492,700701192,3428082639,3518808088,1749810767,
	       3422519286,2432877187,770737794,4059924715,2195426623,
	       259935033,4167398154,3324349141,739599641,3845440202,
	       3545350790,3612324675,2192230155,1548175971,937162094,
	       203279111,393686178,4168364525,1599778598,2233988210,
	       2630437051,515739758,1228695103,1711770102,3982132583,
	       1622416320,3224168482,1161443667,186554552,4219595220,
	       2513774714,4222912597,3233812998,3055654171,3961857144,
	       2565297041,3743687880,868973910,2217774352,2699858314,
	       2124304791,721186157,212484339,4037384865,524514500,
	       1436777513,1225661161,2642161873,1487431520,2940228565,
	       2080942134,908374070,2820970552,1594228495,604039131,
	       1504532155,2510624986,3034247087,2532269705,220741335,
	       1127623311,2547541078,126704043,3092086086,3639117079,
	       1148159661,3734337273,3521598637,3693492906,1125551373,
	       3847604950,367502671,4143880100,2781734525,811685177,
	       1939954097,3298647545,141074408,4229084407,3127462752,
	       467242827,2611487694,457899207,3674387256,3389423083,
	       3761844294,3127319307,110735185,668485394,68929538,
	       440108597,2359099634,3921057811,1062337191,2057462132,
	       757735442,721661736,1075969837,1373986067,3127600229,
	       265107800,1254380190,2503509045,267081199,1469044117,
	       918804406,512292947,2553144455,1427553643,1920872478,
	       2241527618,2556155948,3035212247,4074653117,15041492,
	       1164794895,320094188,1918433870,2083084809,3168846156,
	       2652084277,322821672,2894596186,2964847989,2744014862,
	       2201570264,3977857627,3380703105,3174277560,195439905,
	       4173380805,212478290,3748429722,1003643790,105725427,
	       2268847723,2756816290,124651683,973414226,2218060667,
	       3771155392,3653038793,97751670,2719070801,2269904449,
	       2649780074,1581241935,4125964342,648976279,2772488746,
	       3612590868,2975870828,2862756677,2963847772,278116730,
	       1526571968,2432559256,447115025,100891833,1470984623,
	       3053438437,1057147666,3842358627,3629670374,3627859257,
	       3641245524,554945544,412029681,2509880133,1564568268,
	       4006513335,1088660626,752462740,4186652972,3432980371,
	       3910985535,100094501,3120362616,1854432382,314688154,
	       522122712,3026095676,3681962735,1851548627,2153846465
	      ],
    Refarray =
	[
	 1213401037,1002219625,3788189515,93095675,1795375119,
	 1808998847,4076462670,1269636572,373702949,3356118227,
	 3950917039,1031381744,1194934186,3292904843,3270983098,
	 4013778474,3819662841,3810490693,2451963113,794766842,
	 940337222,1333176417,2492894110,3815163219,1954977255,
	 4081804223,2056609068,572576408,1489430565,1332009465,
	 2274262584,2603751473,1622933372,1392147195,1452768864,
	 3805590192,4174204325,178363955,3753630707,3694261297,
	 3746868623,809795660,1587666085,3047614531,2544206440,
	 271172382,3577649978,3782077959,1080058267,1609836193,
	 2395740271,3301016495,2742038099,3721735030,2582511269,
	 1620909122,2247508014,831480346,3883723715,522929941,
	 1232038779,2682273014,1769584739,1058456033,6337615,
	 2609862123,3957258151,508083088,3067603061,1238577947,
	 1540705381,2363860633,1646973919,2697693571,2094758834,
	 997864129,3674187401,3555146101,2513681524,2427901422,
	 4139582134,1249778801,2933775913,1208745439,833054245,
	 226037094,3361439176,2360034639,731605689,764942843,
	 2394647425,923867126,4242388902,2271245870,1117874031,
	 2365323303,2347482462,3033036290,2303957295,1765201161,
	 4141588795,422117451,2299940481,230156325,4012497835,
	 3747882391,2934073988,1091932655,342353629,5586442,
	 3584836627,3656266524,3528714782,4142382649,2464628244,
	 1297683482,2426249706,575471389,381694163,3351210869,
	 885374272,1849329256,1419416589,1880533361,3953304143,
	 897229606,4250664871,4013803380,3290132224,1646393872,
	 4093440915,280719033,2047322779,1356847086,886856583,
	 1593677749,3476521925,1970050786,2358740102,1311182559,
	 2869125693,211865142,4069373597,3554212940,166889574,
	 4285007264,3050291917,3950870595,1028938734,3486397217,
	 1896930485,332027367,425164142,4051587231,3868242151,
	 4216664206,1652064451,1324674794,985265162,4095434235,
	 597665698,3783258350,2797146500,2006908765,3359031041,
	 3908532852,3733853616,2335115317,4156443603,858075300,
	 3399928503,652790337,2026749703,935005793,4246320173,
	 1080203296,3293981718,983876287,411173312,3019821437,
	 1983789230,218616616,323041965,2215013039,1401362246,
	 2622149389,3015201269,1883429325,325278760,3680641326,
	 2747217382,1598855851,1215319906,3976809275,3831807375,
	 3385761537,1964266316,2142040207,2502117845,908785041,
	 1705515573,1915231606,1270163815,2824068016,3610830587,
	 724504274,308147842,3432514289,1624095708,2718149267,
	 3175810064,3608031230,764529199,1288567466,2055305201,
	 2031751267,4028468099,1693536571,3316411300,2605553626,
	 2902169638,2287627627,934898594,464375985,1110793572,
	 2578052236,604058164,3850731763,759290885,640351056,
	 855968309,121241201,1377248171,3471452241,989724146,
	 1874965893,2818024967,1099221252,2575897924,1211288100,
	 3386309408,3980049659,121399517,1022796858,1416027009,
	 1094149839,536118347,457632147,1015209083,464261658,
	 641239573,1753875184,1323212669,3646085356,1394493575,
	 164907016,2568646193,1298591334,2596978376,2713346823,
	 2235719212,3404874420,2926483015,817521639,2325337599,
	 1190194336,1121711051,2871987415,1996392102,3732019047,
	 2057754050,1285797620,3525747015,3599316192,1311557910,
	 4073156812,3334963259,501862533,3187185148,2834493700,
	 1962918922,3193906273,2607994135,623782957,2954186234,
	 3505476359,1037699835,528251538,3827319387,537623337,
	 1608895986,1044022733,2299981400,3038608441,997582371,
	 723669727,4197437247,3681222029,2193076438,115962248,
	 4011967047,3467475503,2072481816,126311702,876614208,
	 3478515577,2646238025,19562665,378399552,3642937993,
	 2058611917,2111004394,1926866103,2887742563,618906666,
	 4258407965,2958263973,2419816644,3314626229,1442458721,
	 558076912,3053848791,3333535560,995592633,1047922908,
	 2356500762,4207275767,376639869,3529066690,4222332910,
	 3156552049,1462554360,986966587,1767928657,1429222119,
	 977695158,2526255648,2982685435,3869803532,1095012039,
	 267680546,2845102093,1082566213,1332136828,522815606,
	 4139687737,330964150,3454169628,2201079869,1740196729,
	 2349409998,2818834539,2120939493,3376126758,2946051667,
	 4924567,2111031725,3824175290,2473266075,2428982960,
	 3102587221,3690443407,506689177,2798344888,3525715741,
	 1539031458,3636702492,1470941841,175810149,2827707744,
	 2903465077,1650959247,3437601585,3034497372,472118010,
	 4051978563,1901031796,1409064727,1971741620,2527435792,
	 3672974796,1393942329,3819796441,1556101329,2052248169,
	 2557936496,1848902047,2235898955,3973767610,1690868146,
	 3077322427,2608200001,833944767,3998542921,2008926979,
	 3802104409,2450570315,2426406043,2198590908,3979654780,
	 1561617744,1323118922,4070281713,284790709,4141515358,
	 736142438,329507857,3052265563,2317825753,1742462174,
	 1594087153,4088013046,4254983338,429583236,972856373,
	 628743711,2381102700,1051287930,627333394,1597449252,
	 1382413907,782354833,3434647006,1226629497,906647676,
	 3929130393,3973610462,342835343,1928368793,1394796823,
	 1934497469,4289189187,1315021676,2031856979,3587930678,
	 868328634,694962903,3165451711,3251192370,235342767,
	 1510092975,4044997301,3984157879,1375892399,1731198083,
	 897183534,3802763805,814589972,142299678,1207574729,
	 2721196600,3012142849,3377965874,3938002659,3456025350,
	 2487959559,904765592,2292812414,2599274412,2178549968,
	 3271888617,2907425088,1128303638,1801894018,869026091,
	 2035727974,3148527216,2516657100,942617434,4270550483,
	 2321278085,11963886,1159717858,953580654,4175912858,
	 4179683786,2182988288,2504001291,1082949763,1612523311,
	 1215231374,4175744445,880012230,3989047066,453294526,
	 586221520,3768508464,1827725669,4241587799,441082319,
	 1298770459,2497310139,4196896920,1577701951,4254714667,
	 862249229,2012903970,2096820613,1990849796,1703270117,
	 852272511,3229237980,3697809515,867672785,17221026,
	 288848412,2088315744,1440742383,3844911232,2986498221,
	 814099612,2062983048,229264819,2079291882,323917132,
	 243717768,356852074,201866217,504556726,3315205738,
	 450701405,4134049543,856165036,2961305615,1651574742,
	 2092328938,913251909,2932915112,692676614,691196510,
	 2546180050,4083776864,2480694391,3163041102,2432664524,
	 1725997673,3546933482,992733299,592525824,295713684,
	 2993483017,297440700,3517389226,3599068943,2280378170,
	 3472102781,2823687084,1072311987,3571812747,550522631,
	 204762998,965995049,2603455559,2759877645,2499285182,
	 1878178774,4125269177,3992081280,3879467901,3731604236,
	 3424565176,2420188662,1230680928,224329290,1789127563,
	 2356611594,4232337703,437915186,527139689,317221748,
	 2820346665,2371412394,1091430547,362811554,3954005242,
	 589811487,3922172475,3682858225,1305600294,330864566,
	 3811823509,969630425,2242311394,2120243236,3945642955,
	 444052283,129657022,961406690,4012095830,1569950408,
	 3057580478,85571849,4169424671,1045676313,4192235593,
	 155093330,1287782822,186319587,1070205521,1351656704,
	 701839079,4164473197,1426746528,4013088441,1424854980,
	 4257176207,2098556313,2714455545,881819196,2149812594,
	 4224374605,153249521,762156887,3911390861,2314558009,
	 1509054394,598675012,4193138277,2822137310,1277707950,
	 2399873326,600095973,1046837556,1727252309,1921065218,
	 2451546993,4286744527,2429014699,917512105,2146476202,
	 3314509263,2240592149,1399312633,1924468513,860594147,
	 2402718697,1090036732,3451548256,631863464,3760041460,
	 708486403,3771336539,604445173,939789219,80036401,
	 3590064041,1695161011,3984992088,2535160053,1048040763,
	 842173014,879261125,3263255701,2693326530,2787136932,
	 2203029018,2527879816,721332286,3943249838,1439267105,
	 3407165594,2652438420,2510159896,1895686121,3010461540,
	 2019063783,377456939,4058553802,3985549007,3990648065,
	 35891133,1084255889,4058741536,3017262213,854733992,
	 2961817127,1566191274,1269974535,1061385893,1934296790,
	 3414627357,1207154213,2169063962,3645713217,1479522,
	 2689985438,1634530225,864065277,2672726682,859689319,
	 635323776,3365255313,1569018822,4217263691,4042097075,
	 3695316210,4138227098,629666892,1351285517,1934369390,
	 2162647800,2099295887,1271763036,1883303738,2253158917,
	 2571830301,2021354299,4245348230,930564723,717657347,
	 860626062,2635560677,3610527454,608615661,869271169,
	 1236749490,220395479,1578173002,3119440492,4102908789,
	 2883369051,443494207,3066476468,2053051671,3495052118,
	 2931697191,2445226742,1168952815,2722178203,227518833,
	 1821405664,1984333173,178408471,1649711654,2741506961,
	 3736312552,3057151173,3610556956,3408112927,1335860450,
	 3378168144,3939908355,3599806580,879059944,3157765948,
	 3569390375,3320093939,453056499,294491075,3502570840,
	 2351671522,2097831502,520013670,4122641375,360833785,
	 4032004203,605909800,2821812620,768719594,192414323,
	 1688520714,157860104,3327948248,1240329952,3212947902,
	 976889466,3548320346,1762646325,342962173,1003544616,
	 65126654,471424221,4061906609,350603531,2047537397,
	 2460383607,1124011704,2239298963,2401787777,2395657063,
	 2809606252,4011206815,2103078498,849681665,3239658138,
	 454377878,318962394,134678707,1645848595,3688219627,
	 1119459724,2212606443,243069356,4096678109,4049950924,
	 1430188855,3376687605,2713071284,397063508,202199470,
	 3207123536,3523498674,2144158622,1156392159,2897908607,
	 1400157671,2394352073,990056620,3144770445,1536804654,
	 4089632658,4055427606,2183978336,2970981982,3525778176,
	 3366552852,3242943082,2117204540,3996086902,2746280565,
	 1949889669,2949740123,3138662162,50154986,94445067,
	 3860163230,1398775754,1275595861,3221456668,1615414812,
	 1426209298,1509166518,2886331650,1361931038,4247915749,
	 2235497887,1145437786,2190827817,4167305565,3361795949,
	 4120512272,517650201,2794964517,4067973019,799550940,
	 2100720011,1656535186,3554801317,2273864605,3721246389,
	 1848650174,4111661788,252555371,1479149169,4207511886,
	 3771592078,1085550976,1444352474,361783830,197262084,
	 1872651058,510129635,643408024,2380283299,3537991311,
	 4108692298,2712439525,4185893506,3127244235,1545177637,
	 775067312,1234633845,2293720577,3778045647,1893569650,
	 955596059,3130502632,3512322487,2457236623,3247250980,
	 3633960328,2429641312,577152631,3611721077,1890309659,
	 875637133,2890867574,152541005,1205356740,856777352,
	 1962130546,4228049260,1832751323,1136560654,2320155579,
	 749675601,3954333865,1704165610,2177165756,1966195240,
	 3547474042,501064771,290232796,3418362513,1609407374,
	 2133025968,3544255562,4049262104,4016434687,2026338560,
	 1105071235,3970613579,3009120745,117571106,2728067687,
	 4254524777,3624601829,684100681,3881760944,2157408568,
	 1633150817,3607482443,1195137474,838063811,2671430283,
	 3779028933,184059818,1998815784,754698425,879596005,
	 855239848,1318366942,2498942515,687484589,1378955192,
	 895763157,3400833754,2912732490,2791045459,639561355,
	 638097599,991007343,1112019452,1450713999,851566038,
	 3014206548,1019682192,259110455,4013700475,1137615360,
	 2333427341,1665782564,407615411,1645678339,1712572929,
	 427221509,1115350847,183410243,3117255003,2926399354,
	 357446483,3130495927,1177477989,1487365345,3225554801,
	 2764909127,1893438844,1433636831,1121233427,212375185,
	 2235354016,440100203,1201781269,1401424411,4256059105,
	 3476447550,3958909757,603116189,1992155441,1450512874,
	 1301692771,2969787235,4092530603,1954938445,873105978,
	 3346443957,300451651,517315823,3784036939,166169681,
	 3888022637,3342589770,4248214348,3902418067,1571362573,
	 778966034,3710173278,4226663802,2983892053,625306958
	],
    {Refrand, Refarray}.

-endif. % TEST

%% end of module