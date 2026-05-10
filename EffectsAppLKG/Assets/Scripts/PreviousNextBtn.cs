//File: PreviousNextBtn.cs
//Author: Aneta Chalivopulosova (xchali00)
//Description: script used to switch to next or previous effect in sequence
//Resources: official Unity Manual and Forum

using UnityEngine;
using UnityEngine.Rendering.Universal;
using TMPro;

public class PreviousNextBtn : MonoBehaviour
{    
    public UniversalRendererData rendererData;
    public TextMeshProUGUI effectNameTextMesh;
    public TextMeshProUGUI intensityTextMesh;

    private Material targetMat;

    private float originalIntensity;

    public void Update()
    {
        // when pressed N trigger ToggleToNext to switch effect
        if (Input.GetKeyDown(KeyCode.N))
        {
            ToggleToNextOrPrev('+');
        }

        // when pressed N trigger ToggleToNext to switch effect
        if (Input.GetKeyDown(KeyCode.P))
        {
            ToggleToNextOrPrev('-');
        }
    }

    void ToggleToNextOrPrev(char direction)
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

        
        if (activeIndex != -1)
        {
            
            // turn off the current effect
            rendererData.rendererFeatures[activeIndex].SetActive(false);
            

            int nextIndex = 0;
            // index of the next one - in loop
            if (direction == '+')
            {
                nextIndex = (activeIndex + 1) % rendererData.rendererFeatures.Count;
            }
            else if (direction == '-')
            {
                nextIndex = ((activeIndex - 1) < 0) ? (rendererData.rendererFeatures.Count-1) : (activeIndex - 1);
            }
            
            
            // turn on the next effect
            rendererData.rendererFeatures[nextIndex].SetActive(true);

            if (nextIndex == 0) {
                effectNameTextMesh.text = "No Effect";
            }
            else 
            {
                effectNameTextMesh.text = rendererData.rendererFeatures[nextIndex].name;
            }
            
            // set intensity text mesh to current percentage of next effect
            if (rendererData.rendererFeatures[nextIndex] is CustomEffectFeature customFeature) 
            {
                targetMat = customFeature.settings.material;
                originalIntensity = targetMat.GetFloat("_Intensity");
                intensityTextMesh.text = $"{Mathf.CeilToInt(originalIntensity*100)}%";
            }

        }
        else
        {
            // if none is active select no effect
            rendererData.rendererFeatures[0].SetActive(true);
        }

        rendererData.SetDirty();
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
                    // reset material to 1.0 (100%)
                    customFeature.settings.material.SetFloat("_Intensity", 1.0f);
                }
            }
        }

        rendererData.rendererFeatures[0].SetActive(true);
        
        // mark dirty - editor/build registers the reset
        rendererData.SetDirty();
    }
}