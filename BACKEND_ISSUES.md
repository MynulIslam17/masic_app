# Backend Issues & Required Fixes

This document details the backend issues identified from the client's latest feedback and screenshots. It provides the exact API endpoints, expected request/response formats, backend files/modules involved, and actionable solutions for the backend developer.

---

## 1. Orphan / Unplaced Users Created in Database & Directory Leak

### Client Feedback & Screenshot Reference
> *"Didn't we say I don't want any users created if they are not in the tree? Why are those users created when they had a problem with log in and they are not in the tree? I see that you fixed the problem by just deleting the account and not the core of the problem."*  
> **Screenshots:** Users directory showing **Nawal Alsubaie** and **Alma Almouhana** with `treeJoinStatus: "unlinked"`.

### What is Happening:
1. When a user registers via `POST /api/v1/auth/create` (or attempts onboarding), the backend immediately inserts a new document into MongoDB with `treeJoinStatus: "unlinked"` and `linkedMember: null`.
2. If the user disconnects, has an onboarding issue, or never finishes selecting a mother tree, their account permanently remains in MongoDB as an orphan user.
3. When `GET /api/v1/users` is called (without query parameters), the backend query does **not** filter out unplaced users by default. It returns all users in the collection, exposing incomplete accounts to the entire app directory.

### Relevant Endpoints:
- `POST /api/v1/auth/create`
- `GET /api/v1/users`

### Probable Backend Files:
- `src/app/modules/auth/auth.controller.ts` / `auth.service.ts`
- `src/app/modules/user/user.controller.ts` / `user.service.ts`
- `src/app/modules/user/user.model.ts`

### Required Fixes:
1. **Default Filter for `GET /api/v1/users`**:
   - In `user.service.ts` (or directory query builder), ensure default queries filter for placed members only:
     ```typescript
     // Default query condition:
     const queryConditions = {
       isActive: true,
       isDeleted: false,
       treeJoinStatus: "placed" // Default to 'placed' unless explicitly requested otherwise by super-admin
     };
     ```
   - Only return unplaced/unlinked users if explicitly requested by an admin with `?treeJoinStatus=all` or `?placedOnly=false`.
2. **Prevent Orphan Account Creation**:
   - Make `motherTreeMemberId` mandatory during registration (`POST /api/v1/auth/create`), OR do not set `isActive: true` / save user to active directory until mother tree attachment is confirmed.
3. **Database Cleanup**:
   - Remove or soft-delete existing orphan users in MongoDB where `treeJoinStatus: "unlinked"` and `linkedMember: null`.

---

## 2. "Decline Admin Access" Crashes with 500 Internal Server Error

### Client Feedback & Screenshot Reference
> *"Why ?"*  
> **Screenshots:** Admin taps "Decline admin access" on a user card -> Confirmation dialog appears -> Confirming results in toast: **"Something went wrong on our end"** (`InternalServerException` / HTTP 500).

### What is Happening:
1. When a super-admin declines admin access for an existing admin, the mobile app sends:
   - **Method:** `PATCH`
   - **URL:** `/api/v1/super-admin/role/update/:userId`
   - **Body:** `{ "role": "user" }`
2. The backend route handler throws an unhandled exception and responds with **HTTP 500 Internal Server Error**:
   ```json
   {
     "success": false,
     "statusCode": 500,
     "message": "Something went wrong on our end"
   }
   ```
3. Likely root causes:
   - The role update logic only handles upgrading to `'admin'` or `'superAdmin'` and crashes when `'user'` is passed.
   - Or the function tries to access/update admin-specific fields (e.g. `adminScope`, `adminGrantedBy`, permissions array) that fail validation or throw null pointer errors when the role is changed back to `'user'`.

### Relevant Endpoint:
- `PATCH /api/v1/super-admin/role/update/:userId`

### Probable Backend Files:
- `src/app/modules/superAdmin/superAdmin.controller.ts` / `superAdmin.service.ts`
- `src/app/modules/user/user.service.ts`

