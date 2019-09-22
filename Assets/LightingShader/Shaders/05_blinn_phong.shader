// Blinn-Phongシェーディング
// ハーフベクトルによるPhong反射
Shader "Custom/Unlit/05_blinn_phong"
{
    Properties
    {
        _DiffuseColor("Diffuse Color", Color) = (1, 1, 1, 1)
        _SpecularColor("Specular Color", Color) = (1, 1, 1, 1)
        _Shininess("Shininess", Float) = 20
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
            uniform fixed4 _SpecularColor;
            uniform half _Shininess;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                float4 posWorld : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // ワールド変換の逆行列からローカル座標の法線の変換行列を求める
                o.normal = normalize(mul(v.normal, unity_WorldToObject).xyz);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half3 normal = normalize(i.normal);              
                // 光源の向き (ディレクショナルライトに距離の概念はないため)
                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                // 視線ベクトル (頂点をワールド座標系に変換、頂点とカメラの位置関係から求める)
                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
                // ハーフベクトル (光源ベクトルと視線ベクトルの合成と正規化)
                half3 halfDir = normalize(lightDir + viewDir);

                // 内積で各頂点の法線ごとの光の向きを計算
                // saturateで下限を0に (負の値を出さないため)
                half NdotL = saturate(dot(normal, lightDir));
                half NdotH = saturate(dot(normal, halfDir));

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * _DiffuseColor.rgb;
                // 放射照度 * 反射係数 = 拡散反射光
                fixed3 diffuse = _LightColor0.rgb * _DiffuseColor.rgb * NdotL;
                // Blinn-Phong反射 (放射照度 * 鏡面反射係数 * 反射強度(法線とハーフベクトルの内積))
                fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(NdotH, _Shininess);

                fixed4 color = fixed4(ambient + diffuse + specular, 1.0);

                return color;
            }
            ENDCG
        }
    }
}
