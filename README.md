# Smart Study Buddy — Flutter App

A collaborative mobile platform for Makerere University students to share
notes, connect in course-based study groups, message study partners, and
test their knowledge with course quizzes.

## Tech Stack
- Flutter (Dart)
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Google Fonts (Poppins)

## Project Structure
lib/
├── screens/ # All app screens
├── models/ # Data models (quiz, progress, course)
├── widgets/ # Reusable UI components
├── firebase_service.dart # All Firebase Auth/Firestore/Storage logic
├── theme.dart # App colors and theme
└── main.dart # App entry point

## Team Members
| Member | Role |
|--------|------|
| Nayebare Pleasure | Project Lead & App Architecture |
| Mukobeza Nambi Anna | UI Developer — Authentication & Profile |
| Alinaitwe Queen Denise | UI Developer — Core Screens & Quiz System |
| Kimara Cyrus Kilibo | Backend & Database |
| Halema Jesse | Testing & Integration |

## Features
| Feature | Status | Notes |
|---------|--------|-------|
| Splash Screen | ✅ Done | |
| Bottom Navigation | ✅ Done | |
| Sign Up / Login | ✅ Done | Supports login via email or username; friendly error messages |
| Auto Study Group Assignment | ✅ Done | New users are automatically placed into a course-based group on signup |
| Home Dashboard | ✅ Done | Live Firestore data — profile, groups, notes, stats |
| Study Groups (auto-assigned) | ✅ Done | Auto-assignment and group membership fully connected to Firestore |
| Switch Course | ✅ Done | Leaves old course group, joins/creates a group for the new course |
| Quiz System | ✅ Done | Course-based quizzes, scoring, and progress saved to Firestore |
| Progress Tracking | ✅ Done | Visual breakdown of notes shared, groups joined, profile completeness |
| Profile Editing | ✅ Done | Edit name, username, bio |
| Profile Picture Upload | ✅ Done | Firebase Storage integration |
| Real-time Messaging | ✅ Done | 1-to-1 chat with study partners found via Discover |
| Discover Study Partners | ✅ Done | Find and message other students in your course |
| Notes Upload | ✅ Done | Text/link notes shared within a study group |
| Notifications | 🔲 UI only | Static placeholder UI; not yet connected to real events |
| Standalone Groups Browser | 🔲 Known limitation | The Groups tab currently shows sample data; auto-assigned groups are visible on the Home screen |

## Known Limitations
Being transparent about current scope:
- The **Groups tab** (separate from auto-assigned groups on Home) still displays placeholder data and is not yet wired to Firestore — planned for a future iteration.
- **Notifications** are UI-only and not yet driven by real app events.

## Firestore Collections
| Collection | Purpose |
|---|---|
| `users` | Student profiles: name, username, email, course, bio, joinedGroups, photoUrl |
| `groups` | Course-based study groups: members, memberCount, course |
| `notes` | Shared notes/links per group |
| `quizzes` | Course quizzes: questions, options, correct answers |
| `quiz_results` | Saved quiz attempts: score, user, timestamp |
| `messages` | 1-to-1 chat messages between students |

## Project Website
https://pleasurenayebare-tech.github.io/smart-study-buddy.github.io/
