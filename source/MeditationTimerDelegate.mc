import Toybox.Lang;
import Toybox.WatchUi;

class MeditationTimerDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new MeditationTimerMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}