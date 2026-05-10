//File: ResetSwitchBtn.cs
//Author: Aneta Chalivopulosova (xchali00)
//Description: script used to switch between 100% and 0% intensity 
//              and switching between 3D and 2D on the display
//Resources: official Unity Manual and Forum and Looking Glass Developer Docs

using UnityEngine;
using UnityEngine.Rendering.Universal;
using TMPro;
using LookingGlass;

public class ResetSwitchBtn : MonoBehaviour
{
    public int previousEffect;
    public UniversalRendererData rendererData;
    public TextMeshProUGUI effectNameTextMesh;
    public HologramCamera holoCamera;
    public GameObject holoCameraGameObject;
    public GameObject camera2DgameObject;
    public TextMeshProUGUI intensityTextMesh;

    public GameObject isActiveScene2;

    private Material targetMat;

    // used to restore intensity
    private float savedIntensity = 1.0f;
    private bool isReset = false;

    public void Update()
    {
        // when pressed R trigger ResetEffect to reset effect to 0% or back to previous intensity
        if (Input.GetKeyDown(KeyCode.R))
        {
            ResetEffect('R');
        }
        
        // when pressed F trigger ResetEffect to reset effect to 100% or back to previous intensity
        if (Input.GetKeyDown(KeyCode.F))
        {
            ResetEffect('F');
        }

        // when pressed X trigger switch 2D/3D
        if (Input.GetKeyDown(KeyCode.X))
        {
            // switch between 2D and 3D
            holoCamera.Preview2D = !holoCamera.Preview2D;
        }

        /*
        // debug: number of effects
        if (Input.GetKeyDown(KeyCode.E))
        {
            Debug.Log($"Number of effects: {rendererData.rendererFeatures.Count-1}.");
        }
        */

    }

    void ResetEffect(char direction)
    {
      

        if (rendererData == null) return;

        // find the current active feature
        CustomEffectFeature activeFeature = null;
        foreach (var feature in rendererData.rendererFeatures)
        {
            if (feature.isActive && feature is CustomEffectFeature custom)
            {
                activeFeature = custom;
                break;
            }
        }

        if (activeFeature == null || activeFeature.settings.material == null) return;

        targetMat = activeFeature.settings.material;

        if (!isReset)
        {
            // no effect = just set intensity to 0% or 100% (R or F)
            savedIntensity = targetMat.GetFloat("_Intensity");
            float newIntensity = 1.0f;
            if (direction == 'F') 
            {
                newIntensity = 1.0f;
            } 
            else if (direction == 'R')
            {
                newIntensity = 0.0f;
            }
            targetMat.SetFloat("_Intensity", newIntensity);
            intensityTextMesh.text = $"{Mathf.CeilToInt(newIntensity * 100)}%";
            isReset = true;
        }
        else
        {
            // restore the saved intensity
            targetMat.SetFloat("_Intensity", savedIntensity);
            effectNameTextMesh.text = activeFeature.name;
            intensityTextMesh.text = $"{Mathf.CeilToInt(savedIntensity * 100)}%";
            isReset = false;
        }

        rendererData.SetDirty();
    }


    void OnDisable()
    {
        camera2DgameObject.SetActive(false);
        holoCameraGameObject.SetActive(true);

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
                    // reset material to 1.0
                    customFeature.settings.material.SetFloat("_Intensity", 1.0f);
                }
            }
        }

        rendererData.rendererFeatures[0].SetActive(true);
        
        // mark dirty - editor/build registers the reset
        rendererData.SetDirty();
    }
    
}
