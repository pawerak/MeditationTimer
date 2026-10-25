import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Lang;
import Toybox.ActivityMonitor;
import Toybox.Attention;
import Toybox.System;
import Toybox.ActivityRecording;

class CountdownView extends WatchUi.View {
    private var _totalSeconds as Number;
    private var _remainingSeconds as Number;
    private var _timer as Timer.Timer or Null = null;
    private var _heartRate as Number or Null = null;
    private var _stress as Number or Null = null;

    // For calculating averages
    private var _heartRateSum as Number = 0;
    private var _heartRateCount as Number = 0;
    private var _stressSum as Number = 0;
    private var _stressCount as Number = 0;

    // Activity recording
    private var _session as ActivityRecording.Session or Null = null;

    function initialize(seconds as Number) {
        View.initialize();
        _totalSeconds = seconds;
        _remainingSeconds = seconds;

        // Create activity recording session
        // Using SPORT_TRAINING + SUB_SPORT_FLEXIBILITY_TRAINING (closest to meditation)
        _session = ActivityRecording.createSession({
            :name => "Meditation",
            :sport => ActivityRecording.SPORT_TRAINING,
            :subSport => ActivityRecording.SUB_SPORT_FLEXIBILITY_TRAINING
        });
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

        // Calculate averages
        var avgHr = _heartRateCount > 0 ? (_heartRateSum / _heartRateCount) : null;
        var avgStress = _stressCount > 0 ? (_stressSum / _stressCount) : null;

        // Save activity
        saveActivity();

        // Show summary
        var summaryView = new SummaryView(_totalSeconds, avgHr, avgStress);
        WatchUi.switchToView(summaryView, new SummaryDelegate(), WatchUi.SLIDE_LEFT);
    }

    private function updateSensorData() as Void {
        // Get heart rate and stress from ActivityMonitor
        var info = ActivityMonitor.getInfo();

        // Heart rate
        if (info has :heartRate) {
            _heartRate = info.heartRate;
            if (_heartRate != null) {
                _heartRateSum += _heartRate;
                _heartRateCount++;
            }
        }

        // Stress level (available since API 5.0.0)
        if (info has :stressScore) {
            _stress = info.stressScore;
            if (_stress != null) {
                _stressSum += _stress;
                _stressCount++;
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

        // Draw sensors (heart rate and stress) - more space below time
        drawSensors(dc, centerX, centerY + 75);
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
            var startAngle = 90; // top (12 o'clock) - try 90° instead of 270°
            var endAngle = 90 - (progress * 360); // shrink clockwise
            dc.drawArc(centerX, centerY, radius, Graphics.ARC_CLOCKWISE, startAngle, endAngle);
        }

        dc.setPenWidth(1);
    }

    private function drawCenterInfo(dc as Dc, centerX as Number, centerY as Number) as Void {
        // Label "Meditation" - higher up
        dc.setColor(0x9AA5A1, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY - 65, Graphics.FONT_XTINY, "Meditation",
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Remaining time (big)
        dc.setColor(0xF2F5F3, Graphics.COLOR_TRANSPARENT);
        var timeStr = formatTime(_remainingSeconds);
        dc.drawText(centerX, centerY - 10, Graphics.FONT_NUMBER_MILD, timeStr,
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Total time label - more space below
        dc.setColor(0x9AA5A1, Graphics.COLOR_TRANSPARENT);
        var totalStr = "of " + formatTime(_totalSeconds);
        dc.drawText(centerX, centerY + 40, Graphics.FONT_XTINY, totalStr,
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawSensors(dc as Dc, centerX as Number, y as Number) as Void {
        dc.setColor(0x9AA5A1, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);

        // Heart rate (left side) - icon + value only
        var heartX = centerX - 50;
        drawHeart(dc, heartX, y);
        dc.setColor(0xF2F5F3, Graphics.COLOR_TRANSPARENT);
        var hrText = _heartRate != null ? _heartRate.toString() : "--";
        dc.drawText(heartX + 20, y, Graphics.FONT_TINY, hrText,
                   Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Divider line
        dc.setColor(0x2A3531, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(centerX, y - 10, centerX, y + 10);

        // Stress (right side) - icon + value only
        var stressX = centerX + 15;
        drawWave(dc, stressX, y);
        dc.setColor(0xF2F5F3, Graphics.COLOR_TRANSPARENT);
        var stressText = _stress != null ? _stress.toString() : "--";
        dc.drawText(stressX + 20, y, Graphics.FONT_TINY, stressText,
                   Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawHeart(dc as Dc, x as Number, y as Number) as Void {
        // Simple heart icon (red/pink)
        dc.setColor(0xF07C86, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x - 3, y - 2, 4);
        dc.fillCircle(x + 3, y - 2, 4);
        dc.fillPolygon([[x - 7, y], [x, y + 7], [x + 7, y]] as Array<Point2D>);
    }

    private function drawWave(dc as Dc, x as Number, y as Number) as Void {
        // Simple wave icon (blue)
        dc.setColor(0x4DA3FF, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(x - 6, y, x - 3, y - 4);
        dc.drawLine(x - 3, y - 4, x, y);
        dc.drawLine(x, y, x + 3, y + 4);
        dc.drawLine(x + 3, y + 4, x + 6, y);
        dc.setPenWidth(1);
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
