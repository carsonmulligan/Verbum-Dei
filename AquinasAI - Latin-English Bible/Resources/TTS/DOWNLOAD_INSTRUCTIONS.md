# Kokoro TTS Model Files

✅ **STATUS: All files downloaded and ready for use!**

To enable high-quality Kokoro TTS, the following files have been downloaded:

## 1. Model Weights ✅ DOWNLOADED
- **File**: `kokoro-v1_0.safetensors` (~311MB)
- **Location**: `Resources/TTS/kokoro-v1_0.safetensors`
- **Status**: ✅ Downloaded successfully

## 2. Voice Files ✅ DOWNLOADED

### Italian Voices (for Latin pronunciation)
- **if_sara.json** ✅ - Clear female voice, ideal for liturgical texts
- **im_nicola.json** ✅ - Deep male voice, good for scholarly reading

### English Voices
- **af_bella.json** ✅ - High-quality female voice, warm and engaging  
- **am_adam.json** ✅ - Clear male voice, good for narration

### Spanish Voices  
- **ef_dora.json** ✅ - Warm female voice for Spanish text
- **em_alex.json** ✅ - Clear male voice for Spanish text

## 3. Next Step: Add to Xcode Project

**IMPORTANT**: You still need to add these files to your Xcode project:

1. **In Xcode**, right-click on your project
2. **Select** "Add Files to [Project Name]"
3. **Navigate to and select** the `Resources/TTS` folder
4. **Choose** "Create folder references" (not "Create groups")
5. **Ensure** files are added to your app target

## File Structure ✅ COMPLETE
```
Resources/
  TTS/
    kokoro-v1_0.safetensors    ✅ (311MB model)
    Voices/
      if_sara.json             ✅ (Italian female - for Latin)
      im_nicola.json           ✅ (Italian male - for Latin)
      af_bella.json            ✅ (English female)
      am_adam.json             ✅ (English male)
      ef_dora.json             ✅ (Spanish female)
      em_alex.json             ✅ (Spanish male)
```

## Voice Selection by Language

Your app will automatically select appropriate voices:

- **Latin text** → Italian voices (if_sara, im_nicola)
- **English text** → English voices (af_bella, am_adam)  
- **Spanish text** → Spanish voices (ef_dora, em_alex)
- **Fallback** → iOS TTS if Kokoro unavailable

## Current Status
- ✅ **Files downloaded**: All required model and voice files
- ✅ **iOS TTS**: Working (current fallback)
- ⏳ **Kokoro TTS**: Requires files to be added to Xcode project
- ✅ **Hybrid system**: Ready to switch between engines
- ✅ **Multi-language**: Italian, English, Spanish voices ready

## Performance Notes
- **Model size**: ~311MB (loaded into memory when used)
- **Voice files**: ~2.7MB each (loaded as needed)
- **Total download**: ~327MB for complete system
- **Runtime memory**: ~200MB when Kokoro is active

Once you add the `Resources/TTS` folder to your Xcode project, Kokoro TTS will be available as the premium option with high-quality neural voices for all three languages! 