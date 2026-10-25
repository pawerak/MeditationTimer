import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Lang;
import Toybox.Attention;
import Toybox.System;
import Toybox.ActivityRecording;
import Toybox.Application.Storage;
import Toybox.FitContributor;
import Toybox.Activity;
import Toybox.ActivityMonitor;

class CountdownView extends WatchUi.View {
    private var _totalSeconds as Number;
    private var _remainingSeconds as Number;
    private var _timer as Timer.Timer or Null = null;
    private var _heartRate as Number or Null = null;

    // For calculating averages
    private var _heartRateSum as Number = 0;
    private var _heartRateCount as Number = 0;

    // Activity recording
    private var _session as ActivityRecording.Session or Null = null;
    private var _stressField as FitContributor.Field or Null = null;

    // Settings
    private var _intervalSignal as Boolean = false;

    function initialize(seconds as Number) {
        View.initialize();
        _totalSeconds = seconds;
        _remainingSeconds = seconds;

        // Load settings
        var intervalSignal = Storage.getValue("intervalSignal");
        if (intervalSignal != null) {
            _intervalSignal = intervalSignal as Boolean;
        }

        // Create activity recording session
        // Using Activity.SPORT_MEDITATION for proper activity type in Garmin Connect
        _session = ActivityRecording.createSession({
            :name => "Meditation",
            :sport => Activity.SPORT_MEDITATION,
            :subSport => Activity.SUB_SPORT_GENERIC
        });

        // Create FIT contributor field for stress (since it's not automatically recorded)
        _stressField = _session.createField(
            "stress_level",
            0,  // Field ID
            FitContributor.DATA_TYPE_UINT8,
            {:mesgType => FitContributor.MESG_TYPE_RECORD, :units => ""}
        );
    }

    function onShow() as Void {
        // Start timer - update every second (only if not already created)
        if (_timer == null) {
            _timer = new Timer.Timer();
            _timer.start(method(:onTimerTick), 1000, true);
        }

        // Start recording activity
        if (_session != null && !_session.isRecording()) {
            _session.start();
        }
    }

    function onHide() as Void {
        if (_timer != null) {
            _timer.stop();
        }
        // Don't stop session here - will be saved/discarded explicitly
    }

    function onTimerTick() as Void {
        _remainingSeconds--;

        // Update sensor data
        updateSensorData();

        // Check for interval signal (every 5 minutes)
        if (_intervalSignal) {
            var elapsed = _totalSeconds - _remainingSeconds;
            if (elapsed > 0 && elapsed % 300 == 0) { // 300 seconds = 5 minutes
                // Short vibration
                if (Attention has :vibrate) {
                    var vibeData = [
                        new Attention.VibeProfile(30, 200)
                    ] as Array<VibeProfile>;
                    Attention.vibrate(vibeData);
                }
            }
        }

        // Check if finished
        if (_remainingSeconds <= 0) {
            _remainingSeconds = 0;
            _timer.stop();
            onFinished();
        }

        WatchUi.requestUpdate();
    }

    function onFinished() as Void {
        // Vibrate - long pattern (3 pulses)
        if (Attention has :vibrate) {
            var vibeData = [
                new Attention.VibeProfile(50, 500),  // 50% intensity, 500ms
                new Attention.VibeProfile(0, 200),   // pause
                new Attention.VibeProfile(50, 500),
                new Attention.VibeProfile(0, 200),
                new Attention.VibeProfile(50, 500)
            ] as Array<VibeProfile>;
            Attention.vibrate(vibeData);
        }

        // Get average heart rate from Activity API (more accurate than manual calculation)
        var avgHr = getAverageHeartRate();

        // Save activity
        saveActivity();

        // Show summary
        var summaryView = new SummaryView(_totalSeconds, avgHr);
        WatchUi.switchToView(summaryView, new SummaryDelegate(), WatchUi.SLIDE_LEFT);
    }

    private function updateSensorData() as Void {
        // Get heart rate from Activity (live sensor data during recording)
        var activityInfo = Activity.getActivityInfo();
        if (activityInfo != null) {
            _heartRate = activityInfo.currentHeartRate;
            if (_heartRate != null && _heartRate > 0) {
                _heartRateSum += _heartRate;
                _heartRateCount++;
            }
        }

        // Record stress to FIT field (not displayed, but saved for Garmin Connect)
        if (_stressField != null) {
            var monitorInfo = ActivityMonitor.getInfo();
            if (monitorInfo has :stressScore && monitorInfo.stressScore != null) {
                var stress = monitorInfo.stressScore as Number;
                if (stress > 0) {
                    _stressField.setData(stress);
                }
            }
        }
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;

        // Draw progress ring
        drawProgressRing(dc, centerX, centerY);

        // Draw center info
        drawCenterInfo(dc, centerX, centerY);

        // Draw heart rate centered below time
        drawHeartRateRow(dc, centerX, centerY + 90);
    }

