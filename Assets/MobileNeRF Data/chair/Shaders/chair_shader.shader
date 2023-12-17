Shader "MobileNeRF/ViewDependenceNetworkShader/chair" {
    Properties {
        tDiffuse0x ("Diffuse Texture 0", 2D) = "white" {}
        tDiffuse1x ("Diffuse Texture 1", 2D) = "white" {}
    }

    CGINCLUDE
    #include "UnityCG.cginc"

    struct appdata {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f {
        float2 uv : TEXCOORD0;
        float4 vertex : SV_POSITION;
        float3 rayDirection : TEXCOORD1;
        UNITY_VERTEX_OUTPUT_STEREO
    };

    v2f vert(appdata v) {
        v2f o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_OUTPUT(v2f, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = v.uv;
        o.rayDirection = -WorldSpaceViewDir(v.vertex);
        o.rayDirection.xz = -o.rayDirection.xz;o.rayDirection.xyz = o.rayDirection.xzy;

        return o;
    }

    sampler2D tDiffuse0x;
    sampler2D tDiffuse1x;

    half3 evaluateNetwork(fixed4 f0, fixed4 f1, fixed4 viewdir) {
        float4x4 intermediate_one = { 0.2585771, -0.0211769, -0.0383453, 0.1628130, 0.1086640, -0.2139520, -0.0828777, -0.0210760, -0.0463375, 0.0231030, -0.0220173, -0.0442962, 0.1746899, -0.0712821, -0.0505290, 0.1853886 };
        intermediate_one += f0.r * float4x4(-0.2219106, 0.2648382, -0.0804360, 0.0722988, 0.4896969, -0.8830786, -0.6471643, 0.3136749, 0.0709904, 0.0434724, 0.4865980, -0.3208952, -0.0098783, -0.0212289, 0.3112753, -0.2768180)
            + f0.g * float4x4(-0.4845007, -0.1149675, 0.2581294, 0.1260073, -0.7295975, 0.0597386, 0.7359101, -0.4465330, 0.3049549, 0.2948124, 0.4689119, 0.2684540, -0.0659714, 0.7296832, 0.4602348, -0.4792049)
            + f0.b * float4x4(-0.8185899, -0.5766464, -0.1479448, -0.6508079, 0.3187565, 0.7318813, -0.0599704, -0.0699499, 0.3418030, 0.1229749, -0.4627783, 0.5135400, -0.0334656, -0.2161781, 0.4974413, 0.2916854)
            + f0.a * float4x4(-0.1475889, 0.1694397, 0.1456813, -0.2168909, -0.5210251, 0.6568262, -0.3755050, 0.3963549, -0.6509303, -0.2584476, -0.3463354, 0.1340566, 0.0436400, -0.2256358, -0.1236348, -0.7022339)
            + f1.r * float4x4(0.5160989, 0.2255793, -0.0974488, 0.6112303, -0.2491111, -0.4964570, 0.0377998, 0.2023504, 0.6989182, 0.9124404, 0.5712816, 0.3161325, 0.9074748, -0.6891594, 0.0962940, 0.1032841)
            + f1.g * float4x4(0.7390952, -0.2910624, -0.2072725, -0.8836541, 0.4892483, 0.7647177, 0.2681574, -0.6096324, 0.2310429, 0.0831834, 0.5374894, 0.3318019, 0.2419077, 0.7790738, 0.6175798, -0.3574682)
            + f1.b * float4x4(-0.0964625, 0.5201526, 0.0484798, -0.2408223, -0.0290087, 0.4164308, -0.1808192, -0.6027290, -0.7473103, -0.6517222, 0.4105704, -0.8639603, 0.2790841, -0.0723499, -0.3298574, 0.6710708)
            + f1.a * float4x4(0.3958801, -1.4041698, 0.5627323, -0.0272960, 0.3681940, 0.0595756, 0.3895839, 0.7306521, -0.1070764, 0.0326785, 0.4406258, 0.0225872, -0.7096025, -0.1215790, -0.0368467, 0.3377448)
            + viewdir.r * float4x4(0.2893410, -0.2607268, 0.0194980, 0.3423950, -0.0537107, 0.0228548, 0.2042130, 0.0138934, 0.3135874, -0.3115926, -0.0782583, -0.4180056, -0.1437349, -0.2352602, -0.1376777, -0.1459652)
            + viewdir.g * float4x4(0.3687297, -0.3306265, 0.0438467, -0.0869251, -0.5915972, -0.0710213, 0.2528684, 0.0778881, 0.3887043, 0.1812000, 0.0458873, -0.0154701, -0.2722515, 0.1213476, -0.1769656, 0.4877904)
            + viewdir.b * float4x4(-0.0671107, 0.1548110, 0.4133487, -0.2071315, -0.1141344, 0.0950248, -0.2176736, -0.2053779, 0.2584363, -0.2158179, 0.1263154, 0.0287362, 0.2567383, -0.4311441, -0.3199565, 0.0684604);
        intermediate_one[0] = max(intermediate_one[0], 0.0);
        intermediate_one[1] = max(intermediate_one[1], 0.0);
        intermediate_one[2] = max(intermediate_one[2], 0.0);
        intermediate_one[3] = max(intermediate_one[3], 0.0);
        float4x4 intermediate_two = float4x4(
            -0.2000644, -0.0732091, 0.2000838, -0.0064169, 0.1183844, -0.0836983, 0.0849425, 0.2200973, 0.1108803, 0.6314971, 0.0645009, 0.1398835, -0.0936965, -0.0334069, -0.0199609, -0.1513825
        );
        intermediate_two += intermediate_one[0][0] * float4x4(0.8590940, 0.8321470, -0.2179068, -0.0089543, 0.5626348, 0.2119452, 0.6766757, -0.2143195, 0.0724675, 0.3678232, 1.0550504, 0.3539047, -0.0653864, -0.4456612, -0.5153029, 0.4659462)
            + intermediate_one[0][1] * float4x4(-0.6193581, 0.0283567, 0.4243975, 0.0873488, -0.2164693, -0.2714517, -0.8078498, -0.0429285, -0.3167791, -0.3204944, 0.0018940, -1.0107332, 0.4275030, 0.5374742, -0.3017937, -0.1755595)
            + intermediate_one[0][2] * float4x4(1.4618410, -0.3768882, -0.0250269, -0.2621469, -0.3746355, -0.4289248, -0.0255885, -0.0982430, -0.8438100, 0.3375076, 0.1729836, 0.3009253, -0.8990650, 0.3465714, -0.8940296, 0.7916014)
            + intermediate_one[0][3] * float4x4(-0.6792403, 0.1868446, 0.5039264, 0.3437440, -0.2243346, -0.1372272, -0.3299991, -0.5642014, -0.5066483, -0.5957985, -0.5646420, -0.0357452, 0.3914475, 0.4052662, -0.5727931, -0.3171307)
            + intermediate_one[1][0] * float4x4(0.7191840, -0.3632191, -0.8171775, -0.5139873, 0.3884850, -0.6392455, 0.5154428, -0.1006422, -0.0860144, -0.0746828, 0.4476312, 0.4066621, -0.2096747, -0.1481310, -0.4416441, -0.7489054)
            + intermediate_one[1][1] * float4x4(0.6960115, 0.3203762, -0.1868449, -0.0928646, -0.1177522, 0.2106813, 0.3058876, 1.0015723, 0.1468659, -0.5678703, -0.0817990, 0.9837600, 0.3211599, -0.2312526, -0.0147877, -0.3911519)
            + intermediate_one[1][2] * float4x4(-0.5518115, 0.4841210, 0.4832756, 0.3935706, -0.5280809, -0.4283902, -0.2047278, -0.1529333, 0.2176493, -0.4815359, -0.5108227, -0.3667073, 0.3032371, 0.3510822, 0.4875328, -0.1827454)
            + intermediate_one[1][3] * float4x4(-1.5960488, -0.1692475, 0.7504905, -0.1212849, -0.0749975, -0.7704371, 0.4955181, -0.2516306, -0.2253886, 0.4835532, -0.3090824, 0.3517605, -0.0220268, 0.3146090, 0.2470024, -0.0352733)
            + intermediate_one[2][0] * float4x4(-0.3691366, -0.5193053, 0.2706625, 0.1438859, 0.0631189, 0.1559587, 0.0282209, 0.7570263, 0.4111967, -0.3654894, -0.2957088, -0.0892005, -0.0666440, 0.5013679, 0.4223690, 0.2402694)
            + intermediate_one[2][1] * float4x4(0.8640943, 0.3324016, -0.1605616, -0.2537376, 0.0468536, 0.0802287, 0.5647219, -0.3387241, -0.6026466, 0.5562338, -0.0824475, 0.3851839, -0.5349562, 0.0661892, -0.6719152, 0.1858215)
            + intermediate_one[2][2] * float4x4(-0.2872525, -0.2147609, 0.1580929, 0.4439992, 0.6463262, -0.0854282, 0.2473924, -0.0744160, -0.3366590, -0.3275655, 0.2893217, 0.0352060, 0.3364265, 0.3955426, 0.0986192, 0.5184579)
            + intermediate_one[2][3] * float4x4(0.2407622, 0.8768726, -0.0471692, -0.7458690, 0.5975519, -0.1905226, 0.1369857, 0.0052247, -0.0493379, 1.0713485, -0.6091961, 0.3613573, -0.2793847, -0.4197623, 0.2249175, 0.2808645)
            + intermediate_one[3][0] * float4x4(-0.6280583, -0.0337873, 0.1575996, 0.3257197, 0.1723871, -0.0991980, -0.4188410, 0.3486457, 0.6872701, -0.4753686, 0.0379343, -0.1343532, 0.4115400, 0.4117737, 0.5159591, -0.0979935)
            + intermediate_one[3][1] * float4x4(-0.3395225, -0.0238192, 0.2322800, 0.4623786, -0.2186477, -0.7877468, -0.3536233, 0.3348242, 0.7723950, -0.4982136, -0.6619293, -0.1905377, 0.1211730, -0.6998031, 0.5519737, -0.1010231)
            + intermediate_one[3][2] * float4x4(-0.1388618, -0.2572149, 0.0766642, 0.4791993, 0.0600854, 0.4680346, -0.1042584, 0.1469201, 0.3605924, -0.3979291, 0.2511110, -0.2517145, 0.3881604, -0.3244450, 0.3732073, 0.2594287)
            + intermediate_one[3][3] * float4x4(-0.7354003, -0.0479156, 0.1830245, 0.7822472, -0.8401104, 0.7373319, -0.5276921, 0.1566554, 0.1870020, -0.4010218, -0.1486108, -0.0911084, -0.3039701, 0.7897105, 0.2145737, -0.0213895);
        intermediate_two[0] = max(intermediate_two[0], 0.0);
        intermediate_two[1] = max(intermediate_two[1], 0.0);
        intermediate_two[2] = max(intermediate_two[2], 0.0);
        intermediate_two[3] = max(intermediate_two[3], 0.0);
        float3 result = float3(
            0.0535661, 0.1457886, 0.0818631
        );
        result += intermediate_two[0][0] * float3(-0.4180088, 1.3663876, -0.3484590)
                + intermediate_two[0][1] * float3(0.1326222, 0.8160229, 0.3381277)
                + intermediate_two[0][2] * float3(-0.7444341, -0.6539612, -0.0582436)
                + intermediate_two[0][3] * float3(0.1069196, -0.2638001, -0.6758506)
                + intermediate_two[1][0] * float3(0.7559080, 0.3257033, 0.1210366)
                + intermediate_two[1][1] * float3(-0.7471734, -1.4724660, -1.0994586)
                + intermediate_two[1][2] * float3(0.7152942, 0.4997116, 0.5806220)
                + intermediate_two[1][3] * float3(-0.3170819, 0.1101551, -0.1644110)
                + intermediate_two[2][0] * float3(-0.7309898, -0.5595687, 0.2555541)
                + intermediate_two[2][1] * float3(0.7758809, 0.7829887, 1.6358902)
                + intermediate_two[2][2] * float3(0.5763697, 0.3727932, 0.4479653)
                + intermediate_two[2][3] * float3(0.2059326, 0.9155025, 0.4440589)
                + intermediate_two[3][0] * float3(-0.5008492, -0.3951916, -0.7712511)
                + intermediate_two[3][1] * float3(-0.7756605, -0.6284825, -0.4018687)
                + intermediate_two[3][2] * float3(-0.2816875, -0.5065715, -0.8144839)
                + intermediate_two[3][3] * float3(0.9017321, 0.7509986, 0.2758753);
		result = 1.0 / (1.0 + exp(-result));
        return result*viewdir.a+(1.0-viewdir.a);
    }
    ENDCG

    SubShader {
        Cull Off
        ZTest LEqual

        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            fixed4 frag(v2f i) : SV_Target {
                fixed4 diffuse0 = tex2D( tDiffuse0x, i.uv );
                if (diffuse0.r == 0.0) discard;
                fixed4 diffuse1 = tex2D( tDiffuse1x, i.uv );
                fixed4 rayDir = fixed4(normalize(i.rayDirection), 1.0);

                // normalize range to [-1, 1]
                diffuse0.a = diffuse0.a * 2.0 - 1.0;
                diffuse1.a = diffuse1.a * 2.0 - 1.0;

                fixed4 fragColor;
                fragColor.rgb = evaluateNetwork(diffuse0,diffuse1,rayDir);
                fragColor.a = 1.0;

                #if(!UNITY_COLORSPACE_GAMMA)
                    fragColor.rgb = GammaToLinearSpace(fragColor.rgb);
                #endif

                return fragColor;
            }
            ENDCG
        }

        // ------------------------------------------------------------------
        //  Shadow rendering pass
        Pass {
            Tags {"LightMode" = "ShadowCaster"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment fragShadowCaster
            #pragma multi_compile_shadowcaster

            fixed4 fragShadowCaster(v2f i) : SV_Target{
                fixed4 diffuse0 = tex2D(tDiffuse0x, i.uv);
                if (diffuse0.r == 0.0) discard;
                return 0;
            }
            ENDCG
        }
    }
}