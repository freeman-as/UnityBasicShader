﻿Shader "Custom/Unlit/00_basic"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float4 vert (float4 vertex : POSITION) : SV_POSITION
            {

                return UnityObjectToClipPos(vertex);
            }

            fixed4 frag () : SV_Target
            {
                return fixed4(1.0, 0, 0, 1.0);
            }
            ENDCG
        }
    }
}
