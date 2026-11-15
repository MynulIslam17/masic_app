# Frontend Issues & Client Feedback Audit

This document outlines all frontend/mobile app issues reported by the client (from screenshots and messages), explaining what is happening, where it occurs in the codebase, and what needs to be fixed.

---

## 1. Family Tree Hidden Behind Bottom Navigation Bar

### Client Quote & Screenshot Reference
> *"Why I am i not able to scroll up to see this , it's hidden behind the menu bar"*  
> **Screenshots (Images 1, 2, 4):** Family tree view where bottom-most member nodes (e.g., Saad Almousa, Felwah Almousa) are partially or completely blocked by the floating bottom navigation bar.

### What is Happening:
The app uses a custom floating navigation bar (`BottomNavBar` / `AdminBottomNavBar`) with `extendBody: true` on the scaffold. However, the scrollable tree layout does not include bottom padding or margin. As a result, the bottom-most nodes sit behind the navigation bar, and the user cannot scroll them up high enough to see or interact with them.

### Code Locations:
- `lib/features/tree/presentation/screens/tree_screen.dart`
- `lib/features/tree/presentation/screens/admin_tree_screen.dart`
- `lib/features/tree/presentation/widgets/family_tree/layout_builder.dart`

### What Needs to be Fixed:
Add bottom padding (e.g., `EdgeInsets.only(bottom: 120.h)`) or a bottom spacing widget (`SizedBox(height: 120.h)`) inside the scrollable tree view so nodes can be scrolled completely clear of the floating menu bar.

---

## 2. Home Screen Completely Blank White ("Why is nothing visible")

### Client Quote & Screenshot Reference
> *"Why is nothing visible"*  
> **Screenshots (Images 1, 2, 5, 6):** Super Admin logged in, header displays "Super Admin, Welcome to MASIC Generation", but the entire screen below is completely blank white.

### What is Happening:
In `HomeContent`:
1. The "Request for opportunities" section is hidden for admins (`if (!AuthController.to.isAdmin())`).
2. If the announcements list is empty, the announcement carousel is omitted.
3. If the polls list is empty, the poll carousel is omitted.
4. If dashboard charts (`DashboardController.to.dashboard`) have no data or are null, no charts are rendered.
5. Because there is no fallback empty-state widget when all sections have 0 items, `HomeContent` renders zero slivers, leaving the screen as a completely white void.

### Code Locations:
- `lib/features/home/presentation/home_screen.dart`
- `lib/features/home/presentation/widgets/home_content.dart` (Lines 35–280)

### What Needs to be Fixed:
Add a clean empty-state fallback widget (e.g., `EmptyDataWidget` or an informational welcome card) in `HomeContent` when announcements, polls, and dashboard statistics are all empty, so the screen never displays a blank white void.

---

## 3. Date of Birth (DOB) Field Visible Despite Repeated Removal Requests

### Client Quote & Screenshot Reference
> *"For the DOB i told you multiple times to remove it , you keep removing it and bringing it back"*  
> **Screenshots (Images 9, 11):** Profile Information screen displaying `"Date of birth : 11-Feb-2001"`.

### What is Happening:
The client has repeatedly instructed that Date of Birth (DOB) must be eliminated from the application. However, active UI widgets in the profile and tree screens still render the Date of Birth row and edit inputs.

### Code Locations:
1. `lib/features/profile/presentation/screens/user/profile_information_screen.dart` (Line 73: `label: 'Date of birth'`)
2. `lib/features/profile/presentation/screens/admin/profile_details_screen.dart` (Line 60: `label: 'Date of birth'`)
3. `lib/features/tree/presentation/screens/tree_details_screen.dart` (Line 99: `label: 'Date of birth'`)
4. `lib/features/profile/presentation/screens/user/edit_profile_screen.dart` (Line 149: DOB text field & date picker)

### What Needs to be Fixed:
Completely remove the Date of Birth display rows, controllers, and date pickers from these 4 UI screens.

---

## 4. Unplaced / Unlinked Users Visible in Member Directory

### Client Quote & Screenshot Reference
> *"Didnt we say i dont want any users created if they are not in the tree ? Why are those users created when they had a problem with log in and they are not in the tree"*  
> **Screenshots (Images 9, 10):** Users screen showing unlinked users (**Nawal Alsubaie** and **Alma Almouhana**) at the top of the directory list.

