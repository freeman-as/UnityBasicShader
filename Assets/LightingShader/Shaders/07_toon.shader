﻿// Toonシェーディング
// 輪郭線とセル塗りで2Dアニメのような表現
// 要素ごとにパスを分けて2回レンダリング
Shader "Custom/Unlit/07_toon"
{
    Properties
    {
        _ToonLightColor("Toon Light Color", Color) = (1, 1, 1, 1)
        _ToonDarkColor("Toon Dark Color", Color) = (1, 1, 1, 1)
        _OutlineColor("Outline Color", Color) = (1, 1, 1, 1)
        _OutlineWidth("Outline Width", Range(0.01, 0.1)) = 0.01
    }
    SubShader
    {
        // 0: Outline
        Pass
        {
            // カリング変更
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            uniform fixed4 _OutlineColor;
            uniform half _OutlineWidth;

            float4 vert(float4 vertex : POSITION, float3 normal : NORMAL) : SV_POSITION
            {
                // 法線基準に膨張
                vertex.xyz += normal * _OutlineWidth;

                return UnityObjectToClipPos(vertex);
            }

            fixed4 frag() : SV_TARGET
            {
                // 単色で塗りつぶし
                return _OutlineColor;
            }
            ENDCG
        }

        // 1: CelLook
        pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            uniform fixed4 _ToonLightColor;
            uniform fixed4 _ToonDarkColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = normalize(mul(v.normal, unity_WorldToObject).xyz);
                
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                half3 normal = normalize(i.normal);
                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                half NdotL = saturate(dot(normal, lightDir));

                fixed3 toon = lerp(_ToonLightColor.rgb, _ToonDarkColor.rgb, step(NdotL, 0));
                fixed4 color = fixed4(toon, 1.0);

                return color;
            }

            ENDCG
        }
    }
}
