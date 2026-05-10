//File: Pixelated.shader
//Author: Aneta Chalivopulosova (xchali00)
//Description: shader used for the pixelated effect
//Resources: Unity Manual + the shader uses the same logic as Ascii.shader for the grid

Shader "Unlit/Pixelated"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Intensity ("Effect Intensity", Range(0, 1)) = 1.0
        _AsciiCharacters ("Ascii Characters Texture", 2D) = "white" {}
        _GridSize ("Grid Size", Vector) = (8, 8, 0, 0)
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        ZWrite Off ZTest Always Cull Off

        Pass
        {
            Name "Pixelated"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            float _Intensity;

            float2 _GridSize;

            half4 Frag (Varyings input) : SV_Target
            { 
                
                // fix 2D
                float2 resolutionScale = _ScreenParams.xy / float2(1920.0, 1080.0); // common full hd baseline resolution - should be the same in 3D and 2D
                float2 editedGridSize = max(floor((_GridSize * _Intensity) * resolutionScale), float2(1.0, 1.0));

                float2 inputCoords = input.texcoord * _ScreenParams.xy;
                half4 col = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, input.texcoord);

                float2 tileCoords = floor(inputCoords / editedGridSize);

                float2 tileUV = (tileCoords * editedGridSize) / _ScreenParams.xy;

                // color of tile
                half4 tileColor = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, tileUV);

               
                return tileColor;
               
            }
            ENDHLSL
        }
    }
}