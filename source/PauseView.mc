import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class PauseView extends WatchUi.View {
    private var _countdownView as CountdownView;

    function initialize(countdownView as CountdownView) {
        View.initialize();
        _countdownView = countdownView;
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;

        // Header: "Paused · MM:SS"
        var remaining = _countdownView.getRemainingSeconds();
        var timeStr = formatTime(remaining);
        var headerText = WatchUi.loadResource(Rez.Strings.Paused) + " · " + timeStr;
        dc.setColor(0x9AA5A1, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 60, Graphics.FONT_SMALL, headerText,
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Three buttons
        var buttonWidth = 280;
        var buttonHeight = 64;
        var startY = centerY - 80;
        var spacing = 80;

        // 1. Resume (green background, dark text, play icon)
        drawButton(dc, centerX, startY, buttonWidth, buttonHeight,
                  WatchUi.loadResource(Rez.Strings.Resume) as String,
                  0x3DDC97, 0x04140D, true);

        // 2. Save (black with border)
        drawButton(dc, centerX, startY + spacing, buttonWidth, buttonHeight,
                  WatchUi.loadResource(Rez.Strings.Save) as String,
                  Graphics.COLOR_BLACK, 0xF2F5F3, false);

        // 3. Discard (just gray text, no background)
        dc.setColor(0x9AA5A1, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, startY + spacing * 2, Graphics.FONT_SMALL,
                   WatchUi.loadResource(Rez.Strings.Discard) as String,
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawButton(dc as Dc, centerX as Number, y as Number,
                                width as Number, height as Number,
                                text as String, bgColor as Number,
                                textColor as Number, showPlayIcon as Boolean) as Void {
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

        // Play icon for Resume
        if (showPlayIcon) {
            var iconX = centerX - 80;
            dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon([
                [iconX, y - 8],
                [iconX, y + 8],
                [iconX + 12, y]
            ] as Array<Point2D>);
        }

        // Text
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, y, Graphics.FONT_SMALL, text,
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
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

    function getCountdownView() as CountdownView {
        return _countdownView;
    }
}
