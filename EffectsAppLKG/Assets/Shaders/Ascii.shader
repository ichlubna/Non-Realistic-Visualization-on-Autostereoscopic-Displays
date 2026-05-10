//File: Ascii.shader
//Author: Aneta Chalivopulosova (xchali00)
//Description: shader drawing the scene with different ASCII characters from a texture
//Resources: ASCII Rendering Shader in Unity, Stefan Jovanovic 
//          – https://github.com/StefanJo3107/ASCII-Rendering-Shader-in-Unity/tree/master
          


Shader "Unlit/Ascii"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Intensity ("Effect Intensity", Range(0, 1)) = 1.0
        _AsciiCharacters ("Ascii Characters Texture", 2D) = "white" {}
        _OutlineTexture ("Ascii Characters Texture", 2D) = "white" {}
        _GridSize ("Grid Size", Vector) = (8, 8, 0, 0)
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        ZWrite Off ZTest Always Cull Off

        Pass
        {
            Name "AsciiPass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            float _Intensity;

            float2 _GridSize;

            TEXTURE2D(_AsciiCharacters);

            TEXTURE2D(_OutlineTexture);

            half4 Frag (Varyings input) : SV_Target
            { 
                // get luminiscence of the current tile
                // ---
                float2 inputCoords = input.texcoord * _ScreenParams.xy;
                half4 col = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, input.texcoord);

                float2 tileCoords = floor(inputCoords / _GridSize);

                float2 tileUV = (tileCoords * _GridSize) / _ScreenParams.xy;

                // color of tile
                half4 tileColor = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, tileUV);

                // luminescene of the tile (grayscale conversion)
                float lum = dot(tileColor.rgb, float3(0.3, 0.59, 0.11));

                // local position inside the current tile (0.0 to 1.0)
                float2 pixelInTile = frac(inputCoords / _GridSize);

                // create basic outline
                // --- 
                float horizontalStep = _GridSize.x / _ScreenParams.x;

                // uv from the right neighbour
                float2 rightTileUV = float2(tileUV.x + horizontalStep, tileUV.y);

                // sample texture
                half4 rightTileColor = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, rightTileUV);

                // luminiscence of right neighbour
                float rightLum = dot(rightTileColor.rgb, float3(0.3, 0.59, 0.11));

                
                float difference = abs(rightLum - lum);
                if (difference > 0.2)
                {
                    // outline | texture
                    half4 outlineTex = SAMPLE_TEXTURE2D(_OutlineTexture, sampler_LinearClamp, pixelInTile);

                    half4 outlineCol = outlineTex * half4(1,1,1,1); 
                    return lerp(col, outlineCol, _Intensity);
                    
                }

                // sample the right ascii character and return it
                // ---
                
                // multiplying by 4.99 ensures 1.0 brightness maps to the right index
                float charIndex = floor((lum) * 4.99);

                // offset by index and divide by total characters (5)
                float2 asciiUV = float2((pixelInTile.x + charIndex) / 5.0, pixelInTile.y);

                // sample ascii character from texture
                half4 asciiTex = SAMPLE_TEXTURE2D(_AsciiCharacters, sampler_LinearClamp, asciiUV);

                // calculate the color with intensity 100%
                half4 asciiCol = asciiTex * half4(1,1,1,1); 
                return lerp(col, asciiCol, _Intensity);
              
            }
            ENDHLSL
        }
    }
}