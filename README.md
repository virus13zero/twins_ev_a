# 🛡️ Twins_Evil_AT (twins_ev_a)
**Advanced Wireless Security Auditing Framework**

<p align="center">
  <img src="[https://img.shields.io/badge/Maintained%3F-yes-green.svg?style=for-the-badge](https://img.shields.io/badge/Maintained%3F-yes-green.svg?style=for-the-badge)">
  <img src="[https://img.shields.io/badge/Platform-Kali%20Linux-blue?style=for-the-badge](https://img.shields.io/badge/Platform-Kali%20Linux-blue?style=for-the-badge)">
  <img src="[https://img.shields.io/badge/Operator-Dynamic-orange?style=for-the-badge](https://img.shields.io/badge/Operator-Dynamic-orange?style=for-the-badge)">
  <img src="[https://img.shields.io/badge/Owner-Viruszero-red?style=for-the-badge](https://img.shields.io/badge/Owner-Viruszero-red?style=for-the-badge)">
</p>

---

## 📖 Overview | نظرة عامة
**English:**  
`twins_ev_a` is a professional bash-based framework designed for automated **Evil Twin** attacks. Developed by **Viruszero**, it simplifies the process of network auditing by automating deauthentication, DNS spoofing, and live traffic sniffing.

**العربية:**  
أداة `twins_ev_a` هي إطار عمل متقدم مبني لبيئة **Kali Linux** لأتمتة هجمات **Evil Twin**. قام بتطويرها **Viruszero** لتسهيل عمليات فحص الشبكات عبر أتمتة عمليات طرد الأجهزة، تزوير الـ DNS، والتنصت اللحظي على البيانات.

---

## 🚀 Key Features | المميزات الإضافية
* **👤 Identity Protection:** Displays the current system operator while locking the "Owner" tag to **Viruszero**.
* **📡 Intelligence Scanning:** Auto-detects network interfaces and manages monitor mode.
* **🛠️ Automated Setup:** Zero-configuration dependency installer included.
* **🧹 Deep Clean:** Complete system restoration to prevent network conflicts after testing.
* **📊 Traffic Analysis:** Real-time `.pcap` logging for forensics and analysis.

---

## 🛠️ Installation | التثبيت
```bash
# Clone the repository
git clone https://github.com/virus13zero/twins_ev_a.git

# Navigate to the folder
cd twins_ev_a

# Install dependencies
chmod +x setup.sh && sudo ./setup.sh
# Run the tool
sudo ./Twins_Evil_AT.sh
