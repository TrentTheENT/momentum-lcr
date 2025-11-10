# Native iOS and macOS App Setup Guide

## Prerequisites

1. **Xcode** (for iOS and macOS development)
   - Install from Mac App Store
   - Version 14.0 or later recommended

2. **CocoaPods** (for iOS dependencies)
   ```bash
   sudo gem install cocoapods
   ```

3. **Node.js** (already installed)

## Setup Steps

### 1. Initialize Capacitor (Already Done)
```bash
npm run cap:sync
```

### 2. Open iOS Project in Xcode
```bash
npm run cap:open:ios
```

### 3. Configure iOS App

In Xcode:
1. Select the project in the navigator
2. Go to "Signing & Capabilities"
3. Select your development team
4. Change the Bundle Identifier if needed
5. Enable capabilities you need (like Background Modes for notifications)

### 4. Build and Run on iOS Simulator
- In Xcode, select a simulator (iPhone 14 Pro recommended)
- Click the Play button or press `Cmd + R`
- The app will build and launch in the simulator

### 5. Build for Physical iOS Device
1. Connect your iPhone/iPad via USB
2. Select your device in Xcode
3. Trust the computer on your device if prompted
4. Click Play to build and install

### 6. Create macOS App (Catalyst)

Capacitor iOS projects can also run on macOS using Mac Catalyst:

1. In Xcode, select the project
2. Go to "General" tab
3. Under "Deployment Info", check "Mac"
4. Select a macOS version (macOS 11.0+)
5. Build and run - it will create a macOS app!

### 7. Build for App Store Distribution

#### iOS:
1. In Xcode, select "Any iOS Device" as target
2. Product → Archive
3. Once archived, click "Distribute App"
4. Follow the App Store Connect process

#### macOS:
1. Select "My Mac" as target
2. Product → Archive
3. Distribute App → App Store Connect

## Adding Native Features

### Haptic Feedback
The app already includes Capacitor Haptics. Use it in your code:
```javascript
import { Haptics } from '@capacitor/haptics';

// Light impact
await Haptics.impact({ style: ImpactStyle.Light });

// Medium impact
await Haptics.impact({ style: ImpactStyle.Medium });

// Heavy impact
await Haptics.impact({ style: ImpactStyle.Heavy });
```

### Status Bar
```javascript
import { StatusBar, Style } from '@capacitor/status-bar';

// Set status bar style
await StatusBar.setStyle({ style: Style.Dark });
```

## Updating the App

After making changes to your web code:

1. **Sync Capacitor:**
   ```bash
   npm run cap:sync
   ```

2. **Reopen in Xcode:**
   ```bash
   npm run cap:open:ios
   ```

3. **Build and test** in Xcode

## Project Structure

```
Momentum-LCR/
├── ios/                    # iOS native project (generated)
│   ├── App/
│   ├── App.xcodeproj/
│   └── Podfile
├── index.html              # Your web app
├── capacitor.config.ts     # Capacitor configuration
└── package.json
```

## Troubleshooting

### CocoaPods Issues
```bash
cd ios/App
pod install
pod update
```

### Build Errors
- Clean build folder: Product → Clean Build Folder (Shift+Cmd+K)
- Delete Derived Data: Xcode → Preferences → Locations → Derived Data

### Sync Issues
```bash
npm run cap:sync
# Then reopen Xcode
```

## Environment Variables

For Supabase configuration in native apps, you can:
1. Use Capacitor Preferences plugin
2. Or hardcode in `index.html` (not recommended for production)
3. Or use environment-specific config files

## Next Steps

1. Add app icons (in Xcode, Assets.xcassets)
2. Configure app permissions (Info.plist)
3. Set up push notifications if needed
4. Test on physical devices
5. Submit to App Store

## Resources

- [Capacitor Docs](https://capacitorjs.com/docs)
- [iOS Development Guide](https://developer.apple.com/ios/)
- [App Store Connect](https://appstoreconnect.apple.com/)

