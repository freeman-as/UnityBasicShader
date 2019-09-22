Shader "Custom/Unlit/02_diffuse"
{
    Properties
    {
        _DiffuseColor("Diffuse Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Pass
        {
            // UnityエディタのDirectional Light参照時の設定
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // UnityエディタのDirectional Light参照
            uniform fixed4 _LightColor0;
            uniform fixed4 _DiffuseColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed4 color : COLOR0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // ワールド変換の逆行列からローカル座標の法線の変換行列を求める
                half3 normal = normalize(mul(v.normal, unity_WorldToObject).xyz);

                // 光源の向き（ディレクショナルライトに距離の概念はないため）
                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                // 内積で各頂点の法線ごとの光の向きを計算
                // saturateで下限を0に（負の値を出さないため）
                half NdotL = saturate(dot(normal, lightDir));

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * _DiffuseColor.rgb;
                // 反射照度 * 反射係数 = 拡散反射光
                fixed3 diffuse = _LightColor0.rgb * _DiffuseColor.rgb * NdotL;

                o.color = fixed4(ambient + diffuse, 1.0);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
}
