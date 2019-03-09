/*
 (c) 2015-2019, Marco Wittwer
*/
 
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.WatchUi as Ui;
using Toybox.ActivityMonitor as ActMon;
using Toybox.Position as Position;
using Toybox.Math as Math;

class GarminWatchFaceView extends Ui.WatchFace {

	var _background;
	var _wochentage; 
	var _tage;
	var _bluetooth;
	var _alarm;
	var _notification;
	var _sleep;
	var _monde;	
	
	var _activityInfo;
	var _actMonInfo;
	var _clockTime;
	
	var _nowInfo;
	var _lastLon = 1000.0d;
	var _lastLat = 1000.0d;
	var _lastSunMoonCalc = 20000101;
	var _moonPhase;
	var _sunTimes;
	var _resourcesLoaded = false;
	
    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        loadResources();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    	if(!_resourcesLoaded) {
    		loadResources();
    	}
    }

    // Update the view
    function onUpdate(dc) {
        var width, height;
        var screenWidth = dc.getWidth();
       	_clockTime = ClockTime();
        var hour;
        var min;
        
        _activityInfo = Activity.getActivityInfo();
        _actMonInfo = ActMon.getInfo();

        width = dc.getWidth();
        height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;

        var now = Now();

        _nowInfo = Calendar.info(now, Time.FORMAT_SHORT);
        
        SunMoon(dc);

		var dx = (_nowInfo.day_of_week - 1) * 100;
                
        dc.drawBitmap(59 - dx,0,_wochentage);

        dx = (_nowInfo.day - 1) * 26;
        
        dc.drawBitmap(163 - dx,161,_tage);

       	dc.drawBitmap(0,0, _background);
        
        DrawSteps(dc);
        DrawBattery(dc);
        DrawIcons(dc, _actMonInfo);
        DrawAltitude(dc);
       	DrawSun(dc);
        
        hour = ( ( ( _clockTime.hour % 12 ) * 60 ) + _clockTime.min );

		DrawHour(dc, hour, centerX, centerY);
		DrawMinute(dc, _clockTime.min, centerX, centerY);
		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
		dc.fillRectangle(108, 108, 2, 2);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    	_background = null;
        _wochentage = null;
        _tage = null;
        _bluetooth = null;
        _alarm = null;
        _notification = null;
        _sleep = null;
		_monde = null;
		_resourcesLoaded = false;
    	printMemory("onHide");
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }
    
    function SunMoon(dc) {
    	var sunCalc = new SunCalc();
    	var moonCalc = new MoonCalc();
    	
    	var today = Calendar.moment({:day => _nowInfo.day, :month => _nowInfo.month, :year => _nowInfo.year, :hour => 0, :minute => 0, :second => 0});
	    
	    var thisCalc = _nowInfo.year * 10000 + _nowInfo.month * 100 + _nowInfo.day;
	    if(_monde != null && thisCalc > _lastSunMoonCalc) {
		    _moonPhase = sunCalc.GetMoonIllumination(today);
			if(moonCalc.IsNewMoon(_nowInfo.day, _nowInfo.month, _nowInfo.year)) {
		    	_moonPhase = 0;
			} else if(moonCalc.IsFullMoon(_nowInfo.day, _nowInfo.month, _nowInfo.year)) {
		    	_moonPhase = 0.5;
		    }
		}
		
		var loc = _activityInfo.currentLocation;

		if (loc == null) {
			_sunTimes = null;
			_lastLon = 1000.0d;
			_lastLat = 1000.0d;
		} else {
			var lon = loc.toDegrees()[0];
		    var lat = loc.toDegrees()[1];

			var dlon = _lastLon - lon;
			var dlat = _lastLat - lat;
			if(dlon > 0.1 || dlon < -0.1 || dlat > 0.1 || dlat < -0.1 || thisCalc > _lastSunMoonCalc) {
				_sunTimes = sunCalc.GetTimes(today, lon, lat);	
				_lastLon = lon;
				_lastLat = lat;
				_lastSunMoonCalc = thisCalc;
			}		    
		}
		
		if(thisCalc > _lastSunMoonCalc) {
			_lastSunMoonCalc = thisCalc;
		}
		
		DrawMoon(dc);
	}
    
    function DrawSun(dc) {
    
    	if(_sunTimes == null) {
			dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
			dc.drawText(174,97,Gfx.FONT_TINY,"Kein GPS",Gfx.TEXT_JUSTIFY_CENTER);
			return;
		}
    
   		var nowS = (_clockTime.hour * 3600 + _clockTime.min * 60 + _clockTime.sec).toDouble();

		dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);

		if(nowS > _sunTimes["solarNoonS"]) {
		 	// Nachmittag
			var p = (nowS - _sunTimes["solarNoonS"]) / _sunTimes["noonToSetS"];
			if(p >= 0 && p <= 1) {
		    	var decStart = 180;
		    	var decDiff = 180.toFloat();
		    	var dec = decDiff * (p + 1) / 2;
				var decEnd = decStart - dec;
		    	dc.drawArc(173, 108, 33, 1, decStart, decEnd);
		    	dc.drawArc(173, 108, 32, 1, decStart, decEnd);
			}
		} else {
			// Vormittag
			var p = (nowS - _sunTimes["riseS"]) / _sunTimes["riseToNoonS"];
			if(p >= 0 && p <= 1) {
		    	var decStart = 180;
		    	var decDiff = 180.toFloat();
		    	var dec = decDiff * p / 2;
				var decEnd = decStart - dec;
				if(decEnd != decStart) {
		    		dc.drawArc(173, 108, 33, 1, decStart, decEnd);
		    		dc.drawArc(173, 108, 32, 1, decStart, decEnd);
		    	}
			}
		}		

		var sunrise = Lang.format("$1$:$2$", [_sunTimes["sunrise"].hour, _sunTimes["sunrise"].min.format("%02d")]);
		var sunset = Lang.format("$1$:$2$", [_sunTimes["sunset"].hour, _sunTimes["sunset"].min.format("%02d")]);
					
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    	dc.drawText(194,92,Gfx.FONT_TINY,sunrise,Gfx.TEXT_JUSTIFY_RIGHT);
    	dc.drawText(194,109,Gfx.FONT_TINY,sunset,Gfx.TEXT_JUSTIFY_RIGHT);
	}
	
	function DrawIcons(dc, _actMonInfo) {
	    var deviceSettings = Sys.getDeviceSettings();
	    
	    if(_actMonInfo.isSleepMode){
	    	dc.drawBitmap(36,82, _sleep);
	    }
	    
	    if(deviceSettings.notificationCount > 0) {
			dc.drawBitmap(22, 95, _notification);
		}
	
		if(deviceSettings.phoneConnected) {
			dc.drawBitmap(40,95, _bluetooth);
		}
		
		if(deviceSettings.alarmCount > 0) {
			dc.drawBitmap(53, 94, _alarm);
		}
	}
	
	function DrawAltitude(dc) {
		if(_activityInfo.altitude == null) {
			return;
		}
		var altitude = MathFunctions.Round(_activityInfo.altitude);
		
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		
		dc.drawText(45,109,Gfx.FONT_TINY,altitude.toString(),Gfx.TEXT_JUSTIFY_CENTER);
	}
	
	function DrawBattery(dc) {
	   	var bat = Sys.getSystemStats().battery;
       	if(bat >= 30) { 
    		dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
    	} else if(bat >= 15) {
    		dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
    	} else {
    		dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
   		}

		if(bat > 0) {
	    	var decStart = 215;
	    	var decDiff = 250.toFloat();
	    	var dec = decDiff * bat / 100;
			var decEnd = decStart - dec;
	   		dc.drawArc(45, 108, 33, 1, decStart, decEnd);
		    dc.drawArc(45, 108, 32, 1, decStart, decEnd);
		    dc.drawArc(45, 108, 31, 1, decStart, decEnd);
		    dc.drawArc(45, 108, 30, 1, decStart, decEnd);
		    dc.drawArc(45, 108, 29, 1, decStart, decEnd);
   		}	 
	}
	
	function DrawMoon(dc) {
	    var x = 141;
	    var moon = 0;
	    if(_moonPhase == null || _moonPhase == 0.0 || _monde == null) {
	        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
	        dc.fillRectangle(141,76,65, 65);
	    	return;
	    }
	    if(_moonPhase == 0.5) {
	    	moon = 4;
	    } else if(_moonPhase < 0.5) {
	    	moon = MathFunctions.Floor(_moonPhase / (0.5 / 4.0));
	    } else {
	    	moon = MathFunctions.Floor((_moonPhase-0.5) / (0.5 / 4.0)) + 5;
	    }
	    x -= moon * 65;
	   	dc.drawBitmap(x,76, _monde);
	}
	
	function DrawSteps(dc) {
	   
		var steps = _actMonInfo.steps;
		var stepsGoal = _actMonInfo.stepGoal;
		var calories = _actMonInfo.calories;
		var doneF = 100 * steps / stepsGoal.toFloat();
		var done;
		if(doneF >= 100.0) {
			done = 100;
		} else {
			done = MathFunctions.Round(doneF);
			if(done >= 100) {
				done = 99;
			}
		}	
	
		if(done > 0) {
			if(done == 100) {
		       	dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
		    } else {
	       		dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
	       	}
	    	var decStart = 215;
	    	var decDiff = 250.toFloat();
	    	var dec = decDiff * done / 100;
			var decEnd = decStart - dec;
	    	dc.drawArc(109, 174, 33, 1, decStart, decEnd);
	    	dc.drawArc(109, 174, 32, 1, decStart, decEnd);
	    	dc.drawArc(109, 174, 31, 1, decStart, decEnd);
	    	dc.drawArc(109, 174, 30, 1, decStart, decEnd);
	    	dc.drawArc(109, 174, 29, 1, decStart, decEnd);
	    }
	
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		
		if(steps >= 10000) {
			dc.drawText(110,163,Gfx.FONT_SMALL,steps.toString(),Gfx.TEXT_JUSTIFY_CENTER);
		} else if (steps >= 1000) {
			dc.drawText(110,160,Gfx.FONT_MEDIUM,steps.toString(),Gfx.TEXT_JUSTIFY_CENTER);
		} else {
			dc.drawText(110,154,Gfx.FONT_LARGE,steps.toString(),Gfx.TEXT_JUSTIFY_CENTER);
		}
			
		if(stepsGoal >= 10000) {
			dc.drawText(110,183,Gfx.FONT_TINY,stepsGoal.toString(),Gfx.TEXT_JUSTIFY_CENTER);
		} else if(stepsGoal >= 1000) {
			dc.drawText(110,184,Gfx.FONT_TINY,stepsGoal.toString(),Gfx.TEXT_JUSTIFY_CENTER);
		} else {
			dc.drawText(110,182,Gfx.FONT_SMALL,stepsGoal.toString(),Gfx.TEXT_JUSTIFY_CENTER);
		}
		
		dc.drawText(110,146,Gfx.FONT_XTINY,calories.toString(),Gfx.TEXT_JUSTIFY_CENTER);
	}
	
	function DrawMinute(dc, min, centerX, centerY)
	{
		var angle = ( min / 60.0) * Math.PI * 2;
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
	    var coord = new [5];
	    coord[0] = [-3, 15];
	    coord[1] = [-3, -100];
	    coord[2] = [0, -108];
	    coord[3] = [3, -100];
	    coord[4] = [3, 15];
	
	    var cos = Math.cos(angle);
	    var sin = Math.sin(angle);
	
	    var result = new [5];
	    for (var i = 0; i < 5; i += 1)
	    {
	        var x = (coord[i][0] * cos) - (coord[i][1] * sin);
	        var y = (coord[i][0] * sin) + (coord[i][1] * cos);
	        result[i] = [ centerX+x, centerY+y];
	    }
	    
	    dc.fillPolygon(result);
	
		dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
	    var coordInner = new [4];
	    coordInner[0] = [-1, -15];
	    coordInner[1] = [-1, -94];
	    coordInner[2] = [1, -94];
	    coordInner[3] = [1, -15];
	    var resultInner = new [4];
	    for (var i = 0; i < 4; i += 1)
	    {
	        var x = (coordInner[i][0] * cos) - (coordInner[i][1] * sin);
	        var y = (coordInner[i][0] * sin) + (coordInner[i][1] * cos);
	        resultInner[i] = [ centerX+x, centerY+y];
	    }
	    
	    dc.fillPolygon(resultInner);
	}
	
	function DrawHour(dc, hour, centerX, centerY)
	{
	    hour = hour / (12 * 60.0);
	    var angle = hour * Math.PI * 2;
		
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
	    var coord = new [5];
	    coord[0] = [-4, 15];
	    coord[1] = [-4, -72];
	    coord[2] = [0, -80];
	    coord[3] = [4, -72];
	    coord[4] = [4, 15];
	
	    var cos = Math.cos(angle);
	    var sin = Math.sin(angle);
	
	    var result = new [5];
	    for (var i = 0; i < 5; i += 1)
	    {
	        var x = (coord[i][0] * cos) - (coord[i][1] * sin);
	        var y = (coord[i][0] * sin) + (coord[i][1] * cos);
	        result[i] = [ centerX+x, centerY+y];
	    }
	    
	    dc.fillPolygon(result);
	
		dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
	    var coordInner = new [4];
	    coordInner[0] = [-2, -15];
	    coordInner[1] = [-2, -66];
	    coordInner[2] = [2, -66];
	    coordInner[3] = [2, -15];
	    var resultInner = new [4];
	    for (var i = 0; i < 4; i += 1)
	    {
	        var x = (coordInner[i][0] * cos) - (coordInner[i][1] * sin);
	        var y = (coordInner[i][0] * sin) + (coordInner[i][1] * cos);
	        resultInner[i] = [ centerX+x, centerY+y];
	    }
	    
	    dc.fillPolygon(resultInner);
	}
	
	function printMemory(label)  {
		var stats = Sys.getSystemStats();
		System.println("FreeMemory ("+label+"): " + stats.freeMemory);
	}
	
	function checkMemory(amount) {
		var stats = Sys.getSystemStats();
		if(stats.freeMemory < amount) {
			throw new MyOutOfMemory();
		}	
	}
	
	function ClockTime() {
		return Sys.getClockTime();
	}
	
	function Now() {
		return Time.now();
	}
	
	function GetDate(day,month,year,hour, min,sec) {
		var now = Calendar.moment({:day => day, :month => month, :year => year, :hour => hour, :minute => min, :second => sec});
		var info = Calendar.info(now, Time.FORMAT_SHORT);
		
		var nowValue = now.value();
		var now2 = Calendar.moment({:day => info.day, :month => info.month, :year => info.year, :hour => info.hour, :minute => info.min, :second => info.sec});
		var diff = now2.value() - nowValue;
		
		return new Time.Moment(nowValue - diff);
	}
    
    function loadResources() {
        _background = Ui.loadResource(Rez.Drawables.background);
        _wochentage = Ui.loadResource(Rez.Drawables.wochentage);
        _tage = Ui.loadResource(Rez.Drawables.tage);
        _bluetooth = Ui.loadResource(Rez.Drawables.bluetooth);
        _alarm = Ui.loadResource(Rez.Drawables.alarm);
        _notification = Ui.loadResource(Rez.Drawables.notification);
        _sleep = Ui.loadResource(Rez.Drawables.sleep);
        try {
        	checkMemory(10000);
       		_monde = Ui.loadResource(Rez.Drawables.monde);
       	} catch(ex instanceof MyOutOfMemory) {
		}
		_resourcesLoaded = true;
    }
}
