# Xcode handoff

## Structure

52 app Swift files. Models contains data and form values; Methods contains the repository and MVC controller; Components contains reusable UI and photo handling; Screens contains separate authentication, student, employee, and shared screens; Theme contains colors and styling. Empty Employee and method folders were removed. There are no ViewModels.

Copy these app folders and LarpingLostAndFoundApp.swift into your iOS 17+ app target. Replace old sources rather than keeping both versions. Keep only one @main entry point.

Tests/AppControllerTests.swift belongs ONLY to an Xcode unit-test target, not the app target. It assumes the app module is named LarpingLostAndFound. Run Product > Test in Xcode.

## Required target Info keys

- NSCameraUsageDescription: Campus Lost & Found uses the camera to attach photos to lost and found reports.
- NSPhotoLibraryUsageDescription: Campus Lost & Found uses the photo library to attach photos to lost and found reports.

The camera action checks its privacy key, hardware availability, and permission before presentation. Library and camera photos are resized before storage.

## Accounts and behavior

- Student: student@larping.edu / 123456
- Employee: employee@larping.edu / 123456

Unknown emails can create local mock accounts. Existing emails require the correct password and role so typos do not create duplicate accounts. All data is in memory: logout preserves it, restarting resets it.

Reports begin pending, notify staff, and become visible in Browse after approval. Editing approved/rejected reports requires reapproval. Claimed, returned, and archived reports cannot be edited or deleted by students. Deletion removes linked claims and notifies claimants. Claim approval marks the item claimed and rejects competing pending claims. Reopening an item revokes previous claim approval; closing/rejecting an item resolves pending claims.

## Validation

Source checks found no duplicate types, legacy identifiers, missing screen destinations, missing referenced controller members, or unbalanced delimiter counts. Git whitespace checks passed. These are static checks, not Swift compilation.

Five XCTest cases cover report approval across logins, competing claims, ownership and deletion, password/profile changes, and validation/notification privacy. They have NOT been run: Swift, Xcode, and the iOS SDK are unavailable on this Windows machine. Device crash-free behavior cannot be guaranteed here.

In Xcode, also test camera allow/deny, missing camera key, simulator camera fallback, large library photos, photo removal/reselection, report submission while a photo loads, custom locations, all navigation tabs, and alerts after saving/dismissing screens.

## App source inventory

- Components/AppButton.swift
- Components/CameraImagePicker.swift
- Components/ItemCard.swift
- Components/ItemDetails.swift
- Components/ItemFormFields.swift
- Components/ItemPhoto.swift
- Components/ItemStatusFilter.swift
- Components/PhotoPickerButton.swift
- Components/ReportPhoto.swift
- Components/SearchBar.swift
- Components/SettingsRow.swift
- Components/StatCard.swift
- Components/StatusBadge.swift
- LarpingLostAndFoundApp.swift
- Methods/AppController.swift
- Methods/DataRepository.swift
- Methods/MockRepository.swift
- Models/AppEnums.swift
- Models/AppNotification.swift
- Models/Claim.swift
- Models/ItemDraft.swift
- Models/LostFoundItem.swift
- Models/User.swift
- Screens/Authentication/ForgotPasswordScreen.swift
- Screens/Authentication/LoginScreen.swift
- Screens/Authentication/SignUpScreen.swift
- Screens/Employee/EmployeeClaimReviewScreen.swift
- Screens/Employee/EmployeeClaimsScreen.swift
- Screens/Employee/EmployeeDashboardScreen.swift
- Screens/Employee/EmployeeItemsScreen.swift
- Screens/Employee/EmployeeItemStatusScreen.swift
- Screens/Employee/EmployeeProfileScreen.swift
- Screens/Employee/EmployeeReportReviewScreen.swift
- Screens/Employee/EmployeeReportsScreen.swift
- Screens/Employee/EmployeeShell.swift
- Screens/Shared/AboutScreen.swift
- Screens/Shared/ChangePasswordScreen.swift
- Screens/Shared/EditProfileScreen.swift
- Screens/Shared/HelpSupportScreen.swift
- Screens/Shared/NotificationsScreen.swift
- Screens/Shared/ProfileContent.swift
- Screens/Shared/RateAppScreen.swift
- Screens/Student/EditItemScreen.swift
- Screens/Student/StudentBrowseScreen.swift
- Screens/Student/StudentClaimScreen.swift
- Screens/Student/StudentHomeScreen.swift
- Screens/Student/StudentItemDetailScreen.swift
- Screens/Student/StudentMyItemsScreen.swift
- Screens/Student/StudentProfileScreen.swift
- Screens/Student/StudentReportScreen.swift
- Screens/Student/StudentShell.swift
- Theme/AppTheme.swift
