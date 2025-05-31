# Audio Integration Instructions for AquinasAI Latin-English Bible

## Overview
This document outlines the steps to integrate Kokoro TTS (Text-to-Speech) with Italian voice for reading Latin text aloud in the AquinasAI Bible app. Kokoro provides high-quality, offline neural voice synthesis ideal for scholarly Latin pronunciation.

## Why Kokoro + Italian Voice for Latin?
- **Accurate pronunciation**: Italian pronunciation is much closer to ecclesiastical Latin than English
- **Offline privacy**: No network requests, completely private
- **High quality**: Neural TTS with natural-sounding voices
- **Scholarly appropriate**: Fits the academic nature of the app

## Prerequisites

### System Requirements
- iOS 16.4+ or macOS 13.0+
- Apple Silicon (M1/M2) required for reasonable performance
- Xcode 15.0+
- ~150MB additional app storage (model + voice files)

### Dependencies to Add
1. **MLX Swift** - For running the neural network inference
2. **eSpeak NG Framework** - For phonemization (text preprocessing)
3. **Kokoro model weights** - The TTS neural network
4. **Italian voice files** - For pronunciation styling

## Implementation Plan

### Phase 1: Setup Dependencies
1. Add MLX Swift package dependency
2. Download and integrate eSpeak NG framework  
3. Download Kokoro model weights (kokoro-v1_0.safetensors, ~82MB)
4. Add Italian voice configuration files (if_sara.json, im_nicola.json, etc.)

### Phase 2: Core TTS Integration
1. Create `TTSManager` class to handle audio synthesis
2. Create `AudioSessionManager` for iOS audio session management
3. Implement voice loading and model initialization
4. Add text preprocessing pipeline for Latin text

### Phase 3: UI Integration
1. Add play/pause buttons to verse views
2. Create TTS settings panel for voice selection
3. Implement playback controls (speed, volume)
4. Add visual feedback for current reading position

### Phase 4: Enhanced Features
1. Chapter-level continuous reading
2. Background playback support
3. Bookmarking with audio timestamps
4. Multi-language voice support (Italian for Latin, native voices for other languages)

## File Structure Changes

```
BibleReader/
├── Audio/
│   ├── TTSManager.swift                 # Main TTS coordination
│   ├── KokoroTTS.swift                 # Kokoro-specific implementation  
│   ├── AudioSessionManager.swift       # iOS audio session handling
│   ├── VoiceLoader.swift              # Voice file management
│   └── TextProcessor.swift            # Latin text preprocessing
├── Models/
│   ├── Voice.swift                     # Voice configuration model
│   └── AudioSettings.swift            # User TTS preferences
├── Resources/
│   ├── TTS/
│   │   ├── kokoro-v1_0.safetensors    # Main model weights
│   │   ├── Frameworks/
│   │   │   └── ESpeakNG.xcframework   # Phonemization engine
│   │   └── Voices/                    # Italian voice configurations
│   │       ├── if_sara.json           # Female Italian voice
│   │       ├── im_nicola.json         # Male Italian voice
│   │       └── ...                    # Additional voice options
│   └── ...
└── ...
```

## Detailed Implementation Steps

### Step 1: Add Package Dependencies

In Xcode:
1. File → Add Package Dependencies
2. Add MLX Swift: `https://github.com/ml-explore/mlx-swift`
3. Download eSpeak NG framework from kokoro-ios repo
4. Add to project and link frameworks

### Step 2: Download Model and Voice Files

