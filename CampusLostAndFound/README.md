# Campus Lost & Found — SwiftUI (MVC)

A native SwiftUI conversion of the Campus Lost & Found prototype, organized
using the Model–View–Controller pattern. 44 Swift files, no third-party
dependencies — only SwiftUI, UIKit, PhotosUI, and AVFoundation.

## Structure

```
CampusLostAndFound/
├── LarpingLostAndFoundApp.swift   ← @main app entry point
├── Model/                         ← plain data types, no UI or app logic
│   ├── LostFoundItem.swift        (the core lost/found item record)
│   ├── User.swift                 (student/employee account)
│   ├── Claim.swift                (a claim filed against a found item)
│   ├── ItemDraft.swift            (in-progress report/edit form state)
│   ├── AppEnums.swift             (ItemType, ItemStatus, ItemCategory, etc.)
│   └── AppNotification.swift      (in-app notification record)
├── Controller/                    ← app/business logic and state management
│   ├── AppController.swift        (ObservableObject: navigation, auth,
│   │                                CRUD on items/claims, the "C" in MVC)
│   ├── DataRepository.swift       (protocol the controller talks to)
│   └── MockRepository.swift       (in-memory seed data implementation)
└── View/                          ← everything that renders UI
    ├── Theme/AppTheme.swift       (colors, spacing, shared modifiers)
    ├── Components/                (reusable views: buttons, item cards,
    │                                photo pickers, status badges, etc.)
    └── Screens/                   (one file per screen, grouped by area)
        ├── Authentication/        (Login, Sign Up, Forgot Password)
        ├── Student/               (Home, Browse, Report, My Items, Claim,
        │                            Item Detail, Edit Item, tab shell)
        ├── Employee/               (Dashboard, Reports, Claims, Items,
        │                            review screens, tab shell)
        └── Shared/                (Profile, Edit Profile, Change Password,
                                     Notifications, Help, About, Rate App)
```

## How the pieces talk to each other

- **Views** never touch the repository directly — they read from and call
  methods on `AppController`, which is injected as an `@EnvironmentObject`.
- **AppController** (the Controller) owns all app state — the logged-in
  user, the list of items and claims, current navigation — and exposes
  intent methods like `submitReport`, `approveClaim`, `logout`. It talks to
  a `DataRepository` for data access rather than owning storage itself.
- **Models** are inert value types (`struct`s and `enum`s) with no
  behavior beyond simple computed properties — they carry data between the
  Controller and the Views.

## Opening this in Xcode

This folder isn't wired up as an `.xcodeproj` — it's organized source
ready to drop into a new project. To use it:
1. In Xcode, create a new iOS App project (SwiftUI interface).
2. Delete the default `ContentView.swift`.
3. Drag the `Model/`, `View/`, and `Controller/` folders (and
   `LarpingLostAndFoundApp.swift`) into the project, keeping "Create
   groups" selected.
4. In your target's Info settings, add `NSCameraUsageDescription` and
   `NSPhotoLibraryUsageDescription` (the camera/photo-attach flow in the
   report screen needs these).

If you just want to run it — without Xcode, directly on an iPad — use the
separate `CampusLostAndFound.swiftpm.zip`, which is this same code
pre-wired as a Swift Playgrounds app project.
