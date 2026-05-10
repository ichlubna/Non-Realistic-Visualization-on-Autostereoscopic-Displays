//File: PinkShades.shader
//Author: Aneta Chalivopulosova (xchali00)
//Description: shader used for the pink shades effect using normals
//Resources: Oil Paint Brush, Shadertoy (https://www.shadertoy.com/view/MtKcDG)


Shader "Hidden/PinkShades"
{
    Properties
    {
        _MainTex ("Source", 2D) = "white" {}
        _Intensity ("Effect Intensity", Range(0, 1)) = 1.0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            Name "PinkShadesPass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
            
            float _Intensity;

            // brightness -> height (from shadertoy)
            float GetVal(float2 uv)
            {
                float3 col = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv).rgb;
                return length(col);
            }

            // image gradient from shadertoy
            float2 GetGrad(float2 uv, float delta)
            {
                float2 d = float2(delta, 0);
                return float2(
                    GetVal(uv + d.xy) - GetVal(uv - d.xy),
                    GetVal(uv + d.yx) - GetVal(uv - d.yx)
                ) / delta;
            }

            half4 Frag(Varyings i) : SV_Target
            {
                
                float2 uv = i.texcoord;

                // original color
                half4 originalCol = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv);

                // pixel size
                float delta = _BlitTexture_TexelSize.y;

                // fake normal from brightness
                float2 grad = GetGrad(uv, delta);
                float3 n = normalize(float3(grad, 1));
                
                if (n.x > 0.4)
                {
                    // from (-1,1) to (0,1)
                    float4 newCol = float4(n * 0.5 + 0.5, 1);
                    
                    return lerp(originalCol, newCol, _Intensity);
                } 
                else 
                {
                    float4 newCol = float4(1, 1, 1, 1);
                    return lerp(originalCol, newCol, _Intensity);
                }
            }
            ENDHLSL
        }
    }
}