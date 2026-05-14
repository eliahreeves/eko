# Navigation Tests

This folder contains widget-level navigation tests for the app router (`GoRouter`).

## What these tests validate

- Unauthenticated route behavior:
  - Protected routes redirect signed-out users to `/`
  - Public auth/download routes are reachable (`/`, `/signup`, `/login`, `/download`)
- Shell navigation routes:
  - `/feed`
  - `/messages`
  - `/profile` redirect behavior to `/users/:username?uid=:uid`
- Feed stack routing:
  - `/feed/post/:id` for valid post ids
  - fallback behavior for invalid post ids
- Profile subtree routing:
  - `/users/:username`
  - `/users/:username/edit_profile`
  - `/users/:username/share_profile`
  - `/users/:username/user_settings`
  - nested settings routes:
    - `.../change_email`
    - `.../change_password`
    - `.../blocked_users`
- Misc route coverage:
  - `/profile_picture_detail/:id`

Some routes are not asserted here because they currently require heavier platform/network/runtime setup in widget tests:

- `/camera` (camera/sensors platform behavior)
- `/gif` (external HTTP behavior in init flow)
- `/compose` deep behavior (UI internals with timer-driven/async widgets)
- profile followers/following list pages that depend on RPC-backed list loading
