# WorshipFlow AI

WorshipFlow AI is a SwiftUI iOS app scaffold for worship planning and team operations. It is positioned as an organizational planning tool for worship teams, not theological authority or ministry certification software.

## What is included

- SwiftUI app target with `NavigationStack`
- MVVM-style app state in `AppViewModel`
- SwiftData local persistence models
- Mock AI enabled by default through `MockAIService`
- Remote AI service placeholder for `POST https://YOUR_BACKEND_URL.com/worshipflow-ai`
- StoreKit 2 subscription scaffolding
- Local notification request and rehearsal reminder service
- Native PDF generation and share sheet
- Swift Charts analytics placeholder
- Sync, WidgetKit, and Apple Watch placeholder architecture
- Dark, stage-inspired design system with gold and deep blue accents

## Build

Open `WorshipFlowAI.xcodeproj` in Xcode on macOS, choose an iOS 17+ simulator, and run the `WorshipFlowAI` scheme.

This repository was generated in a Windows workspace, so `xcodebuild` could not be run locally here.

## AI Safety Note

The app displays this disclaimer in planning surfaces:

> WorshipFlow AI is an organizational and planning tool only. Users remain responsible for ministry decisions. AI suggestions are optional recommendations.

Never store API keys in the iOS app. Add a secure backend before enabling `RemoteAIService`.
