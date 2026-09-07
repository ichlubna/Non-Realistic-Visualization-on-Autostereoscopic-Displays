using UnityEngine;
using UnityEngine.Rendering.Universal;
using System.IO;
using System;
using System.Collections.Generic;

public class RendererFeatureShuffler : MonoBehaviour
{
    [SerializeField] private UniversalRendererData rendererData;

    // Static reference mapping feature names to their official original indices (1-22)
    private static readonly Dictionary<string, int> OriginalIndices = new Dictionary<string, int>
    {
        { "ColorShading", 1 },
        { "OutlineFull", 2 },
        { "OutlineOnly", 3 },
        { "Swirl", 4 },
        { "RevealNormals", 5 },
        { "Tresholding", 6 },
        { "RandomDithering", 7 },
        { "MatrixDithering", 8 },
        { "Dithering", 9 },
        { "Wobble", 10 },
        { "Wobble2", 11 },
        { "SwirlBlackAndWhite", 12 },
        { "Voronoi", 13 },
        { "Ascii", 14 },
        { "Pixelated", 15 },
        { "Grunge", 16 },
        { "InvertColors", 17 },
        { "OldMovie", 18 },
        { "NightVision", 19 },
        { "Distortion", 20 },
        { "DotShading", 21 },
        { "StripeShading", 22 }
    };

    void Awake()
    {
        if (rendererData == null || rendererData.rendererFeatures.Count <= 3) return;

        var features = rendererData.rendererFeatures;

        // Fisher-Yates shuffle starting from index 2 (keeping indices 0 & 1 fixed)
        for (int i = 2; i < features.Count; i++)
        {
            int randomIndex = UnityEngine.Random.Range(i, features.Count);
            var temp = features[i];
            features[i] = features[randomIndex];
            features[randomIndex] = temp;
        }

        ExportToCSV(features);
    }

    private void ExportToCSV(List<ScriptableRendererFeature> features)
    {
        List<string> csvLines = new List<string>();
        
        // CSV Header
        csvLines.Add("original index,shuffled index,name");

        for (int i = 0; i < features.Count; i++)
        {
            string featureName = features[i] != null ? features[i].name : "Missing Feature";
            string cleanName = featureName.Trim();

            // Match name against original index lookup
            string originalIndexStr = OriginalIndices.TryGetValue(cleanName, out int origIdx) 
                ? origIdx.ToString() 
                : "N/A";

            int shuffledIndex = i + 1; // 1-based shuffled index

            // Format row (escaping quotes around name to prevent formatting bugs)
            csvLines.Add($"{originalIndexStr},{shuffledIndex},\"{featureName}\"");
        }

        // Target folder: executable parent folder in builds, 'Assets' folder in Editor
        string directoryPath = Application.isEditor 
            ? Application.dataPath 
            : Directory.GetParent(Application.dataPath).FullName;

        string timestamp = DateTime.Now.ToString("yyyy-MM-dd_HH-mm-ss");
        string fileName = $"RendererOrder_{timestamp}.csv";
        string fullPath = Path.Combine(directoryPath, fileName);

        try
        {
            File.WriteAllLines(fullPath, csvLines);
            Debug.Log($"[Renderer Shuffler] CSV exported to: {fullPath}");
        }
        catch (Exception e)
        {
            Debug.LogError($"[Renderer Shuffler] Failed to write CSV file: {e.Message}");
        }
    }
}