# 🛠️ Shell Scripts Toolkit

Welcome to the **Shell Scripts Toolkit** – a collection of simple, practical shell scripts created to help automate everyday IT tasks. Each script is written in Bash with clarity, reusability, and learning in mind.

---

## 📂 Toolkit Structure


shell-scripts-toolkit/
├── network-tools/
│ └── ping-sweep/
│ ├── ping_sweep_mac.sh
│ ├── tmp/ # Stores temporary scan logs
│ └── README.md
└── wallpaper-tools/
└── (coming soon)


---

## 🚀 Featured Script: `ping_sweep_mac.sh`

A macOS-native ping sweep tool to scan and detect live hosts on your current subnet. It automatically detects your network prefix and lets you scan a customizable range.

### 🔧 Features

- ✅ **Auto-detect local IP and subnet**
- 🔢 **Customizable IP range**
- 🟢 `--up-only`: Show only live hosts
- ⚡ `--parallel`: Ping multiple hosts concurrently
- 🔄 `--compare`: Detect new or missing hosts between scans

---

### 🖥️ Usage

```bash
./ping_sweep_mac.sh
./ping_sweep_mac.sh --up-only
./ping_sweep_mac.sh --parallel
./ping_sweep_mac.sh --compare