### Required Fix:
1. Handle downgrading from `admin` to `user` cleanly:
   ```typescript
   // In updateRole function:
   const { role } = req.body; // e.g. "user" or "admin"
   
   if (!['user', 'admin', 'superAdmin'].includes(role)) {
     throw new AppError(httpStatus.BAD_REQUEST, 'Invalid role');
   }
   
   const updateData: any = { role };
   if (role === 'user') {
     updateData.adminScope = null;
     updateData.adminGrantedBy = null;
   }
   
   const updatedUser = await User.findByIdAndUpdate(userId, updateData, { new: true });
   return res.status(200).json({
     success: true,
     statusCode: 200,
     message: "Role updated successfully",
     data: updatedUser
   });
   ```

---

## 3. Pending Announcements Review Fails to Load ("Failed to load announcements")

### Client Feedback & Screenshot Reference
> **Screenshot:** Admin navigates to Announcements -> "Requested announce" tab -> Screen displays: **"Failed to load announcements. Please try again."** with error icon and Refresh button.

### What is Happening:
1. In the admin review screen for submitted announcement requests, the app queries:
   - **URL:** `/api/v1/announcement/all?page=1&limit=10&status=pending` (or `/api/v1/announcement?status=pending`)
2. The server responds with an error or unhandled status, causing the screen to fail loading.
3. Ensure that when filtering announcements:
   - `status=pending` correctly returns all submitted requests awaiting review.
   - If there are 0 pending announcements, the endpoint must return HTTP 200 with an empty array (`"data": []`), **never** throw a 404 or 500 error.

### Relevant Endpoints:
- `GET /api/v1/announcement`
- `GET /api/v1/announcement/all`
- `GET /api/v1/announcement/my-requests`

### Probable Backend Files:
- `src/app/modules/announcement/announcement.controller.ts` / `announcement.service.ts`
- `src/app/modules/announcement/announcement.route.ts`

### Required Fix:
1. Ensure the announcement query handler accepts `status=pending`, `status=approved`, `status=declined`:
   ```typescript
   const { status, page = 1, limit = 10, searchTerm } = req.query;
   
   const filter: any = { isDeleted: false };
   if (status) {
     filter.status = status;
   }
   // If no records match, return 200 with empty array, not an exception:
   const announcements = await Announcement.find(filter)
     .skip((page - 1) * limit)
     .limit(limit);
     
   return res.status(200).json({
     success: true,
     statusCode: 200,
     meta: { total, page, limit, totalPage },
     data: announcements || []
   });
   ```

---

## 4. Date of Birth (DOB) Field Deprecation

### Client Feedback & Screenshot Reference
> *"For the DOB I told you multiple times to remove it, you keep removing it and bringing it back."*  
> **Screenshot:** Profile Information screen displaying "Date of birth : 11-Feb-2001".

### What is Happening:
- The client has explicitly requested multiple times that Date of Birth (DOB) be completely removed from the application.
- While the mobile app needs to remove the UI elements, the backend still requires/validates/returns `dateOfBirth` and calculates `age`.

### Relevant Endpoints:
- `POST /api/v1/auth/create`
- `PATCH /api/v1/users/edit-profile`
- `GET /api/v1/users/me`
- `GET /api/v1/users`

### Probable Backend Files:
- `src/app/modules/user/user.validation.ts`
- `src/app/modules/user/user.model.ts`
- `src/app/modules/user/user.service.ts`

### Required Fix:
1. Remove `dateOfBirth` from any mandatory validation schemas (make it completely optional or remove validation).
2. Ensure profile update (`PATCH /api/v1/users/edit-profile`) does not fail if `dateOfBirth` is omitted.
3. If the client wants existing DOB data wiped from the database, run a migration to unset `dateOfBirth` on user records.

---

## Summary Checklist for Backend Developer

| # | Task | Endpoint | Expected Result |
|---|---|---|---|
| 1 | Default directory query to `treeJoinStatus: "placed"` | `GET /api/v1/users` | Unplaced/unlinked users are excluded by default |
| 2 | Fix role downgrade to `"user"` | `PATCH /api/v1/super-admin/role/update/:userId` | Returns HTTP 200 when declining admin access (body: `{ "role": "user" }`) |
| 3 | Handle `status=pending` query without error | `GET /api/v1/announcement?status=pending` | Returns HTTP 200 with matching items or `[]` |
| 4 | Remove `dateOfBirth` mandatory requirements | `POST /auth/create`, `PATCH /users/edit-profile` | DOB is optional / ignored |

