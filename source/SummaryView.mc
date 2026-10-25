import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class SummaryView extends WatchUi.View {
    private var _duration as Number;
    private var _avgHeartRate as Number or Null;
    private var _avgStress as Number or Null;

    function initialize(duration as Number, avgHr as Number or Null, avgStress as Number or Null) {
        View.initialize();
        _duration = duration;
        _avgHeartRate = avgHr;
        _avgStress = avgStress;
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;

        // Green circle with checkmark
        var circleY = centerY - 60;
        dc.setColor(0x3DDC97, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, circleY, 40);

        // Checkmark
        dc.setColor(0x04140D, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(4);
        dc.drawLine(centerX - 15, circleY, centerX - 5, circleY + 12);
        dc.drawLine(centerX - 5, circleY + 12, centerX + 15, circleY - 12);
        dc.setPenWidth(1);

        // "Meditation saved" label
        dc.setColor(0x9AA5A1, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, circleY + 60, Graphics.FONT_SMALL,
                   WatchUi.loadResource(Rez.Strings.MeditationSaved) as String,
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Duration (big) - more space below label
        dc.setColor(0xF2F5F3, Graphics.COLOR_TRANSPARENT);
        var timeStr = formatTime(_duration);
        dc.drawText(centerX, circleY + 115, Graphics.FONT_NUMBER_MILD, timeStr,
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Stats row: avg heart rate | avg stress - adjust position
        var statsY = circleY + 170;
        drawStats(dc, centerX, statsY);
    }

    private function drawStats(dc as Dc, centerX as Number, y as Number) as Void {
        // Average heart rate (left)
        var hrX = centerX - 70;
        dc.setColor(0x4DA3FF, Graphics.COLOR_TRANSPARENT);
        var hrText = _avgHeartRate != null ? _avgHeartRate.toString() : "--";
        dc.drawText(hrX, y, Graphics.FONT_MEDIUM, hrText,
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(0x9AA5A1, Graphics.COLOR_TRANSPARENT);
        dc.drawText(hrX, y + 25, Graphics.FONT_XTINY,
                   WatchUi.loadResource(Rez.Strings.AvgHeartRate) as String,
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Divider
        dc.setColor(0x2A3531, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(centerX, y - 15, centerX, y + 15);

        // Average stress (right)
        var stressX = centerX + 70;
        dc.setColor(0x4DA3FF, Graphics.COLOR_TRANSPARENT);
        var stressText = _avgStress != null ? _avgStress.toString() : "--";
        dc.drawText(stressX, y, Graphics.FONT_MEDIUM, stressText,
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(0x9AA5A1, Graphics.COLOR_TRANSPARENT);
        dc.drawText(stressX, y + 25, Graphics.FONT_XTINY,
                   WatchUi.loadResource(Rez.Strings.AvgStress) as String,
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
}
