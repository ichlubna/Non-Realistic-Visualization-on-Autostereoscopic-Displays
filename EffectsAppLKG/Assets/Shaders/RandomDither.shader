//File: RandomDither.shader
//Author: Aneta Chalivopulosova (xchali00)
//Description: shader used for the random dithering effect
//Resources: Bachelor's thesis by the same author - Non-realistic effects on Lume Pad 
//          (https://github.com/AniChali/Non-realistic-effects-on-Lume-Pad),
//          the code was rewritten from Cg to HLSL with the help from Google Gemini (https://gemini.google.com/)

Shader "Hidden/RandomDither" {

    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _MainTexBlack ("Base black (RGB)", 2D) = "black" {}
    
        _bwBlend ("Black & White blend", Range (0, 1)) = 1

        _Intensity ("Effect Intensity", Range(0, 1)) = 1.0
    }
    
    SubShader {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        ZWrite Off ZTest Always Cull Off
        
        Pass {
            Name "RandomDitherPass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
            
            TEXTURE2D(_MainTexBlack);
            SAMPLER(sampler_MainTexBlack);
            
            uniform float _bwBlend;

            float _Intensity;

            float rand (float2 uv)
            {
                // RESOURCE: https://thebookofshaders.com/10/
                return frac(sin(dot(uv,float2(12.9898,78.233)))*43758.5453123);
            }
            

            half4 Frag(Varyings i) : SV_Target {
                
                float4 c = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, i.texcoord);
                float4 cW = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, i.texcoord);
                float4 cB = SAMPLE_TEXTURE2D(_MainTexBlack, sampler_MainTexBlack, i.texcoord);

                
                // RESOURCE: https://www.alanzucconi.com/2015/07/08/screen-shaders-and-postprocessing-effects-in-unity3d/
                float lum = c.r*.3 + c.g*.59 + c.b*.11;
                float3 bw = float3( lum, lum, lum ); 
                
                float4 result = c;
                result.rgb = lerp(c.rgb, bw, _bwBlend);
                cW.rgb = lerp(cW.rgb, float3( 1, 1, 1 ), _bwBlend);
                cB.rgb = lerp(cB.rgb, float3( 0, 0, 0 ), _bwBlend);
            
                // opaque alpha
                cW.a = 1.0;
                cB.a = 1.0;

                // random tresholding
                if (result.rgb.r < rand(i.texcoord + rand(float2(i.texcoord.x+2,i.texcoord.y+2)))) {
                    //return cB;
                    return lerp(c, cB, _Intensity);
                } else {
                    //return cW;
                    return lerp(c, cW, _Intensity);
                }
                
            }
            ENDHLSL
        }
    }
}