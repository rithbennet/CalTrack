# Firebase Security Rules Documentation for CalTrack

This document explains the security rules implemented for the CalTrack application.

## Firestore Rules

The Firestore security rules are designed based on the following principles:

1. Each user only has access to their own data
2. All documents have proper timestamp tracking
3. Authentication is required for most operations
4. Collections have specific permissions based on their intended use

### Collections and Security Structure

#### Connection Test Collection

- Purpose: Used to test the connection to Firestore
- Access:
  - Anyone can read
  - Only authenticated users can write or delete

#### Users Collection

- Purpose: Stores user profile information
- Access:
  - Users can only read, create, update, or delete their own data
  - All create operations must include valid timestamps
  - All update operations must include a valid updatedAt timestamp

#### Calorie Entries Subcollection

- Structure: Nested under each user document as `/users/{userId}/calorie_entries/{entryId}`
- Purpose: Stores individual food entries for a user's calorie tracking
- Access:
  - Users can only read, create, update, or delete their own entries
  - All create operations must include a timestamp

#### Curated Foods Collection (potential future implementation)

- Purpose: Shared food database accessible by all users
- Access:
  - All authenticated users can read
  - No users can write (admin only via Firebase Admin SDK)

### Helper Functions

- `isSignedIn()`: Checks if a user is authenticated
- `isOwner(userId)`: Checks if the authenticated user matches the document owner
- `hasValidTimestamps(resource)`: Validates that a document has the required timestamp fields
- `hasValidUpdatedAt(resource)`: Validates that a document has an updatedAt timestamp

## Storage Rules

Storage rules are designed for future image storage functionality:

### User Profile Images

- Path: `/users/{userId}/profile_image`
- Access:
  - All authenticated users can read
  - Only the user themselves can upload their own profile image
  - Images must be under 5MB and have a valid image MIME type

### User Food Images

- Path: `/users/{userId}/food_images/{imageId}`
- Access:
  - All authenticated users can read
  - Only the user themselves can upload images
  - Images must be under 5MB and have a valid image MIME type

### Curated Food Images (potential future implementation)

- Path: `/curated_food_images/{imageId}`
- Access:
  - All authenticated users can read
  - No users can write (admin only via Firebase Admin SDK)

## Deployment

To deploy these rules:

1. Ensure you have the Firebase CLI installed:

   ```bash
   npm install -g firebase-tools
   ```

2. Log in to your Firebase account:

   ```bash
   firebase login
   ```

3. Deploy the rules:
   ```bash
   firebase deploy --only firestore:rules,storage:rules
   ```

## Security Considerations

- The rules follow the principle of least privilege
- All write operations are authenticated
- Data is properly segregated per user
- Size and content type validations for storage
- Default deny rule as a fallback security measure
