using Toybox.Communications as Comm;
using Toybox.WatchUi as Ui;
using Toybox.System;


class ScheduleViewDelegate extends Ui.BehaviorDelegate {
    var notify;
 
    // Handle menu button press
    function onMenu() {
    	return false;
    }
    
    function onBack() {
    	popView(Ui.SLIDE_UP);
    	return true;
    }
    
    function onKey(KEY_START) {
        return false;
    }

    function onSelect() {
        return false;
    }

    // Set up the callback to the view
    function initialize(handler) {
        Ui.BehaviorDelegate.initialize();
        notify = handler;
    }
    
    function makeRequest(direction) {
    	notify.invoke("Executing\nRequest");
    	
    	var url = "https://www3.septa.org/hackathon/NextToArrive/" + replaceSpaces(startStation) + "/" + replaceSpaces(endStation) + "/20"; 
		directionString = startStation + "\n -->" + endStation;
        
        Comm.makeWebRequest(
            url,
            {},
            {"Content-Type" => Comm.REQUEST_CONTENT_TYPE_JSON},
            method(:onReceive)
        );
    }


    function replaceSpaces(word) {
        var word1, word2;
    	var wordLength = word.length();
    	var space = word.find(" ");
    	
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
    	return word;
    }
    
    
    // Receive the data from the web request
    function onReceive(responseCode, data) { 
    	var data_text = "Delay  Depart   Arr\n";
    	    	
      	if (data instanceof Lang.Dictionary) {
            System.println("data is a Dictionary.");
            System.println("Dictionary size: " + data.size());
        } 
        else if (data instanceof Lang.Array) {
            System.println("data is an Array.");
            System.println("Array size: " + data.size());
            
            for (var i = 0; i < data.size(); i++) {
            	var data_temp = data[i]; //convert the array to a dictionary type
            	var delay = data_temp.get("orig_delay");
            	
            	if (delay.equals("On time")) {delay = 0;}
            	else {delay = delay.substring(0, delay.find(" min")).toNumber();}

            	data_text += Lang.format("$1$m  $2$->$3$\n",  
            		[delay.format("%02d"), 
            		formatTime(data_temp.get("orig_departure_time")), 
            		formatTime(data_temp.get("orig_arrival_time"))]
            		);
            }
        }      	

        if (responseCode == 200) {
        	System.println("reponseCode: " + responseCode);
            notify.invoke(data_text);
        } else {
            notify.invoke("Failed to load\nError: " + responseCode.toString());
        }
    }
}