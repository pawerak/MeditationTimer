import Toybox.WatchUi;
import Toybox.Lang;

class CountdownDelegate extends WatchUi.BehaviorDelegate {
    private var _view as CountdownView;

    function initialize(view as CountdownView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    // Handle START/STOP button - pause countdown and show pause screen
    function onSelect() as Boolean {
        _view.pause();
        var pauseView = new PauseView(_view);
        WatchUi.switchToView(pauseView, new PauseDelegate(pauseView), WatchUi.SLIDE_UP);
        return true;
    }

    // Handle BACK button - pause countdown and show pause screen
    function onBack() as Boolean {
        _view.pause();
        var pauseView = new PauseView(_view);
        WatchUi.switchToView(pauseView, new PauseDelegate(pauseView), WatchUi.SLIDE_UP);
        return true;
    }
}
