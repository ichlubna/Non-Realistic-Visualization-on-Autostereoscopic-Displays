//File: SwirlBlackAndWhite.shader
//Author: Aneta Chalivopulosova (xchali00)
//Description: shader used for the black and white swirl effect
//Resources: Learning Shaders with Char, Looking Glass 
//          (website: https://lookingglassfactory.com/tutorial/learning-shaders-with-char, 
//          code: https://gist.github.com/CharStiles/2d8e47d3a61c45b0ac785155e438f06e)

Shader "Hidden/SwirlBlackAndWhite"
{
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Strength ("Swirl Strength", Range(0, 10)) = 0.5
        _Speed ("Swirl Speed", Range(0, 10)) = 1.0
        _RingFreq ("Ring Frequency", Range(1, 20)) = 5.0
        _Intensity ("Effect Intensity", Range(0, 1)) = 1.0
    }

    SubShader {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        Cull Off ZWrite Off ZTest Always

        Pass {
            Name "SwirlBlackAndWhitePass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            float4 _MainTex_TexelSize;
            float _Strength;
            float _Speed;
            float _RingFreq;
            float _Intensity;

            float3 swirlColor(float2 pos, float t)
            {
                float angle = atan2(pos.y, pos.x);
                float r = sin(angle + t);
                float g = cos(length(pos * _RingFreq));
                float b = cos(angle + cos(length(pos * 15.0)));
                return float3(r, g, b) * 0.5 + 0.5; // map [-1,1] -> [0,1]
            }

            half4 Frag(Varyings i) : SV_Target
            {
                // original UV (0.0 to 1.0)
                float2 baseUV = i.texcoord;

                // centered version (-1.0 to 1.0)
                float2 centeredUV = baseUV * 2.0 - 1.0;
                
                // swirl distortion
                float radius = length(centeredUV);
                float angle = atan2(centeredUV.y, centeredUV.x);
                
                // twist based on radius and strength
                float twistedAngle = angle + (radius * _Strength);
                
                // convert back to cartesian coords
                float2 swirledCentered = float2(cos(twistedAngle), sin(twistedAngle)) * radius;
                
                // mp back from [-1, 1] to [0, 1]
                float2 swirledUV = swirledCentered * 0.5 + 0.5;

                // add intensity logic
                float2 finalUV = lerp(baseUV, swirledUV, _Intensity);

                float4 col = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, finalUV);

                // just getting the r channel from rgb - grayscale
                float4 grayScaleCol = float4(col.r, col.r, col.r, 1.0);

                return lerp(col, grayScaleCol, _Intensity);

            }
            ENDHLSL
        }
    }
}