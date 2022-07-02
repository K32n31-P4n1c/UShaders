Shader "MyShader/US_Unlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION; 
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            // Vertex shader
            v2f vert (appdata v)
            {
                v2f o;

                // Deforming surface
                // v.vertex.y += sin(v.vertex.x);
                // v.vertex.y += sin(v.vertex.x + _Time.y) * .1;
                o.vertex = UnityObjectToClipPos(v.vertex);

                // o.uv = v.uv // if we dont use the tiling we can use this
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            // Pixel Shader, fragment Shader
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);

                float2 uv = i.uv - .5;  // 0 is in the middle instead of the bottom left corner
                float a = _Time.y;
                float2 p = float2(sin(a), cos(a)) *.4;
                float2 distort = uv - p;
                float d = length(distort);   // Give me the distance from the pixel we render to the middle of the screen.
                float m = smoothstep(.07, .0, d);

                distort = distort * 10 * m;

                fixed4 col2 = tex2D(_MainTex, i.uv + distort);


                return col2;
                // return col;
            }
            ENDCG
        }
    }
}
