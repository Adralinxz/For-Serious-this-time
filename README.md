# For Serious this time

A Roblox clicker game designed for retention and fun, focusing on simple progression and rewarding loops.

## Features
- Click to earn coins
- Persistent coin storage via DataStore
- Upgrade system to increase click power
- Leaderboard showing coin count
- Simple UI for clicking and upgrades

## Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/Adralinxz/For-Serious-this-time.git
   cd "For Serious this time"
   ```

2. **Open in Roblox Studio**
   - Launch Roblox Studio.
   - Choose `File > Open` and select the `README.md` folder? Actually you need a `.rbxl` place file.
   - For a quick start, create a new Baseplate place in Studio, then copy the contents of the `src` folder into the appropriate services:
     - `ServerScriptService` → place server scripts here
     - `StarterPlayer.StarterPlayerScripts` → place local scripts here
     - `ReplicatedStorage` → ensure the `UpgradeRequested` RemoteEvent exists (the server script creates it on start, but you can also manually add a RemoteEvent named `UpgradeRequested`).

3. **Test Play**
   - Click the large button to earn coins.
   - Use the upgrade button to purchase click boosts.
   - Coins persist between sessions via DataStore (requires game to be published with API access enabled).

4. **Publish to Roblox**
   - File → Publish to Roblox As...
   - Enable API Services in Game Settings → Security.
   - Consider adding Developer Products for monetization (e.g., coin boosts, cosmetic items).

## Monetization Ideas (Non‑Pay‑to‑Win)
- **Cosmetic Trails** – Purchase different particle effects for your clicker.
- **Double Coins Game Pass** – Temporary 2x coin earnings.
- **Skip Wait** – Reduce upgrade cooldowns (if you add timers).
All purchases should be optional and not affect core progression balance.

## Development Notes
- Server script handles data saving and upgrade logic.
- Local script handles click detection, UI, and upgrade requests.
- Feel free to expand with more upgrades, leaderboards, daily rewards, and events.

## License
This project is licensed under the MIT License – see the `LICENSE` file for details.