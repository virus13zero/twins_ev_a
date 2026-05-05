# Viruszero Framework: Twins_Evil_AT 🚀

<p align="center">
  <img src="https://img.shields.io/badge/Owner-Viruszero-red?style=for-the-badge">
  <img src="https://img.shields.io/badge/OS-Kali%20Linux-blue?style=for-the-badge">
  <img src="https://img.shields.io/badge/Language-Bash-green?style=for-the-badge">
</p>

---

## 🇺🇸 English Version

### 📖 Description
**Twins_Evil_AT** is a professional wireless network penetration testing tool based on the **Evil Twin** technique. Developed by **Viruszero**, it features a dynamic interface that automatically detects the current system operator while maintaining the core framework branding.

### 🛠 Features
*   **Auto-Operator Detection:** Identifies the current system user dynamically.
*   **Targeted Deauth:** Disconnects clients from the original access point.
*   **Live Sniffing:** Captures data traffic into `.pcap` files using TShark.
*   **Advanced DNS Fix:** Resolves common errors like `REFUSED` to ensure internet flow for targets.
*   **Smart Cleanup:** Restores all network settings to default with one click.

### 📥 Installation & Usage
```bash
# Clone the repository
git clone [https://github.com/your-username/Twins_Evil_AT.git](https://github.com/your-username/Twins_Evil_AT.git)

# Enter the directory
cd Twins_Evil_AT

# Run the setup script (Install dependencies)
chmod +x setup.sh
sudo ./setup.sh

# Launch the tool
sudo ./Twins_Evil_AT.sh
