USE BD_OCEF_CtasPorCobrar
GO

--SELECT * FROM dbo.TR_Comprobante c
--INNER JOIN dbo.TR_Comprobante_PagoBanco p ON p.I_ComprobanteID = c.I_ComprobanteID
--WHERE p.B_Habilitado = 1 AND c.I_TipoComprobanteID = 2 AND c.I_SerieID = 2 AND c.I_NumeroComprobante = 41

--SELECT * FROM dbo.TR_PagoBanco where I_PagoBancoID = 2300297

BEGIN TRAN
BEGIN try

	UPDATE c SET c.I_EstadoComprobanteID = 3 FROM dbo.TR_Comprobante c
	INNER JOIN dbo.TR_Comprobante_PagoBanco p ON p.I_ComprobanteID = c.I_ComprobanteID
	WHERE p.B_Habilitado = 1 AND c.I_TipoComprobanteID = 2 AND c.I_SerieID = 2 AND c.I_NumeroComprobante IN (
		41,
		42,
		43,
		44,
		45,
		46,
		47,
		48,
		49,
		50,
		51,
		52,
		53,
		54,
		55,
		56,
		57,
		58,
		59,
		60,
		61,
		65,
		66,
		70,
		71,
		74,
		77,
		82,
		88,
		93,
		96,
		97,
		101,
		116,
		120,
		122,
		126,
		130,
		131,
		140,
		142,
		152,
		156,
		159,
		162,
		164,
		165,
		173,
		176,
		181,
		184,
		192,
		195,
		199,
		204,
		206,
		222,
		225,
		233,
		238,
		239,
		244,
		251,
		253,
		255,
		259,
		266,
		269,
		270,
		272,
		278,
		282,
		290,
		291,
		303,
		305,
		306,
		312,
		313,
		325,
		328,
		337,
		339,
		345,
		348,
		378,
		396,
		397,
		398,
		404,
		406,
		409,
		410,
		415,
		417,
		421,
		427,
		428,
		429,
		436,
		438,
		443,
		452,
		459,
		461,
		465,
		467,
		499,
		500,
		501,
		503,
		505,
		508,
		511,
		516,
		542,
		544,
		547,
		550,
		553,
		556,
		571,
		578,
		582,
		583,
		585,
		589,
		597,
		602,
		605,
		609,
		622,
		624,
		626,
		654,
		668,
		669,
		683,
		684,
		690,
		693,
		699,
		700,
		714,
		721,
		726,
		733,
		738,
		744,
		750,
		754,
		758,
		762,
		770,
		772,
		779,
		784,
		791,
		792,
		804,
		807,
		809,
		815,
		816,
		821,
		832,
		850,
		869,
		880,
		885,
		887,
		903,
		905,
		906,
		913,
		926,
		941,
		948,
		952,
		985,
		988,
		1019,
		1029,
		1034,
		1051,
		1059,
		1060,
		1069,
		1081,
		1082,
		1083,
		1084,
		1177,
		1178,
		1179,
		1180,
		1181,
		1182,
		1183,
		1184,
		1185,
		1186,
		1187,
		1188,
		1189,
		1190,
		1191,
		1192,
		1193,
		1194,
		1195,
		1196,
		1197,
		1199,
		1201,
		1202,
		1203,
		1204,
		1205,
		1208,
		1228,
		1234,
		1235,
		1236,
		1241,
		1254,
		1256,
		1263,
		1267,
		1271,
		1286,
		1287,
		1297,
		1304,
		1305,
		1318,
		1323,
		1324,
		1326,
		1335,
		1345,
		1347,
		1351,
		1352,
		1353,
		1354,
		1365,
		1367,
		1369,
		1393,
		1397,
		1399,
		1408,
		1411,
		1424,
		1426,
		1428,
		1435,
		1437,
		1439,
		1440,
		1443,
		1446,
		1456,
		1464,
		1465,
		1494,
		1499,
		1501,
		1505,
		1506,
		1508,
		1509,
		1516,
		1519,
		1522,
		1525,
		1528,
		1534,
		1537,
		1547,
		1554,
		1560,
		1561,
		1564,
		1571,
		1573,
		1575,
		1584,
		1609,
		1613,
		1616,
		1629,
		1630,
		1633,
		1636,
		1641,
		1648,
		1661,
		1666,
		1673,
		1676,
		1678,
		1681,
		1685,
		1690,
		1698,
		1710,
		1715,
		1737,
		1742,
		1744,
		1746,
		1750,
		1753,
		1764,
		1777,
		1780,
		1781,
		1783,
		1793,
		1794,
		1798,
		1811,
		1816,
		1823,
		1848,
		1849,
		1853,
		1858,
		1885,
		1921,
		1927,
		1931,
		1940,
		1960,
		1967,
		1978,
		1996,
		2014,
		2036,
		2037,
		2043,
		2050,
		2054,
		2055,
		2056,
		2062,
		2063,
		2067,
		2069,
		2081,
		2082,
		2083,
		2315,
		2316,
		2317,
		2318,
		2319,
		2320,
		2321,
		2322,
		2323,
		2324,
		2325,
		2326,
		2327,
		2328,
		2329,
		2330,
		2331,
		2332,
		2334,
		2335,
		2336,
		2340,
		2342,
		2343,
		2346,
		2350,
		2357,
		2360,
		2368,
		2369,
		2371,
		2373,
		2374,
		2376,
		2377,
		2379,
		2380,
		2381,
		2382,
		2387,
		2389,
		2391,
		2392,
		2395,
		2398,
		2400,
		2401,
		2413,
		2417,
		2426,
		2427,
		2428,
		2429,
		2430,
		2432,
		2434,
		2445,
		2447,
		2452,
		2453,
		2454,
		2455,
		2456,
		2457,
		2458,
		2460,
		2471,
		2472,
		2481,
		2490,
		2501,
		2504,
		2509,
		2519,
		2522,
		2526,
		2529,
		2536,
		2539,
		2551,
		2559,
		2570,
		2574,
		2577,
		2589,
		2591,
		2593,
		2603,
		2607,
		2613,
		2614,
		2618,
		2623,
		2624,
		2630,
		2631,
		2638,
		2639,
		2641,
		2647,
		2650,
		2655,
		2660,
		2662,
		2664,
		2666,
		2667,
		2671,
		2675,
		2690,
		2696,
		2698,
		2699,
		2714,
		2734,
		2736,
		2741,
		2745,
		2754,
		2755,
		2758,
		2765,
		2767,
		2768,
		2769,
		2772,
		2782,
		2785,
		2793,
		2797,
		2800,
		2808,
		2809,
		2812,
		2817,
		2819,
		2824,
		2832,
		2836,
		2839,
		2846,
		2847,
		2865,
		2868,
		2871,
		2876,
		2880,
		2882,
		2888,
		2891,
		2893,
		2894,
		2907,
		2920,
		2923,
		2930,
		2938,
		2941,
		2944,
		2951,
		2957,
		2969,
		2972,
		2974,
		2980,
		2993,
		3004,
		3006,
		3049,
		3052,
		3054,
		3060,
		3062,
		3069,
		3070,
		3083,
		3084,
		3089,
		3093,
		3098,
		3099,
		3103,
		3112,
		3113,
		3123,
		3127,
		3128,
		3135,
		3136,
		3137,
		3138,
		3139,
		3140,
		3492,
		3493,
		3494,
		3495,
		3496,
		3497,
		3498,
		3499,
		3500,
		3501,
		3502,
		3503,
		3504,
		3515,
		3528,
		3530,
		3536,
		3543,
		3553,
		3557,
		3578,
		3582,
		3587,
		3591,
		3594,
		3597,
		3612,
		3617,
		3621,
		3634,
		3637,
		3638,
		3641,
		3643,
		3646,
		3648,
		3658,
		3663,
		3666,
		3681,
		3685,
		3690,
		3695,
		3697,
		3699,
		3700,
		3706,
		3709,
		3711,
		3712,
		3731,
		3732,
		3745,
		3749,
		3758,
		3763,
		3766,
		3767,
		3777,
		3794,
		3804,
		3815,
		3818,
		3821,
		3834,
		3840,
		3853,
		3856,
		3857,
		3873,
		3874,
		3877,
		3903,
		3913,
		3922,
		3923,
		3927,
		3934,
		3941,
		3969,
		3979,
		3981,
		3990,
		3993,
		3995,
		3998,
		4002,
		4007,
		4014,
		4016,
		4018,
		4019,
		4021,
		4028,
		4033,
		4037,
		4051,
		4053,
		4060,
		4064,
		4088,
		4119,
		4126,
		4141,
		4144,
		4152,
		4157,
		4178,
		4180,
		4181,
		4184,
		4186,
		4187,
		4192,
		4193,
		4195,
		4199,
		4206,
		4207,
		4208,
		4210,
		4215,
		4220,
		4224,
		4235,
		4255,
		4264,
		4277,
		4279,
		4286,
		4287,
		4306,
		4308,
		4322,
		4323,
		4899,
		4900,
		4901,
		4902,
		4903,
		4904,
		4905,
		4906,
		4907,
		4908,
		4909,
		4910,
		4911,
		4912,
		4913,
		4914,
		4916,
		4917,
		4918,
		4919,
		4920,
		4923,
		4924,
		4927,
		4929,
		4930,
		4931,
		4932,
		4940,
		4946,
		4948,
		4951,
		4961,
		4968,
		4970,
		4974,
		4976,
		4984,
		4985,
		4988,
		4998,
		5002,
		5020,
		5021,
		5027,
		5040,
		5041,
		5044,
		5072,
		5073,
		5075,
		5076,
		5084,
		5096,
		5102,
		5109,
		5111,
		5120,
		5127,
		5133,
		5157,
		5158,
		5164,
		5168,
		5170,
		5172,
		5176,
		5191,
		5196,
		5197,
		5202,
		5206,
		5208,
		5209,
		5216,
		5234,
		5258,
		5263,
		5266,
		5270,
		5285,
		5286,
		5294,
		5299,
		5301,
		5305,
		5306,
		5307,
		5314,
		5316,
		5324,
		5325,
		5334,
		5336,
		5340,
		5349,
		5368,
		5375,
		5377,
		5385,
		5387,
		5395,
		5400,
		5402,
		5416,
		5432,
		5452,
		5469,
		5492,
		5493,
		5494,
		5496,
		5498,
		5502,
		5512,
		5513,
		5514,
		5522,
		5524,
		5529,
		5541,
		5544,
		5549,
		5570,
		5579,
		5580,
		5582,
		5593,
		5599,
		5617,
		5626,
		5639,
		5641,
		5643,
		5647,
		5652,
		5654,
		5663,
		5667,
		5673,
		5686,
		5687,
		5694,
		5699,
		5708,
		5709,
		5710,
		5718,
		5719,
		5726,
		5737,
		5748,
		5750,
		5763,
		5768,
		5776,
		5778,
		5785,
		5788,
		5789,
		5796,
		5797,
		5800,
		5801,
		5802,
		5803,
		6157,
		6158,
		6159,
		6160,
		6161,
		6162,
		6163,
		6164,
		6165,
		6166,
		6167,
		6168,
		6169,
		6170,
		6171,
		6172,
		6173,
		6174,
		6175,
		6176,
		6177,
		6178,
		6179,
		6180,
		6181,
		6182,
		6183,
		6184,
		6185,
		6186,
		6187,
		6189,
		6191,
		6194,
		6204,
		6205,
		6212,
		6222,
		6225,
		6237,
		6253,
		6263,
		6264,
		6266,
		6267,
		6273,
		6274,
		6278,
		6287,
		6295,
		6297,
		6299,
		6303,
		6305,
		6308,
		6309,
		6310,
		6315,
		6317,
		6323,
		6324,
		6331,
		6334,
		6342,
		6343,
		6344,
		6361,
		6376,
		6387,
		6389,
		6392,
		6401,
		6405,
		6408,
		6410,
		6414,
		6419,
		6420,
		6423,
		6425,
		6426,
		6432,
		6433,
		6435,
		6436,
		6437,
		6441,
		6445,
		6452,
		6455,
		6457,
		6458,
		6462,
		6463,
		6464,
		6466,
		6468,
		6471,
		6477,
		6481,
		6484,
		6490,
		6494,
		6505,
		6507,
		6509,
		6512,
		6513,
		6514,
		6515,
		6516,
		6517,
		6518,
		6524,
		6525,
		6526,
		6527,
		6528,
		6529,
		6530,
		6531,
		6532,
		6533,
		6534,
		6535,
		6536,
		6537,
		6538,
		6539,
		6540,
		6541,
		6542,
		6543,
		6544,
		6545,
		6546,
		6547,
		6548,
		6549,
		6550,
		6551,
		8318,
		8319,
		8320,
		8321,
		8322,
		8323,
		8324,
		8325,
		8326,
		8327,
		8328,
		8329,
		8330,
		8331,
		8332,
		8333,
		8334,
		8335,
		8336,
		8337,
		8339,
		8348,
		8349,
		8350,
		8353,
		8358,
		8361,
		8363,
		8365,
		8367,
		8369,
		8370,
		8384,
		8385,
		8386,
		8387,
		8397,
		8399,
		8400,
		8404,
		8415,
		8418,
		8419,
		8420,
		8427,
		8454,
		8456,
		8461,
		8466,
		8467,
		8474,
		8477,
		8481,
		8482,
		8486,
		8487,
		8494,
		8495,
		8496,
		8497,
		8500,
		8501,
		8503,
		8504,
		8508,
		8523,
		8524,
		8525,
		8530,
		8534,
		8550,
		8560,
		8561,
		8577,
		8579,
		8580,
		8587,
		8590,
		8597,
		8605,
		8607,
		8608,
		8611,
		8618,
		8622,
		8623,
		8632,
		8636,
		8638,
		8643,
		8644,
		8651,
		8652,
		8669,
		8672,
		8676,
		8678,
		8688,
		8692,
		8693,
		8696,
		8707,
		8711,
		8713,
		8720,
		8721,
		8739,
		8744,
		8745,
		8749,
		8753,
		8759,
		8790,
		8795,
		8796,
		8802,
		8804,
		8807,
		8809,
		8811,
		8812,
		8826,
		8832,
		8834,
		8839,
		8841,
		8856,
		8873,
		8877,
		8878,
		8884,
		8889,
		8908,
		8914,
		8918,
		8922,
		8932,
		8933,
		8964,
		8970,
		8976,
		8977,
		8978,
		8980,
		8982,
		9013,
		9019,
		9024,
		9039,
		9044,
		9082,
		9087,
		9091,
		9102,
		9107,
		9116,
		9120,
		9123,
		9127,
		9138,
		9144,
		9166,
		9180,
		9186,
		9187,
		9189,
		9190,
		9192,
		9200,
		9227,
		9232,
		9235,
		9237,
		9241,
		9248,
		9252,
		9254,
		9264,
		9269,
		9270,
		9284,
		9299,
		9308,
		9319,
		9322,
		9331,
		9336,
		9338,
		9340,
		9344,
		9347,
		9348,
		9350,
		9360,
		9365,
		9366,
		9368,
		9369,
		9370,
		9371,
		9374,
		9375,
		9376,
		9379,
		9386,
		9401,
		9405,
		9414,
		9417,
		9418,
		9421,
		9426,
		9428,
		9433,
		9440,
		9442,
		9450,
		9454,
		9462,
		9465,
		9466,
		9467,
		9468,
		9469,
		9476,
		9479,
		9481,
		9510,
		9512,
		9515,
		9525,
		9531,
		9539,
		9544,
		9550,
		9559,
		9561,
		9563,
		9573,
		9578,
		9583,
		9585,
		9587,
		9589,
		9590,
		9602,
		9610,
		9611
	);

	COMMIT TRAN;
	PRINT 'Actualización exitosa';
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	PRINT ERROR_MESSAGE();
END CATCH
GO
