# Kokoro TTS Model Files

To enable high-quality Kokoro TTS, download these files:

## 1. Model Weights (Required)
Download the Kokoro model from Hugging Face:
- **File**: `kokoro-v1_0.safetensors` (~311MB)
- **URL**: https://huggingface.co/prince-canuma/Kokoro-82M/blob/main/kokoro-v1_0.safetensors
- **Location**: Place in `Resources/TTS/kokoro-v1_0.safetensors`

## 2. Italian Voice Files (Required for Latin)
Download these voice configurations from MLX-Audio:
- **File**: `if_sara.json` (Clear female voice)
- **URL**: https://raw.githubusercontent.com/Blaizzy/mlx-audio/main/mlx_audio_swift/tts/Swift-TTS/Kokoro/Resources/if_sara.json
- **Location**: Place in `Resources/TTS/Voices/if_sara.json`

- **File**: `im_nicola.json` (Deep male voice)  
- **URL**: https://raw.githubusercontent.com/Blaizzy/mlx-audio/main/mlx_audio_swift/tts/Swift-TTS/Kokoro/Resources/im_nicola.json
- **Location**: Place in `Resources/TTS/Voices/im_nicola.json`

## 3. Add to Xcode Project
After downloading:
1. In Xcode, right-click on your project
2. Select "Add Files to [Project Name]"
3. Navigate to and select the `Resources/TTS` folder
4. Choose "Create folder references" (not "Create groups")
5. Ensure files are added to your app target

## Download Commands
You can use these terminal commands from your project root:

```bash
# Download model weights
curl -L -o "Resources/TTS/kokoro-v1_0.safetensors" "https://huggingface.co/prince-canuma/Kokoro-82M/resolve/main/kokoro-v1_0.safetensors"

# Download voice files
curl -L -o "Resources/TTS/Voices/if_sara.json" "https://raw.githubusercontent.com/Blaizzy/mlx-audio/main/mlx_audio_swift/tts/Swift-TTS/Kokoro/Resources/if_sara.json"

curl -L -o "Resources/TTS/Voices/im_nicola.json" "https://raw.githubusercontent.com/Blaizzy/mlx-audio/main/mlx_audio_swift/tts/Swift-TTS/Kokoro/Resources/im_nicola.json"
```

## File Structure
```
Resources/
  TTS/
    kokoro-v1_0.safetensors    (311MB model)
    Voices/
      if_sara.json             (Female voice)
      im_nicola.json           (Male voice)
```

## Current Status
- ✅ iOS TTS: Working (current fallback)
- ⏳ Kokoro TTS: Requires model files above
- ✅ Hybrid system: Ready to switch between engines

Once these files are downloaded and added to Xcode, Kokoro TTS will be available as the premium option! 