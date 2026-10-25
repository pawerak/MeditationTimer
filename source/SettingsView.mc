import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application.Storage;

class SettingsView extends WatchUi.View {
    private var _intervalSignal as Boolean = false;

    function initialize() {
        View.initialize();

        // Load settings
        var setting = Storage.getValue("intervalSignal");
        if (setting != null) {
            _intervalSignal = setting as Boolean;
        }
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var centerX = width / 2;

        // Title
        dc.setColor(0xF2F5F3, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 50, Graphics.FONT_MEDIUM, "Settings",
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Setting 1: Interval signal (toggleable)
        drawSetting(dc, centerX, 130,
                   WatchUi.loadResource(Rez.Strings.IntervalSignal) as String,
                   WatchUi.loadResource(Rez.Strings.IntervalSignalDesc) as String,
                   _intervalSignal, true);

        // Setting 2: End signal (always on, not toggleable)
        drawSetting(dc, centerX, 210,
                   WatchUi.loadResource(Rez.Strings.EndSignal) as String,
                   WatchUi.loadResource(Rez.Strings.EndSignalDesc) as String,
                   true, false);
    }

    private function drawSetting(dc as Dc, centerX as Number, y as Number,
                                 label as String, description as String,
                                 enabled as Boolean, toggleable as Boolean) as Void {
        // Label (white for both)
        dc.setColor(0xF2F5F3, Graphics.COLOR_TRANSPARENT);
        dc.drawText(40, y, Graphics.FONT_TINY, label,
                   Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Description (smaller, gray) - more space to avoid overlap
        dc.setColor(0x9AA5A1, Graphics.COLOR_TRANSPARENT);
        dc.drawText(40, y + 24, Graphics.FONT_XTINY, description,
                   Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Vertical toggle switch on the right (native Garmin style)
        var toggleX = 340;
        var toggleY = y + 10;
        var switchHeight = 50;
        var switchWidth = 26;
        var knobHeight = 24;

        // Switch background (vertical rounded rectangle)
        dc.setColor(enabled ? 0x3DDC97 : 0x2A3531, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(toggleX - switchWidth/2, toggleY - switchHeight/2,
                               switchWidth, switchHeight, switchWidth/2);

        // Switch knob (rounded rectangle)
        var knobY = enabled ? toggleY - 13 : toggleY + 13;
        dc.setColor(0xF2F5F3, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(toggleX - switchWidth/2 + 2, knobY - knobHeight/2,
                               switchWidth - 4, knobHeight, (switchWidth - 4)/2);
    }

    function toggleIntervalSignal() as Void {
        _intervalSignal = !_intervalSignal;
        Storage.setValue("intervalSignal", _intervalSignal);
        WatchUi.requestUpdate();
    }

    function isIntervalSignal() as Boolean {
        return _intervalSignal;
    }
}
