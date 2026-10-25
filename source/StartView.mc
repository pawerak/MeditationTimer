import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application.Storage;

class StartView extends WatchUi.View {
    private var _lastTime as Number = 600; // default 10:00

    function initialize() {
        View.initialize();

        // Load last time from storage
        var stored = Storage.getValue("lastTime");
        if (stored != null) {
            _lastTime = stored as Number;
        }
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;

        // Title
        dc.setColor(0xF2F5F3, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 60, Graphics.FONT_MEDIUM, "Meditation",
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Three buttons
        var buttonWidth = 280;
        var buttonHeight = 64;
        var startY = centerY - 60;
        var spacing = 80;

        // 1. Quick Start (last time)
        var lastTimeStr = formatTime(_lastTime);
        drawButton(dc, centerX, startY, buttonWidth, buttonHeight,
                  WatchUi.loadResource(Rez.Strings.QuickStart) as String,
                  lastTimeStr, 0x3DDC97, 0x04140D);

        // 2. New Timer
        drawButton(dc, centerX, startY + spacing, buttonWidth, buttonHeight,
                  WatchUi.loadResource(Rez.Strings.NewTimer) as String,
                  "", Graphics.COLOR_BLACK, 0xF2F5F3);

        // 3. Settings
        dc.setColor(0x9AA5A1, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, startY + spacing * 2, Graphics.FONT_SMALL,
                   WatchUi.loadResource(Rez.Strings.Settings) as String,
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawButton(dc as Dc, centerX as Number, y as Number,
                                width as Number, height as Number,
                                text as String, subtext as String,
                                bgColor as Number, textColor as Number) as Void {
        var x = centerX - width / 2;
        var cornerRadius = 8;

        // Background
        dc.setColor(bgColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x, y - height/2, width, height, cornerRadius);

        // Border for non-green buttons
        if (bgColor != 0x3DDC97) {
            dc.setColor(0x2A3531, Graphics.COLOR_TRANSPARENT);
            dc.drawRoundedRectangle(x, y - height/2, width, height, cornerRadius);
        }

        // Main text
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        if (subtext.length() > 0) {
            dc.drawText(centerX, y - 16, Graphics.FONT_SMALL, text,
                       Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            // Subtext (last time) - smallest font
            dc.setColor(bgColor == 0x3DDC97 ? 0x04140D : 0x9AA5A1, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, y + 18, Graphics.FONT_XTINY, subtext,
                       Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            dc.drawText(centerX, y, Graphics.FONT_SMALL, text,
                       Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    private function formatTime(totalSeconds as Number) as String {
        var hours = totalSeconds / 3600;
        var minutes = (totalSeconds % 3600) / 60;
        var seconds = totalSeconds % 60;

        if (hours > 0) {
            return hours.format("%d") + ":" +
                   minutes.format("%02d") + ":" +
                   seconds.format("%02d");
        } else {
            return minutes.format("%02d") + ":" +
                   seconds.format("%02d");
        }
    }

    function getLastTime() as Number {
        return _lastTime;
    }
}
