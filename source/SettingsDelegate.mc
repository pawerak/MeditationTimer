import Toybox.WatchUi;
import Toybox.Lang;

class SettingsDelegate extends WatchUi.InputDelegate {
    private var _view as SettingsView;

    function initialize(view as SettingsView) {
        InputDelegate.initialize();
        _view = view;
    }

    // Tap to toggle interval signal setting
    function onTap(clickEvent as ClickEvent) as Boolean {
        var coords = clickEvent.getCoordinates();
        var y = coords[1];

        // First setting area (interval signal) - toggleable
        if (y >= 100 && y <= 170) {
            _view.toggleIntervalSignal();
            return true;
        }

        // Second setting (end signal) - not toggleable, do nothing

        return false;
    }

    // BACK button closes settings
    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    // Physical buttons
    function onKey(keyEvent as KeyEvent) as Boolean {
        var key = keyEvent.getKey();
        if (key == WatchUi.KEY_ENTER) { // SELECT = toggle first setting
            _view.toggleIntervalSignal();
            return true;
        }
        return false;
    }
}
