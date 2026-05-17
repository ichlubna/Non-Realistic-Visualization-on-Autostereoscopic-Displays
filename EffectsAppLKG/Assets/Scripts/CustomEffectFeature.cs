//File: CustomEffectFeature.cs
//Author: Aneta Chalivopulosova (xchali00)
//Description: Scriptable Renderer Feature used to inject post-processing effects into the pipeline
//Resources: official Unity Manual and Forum (https://docs.unity3d.com/6000.0/Documentation/Manual/index.html) and the book Unity 6 Shaders and Effects Cookbook
//           by John P. Doran (https://github.com/PacktPublishing/Unity-6-Shaders-and-Effects-Cookbook) + help from Google Gemini (https://gemini.google.com/)

using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CustomEffectFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class Settings {
        public Material material;
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
    }

    public Settings settings = new Settings();
    private CustomEffectPass m_RenderPass;

    public override void Create() {
        m_RenderPass = new CustomEffectPass(settings.material);
        m_RenderPass.renderPassEvent = settings.renderPassEvent;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData) {
        if (settings.material != null && renderingData.cameraData.cameraType == CameraType.Game || renderingData.cameraData.cameraType == CameraType.SceneView) {
            renderer.EnqueuePass(m_RenderPass);
        }
    }

    // clean up the pass when the feature is destroyed/disabled
    protected override void Dispose(bool disposing) {
        m_RenderPass?.Dispose();
    }

    class CustomEffectPass : ScriptableRenderPass {
        private Material m_Material;
        private RTHandle m_TemporaryColorTexture;

        public CustomEffectPass(Material mat) {
            m_Material = mat;
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData) {
            if (m_Material == null) return;

            // get current camera target
            RTHandle cameraTarget = renderingData.cameraData.renderer.cameraColorTargetHandle;

            if (cameraTarget == null || cameraTarget.rt == null) return;

            CommandBuffer cmd = CommandBufferPool.Get("CustomEffectPass");

            using (new ProfilingScope(cmd, new ProfilingSampler("CustomEffectPass"))) {
                RenderTextureDescriptor desc = renderingData.cameraData.cameraTargetDescriptor;
                desc.depthBufferBits = 0; 

                // check if dimensions are valid before allocating
                if (desc.width > 0 && desc.height > 0) {
                    RenderingUtils.ReAllocateIfNeeded(ref m_TemporaryColorTexture, desc, FilterMode.Bilinear, TextureWrapMode.Clamp, name: "_TempCustomEffect");
                }

                // check if temp texture is ready
                if (m_TemporaryColorTexture != null && m_TemporaryColorTexture.rt != null) {
                    // blit 1: camera -> temp (with material)
                    Blitter.BlitCameraTexture(cmd, cameraTarget, m_TemporaryColorTexture, m_Material, 0);
                    
                    // blit 2: temp -> camera (back to screen)
                    Blitter.BlitCameraTexture(cmd, m_TemporaryColorTexture, cameraTarget);
                }
            }

            // execute command
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);  
        }

        public void Dispose() {
            m_TemporaryColorTexture?.Release();
        }
    }
}