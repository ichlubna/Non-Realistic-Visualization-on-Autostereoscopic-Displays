//File: ColorShading.shader
//Author: Aneta Chalivopulosova (xchali00)
//Description: shader drawing the scene with different shades of green based on luminescene
//Resources: Bachelor's thesis by the same author - Non-realistic effects on Lume Pad 
//          (https://github.com/AniChali/Non-realistic-effects-on-Lume-Pad),
//          the code was rewritten from Cg to HLSL with the help from Google Gemini

Shader "Unlit/ColorShading"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Intensity ("Effect Intensity", Range(0, 1)) = 1.0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        ZWrite Off ZTest Always Cull Off

        Pass
        { 
            Name "ColorShadingPass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            float _PixelSize = 5.0;
            float _Intensity;

            half4 Frag (Varyings input) : SV_Target
            {
                
                float ratioX = (input.texcoord.x) * _PixelSize;
                float ratioY = (input.texcoord.y) * _PixelSize;
                
                float2 distortedUV = input.texcoord + float2(ratioX, ratioY);
                half4 col = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, distortedUV);
                half4 originalColor = col;
                // convert to grayscale
                float lum = dot(col.rgb, float3(0.3, 0.59, 0.11));

                // threshold colors
                if (lum <= 0.1)
                {
                    col = half4(0.06, 0.22, 0.06, 1.0);
                }
                else if (lum > 0.5)
                {
                    col = half4(0.6, 0.74, 0.06, 1.0);
                }
                else // between 0.1 and 0.5
                {
                    col = half4(0.19, 0.38, 0.19, 1.0);
                }

                return lerp(originalColor, col, _Intensity);
            }
            ENDHLSL
        }
    }
}