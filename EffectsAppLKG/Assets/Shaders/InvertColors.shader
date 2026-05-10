//File: InvertColors.shader
//Author: Aneta Chalivopulosova (xchali00)
//Description: shader used to invert original colors in the scene
//Resources: Unity Manual

Shader "Unlit/InvertColors"
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
            Name "InvertColorsPass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"


            float _Intensity;

            half4 Frag (Varyings input) : SV_Target
            {
    
                float2 uv = input.texcoord;
                half4 col = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv);

                float4 invertedCol = float4(1.0 - abs(1.0 - col.r - _Intensity),1.0 - abs(1.0 - col.g - _Intensity), 1.0 - abs(1.0 - col.b - _Intensity), col.a);
        
                return invertedCol;
            }
            ENDHLSL
        }
    }
}