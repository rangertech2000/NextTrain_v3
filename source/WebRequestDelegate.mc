using Toybox.Communications as Comm;
using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;


class WebRequestDelegate extends Ui.BehaviorDelegate {
    var notify;
    hidden var sView;
    var myTZoffset;

    // Show Schedule view
    function onMenu() {
    	sView = new ScheduleView();
    	Ui.pushView(sView, new ScheduleViewDelegate(sView.method(:onReceive)), Ui.SLIDE_UP );
    	return true;
    }
    
    // Quit the app
    function onKey(KEY_START) {
    	System.exit();
    }

	// Go to Station Picker
    function onBack() {
    	Ui.pushView(new Station1Picker(), new Station1PickerDelegate(), Ui.SLIDE_IMMEDIATE);
    	return true;
    }
        
    // Change direction
	function onNextPage() {
    	changeDirection();
        makeRequest(direction);
        return true;
    }
	function onPreviousPage() {
    	changeDirection();
        makeRequest(direction);
        return true;
    }	
	
	// Refresh the data
    function onSelect() {
        makeRequest(direction);
        return true;
    }
    
    // Set up the callback to the view
    function initialize(handler) {
        Ui.BehaviorDelegate.initialize();
        notify = handler;
            
    	//Get the Time Zone offset
		var myTime = System.getClockTime();
		myTZoffset = myTime.timeZoneOffset/3600; //convert offset to hours   
		System.println("Time Zone offset: " + myTZoffset);	
    }

    function makeRequest(direction) {
    	notify.invoke("Executing\nRequest");
   		
   		if (direction == null) { changeDirection(); }
   		
    	var url = "https://www3.septa.org/hackathon/NextToArrive/" + replaceSpaces(startStation) + "/" + replaceSpaces(endStation) + "/1"; 
		directionString = startStation + "\n--> " + endStation;
        
        Comm.makeWebRequest(
            url,
            {},
            {
            //:method => Comm.HTTP_REQUEST_METHOD_GET,
            "Content-Type" => Comm.REQUEST_CONTENT_TYPE_JSON//,
            //:headers {"Content-Type" => Comm.REQUEST_CONTENT_TYPE_JSON}//,
            //:responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
             },
            method(:onReceive)
        );
    }
    
    function replaceSpaces(word) {
        var word1, word2;
    	var wordLength = word.length();
    	var space = word.find(" ");
    	// Remove any spaces
    	while (space != null) {
    		word1 = word.substring(0, space) + "%20";
    		word2 = word.substring(space + 1, wordLength);
    		word = word1 + word2;
    		space = word.find(" ");
    		wordLength = word.length();
    	}
    	return word;
    }
    
    function formatTime(word) {
       	var word1, word2;
    	var wordLength = word.length();
    	var space = word.find(" ");
    	// Remove any spaces
    	while (space != null) {
    		word1 = word.substring(0, space);
    		word2 = word.substring(space + 1, wordLength);
    		word = word1 + word2;
    		space = word.find(" ");
    		wordLength = word.length();
    	}
    	// Remove the trailing "M"
    	word = word.substring(0, wordLength - 1); 
    	//word = word.substring(0, (word.length() - 1)); 
    	return word;
    }

    function changeDirection() {
	    if (direction == 1) {
	    		direction = 2;
	    		startStation = station2;
	    		endStation = station1;
	    	}
	    	else {
	    		direction = 1;
	    		startStation = station1;
	    		endStation = station2;
	    	}
    }
    
    // Receive the data from the web request
    function onReceive(responseCode, data) { 
		if (responseCode == 200) {
        	System.println("reponseCode: " + responseCode);
        	
        	var data_text = "";
        	
	      	if (data instanceof Lang.Dictionary) {
	            System.println("data is a Dictionary.");
	            System.println("Dictionary size: " + data.size());
	            
	            var keys = data.keys();
	            for( var i = 0; i < keys.size(); i++ ) {
	                System.println(keys[i] + " : " + data[keys[i]]);
	            }
	        } 
	        else if (data instanceof Lang.Array) {
	            System.println("data is an Array.");
	            System.println("Array size: " + data.size());
	            
	            if (data.size() > 0) {    
	            System.println(data[0]);	
		    		data = data[0]; //convert the array to a dictionary type
		    	
		    		var intDelay;
			    	var strDelay = data.get("orig_delay");
			    	if (!strDelay.equals("On time")) {	
			    		intDelay = strDelay.toNumber();
			    		strDelay = strDelay + " late";
			    	}
			    	else {
			    		intDelay = 0;
			    	}
			        
				        // Get hour and minute info from Depart Time    	 
				        var departTime = formatTime(data.get("orig_departure_time"));				        
				        var colon = departTime.find(":");   
				        var mHour = departTime.substring(0, colon).toNumber();
				        var mMins = departTime.substring(colon+1, colon+3).toNumber();
				        
				        // Convert to 24hr format
				        if (departTime.find("A") != null && mHour == 12){
				        	mHour = 0;
				        }
				        if (departTime.find("P") != null && mHour < 12){
				        	mHour = mHour + 12;
				        }
			        	System.println("mHour: " + mHour + ", mMins: " + mMins + ", myTZoffset: " + myTZoffset);
			        	
				        // Get the current Gregorian depart time	
		        		var options = {
							:hour=>(mHour),
							:minute=>mMins
							};
						System.println("options: " + options[0]);	
						
						var DepartTimeGregorian = Gregorian.moment(options);
						// --debug-->
						var today2 = Gregorian.info(DepartTimeGregorian, Time.FORMAT_MEDIUM);
						var dateStringDepart = Lang.format(
						    "$1$:$2$:$3$ $4$ $5$ $6$ $7$",
						    [
						        today2.hour,
						        today2.min,
						        today2.sec,
						        today2.day_of_week,
						        today2.day,
						        today2.month,
						        today2.year
						    ]
						);						
						System.println("Depart Time(GMT): " + dateStringDepart);     
						// <--debug--   
			       		        		        
				        // Calculate minutes until departure
				        // ----	Get the current Time.Moment 
			        		var mNow = new Time.Moment(Time.now().value());
			        		// --debug-->
			        		var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
							var dateString = Lang.format(
							    "$1$:$2$:$3$ $4$ $5$ $6$ $7$",
							    [
							        today.hour,
							        today.min,
							        today.sec,
							        today.day_of_week,
							        today.day,
							        today.month,
							        today.year
							    ]
							);
							System.println("Current Time: " + dateString);
							// <--debug--
							var MinutesRemaining = (DepartTimeGregorian.compare(mNow)/60 - myTZoffset*60) + intDelay;
							System.println("MinutesRemaining: " + MinutesRemaining); 
			        	
			        		
			    	data_text = {
			    	"Depart Time"=>formatTime(data.get("orig_departure_time"))
			    	,"Delay"=>strDelay
			    	,"Remaining"=>MinutesRemaining.toString()
			    	};
		    	}
		    	else {
		    		data_text = "No trains\navailable";
		    	}    	
	        }      	
            notify.invoke(data_text);
        } 
        else {
            notify.invoke("Failed to load\nError: " + responseCode.toString());
        }
    }
}