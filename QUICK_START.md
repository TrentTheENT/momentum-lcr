# Quick Start Guide

## ✅ Vercel Deployment - COMPLETE!

Your app is live at: **https://momentum-2qvmlel9e-trentonmcnelly-gmailcoms-projects.vercel.app**

## 📱 Building Native iOS/macOS Apps

### Prerequisites Setup

1. **Install CocoaPods:**
   ```bash
   sudo gem install cocoapods
   ```

2. **Agree to Xcode License:**
   ```bash
   sudo xcodebuild -license
   ```
   (Press space to scroll, type `agree` at the end)

3. **Install iOS Dependencies:**
   ```bash
   cd ios/App
   pod install
   cd ../..
   ```

### Build and Run

1. **Open in Xcode:**
   ```bash
   npm run cap:open:ios
   ```

2. **In Xcode:**
   - Select a simulator (iPhone 14 Pro recommended)
   - Click the Play button (▶) or press `Cmd + R`
   - Your app will launch!

3. **For macOS App (Mac Catalyst):**
   - In Xcode, go to the project settings
   - Under "Deployment Info", check "Mac"
   - Select macOS 11.0+ as minimum version
   - Build and run - you'll have a native macOS app!

### Update Web Code

After making changes to `index.html`:

```bash
# Copy changes to www directory
cp index.html www/

# Sync with native projects
npm run cap:sync

# Reopen Xcode
npm run cap:open:ios
```

## 🔧 Configuration

### Supabase Setup

1. Edit `www/index.html` (lines 557-558):
   ```javascript
   const SUPABASE_URL = 'https://your-project.supabase.co';
   const SUPABASE_ANON_KEY = 'your-anon-key';
   ```

2. Run the SQL schema in Supabase:
   - Copy contents of `supabase-schema.sql`
   - Paste in Supabase SQL Editor
   - Run it

## 📦 App Store Distribution

### iOS:
1. In Xcode: Product → Archive
2. Distribute App → App Store Connect
3. Follow the submission process

### macOS:
1. Enable Mac Catalyst in Xcode project settings
2. Product → Archive
3. Distribute App → App Store Connect

## 🎯 Next Steps

- [ ] Set up Supabase credentials
- [ ] Install CocoaPods and agree to Xcode license
- [ ] Test on iOS simulator
- [ ] Test on physical iPhone/iPad
- [ ] Enable Mac Catalyst for macOS app
- [ ] Add app icons and splash screens
- [ ] Configure app permissions
- [ ] Submit to App Store

## 📚 Resources

- [Capacitor Docs](https://capacitorjs.com/docs)
- [iOS Development](https://developer.apple.com/ios/)
- [Mac Catalyst](https://developer.apple.com/mac-catalyst/)

