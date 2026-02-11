# 📦 PlayerTools
A lightweight Turtle WoW addon that adds useful right‑click menu tools for players, guild leaders, and community organizers.

PlayerTools extends the default UnitPopup (right‑click) menus with three practical options:

### 🔸 Guild Invite (conditional)
Displayed only if your guild rank has the *Invite Member* permission.  

### 🔸 Armory Link
Opens a popup with a direct link to:
```
https://turtlecraft.gg/armory/<realm>/<player>
```

### 🔸 Log Link
Opens a popup with a direct link to:
```
https://turtlogs.com/armory/character/Turtle WoW <realm>/<player>
```

---

## 🛠 Installation

1. Download the **PlayerTools** folder  
2. Place it inside:

```
World of Warcraft\Interface\AddOns\
```

3. Make sure the folder name is exactly **PlayerTools**  
4. Launch the game and enable the addon in the AddOns menu

---

## 🧩 Compatibility

- **Turtle WoW** (1.12 client)  
- No dependencies  
- No invasive hooks  

---

## ⚠️ Known Issues

### Slow loading on login
In some cases the addon may take a while (10–300 seconds) to initialize after logging in.  
This happens because PlayerTools must wait for `GuildControlGetRankFlags()` to return valid guild‑permission data before the right‑click menu entries can be safely added.  
The delay depends entirely on how quickly the server provides this information, and the timing can vary from login to login.  
There is currently no reliable way to speed this up without risking incorrect or missing menu entries.

---

## 👤 Author
**Subby** _(Requested by Plooga)_  
PlayerTools is built for the Turtle WoW community with a focus on simplicity, stability, and full Vanilla compatibility.

---

## 📄 License

MIT License — do what you want with it. Credits appreciated but not required.
