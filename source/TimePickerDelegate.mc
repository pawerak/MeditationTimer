import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Math;

class TimePickerDelegate extends WatchUi.BehaviorDelegate {
    private var _view as TimePickerView;

    function initialize(view as TimePickerView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    // Handle tap on screen
    function onTap(clickEvent as ClickEvent) as Boolean {
        var coords = clickEvent.getCoordinates();
        var x = coords[0];
        var y = coords[1];

        // Screen center for Venu 2 (416x416)
        var centerX = 208;
        var centerY = 208;
        var digitRadius = 152;
        var tapRadius = 36; // detection radius around digit

        // Check if tapped on clear button (X at top)
        if (isNear(x, y, centerX, 132, tapRadius)) {
            _view.removeDigit();
            return true;
        }

        // Check if tapped on start button (checkmark at bottom)
        if (isNear(x, y, centerX, 290, tapRadius)) {
            _view.startTimer();
            return true;
        }

        // Check if tapped on any digit
        for (var i = 0; i < 10; i++) {
            var angle = i * 36.0 - 90.0; // same calculation as in view
            var rad = Math.toRadians(angle);
            var digitX = (centerX + digitRadius * Math.cos(rad)).toNumber();
            var digitY = (centerY + digitRadius * Math.sin(rad)).toNumber();

            if (isNear(x, y, digitX, digitY, tapRadius)) {
                _view.addDigit(i);
                return true;
            }
        }

        return false;
    }

    // Check if point (x,y) is near target (tx,ty) within radius r
    private function isNear(x as Number, y as Number, tx as Number, ty as Number, r as Number) as Boolean {
        var dx = x - tx;
        var dy = y - ty;
        var distSq = dx * dx + dy * dy;
        return distSq <= r * r;
    }

    // Handle START button (upper right physical button)
    function onSelect() as Boolean {
        _view.startTimer();
        return true;
    }

    // Handle BACK button (lower right physical button) - exit app
    function onBack() as Boolean {
        System.exit();
    }
}
