//File: IntensitySlider.cs
//Author: Aneta Chalivopulosova (xchali00)
//Description: script used to change the intensity of the effect by adding or subtracting 5%
//Resources: official Unity Manual and Forum (https://docs.unity3d.com/6000.0/Documentation/Manual/index.html)

using UnityEngine;
using UnityEngine.Rendering.Universal;
using TMPro;

public class IntensitySlider : MonoBehaviour
{
    public UniversalRendererData rendererData;
    public TextMeshProUGUI intensityTextMesh;

    private Material targetMat;
    private float originalIntensity;

   

    void Update()
    {
        // when pressed RightArrow trigger Adding more intensity
        if (Input.GetKeyDown(KeyCode.RightArrow))
        {
            ChangeIntensity('+');   
            
        } 

        if (Input.GetKeyDown(KeyCode.LeftArrow))
        {
           
            ChangeIntensity('-');   
        }


    }


    void ChangeIntensity(char direction)
    {
        if (rendererData == null || rendererData.rendererFeatures.Count == 0) return;

        int activeIndex = -1;
        var feature = rendererData.rendererFeatures[0];

        // find currect effect
        for (int i = 0; i < rendererData.rendererFeatures.Count; i++)
        {
            if (rendererData.rendererFeatures[i].isActive)
            {
                feature = rendererData.rendererFeatures[i];
                activeIndex = i;
                break;
            }
        }

        if (feature is CustomEffectFeature customFeature && customFeature.isActive) 
        {
            targetMat = customFeature.settings.material;

            if (targetMat != null)
            {
                // store original for the OnDisable reset
                originalIntensity = targetMat.GetFloat("_Intensity");
                float newIntensity;
                // set the new intensity
                if (direction == '+' && originalIntensity < 1.0f)
                {
                    newIntensity = originalIntensity + 0.05f;
                    targetMat.SetFloat("_Intensity", newIntensity);
                    intensityTextMesh.text = $"{Mathf.CeilToInt(newIntensity*100)}%";

                    
                }
                else if (direction == '-' && originalIntensity > 0.0f)
                {
                    newIntensity = originalIntensity - 0.05f;
                    targetMat.SetFloat("_Intensity", newIntensity);
                    intensityTextMesh.text = $"{Mathf.CeilToInt(newIntensity*100)}%";
                }
                    

            }
        }

    }


    void OnDisable()
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
                    // reset material to 1.0 (100% intensity)
                    customFeature.settings.material.SetFloat("_Intensity", 1.0f);
                }
            }
        }
        rendererData.rendererFeatures[0].SetActive(true);

        // mark dirty - editor/build registers the reset
        rendererData.SetDirty();
    }
}