    private function drawProgressRing(dc as Dc, centerX as Number, centerY as Number) as Void {
        var radius = 196;
        var thickness = 8;
        var progress = 1.0 - (_remainingSeconds.toFloat() / _totalSeconds.toFloat());

        // Draw background ring
        dc.setColor(0x16211D, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(thickness);
        dc.drawCircle(centerX, centerY, radius);

        // Draw progress arc (green) - shrinks from full circle, clockwise from top
        if (progress > 0) {
            dc.setColor(0x3DDC97, Graphics.COLOR_TRANSPARENT);
            var startAngle = 90; // top (12 o'clock)
            var endAngle = 90 - (progress * 360); // shrink clockwise
            dc.drawArc(centerX, centerY, radius, Graphics.ARC_CLOCKWISE, startAngle, endAngle);
        }

        dc.setPenWidth(1);

        // Draw interval dots ON TOP (if enabled and total time >= 5 min)
        if (_intervalSignal && _totalSeconds >= 300) {
            drawIntervalDots(dc, centerX, centerY, radius);
        }
    }

    private function drawIntervalDots(dc as Dc, centerX as Number, centerY as Number, radius as Number) as Void {
        // Draw blue marks every 5 minutes on the ring
        var intervalSeconds = 300; // 5 minutes

        dc.setColor(0x6FB6FF, Graphics.COLOR_TRANSPARENT); // blue like time picker digits
        dc.setPenWidth(3);

        for (var i = 1; i * intervalSeconds < _totalSeconds; i++) {
            var dotProgress = (i * intervalSeconds).toFloat() / _totalSeconds.toFloat();
            var arcAngle = 90 - (dotProgress * 360); // Angle for drawArc (90° = top)
            var mathAngle = -arcAngle; // Convert to Math.cos/sin convention (negate the angle)
            var rad = Math.toRadians(mathAngle);

            // Draw mark perpendicular to ring (from inner to outer edge)
            var innerRadius = radius - 10;
            var outerRadius = radius + 10;

            var innerX = (centerX + innerRadius * Math.cos(rad)).toNumber();
            var innerY = (centerY + innerRadius * Math.sin(rad)).toNumber();
            var outerX = (centerX + outerRadius * Math.cos(rad)).toNumber();
            var outerY = (centerY + outerRadius * Math.sin(rad)).toNumber();

            dc.drawLine(innerX, innerY, outerX, outerY);
        }

        dc.setPenWidth(1);
    }

    private function drawCenterInfo(dc as Dc, centerX as Number, centerY as Number) as Void {
        // Label "Meditation" - higher up
        dc.setColor(0x9AA5A1, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY - 75, Graphics.FONT_XTINY, "Meditation",
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Remaining time (big)
        dc.setColor(0xF2F5F3, Graphics.COLOR_TRANSPARENT);
        var timeStr = formatTime(_remainingSeconds);
        dc.drawText(centerX, centerY - 10, Graphics.FONT_NUMBER_HOT, timeStr,
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Total time label - more space below
        dc.setColor(0x9AA5A1, Graphics.COLOR_TRANSPARENT);
        var totalStr = "of " + formatTime(_totalSeconds);
        dc.drawText(centerX, centerY + 50, Graphics.FONT_XTINY, totalStr,
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawHeartRateRow(dc as Dc, centerX as Number, y as Number) as Void {
        // Heart icon centered with value
        var hrText = _heartRate != null && _heartRate > 0 ? _heartRate.toString() : "--";
        drawHeart(dc, centerX - 20, y);
        dc.setColor(0xF2F5F3, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX + 2, y, Graphics.FONT_SMALL, hrText,
                   Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawHeart(dc as Dc, x as Number, y as Number) as Void {
        // Simple heart icon (red/pink)
        dc.setColor(0xF07C86, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x - 3, y - 2, 4);
        dc.fillCircle(x + 3, y - 2, 4);
        dc.fillPolygon([[x - 7, y], [x, y + 7], [x + 7, y]] as Array<Point2D>);
    }

    private function formatTime(totalSeconds as Number) as String {
        var hours = totalSeconds / 3600;
        var minutes = (totalSeconds % 3600) / 60;
        var seconds = totalSeconds % 60;

        if (hours > 0) {
            return hours.format("%d") + ":" +
                   minutes.format("%02d") + ":" +
                   seconds.format("%02d");
        } else {
            return minutes.format("%02d") + ":" +
                   seconds.format("%02d");
        }
    }

    // Pause the countdown (stop timer but keep it alive)
    function pause() as Void {
        if (_timer != null) {
            _timer.stop();
        }
    }

    // Resume the countdown (restart existing timer)
    function resume() as Void {
        if (_timer != null) {
            _timer.start(method(:onTimerTick), 1000, true);
        }
    }

    function getRemainingSeconds() as Number {
        return _remainingSeconds;
    }

    function getTotalSeconds() as Number {
        return _totalSeconds;
    }

    function getAverageHeartRate() as Number or Null {
        var activityInfo = Activity.getActivityInfo();
        if (activityInfo != null && activityInfo.averageHeartRate != null) {
            return activityInfo.averageHeartRate;
        }
        if (_heartRateCount > 0) {
            return _heartRateSum / _heartRateCount;
        }
        return null;
    }

    // Save the activity recording
    function saveActivity() as Void {
        if (_session != null && _session.isRecording()) {
            _session.stop();
            _session.save();
            System.println("Activity saved");
        }
    }

    // Discard the activity recording
    function discardActivity() as Void {
        if (_session != null) {
            if (_session.isRecording()) {
                _session.stop();
            }
            _session.discard();
            System.println("Activity discarded");
        }
    }
}
