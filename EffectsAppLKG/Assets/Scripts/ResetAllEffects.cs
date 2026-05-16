//File: ResetAllEffects.cs
//Author: Aneta Chalivopulosova (xchali00)
//Description: script used to reset the whole app 
//              - switch to no effect and set all effect's intensity to 100%
//Resources: official Unity Manual and Forum (https://docs.unity3d.com/6000.0/Documentation/Manual/index.html)

using UnityEngine;
using UnityEngine.Rendering.Universal;
using TMPro;

public class ResetAllEffects : MonoBehaviour
{
    public UniversalRendererData rendererData;
    public TextMeshProUGUI effectNameTextMesh;
    public TextMeshProUGUI intensityTextMesh;

    private Material targetMat;

   
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.LeftControl))
        {
            ResetAll();
        }

    }

    void ResetAll()
    {
        // reset so the asset file isn't permanently changed
        if (rendererData == null) return;

        // loop through all features
        foreach (var feature in rendererData.rendererFeatures)
        {
            if (feature.isActive)
            {
                feature.SetActive(false);
            }

            if (feature is CustomEffectFeature customFeature)
            {
                if (customFeature.settings.material != null)
                {
                    // reset material to 1.0 intensity (100%)
                    customFeature.settings.material.SetFloat("_Intensity", 1.0f);
                    
                }
            }
        }

        rendererData.rendererFeatures[0].SetActive(true);
        intensityTextMesh.text = "100%";
        effectNameTextMesh.text = "No Effect";
        
        // mark dirty - editor/build registers the reset
        rendererData.SetDirty();
    }
}
