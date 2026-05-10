//File: Distortion.shader
//Author: Aneta Chalivopulosova (xchali00)
//Description: shader used for the effect of a distorted look through a lens
//Resources: the book Unity 6 Shaders and Effects Cookbook by John P. Doran 
//          (https://github.com/PacktPublishing/Unity-6-Shaders-and-Effects-Cookbook)


Shader "Unlit/Distortion"
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
            Name "DistortionPass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            float _PixelSize = 5.0;
            float _Intensity;

            half4 Frag (Varyings input) : SV_Target
            {
                // RESOURCE:
                // Lens distortion algorithm see
                // Lens Distortion White Paper, Andersson Technologies LLC
                // https://support.borisfx.com/hc/en-us/articles/24284292845325-Lens-Distortion-White-Paper

                float2 uv = input.texcoord;
                half4 col = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv);

                float distortion = 3;
                float scale = 0.6;

                float2 h = uv - float2(0.5, 0.5);
                float r2 = h.x * h.x + h.y * h.y;
                float f = 1.0 + r2 * (distortion * sqrt(r2));
                float2 distortedUV = f * scale * h + 0.5;

                // add Intensity
                float2 finalUV = lerp(uv, distortedUV, _Intensity);

                half4 newCol = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, finalUV);


                return newCol;
                                
            }
            ENDHLSL
        }
    }
}