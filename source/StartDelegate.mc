import Toybox.WatchUi;
import Toybox.Lang;

class StartDelegate extends WatchUi.InputDelegate {
    private var _view as StartView;

    function initialize(view as StartView) {
        InputDelegate.initialize();
        _view = view;
    }

    function onTap(clickEvent as ClickEvent) as Boolean {
        var coords = clickEvent.getCoordinates();
        var y = coords[1];

        var centerY = 208;
        var startY = centerY - 60;
        var spacing = 80;
        var buttonHeight = 64;

        // Quick Start button
        if (y >= startY - buttonHeight/2 && y <= startY + buttonHeight/2) {
            onQuickStart();
            return true;
        }

        // New Timer button
        if (y >= startY + spacing - buttonHeight/2 && y <= startY + spacing + buttonHeight/2) {
            onNewTimer();
            return true;
        }

        // Settings button
        if (y >= startY + spacing * 2 - 30 && y <= startY + spacing * 2 + 30) {
            onSettings();
            return true;
        }

        return false;
    }

    function onQuickStart() as Void {
        // Start countdown with last time
        var lastTime = _view.getLastTime();
        var countdownView = new CountdownView(lastTime);
        WatchUi.switchToView(countdownView, new CountdownDelegate(countdownView), WatchUi.SLIDE_LEFT);
    }

    function onNewTimer() as Void {
        // Go to time picker
        var timePickerView = new TimePickerView();
        WatchUi.switchToView(timePickerView, new TimePickerDelegate(timePickerView), WatchUi.SLIDE_LEFT);
    }

    function onSettings() as Void {
        // Open settings view
        var view = new SettingsView();
        WatchUi.pushView(view, new SettingsDelegate(view), WatchUi.SLIDE_UP);
    }

    // BACK button exits app
    function onBack() as Boolean {
        System.exit();
    }

    // Handle physical buttons
    function onKey(keyEvent as KeyEvent) as Boolean {
        var key = keyEvent.getKey();
        if (key == WatchUi.KEY_ENTER) { // SELECT = Quick Start
            onQuickStart();
            return true;
        }
        return false;
    }
}
