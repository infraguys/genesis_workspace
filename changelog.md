# Changelog

# 1.7.4
- Added update functionality for windows
- Added create channels functionality
- Refactored navigation logic after forward message
- Refactored my activity container
- Added quote forward/reply functionality

# 1.7.3
- Added sections for favorites, starred, draft messages
- Refactored forward message functionality
- Fixed bug when topics not closed after change folder on mobile
- Configured android project for stores

# 1.7.0
- Added icon for application (ios, android, macos)
- Added developer profile at ios, macos
- Fixed webrtc in webview in release mode
- Added connection status in appbar
- Added forward message functionality
- Refactored read all functionality

# 1.6.5
- Topics ui refactor

# 1.6.4
- Fixed emoji on windows
- Set "All" folder at the 0 index
- Autofocus on chat input
- Topic separator in the chats
- List of genesis services


# 1.6.3
- Add progress indicator for info panel
- Fixed overflowed channel name
- Added users presences in info panel
- Added loading messages after losing connection
- Added logs file

# 1.6.2
- Added refresh button on updates screen
- Refactored get messages after lost connection
- Added calendar and mail webviews for android, ios, macos, windows
- Added copy message functionality
- Added read all messages buttons for channels and topics
- Improved folders functions

# 1.6.1
- Added double-tap hotkey on message
- Added message readers functionality
- UI fixes (unread badges, lazy loading messages etc.)
- Fixed hotkeys for linux
- Set meeting url for organization from server settings
- Added esc hotkey support for chat unselect
- Added notifications for desktop platforms (linux, macos, windows)

# 1.6.0
- Fixed update feature on linux
- Added profile panel
- Fixed channel grey colors
- Remove sound notification if channel is muted
- Added notifications for desktop platforms
- Fixed last message preview in topics

## 1.5.5
- Fixed mute/unmute channel text in context menu actions on russian language
- Fixed folders sync between devices on the same account
- Fixed pin chats
- Create new chat button added to the header of chats list
- Fixed bug with unselected topic and empty messages
- Implemented create call functionality. Available on calls buttons in the chats
- Redesigned input following current design

## 1.5.4
- Inline images now resolve `/user_uploads` links through the base URL, show cached thumbnails, and open the full file via an authorized fetch; attachment downloads reuse the same resolver for safer link handling.
- Update checks now verify the manifest SHA-256 from the repository, exposing a checksum endpoint and blocking installation when the config is not trusted.
- Base URL entry requires HTTPS across onboarding/add-organization flows; tokens are stored only via secure storage, and external links go through an allowlist with a confirmation dialog before leaving the workspace.
- Chat/topic UX tweaks: channel arrows are clickable to expand and fetch topics, active chat highlighting is fixed, message inputs clear on topic change, and real-time events from other organizations are ignored.
- Messaging polish: bot badge shown in chat header, tightened avatar/time layout and safer call links, emoji keyboard height now relies on system insets (plugin removed), and macOS windows no longer drag by clicking the background.
- Fixed keyboard height on mobile devices
- Fixed message disappear when other user sent a message

## 1.5.3
- Added chat sorting preferences (prioritize unread personal chats and unmuted channels) in Settings; messenger now reorders chats accordingly and persists choices.
- Update selector now switches between Dev and Stable channels via a segmented toggle, marking "Latest" per channel and handling empty/error states more clearly.
- Reworked the desktop message context menu with proper cursor-anchored positioning, fade/scale animation, and auto-close after actions or emoji selection.
- Channel chats now show a localized input placeholder until a topic is selected, preventing sending messages without choosing a topic.
- Pin/unpin actions display inline progress and the folder dialog layout was simplified to avoid accidental repeat actions.
- Unread counters are more reliable: muted chats use dimmed badges, unread fetches no longer skip when a real-time connection is active, self-sent messages are ignored for badges, and a logs view is available from Notifications for connection diagnostics.
- Add avatars on messages

## 1.5.2
- Added a rich message context menu with quick reactions, emoji picker, and actions (reply, edit, copy, forward, mark/unmark important, delete, select) using new SVG icons.
- Refactored message items to StatefulWidget with desktop right-click support and in-context handlers for replies, edits, starring, deletions, and emoji reactions via messenger cubit.
- Message input now treats Shift+Enter as a newline (keeps focus) while Enter continues to send, matching desktop chat shortcuts.
- Messenger now processes real-time edit/delete events, keeping chat previews, unread counters, and topics in sync while scoping updates to the active organization.
- ChatEntity can force last-message refresh to keep previews correct after removals, and HTML message selection suppresses the default context menu to avoid conflicts.
- Localized all new context menu labels for English and Russian.

## 1.5.1
- Introduced server-synced chat folders with create/update/delete flows, membership storage, and pinned chat metadata, exposed via a new folder rail and dialogs.
- Reworked pinned chats into a reorderable, per-folder list with optimistic updates and persisted ordering shared across the messenger list.
- Added dedicated chat/channel info pages (`chat-info` / `channel-info` routes) with member lists and quick actions, replacing the old right-side panel layout.
- Messenger UX tweaks: active call panel in the list, streamlined chat/topic list rendering, and message input now requesting focus on tap to avoid lost keystrokes.
- Stability fixes: more resilient real-time queue handling and base URL resolution, plus the update view now surfaces dev builds by default to fix missing version entries (e.g., on Linux).