### What is Happening:
In `ProfileController`, the active tree join status filter (`_activeTreeJoinStatus`) only passes `'placed'` when `_motherTreePickerMode` is enabled. When regular users browse the member directory (`AllUserScreen` or `HomeScreen`), `_activeTreeJoinStatus` evaluates to `null`. As a result, the app requests all users without `placedOnly=true` or `treeJoinStatus=placed`, displaying unlinked users to everyone.

### Code Location:
- `lib/features/profile/presentation/controllers/profile_controller.dart` (Lines 278–279)

### What Needs to be Fixed:
Update `_activeTreeJoinStatus` in `ProfileController` so that unless a super-admin is specifically managing all users, the directory query defaults to `'placed'`:
```dart
String? get _activeTreeJoinStatus {
  if (_motherTreePickerMode) {
    return _motherTreePlacedOnly ? 'placed' : null;
  }
  return AuthController.to.isAdmin() ? null : 'placed';
}
```

---

## 5. Announcements "Requested Announce" Screen Failure ("Failed to load announcements")

### Client Screenshot Reference
> **Screenshot (Image 3):** Admin navigates to Announcements -> "Requested announce" tab -> Screen displays: `"Failed to load announcements. Please try again."` with an error illustration and Refresh button.

### What is Happening:
1. In `AnnouncementController`, for admin users on Tab 0 ("Requested announce"), it appends `status: 'pending'` to `ApiConstants.announcements(page, limit)` which targets `/api/v1/announcement/all?page=1&limit=10&status=pending`.
2. The client integration guide specifies the endpoint as `GET /announcement?status=pending` (not `/announcement/all`).
3. If the backend fails or returns an empty/unexpected response, `AnnouncementController` flips to `LoadingState.error` instead of showing a clean empty state like `"No pending announcement requests"`.

### Code Locations:
- `lib/core/constants/api_constants.dart` (Line 34)
- `lib/features/announcement/presentation/controllers/announcement_controller.dart` (Lines 46–48)
- `lib/features/announcement/data/repositories/announcement_repository.dart` (Line 43)

### What Needs to be Fixed:
- Route admin pending requests to `/api/v1/announcement?status=pending` instead of `/announcement/all`.
- Distinguish between an actual network error and zero results (empty list), displaying an empty state rather than `"Failed to load announcements"`.

---

## 6. "My Requests" Announcement Cache Leak (Offline & Pagination)

### What is Happening:
In `AnnouncementRepository`:
- `_cacheKey(type)` only checks `case 'my'`.
- However, `getAnnouncements` and `fetchMoreAnnouncements` pass the already converted key `cacheKey` (`'announcements_my'`) into `getCachedAnnouncements()`.
- Because `'announcements_my'` does not match `'my'`, it falls through to the `default:` branch, returning `'announcements'` (the public announcements cache).
- Consequently, when offline or when loading page 2 of "My Requests", public announcements leak into the user's private requests list.

### Code Location:
- `lib/features/announcement/data/repositories/announcement_repository.dart` (Lines 23–30, 65, 71, 95)

### What Needs to be Fixed:
Add `case ApiConstants.cacheMyAnnouncements:` to `_cacheKey()`, and pass the proper key when calling `getCachedAnnouncements()`.

---

## 7. App Launch 401 Error on Startup (Unnecessary Protected API Calls)

### What is Happening:
When the app starts up without an active login session, `ProfileController` is initialized immediately via `Get.put(permanent: true)` in `dependency_injection.dart`. Its `onInit()` unconditionally calls `loadData()`, which sends `GET /api/v1/users/me` and `GET /api/v1/users` before checking if the user is logged in. Because there is no token, the server returns 401 Unauthorized, flooding the console with error logs.

### Code Locations:
- `lib/core/di/dependency_injection.dart` (Line 170)
- `lib/features/profile/presentation/controllers/profile_controller.dart` (Lines 237–242, 426)

### What Needs to be Fixed:
Add a guard in `loadData()` and `onInit()`:
```dart
if (!AuthController.to.isLoggedIn()) {
  _loadFromCache();
  return;
}
```
Only make network calls if `AuthController.to.isLoggedIn()` is `true`.

