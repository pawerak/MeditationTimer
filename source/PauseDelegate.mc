import Toybox.WatchUi;
import Toybox.Lang;

class PauseDelegate extends WatchUi.InputDelegate {
    private var _view as PauseView;

    function initialize(view as PauseView) {
        InputDelegate.initialize();
        _view = view;
    }

    // Handle screen taps (for touchscreen buttons)
    function onTap(clickEvent as ClickEvent) as Boolean {
        var coords = clickEvent.getCoordinates();
        var y = coords[1];

        var centerY = 208;
        var startY = centerY - 80;
        var spacing = 80;
        var buttonHeight = 64;

        // Resume button
        if (y >= startY - buttonHeight/2 && y <= startY + buttonHeight/2) {
            onResume();
            return true;
        }

        // Save button
        if (y >= startY + spacing - buttonHeight/2 && y <= startY + spacing + buttonHeight/2) {
            onSave();
            return true;
        }

        // Discard button (just text, larger tap area)
        if (y >= startY + spacing * 2 - 30 && y <= startY + spacing * 2 + 30) {
            onDiscard();
            return true;
        }

        return false;
    }

    function onResume() as Void {
        // Resume countdown and go back to countdown view
        var countdownView = _view.getCountdownView();
        countdownView.resume();
        WatchUi.switchToView(countdownView, new CountdownDelegate(countdownView), WatchUi.SLIDE_DOWN);
    }

    function onSave() as Void {
        // TODO: Save activity and show summary
        var countdownView = _view.getCountdownView();
        var elapsed = countdownView.getTotalSeconds() - countdownView.getRemainingSeconds();

        // For now, just show summary (activity recording in Stage 4)
        var summaryView = new SummaryView(elapsed, null, null);
        WatchUi.switchToView(summaryView, new SummaryDelegate(), WatchUi.SLIDE_LEFT);
    }

    function onDiscard() as Void {
        // TODO: Show confirmation dialog, then exit to time picker
        // For now, just exit to time picker
        var timePickerView = new TimePickerView();
        WatchUi.switchToView(timePickerView, new TimePickerDelegate(timePickerView), WatchUi.SLIDE_RIGHT);
    }

    // Handle physical buttons (SELECT = Resume, BACK = Resume)
    function onKey(keyEvent as KeyEvent) as Boolean {
        var key = keyEvent.getKey();
        if (key == WatchUi.KEY_ENTER) { // SELECT button
            onResume();
            return true;
        } else if (key == WatchUi.KEY_ESC) { // BACK button
            onResume();
            return true;
        }
        return false;
    }
}
