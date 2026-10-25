import Toybox.WatchUi;
import Toybox.Lang;

class CountdownDelegate extends WatchUi.BehaviorDelegate {
    private var _view as CountdownView;

    function initialize(view as CountdownView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    // Handle START/STOP button - pause countdown
    function onSelect() as Boolean {
        _view.pause();
        // TODO: Show pause screen
        System.println("Countdown paused");
        return true;
    }

    // Handle BACK button - pause countdown
    function onBack() as Boolean {
        _view.pause();
        // TODO: Show pause screen
        System.println("Countdown paused");
        return true;
    }
}
