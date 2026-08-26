# AnuMealAI — Firebase Remote Config Parameter Reference

Configure the following parameters in **Firebase Console -> Remote Config** to manage live application behavior without store releases.

---

## 1. Remote Config Parameters Table

| Parameter Key | Data Type | Default Value | Description |
|---|---|---|---|
| `app_minimum_supported_version` | String | `"1.0.0"` | Minimum required version. Clients below this trigger non-bypassable Force Update. |
| `app_latest_version` | String | `"1.0.0"` | Current production store version. Clients below this trigger a Soft Update dialog. |
| `app_force_update` | Boolean | `false` | Global emergency switch to immediately force all clients to update. |
| `app_update_message` | String | `"You're using an older version of AnuMealAI. Update now to continue."` | Message displayed on the update modal. |
| `android_store_url` | String | `"https://play.google.com/store/apps/details?id=com.anumealai.anu_meal_ai"` | Target Google Play redirect link. |
| `ios_store_url` | String | `"https://apps.apple.com/app/id6740123456"` | Target Apple App Store redirect link. |
| `maintenance_mode` | Boolean | `false` | Global switch. If `true`, routes all active users to the Maintenance screen. |
| `maintenance_message` | String | `"AnuMealAI is getting better! We're performing a quick service update. Please check back shortly."` | Message displayed on Maintenance screen. |
| `free_daily_recipe_limit` | Number (Long) | `3` | Maximum free AI recipe recommendations allowed per day per user. |
| `free_weekly_plan_limit` | Number (Long) | `1` | Maximum weekly meal planner generations allowed per week for free users. |
| `free_favorite_limit` | Number (Long) | `20` | Maximum number of bookmarks allowed for free tier users. |
| `enable_ai_recipes` | Boolean | `true` | Feature flag to remotely toggle AI recipe generation. |
| `enable_weekly_planner` | Boolean | `true` | Feature flag to remotely toggle the 7-day planner module. |
| `enable_notifications` | Boolean | `true` | Feature flag to remotely control meal inspiration push reminders. |
| `enable_mood_recommendations` | Boolean | `true` | Feature flag to remotely control the mood-based recipe filter carousel. |
| `enable_new_home` | Boolean | `true` | Remote UI feature flag. |
| `enable_premium_features` | Boolean | `true` | Feature flag to control premium upgrade triggers. |

---

## 2. Testing Scenarios

### Force Update Test
1. Set `app_minimum_supported_version` = `1.1.0` in Firebase Console.
2. Publish changes.
3. Launch app version `1.0.0` -> The **Force Update Dialog** displays immediately and cannot be dismissed.

### Maintenance Mode Test
1. Set `maintenance_mode` = `true` in Firebase Console.
2. Publish changes.
3. Open app -> The app routes to `MaintenancePage` with retry button.

