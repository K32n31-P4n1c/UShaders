Shader "MyShader/US_SimpleShader"
{
    Properties
    {
        // _MainTex ("Texture", 2D) = "white" {} 
        _Color ("Color", Color) = (1,1,1,1)
        _WaterShallow ("WaterShallow", Color) = (1,1,1,1)
        _WaterDeep ("WaterDeep", Color) = (1,1,1,1)
        _WaveColor ("WaveColor", Color) = (1,1,1,1)
        _Gloss ("Gloss", Float) = 1
        _ShorelineTex ("Shoreline", 2D) = "black" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            // Mesh data:  vertex position, vertex normal, UVs, tangents, vertex colors
            // Renamed from appdata 
            struct VertexInput
            {
                float4 vertex : POSITION;
                // float4 colors : COLOR;
                float3 normal : NORMAL;
                // float4 tanget : TANGENT;
                float2 uv0 : TEXCOORD0;
                // float2 uv1 : TEXCOORD1;
            };

            // Renamed from v2f
            struct VertexOutput
            {
                float4 clipSpacePos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;  
            };

            // sampler2D _MainTex;
            sampler2D _ShorelineTex;
            // float4 _MainTex_ST;
            float4 _Color;
            float _Gloss;
            uniform float3 _MousePos;

            float3 _WaterShallow;
            float3 _WaterDeep;
            float3 _WaveColor;

            // Vertex shader
            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.uv0 = v.uv0;
                o.normal = v.normal;
                o.worldPos = mul( unity_ObjectToWorld, v.vertex );
                o.clipSpacePos = UnityObjectToClipPos(v.vertex);
                return o;
            }

        // -----------------------------------------------------------------------
            
            float InvLerp ( float a, float b, float value)
            {
                return ( value - a ) / ( b - a );
            }

            float3 MyLerp ( float3 a, float3 b, float t)
            {
                return (t * b) + ((1.0-t) * a);
            }

            float Posterize( float steps, float value)
            {
                return floor(value * steps) / steps;
            }
            
            // -----------------------------------------------------------------------

            float4 frag (VertexOutput o) : SV_Target
            {
                float shoreline =  tex2D(_ShorelineTex, o.uv0).x;
                float waveSize = 0.04;

                float shape = shoreline;
                //float shape = o.uv0.y;

                float waveAmp = (sin(shape / waveSize + _Time.y * 4) + 1) * 0.5;
                waveAmp = waveAmp * shoreline;

                float3 waterColor = lerp( _WaterDeep, _WaterShallow, shoreline);
                float3 waterWithWaves = lerp ( waterColor, _WaveColor, waveAmp);

                return float4 (waterWithWaves,0);
                
                return frac(_Time.y);


                //------------------------------------------------------------------------------------

                float dist = distance(_MousePos, o.worldPos);
                //return dist;
                float glow = saturate(1-dist);


                float2 uv = o.uv0;

                float3 colorA = float3(0.1, 0.8, 1);
                float3 colorB = float3(1, 0.1, 0.8);
                
                //float t = step(uv.y,0.5);   // with lerp function
                //float t = InvLerp( 0.25, 0.75, uv.y);
                //float t = smoothstep(0.35, 0.65, uv.y); // Same as IvrLerp but smooth
                float t = uv.y;
                t = Posterize(16, t);
                //return t;

                float3 blend = MyLerp(colorA, colorB, t);  // Blend between two colors on the y axis
                //return float4(blend,0);


                //------------------------------------------------------------------------------------

                float3 normal = normalize(o.normal); // Interpolated

                //return float4(o.worldPos, 1);

                // float3 lightDir = normalize( float3 (1,1,1));
                // Direct diffuse light
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float lightFalloff = max(0, dot(lightDir, normal) ); // saturata clampps between 0 and 1 
                //lightFalloff = step(0.1,lightFalloff); // for cutoff CARTOONISH LOOK
                lightFalloff = Posterize(3,lightFalloff);  // Add more rings
                float3 lightColor = _LightColor0.rgb;
                float3 directDiffuseLight = lightColor * lightFalloff;

                // Ambient light
                float3 ambientLight = float3(0.1, 0.1, 0.1);

                // Direct specular light
                float3 camPos = _WorldSpaceCameraPos;
                float3 fragToCam = camPos - o.worldPos;
                float3 viewDir = normalize(fragToCam);
                //return float4 (viewDir,1);
                float3 viewReflect = reflect(-viewDir, normal);
                //return float4 (viewReflect, 0);
                float specularFalloff = max(0,dot(viewReflect, lightDir));
                //return float4(specularFalloff.xxx,0);
                specularFalloff = pow( specularFalloff,  _Gloss); // Modify gloss
                //specularFalloff = step(0.1, specularFalloff); // for more CARTOONISH LOOK
                specularFalloff = Posterize(5,specularFalloff); // Add more rings    
                //return float4(specularFalloff.xxx,0);
            
                float3 directSpecular = specularFalloff * lightColor;

                // Composite light
                float3 diffuselight = ambientLight + directDiffuseLight;
                float3 finalSurfaceColor = diffuselight * _Color.rgb + directSpecular + glow;

                // float3 normal = o.normal / 2 + 0.5;   // -1 to 1 after we devide with 2 its -0.5 to 0.5 thats why we add + 0.5 so now itss from 0 to 1

                return float4( finalSurfaceColor, 0);
            }
            ENDCG
        }
    }
}
