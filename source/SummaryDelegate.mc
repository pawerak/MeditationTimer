import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;

class SummaryDelegate extends WatchUi.InputDelegate {

    function initialize() {
        InputDelegate.initialize();
    }

    // Tap anywhere to exit
    function onTap(clickEvent as ClickEvent) as Boolean {
        System.exit();
    }

    // BACK button exits
    function onBack() as Boolean {
        System.exit();
    }
}
