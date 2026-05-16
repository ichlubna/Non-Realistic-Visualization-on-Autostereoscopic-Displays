//File: Wobble2.shader
//Author: Aneta Chalivopulosova (xchali00)
//Description: shader used for the wobble 2 effect
//Resources: Bachelor's thesis by the same author - Non-realistic effects on Lume Pad 
//          (https://github.com/AniChali/Non-realistic-effects-on-Lume-Pad),
//          the code was rewritten from Cg to HLSL with the help from Google Gemini (https://gemini.google.com/)

Shader "Hidden/Wobble2" {

    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Intensity ("Effect Intensity", Range(0, 1)) = 1.0
    }
    
    SubShader {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        ZWrite Off ZTest Always Cull Off
        
        Pass {
            Name "Wobble2Pass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"


            float _Intensity;


            float2 wobble (float2 uv, float amplitude, float frequence, float speed, float intensity) {
                // get offset on x-axis with sinus function
                float offset = amplitude*sin(uv.y*frequence+speed);
                return float2(uv.x + (offset * intensity),uv.y);    
            }


            half4 Frag(Varyings i) : SV_Target {

                // RESOURCE: https://www.shadertoy.com/view/MdS3RV
                
                float2 uv = i.texcoord;
                float amplitude = 0.05;
                float frequence = 30.00;
                float speed = 10.0;
                // create offset with wobble function
                uv = wobble(uv,amplitude,frequence,speed,_Intensity);
                
                float4 c = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv);
                
                // opaque alpha 
                c.a = 1.0;

                return c;
                   
            }
            ENDHLSL
        }
    }
}