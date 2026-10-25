import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class SummaryView extends WatchUi.View {
    private var _duration as Number;
    private var _avgHeartRate as Number or Null;

    function initialize(duration as Number, avgHr as Number or Null) {
        View.initialize();
        _duration = duration;
        _avgHeartRate = avgHr;
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;

        // Green circle with checkmark
        var circleY = centerY - 70;
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
        dc.drawText(centerX, circleY + 65, Graphics.FONT_SMALL,
                   WatchUi.loadResource(Rez.Strings.MeditationSaved) as String,
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Duration (big)
        dc.setColor(0xF2F5F3, Graphics.COLOR_TRANSPARENT);
        var timeStr = formatTime(_duration);
        dc.drawText(centerX, circleY + 125, Graphics.FONT_NUMBER_MILD, timeStr,
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Average heart rate centered below duration: heart icon + value
        var statsY = circleY + 190;
        var hrText = _avgHeartRate != null ? _avgHeartRate.toString() : "--";
        drawHeart(dc, centerX - 22, statsY);
        dc.setColor(0xF2F5F3, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, statsY, Graphics.FONT_MEDIUM, hrText,
                   Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(0x9AA5A1, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, statsY + 35, Graphics.FONT_XTINY,
                   WatchUi.loadResource(Rez.Strings.AvgHeartRate) as String,
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawHeart(dc as Dc, x as Number, y as Number) as Void {
        dc.setColor(0xF07C86, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x - 3, y - 2, 4);
        dc.fillCircle(x + 3, y - 2, 4);
        dc.fillPolygon([[x - 7, y], [x, y + 7], [x + 7, y]] as Array<Point2D>);
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
