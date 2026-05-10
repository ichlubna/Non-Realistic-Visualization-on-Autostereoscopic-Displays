//File: Wobble.shader
//Author: Aneta Chalivopulosova (xchali00)
//Description: shader used for the wobble effect
//Resources: Bachelor's thesis by the same author - Non-realistic effects on Lume Pad 
//          (https://github.com/AniChali/Non-realistic-effects-on-Lume-Pad),
//          the code was rewritten from Cg to HLSL with the help from Google Gemini

Shader "Hidden/Wobble" {

    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _MainTexBlack ("Base black (RGB)", 2D) = "black" {}
        _Intensity ("Effect Intensity", Range(0, 1)) = 1.0
    }
    
    SubShader {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        ZWrite Off ZTest Always Cull Off
        
        Pass {
            Name "WobblePass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
            
            TEXTURE2D(_MainTexBlack);
            SAMPLER(sampler_MainTexBlack);
            
    
            float _Intensity;

            // jump using intensity as angle
            float2 jump(float2 uv, float radius) {
              
                float3 color = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv).rgb;
                half intensity = color.r*.3 + color.g*.59 + color.b*.11;
                float angle = radians(intensity*500.0);
                return uv+float2(cos(angle),sin(angle))*radius;
            }

            half4 Frag(Varyings input) : SV_Target {
                // RESOURCE: https://www.shadertoy.com/view/ds3GD8

                float4 c = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, input.texcoord);
                float2 uv = input.texcoord;
                
                // jump five times to get to final position
                for (int k=0; k<5; ++k) {
                    float jumpRadius = 0.003 * _Intensity;
                    uv = jump(uv,jumpRadius);
                }

                // get grayscale color of pixel on final position
                c = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv);
                float lum = c.r*.3 + c.g*.59 + c.b*.11;
                float3 bw = float3( lum, lum, lum ); 
                
                float4 result = c;
                result.rgb = lerp(c.rgb, bw, _Intensity);
                
                // opaque alpha
                result.a = 1.0;
                
                return result;

            }
            ENDHLSL
        }
    }
}