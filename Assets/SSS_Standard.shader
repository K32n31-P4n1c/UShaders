Shader "MyShader/NewSurfaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Saturation ("Saturation", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;           // half , float , fixed , int
        half _Metallic;
        half _Saturation;            // We exposed it later
        fixed4 _Color;              // vector -> rgba thats 4


        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            // colors are between 0 and 1


            // fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            
            float2 uv = IN.uv_MainTex;
            uv.y  += sin(uv.x * 6.2831 + _Time.y) * .1;      // Animated because we used time works only in play mode
            fixed4 c = tex2D (_MainTex, uv) * _Color;
            
            // ----------------------- // 
            // o.Albedo = c;
            o.Albedo = lerp((c.r + c.g + c.b) / 3 , c, _Saturation);  // mix between black and white and colored version, 0 - gives first value 1 - gives second value, We use _Saturation to expose it to a variable
            //o.Albedo = (c.r + c.g, + c.b) / 3;  // Average of the tree color channels
            // o.Albedo = c.b; // Take only the blue channel, this produces a black and white image, same as float3(c.b, c.b, c.b)
            // o.Albedo = 1 - c; // 1-c is inverted color
            // o.Albedo = float3(0,1,1) * float3(1,0,0);   // (0*1, 1*0, 1*0) = (0,0,0)
            //
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
