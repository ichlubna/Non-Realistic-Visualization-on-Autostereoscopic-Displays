//File: OutlineOnly.shader
//Author: Aneta Chalivopulosova (xchali00)
//Description: shader used for the outline only effect
//Resources: Bachelor's thesis by the same author - Non-realistic effects on Lume Pad 
//          (https://github.com/AniChali/Non-realistic-effects-on-Lume-Pad),
//          the code was rewritten from Cg to HLSL with the help from Google Gemini

Shader "Hidden/OutlineOnly" {

    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _MainTexBlack ("Base black (RGB)", 2D) = "black" {}
        _Intensity ("Effect Intensity", Range(0, 1)) = 1.0
    }
    
    SubShader {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        ZWrite Off ZTest Always Cull Off
        
        Pass {
            Name "OutlineOnlyPass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            float _bwBlend;
            float _Intensity;
            
            TEXTURE2D(_MainTexBlack);
            SAMPLER(sampler_MainTexBlack);

            // function that returns grayscale color of pixel
            float getGrayscale (float x, float y, float2 uv) {
                x = x / _ScreenParams.x;
                y = y / _ScreenParams.y;
                
                float4 c = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv + float2(x,y));
                
                float lum = c.r*.3 + c.g*.59 + c.b*.11;
                float3 bw = float3( lum, lum, lum ); 
                
                float4 grayscaleC = c;
                grayscaleC.rgb = lerp(c.rgb, bw, _bwBlend);
                return grayscaleC.r;
            }
            

            half4 Frag(Varyings input) : SV_Target {

                // input.texcoord is the URP equivalent of i.uv
                float4 c = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, input.texcoord);
                
                // RESOURCE: https://www.alanzucconi.com/2015/07/08/screen-shaders-and-postprocessing-effects-in-unity3d/
                float lum = c.r*.3 + c.g*.59 + c.b*.11;
                float3 bw = float3( lum, lum, lum ); 
                
                float4 grayscaleC = c;
                grayscaleC.rgb = lerp(c.rgb, bw, _bwBlend);
                float2 uv = input.texcoord;
                float x = uv.x;
                float y = uv.y;

                // RESOURCE: https://www.imageeprocessing.com/2011/12/sobel-edge-detection.html
                // get gradients using the sobel operator
                float Gx=((2*getGrayscale(2,1,uv)+getGrayscale(2,0,uv)+getGrayscale(2,2,uv))-(2*getGrayscale(0,1,uv)+getGrayscale(0,0,uv)+getGrayscale(0,2,uv)));
                float Gy=((2*getGrayscale(1,2,uv)+getGrayscale(0,2,uv)+getGrayscale(2,2,uv))-(2*getGrayscale(1,0,uv)+getGrayscale(0,0,uv)+getGrayscale(2,0,uv)));

                // magnitude of gradient vector
                float tmp = sqrt((Gx*Gx)+(Gy*Gy));
                grayscaleC = float4(tmp,tmp,tmp,tmp);
                
                float tres = 0.2;
                tmp = max(tmp,tres);
                // tresholding
                if (tmp > tres) {
                    tmp = 1;
                    grayscaleC = float4(tmp,tmp,tmp,tmp);
                    return lerp(c, grayscaleC, _Intensity);
                } else {
                    return c;
                }
                
                
            }
            ENDHLSL
        }
    }
}