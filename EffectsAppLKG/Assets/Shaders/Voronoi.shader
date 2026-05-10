//File: Voronoi.shader
//Author: Aneta Chalivopulosova (xchali00)
//Description: shader used for the dynamic voronoi effect
//Resources: Voronoi Image, Shadertoy (https://www.shadertoy.com/view/4f2yWw)


Shader "Unlit/Voronoi"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Intensity ("Effect Intensity", Range(0, 1)) = 1.0
        _FRAG_NUM ("Grid Size", Range(1, 200)) = 50.0 
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        ZWrite Off ZTest Always Cull Off

        Pass
        {
            Name "VoronoiPass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            float _PixelSize = 5.0;
            float _Intensity;

            float _FRAG_NUM = 100.0;

            float2 noise22(float2 uv) {
                float3 a = frac(uv.xyx * float3(435.24,342.45,856.05));
                a += dot(a, a+15.43);
                return frac(float2(a.x*a.y, a.y*a.z));
            }

            half4 Frag (Varyings input) : SV_Target
            {
                float2 uv = input.texcoord;

                // skip calculations if intensity is almost 0
                if (_Intensity < 0.01) {
                    return SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv);
                }

                //uv += 0.5;
                float4 originalCol = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv);

                float m = 0.0;
                float t =  _Time.y * 2.0;
        
                float minDist = 100.0;
                float cellIndex = 0.0;

                float3 finalCol = float3(0.0,0.0,0.0);

                // add Intensity 
                float currentGridSize = _FRAG_NUM / max(_Intensity, 0.001);
                uv *= currentGridSize;
                
                float2 gv = frac(uv)-0.5;
                float2 id = floor(uv);

                for(float y=-1.; y<=1.; y++) {
                    for(float x=-1.; x<=1.; x++) {
                        float2 offs = float2(x,y);
                        float2 loc = id+offs;
                        float2 n = noise22(loc);
                        float2 p = offs + sin(n*t)*.5;
                        float d = length(gv-p);
                        
                        if(d<minDist) {
                            minDist = d;
                            float2 uv = loc / currentGridSize;
                            finalCol = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv).xyz;
                        }
                    }   
                }

                return float4(finalCol,1.0);
            }
            ENDHLSL
        }
    }
}