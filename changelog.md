# Changelog

## 1.5.3
- Added chat sorting preferences (prioritize unread personal chats and unmuted channels) in Settings; messenger now reorders chats accordingly and persists choices.
- Update selector now switches between Dev and Stable channels via a segmented toggle, marking "Latest" per channel and handling empty/error states more clearly.
- Reworked the desktop message context menu with proper cursor-anchored positioning, fade/scale animation, and auto-close after actions or emoji selection.
- Channel chats now show a localized input placeholder until a topic is selected, preventing sending messages without choosing a topic.
- Pin/unpin actions display inline progress and the folder dialog layout was simplified to avoid accidental repeat actions.
- Unread counters are more reliable: muted chats use dimmed badges, unread fetches no longer skip when a real-time connection is active, self-sent messages are ignored for badges, and a logs view is available from Notifications for connection diagnostics.

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
