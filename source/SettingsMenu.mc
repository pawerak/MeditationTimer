import Toybox.WatchUi;
import Toybox.Application.Storage;
import Toybox.Lang;

class SettingsMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title => "Settings"});

        // Get current setting
        var intervalSignal = Storage.getValue("intervalSignal");
        if (intervalSignal == null) {
            intervalSignal = false; // default off
        }

        // Toggle: Signal every 5 min
        Menu2.addItem(new WatchUi.ToggleMenuItem(
            WatchUi.loadResource(Rez.Strings.IntervalSignal) as String,
            {:subtitle => WatchUi.loadResource(Rez.Strings.IntervalSignalDesc) as String},
            :intervalSignal,
            intervalSignal as Boolean,
            {}
        ));

        // Info: End signal always on (disabled toggle)
        Menu2.addItem(new WatchUi.ToggleMenuItem(
            WatchUi.loadResource(Rez.Strings.EndSignal) as String,
            {:subtitle => WatchUi.loadResource(Rez.Strings.EndSignalDesc) as String},
            :endSignal,
            true, // always on
            {:enabled => false} // disabled
        ));
    }
}

class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        if (item.getId() == :intervalSignal) {
            var toggle = item as ToggleMenuItem;
            Storage.setValue("intervalSignal", toggle.isEnabled());
            System.println("Interval signal: " + toggle.isEnabled());
        }
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
