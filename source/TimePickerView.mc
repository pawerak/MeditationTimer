import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application.Storage;
import Toybox.Lang;

class TimePickerView extends WatchUi.View {
    private var _digits as Array<Number> = [] as Array<Number>; // digits entered (right to left)
    private var _lastTime as Number = 600; // default 10:00 in seconds
    private var _showingLastTime as Boolean = true;

    function initialize() {
        View.initialize();

        // Load last time from storage, default to 10:00 (600 seconds)
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
        var centerX = width / 2; // 208
        var centerY = height / 2; // 208
        var radius = 152;

        // Draw digit dial (0-9)
        drawDigitDial(dc, centerX, centerY, radius);

        // Draw time in center
        drawCenterTime(dc, centerX, centerY);

        // Draw clear button (X) at top
        drawClearButton(dc, centerX, 132);

        // Draw start button (checkmark) at bottom
        drawStartButton(dc, centerX, 290);
    }

    private function drawDigitDial(dc as Dc, centerX as Number, centerY as Number, radius as Number) as Void {
        dc.setColor(0x6FB6FF, Graphics.COLOR_TRANSPARENT);

        for (var i = 0; i < 10; i++) {
            var angle = i * 36.0 - 90.0; // 0 at top, rotate 36° per digit, -90 to start from top
            var rad = Math.toRadians(angle);
            var x = (centerX + radius * Math.cos(rad)).toNumber();
            var y = (centerY + radius * Math.sin(rad)).toNumber();

            dc.drawText(x, y, Graphics.FONT_NUMBER_MEDIUM, i.toString(),
                       Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    private function drawCenterTime(dc as Dc, centerX as Number, centerY as Number) as Void {
        var seconds = getCurrentSeconds();
        var timeStr = formatTime(seconds);

        // If showing last time, draw label above
        if (_showingLastTime && _digits.size() == 0) {
            dc.setColor(0x9AA5A1, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, centerY - 30, Graphics.FONT_XTINY,
                       WatchUi.loadResource(Rez.Strings.LastTime) as String,
                       Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // Draw time
        dc.setColor(0xF2F5F3, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY, Graphics.FONT_NUMBER_MEDIUM, timeStr,
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawClearButton(dc as Dc, centerX as Number, y as Number) as Void {
        dc.setColor(0x9AA5A1, Graphics.COLOR_TRANSPARENT);
        var size = 16;
        // Draw X
        dc.drawLine(centerX - size/2, y - size/2, centerX + size/2, y + size/2);
        dc.drawLine(centerX - size/2, y + size/2, centerX + size/2, y - size/2);
    }

    private function drawStartButton(dc as Dc, centerX as Number, y as Number) as Void {
        var radius = 28;
        var active = getCurrentSeconds() > 0;

        // Draw circle
        dc.setColor(active ? 0x3DDC97 : 0x2A3531, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, y, radius);

        // Draw checkmark
        dc.setColor(0x04140D, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(centerX - 10, y, centerX - 3, y + 8);
        dc.drawLine(centerX - 3, y + 8, centerX + 10, y - 8);
        dc.setPenWidth(1);
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

    // Get current time in seconds based on entered digits or last time
    function getCurrentSeconds() as Number {
        if (_digits.size() == 0) {
            return _lastTime;
        }

        // Convert digits to time (digits entered right to left)
        var value = 0;
        for (var i = 0; i < _digits.size(); i++) {
            value = value * 10 + _digits[i];
        }

        // Parse as HHMMSS or MMSS depending on length
        var seconds = 0;
        if (_digits.size() <= 2) {
            seconds = value; // SS
        } else if (_digits.size() <= 4) {
            seconds = (value / 100) * 60 + (value % 100); // MMSS
        } else {
            var hh = value / 10000;
            var mm = (value / 100) % 100;
            var ss = value % 100;
            seconds = hh * 3600 + mm * 60 + ss;
        }

        return seconds;
    }

    // Add a digit (0-9)
    function addDigit(digit as Number) as Void {
        if (_digits.size() >= 6) {
            return; // max 6 digits (HHMMSS)
        }

        // Ignore leading zero
        if (_digits.size() == 0 && digit == 0) {
            return;
        }

        _showingLastTime = false;
        _digits.add(digit);
        WatchUi.requestUpdate();
    }

    // Remove last digit
    function removeDigit() as Void {
        if (_digits.size() > 0) {
            _digits.remove(_digits[_digits.size() - 1]);
            WatchUi.requestUpdate();
        } else {
            // Restore last time
            _showingLastTime = true;
            WatchUi.requestUpdate();
        }
    }

    // Start timer with current time
    function startTimer() as Void {
        var seconds = getCurrentSeconds();
        if (seconds > 0) {
            // Save to storage
            Storage.setValue("lastTime", seconds);
            _lastTime = seconds;

            // TODO: transition to countdown view
            System.println("Start timer: " + seconds + " seconds");
        }
    }
}
