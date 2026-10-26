<p align="center">
  <img src="icon/launcher_icon_500.png" alt="Meditation Timer icon" width="160">
</p>

<h1 align="center">Meditation Timer</h1>

<p align="center">
  A minimalist meditation timer for Garmin watches, built with Connect IQ.<br>
  Set the time, close your eyes, feel the vibration when it's over.
</p>

---

## Why

Garmin's built-in meditation options come with predefined sessions. This app does one thing: you pick how long you want to sit, and it counts down. It remembers your last duration, so a repeat session is one tap away. Each session is saved to Garmin Connect as a **Meditation** activity, with heart rate.

## Features

- **Quick start** — the start screen offers your last used duration, ready to go.
- **Fast time entry** — a circular digit dial modelled on Garmin's native timer: tap digits and they fill in from the right (`1 5 0 0` → `00:15:00`).
- **Calm countdown** — remaining time in the centre, a progress ring around the edge, live heart rate below.
- **Vibration only** — a long vibration at the end; an optional short vibration every 5 minutes (enable it in Settings). Interval points are marked on the ring.
- **Pause** — resume, save early, or discard the session.
- **Summary** — session duration and average heart rate.
- **Recorded to Garmin Connect** — saved as a *Meditation* activity (`Activity.SPORT_MEDITATION`), with heart rate and stress data.
- **AMOLED-friendly design** — black background, green and blue accents only.

## Supported devices

| Device | Status |
|---|---|
| Garmin Venu 2 | Developed and tested on a real watch |

Requires Connect IQ API level 5.0.0 or newer. Other round touchscreen devices may work but have not been tested yet.

## Using the app

| Screen | Touch | Buttons |
|---|---|---|
| Start | Quick start · New timer · Settings | START = quick start, BACK = exit |
| Time dial | Tap digits, ✕ deletes the last digit, ✓ starts | START = start |
| Countdown | — | START/STOP = pause |
| Pause | Resume · Save · Discard | |
| Summary | Tap to close | BACK = close |

## Building from source

### Requirements

- [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) 9.x, installed through the SDK Manager, with the **Venu 2** device profile downloaded
- Java (JDK) — tested with OpenJDK 25
- [Visual Studio Code](https://code.visualstudio.com/) with the **Monkey C** extension by Garmin
- A Connect IQ developer key (`Monkey C: Generate a Developer Key` in VS Code)

### Build and run in the simulator

The easiest way: open the folder in VS Code, open any file in `source/`, then **Run → Run Without Debugging** and choose **Venu 2**.

From the command line:

```powershell
monkeyc -d venu2 -f monkey.jungle -o bin\MeditationTimer.prg -y <path-to-developer-key> -w
connectiq
monkeydo bin\MeditationTimer.prg venu2
```

### Install on your watch (sideload)

1. Build `bin\MeditationTimer.prg` as above.
2. Connect the watch to your computer with a USB cable.
3. Copy the `.prg` file to the `GARMIN\APPS` folder on the watch.
4. Disconnect — the app appears in the watch's app list.

## Project structure

```
manifest.xml          App id, target devices, permissions, API level
monkey.jungle         Build configuration
source/
  MeditationTimerApp.mc   Entry point
  StartView / StartDelegate             Start screen (quick start, new timer, settings)
  TimePickerView / TimePickerDelegate   Circular digit dial
  CountdownView / CountdownDelegate     Countdown, progress ring, heart rate, activity recording
  PauseView / PauseDelegate             Pause menu
  SummaryView / SummaryDelegate         Session summary
  SettingsMenu / SettingsView / SettingsDelegate   Interval signal setting
resources/
  strings/            UI text
  drawables/          Launcher icon
icon/                 Icon source files (SVG + large PNGs)
```

### Permissions

| Permission | Used for |
|---|---|
| `Sensor` | Live heart rate |
| `Fit` | Recording the session as an activity |
| `FitContributor` | Extra data field saved with the activity (stress) |

## Known limitations

- **No live stress on the watch.** Garmin pauses all-day stress measurement while an activity is being recorded, so Connect IQ apps cannot show a live stress value during a session. Stress data is still available in Garmin Connect after the session.
- **Heart rate in the simulator** is simulated or empty; real values appear on the watch.

## Roadmap

- [x] Polish translation of the interface
- [ ] Interval signal setting also available in the Garmin Connect app
- [ ] Support for more devices
- [x] Submitted to the Connect IQ Store (review pending)

## Po polsku

Minimalistyczny timer medytacji na zegarki Garmin (Connect IQ). Ustawiasz czas na tarczy z cyframi jak w natywnym minutniku, aplikacja pamięta ostatni czas, odlicza z pierścieniem postępu i tętnem na żywo, a koniec sygnalizuje wibracją (opcjonalnie także co 5 minut). Sesja zapisuje się w Garmin Connect jako aktywność *Medytacja*. Testowana na Garmin Venu 2.

## License

[MIT License](LICENSE.md) — free to use, modify and share, including commercially. Keep the copyright notice and the license text with every copy.

Copyright (c) 2026 Paweł Jurak.

## Credits

Built by [@pawerak](https://github.com/pawerak), with help from Claude (Anthropic) for design and code.