Required files:
- **Model weights**: [Download kokoro-v1_0.safetensors](https://huggingface.co/prince-canuma/Kokoro-82M/blob/main/kokoro-v1_0.safetensors) (82MB)
- **Italian voices**: Available in MLX-Audio repository under voice configurations
- **eSpeak NG**: Pre-compiled framework for phonemization

### Step 3: Create Core TTS Classes

Key classes to implement:
- `TTSManager`: Central coordinator for all TTS functionality
- `KokoroTTS`: Handles model loading and inference  
- `VoiceLoader`: Manages voice file selection and loading
- `AudioSessionManager`: iOS-specific audio handling

### Step 4: UI Integration Points

Add TTS controls to:
- `VerseViews.swift`: Individual verse playback buttons
- `ContentView.swift`: Chapter-level controls
- Settings panel: Voice selection and playback preferences

## Voice Configuration

### Recommended Italian Voices for Latin:
1. **if_sara.json** - Clear female voice, good for liturgical texts
2. **im_nicola.json** - Deep male voice, good for scholarly reading
3. **if_isabella.json** - Softer female voice for meditative texts

### Voice Selection Strategy:
- Default: `if_sara` (clear pronunciation)
- User configurable via settings
- Consider gender preferences for different text types (prayers vs scripture)

## Performance Considerations

### Optimization Strategies:
1. **Lazy loading**: Only load model when first TTS request is made
2. **Caching**: Cache generated audio for recently read verses
3. **Background processing**: Generate audio on background queue
4. **Memory management**: Unload model when app backgrounded

### Expected Performance:
- Model loading: 2-3 seconds on M1
- Audio generation: 0.1-0.5 seconds per verse
- Real-time factor: ~0.1x (10x slower than real-time on M1)

## User Experience Design

### TTS Controls:
- **Play button**: Small speaker icon next to each verse
- **Chapter controls**: Play/pause/stop for continuous reading
- **Progress indicator**: Visual feedback during audio generation
- **Settings**: Voice selection, playback speed, volume

### Audio Features:
- **Background playback**: Continue reading when app backgrounded
- **Auto-advance**: Option to continue to next verse/chapter
- **Reading position**: Highlight currently spoken text
- **Bookmark integration**: Save position with audio timestamp

## Testing Strategy

### Unit Tests:
- Voice file loading and validation
- Text preprocessing accuracy
- Audio generation functionality
- Settings persistence

### Integration Tests:
- End-to-end TTS workflow
- Audio session management
- Background playback behavior
- Memory usage under load

### User Testing:
- Pronunciation accuracy validation with Latin scholars
- UI usability for different user groups
- Performance on various device models
- Battery impact assessment

## Deployment Considerations

### App Store:
- Update app description to mention offline TTS
- Include audio features in screenshots
- Consider app size impact in marketing

### User Onboarding:
- Optional TTS setup during first launch
- Voice preview during setup
- Clear explanation of storage requirements
- Offline capability messaging

## Future Enhancements

### Advanced Features:
1. **Custom voice training**: Allow users to train on specific Latin pronunciations
2. **SSML support**: Advanced pronunciation markup for complex Latin texts
3. **Multi-voice dialogues**: Different voices for different speakers in scripture
4. **Audio annotations**: Voice notes linked to specific verses

### Language Expansion:
1. **Native voices**: Spanish and English voices for their respective texts
2. **Regional variants**: Different Latin pronunciation styles (Classical vs Ecclesiastical)
3. **Additional languages**: Support for other liturgical languages

## Troubleshooting

### Common Issues:
1. **Model fails to load**: Check file permissions and storage space
2. **Poor audio quality**: Verify voice file integrity and model compatibility
3. **Performance issues**: Ensure running on Apple Silicon device
4. **Audio session conflicts**: Check for other audio app interference

### Debug Tools:
- Audio generation timing logs
- Model loading success/failure tracking
- Voice file validation checks
- Memory usage monitoring

## Success Metrics

### Technical Metrics:
- Audio generation time < 500ms per verse
- Model loading time < 3 seconds
- Memory usage < 200MB during active use
- Zero crashes during audio playback

### User Experience Metrics:
- TTS feature adoption rate
- User satisfaction with pronunciation quality
- Retention impact of audio features
- Support ticket volume related to audio

## Conclusion

Integrating Kokoro TTS with Italian voice will significantly enhance the scholarly experience of reading Latin texts in the AquinasAI Bible app. The offline, high-quality pronunciation will provide users with an authentic way to engage with Latin scripture and prayers.

The implementation requires careful attention to performance optimization and user experience design, but the result will be a unique feature that sets this app apart from other Bible readers.

---

*This document should be updated as implementation progresses and new requirements are discovered.* 