﻿Shader "Custom/Unlit/01_ambient"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // UnityエディタのEnvironment Lightingを反映
                return UNITY_LIGHTMODEL_AMBIENT;
            }
            ENDCG
        }
    }
}
