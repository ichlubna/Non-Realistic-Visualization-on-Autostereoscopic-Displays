//File: MatrixDith.shader
//Author: Aneta Chalivopulosova (xchali00)
//Description: shader used for the matrix dithering effect
//Resources: Bachelor's thesis by the same author - Non-realistic effects on Lume Pad 
//          (https://github.com/AniChali/Non-realistic-effects-on-Lume-Pad),
//          the code was rewritten from Cg to HLSL with the help from Google Gemini

Shader "Hidden/MatrixDith" {

    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _MainTexBlack ("Base black (RGB)", 2D) = "black" {}
        _bwBlend ("Black & White blend", Range (0, 1)) = 0

        _Intensity ("Effect Intensity", Range(0, 1)) = 1.0
    }
    
    SubShader {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        ZWrite Off ZTest Always Cull Off
        
        Pass {
            Name "MatrixDithPass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            
            TEXTURE2D(_MainTexBlack);
            SAMPLER(sampler_MainTexBlack);
            
            uniform float _bwBlend;

            float _Intensity;

            // RESOURCE: https://www.shadertoy.com/view/4lcyzn
            static const float4x4 M2 = float4x4(
                0.0, 8.0, 2.0, 10.0, 
                12.0, 4.0, 14.0, 6.0,
                3.0,11.0,1.0,9.0,
                15.0,7.0,13.0, 5.0);


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
                cW.a = 1.0;
                cB.a = 1.0;

                int j, k;
                int m_side = 4;
                
                // fix 2D
                float2 referenceResolution = float2(1920.0, 1080.0); // common full hd baseline resolution - should be the same in 3D and 2D
                float2 scale = _ScreenParams.xy / referenceResolution;
                int x = i.positionCS.x / scale.x;
                int y = i.positionCS.y / scale.y;
                
                j = x % m_side;
                k = y % m_side;
                float r = result.rgb.r;


                // fixes weird blending 
                // RESOURCE: https://www.shadertoy.com/view/4lcyzn
                float threshold = M2[int(j)][int(k)] / 32.0;

                // compute luminance
                float lum_original = r;

                // binary dither decision
                float dithered = step(threshold, lum_original);

                // convert to black and white color
                float3 ditherColor = lerp(cB.rgb, cW.rgb, dithered);

                // blend dithering color ditherColor with the original color c
                float3 finalColor = lerp(c, ditherColor, _Intensity);

                return float4(finalColor, 1.0);
                
            }
            ENDHLSL
        }
    }
}