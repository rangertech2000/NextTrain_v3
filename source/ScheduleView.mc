using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;

class ScheduleView extends Ui.View {
    hidden var mMessage = "Schedule View";

    function initialize() {
        Ui.View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
    	//setLayout(Rez.Layouts.WatchFace(dc));
    	     
        // Retrieve schedule data on page load
        var v = new ScheduleViewDelegate(ScheduleView.method(:onReceive));
    	// Get the callback for the onReceive method.
    	var m = v.method(:makeRequest);
    	// Invoke v's makeRequest method.
    	mMessage = m.invoke(direction);
    }

    // Restore the state of the app and prepare the view to be shown
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
    	if (mMessage == null){
  	    	mMessage = "Retrieving\nSchedule";
  	    }
        
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.clear();
        dc.drawText(0, 0, Gfx.FONT_MEDIUM, mMessage, Gfx.TEXT_JUSTIFY_LEFT);    
    }

    // Called when this View is removed from the screen. Save the
    // state of your app here.
    function onHide() {
    }

    function onReceive(args) {
        if (args instanceof Lang.String) {
        	System.println("args is a String type.");
        	System.println("args: " + args.toString());
            mMessage = args;
        }
        else if (args instanceof Lang.Dictionary) {
            // Print the arguments duplicated and returned by httpbin.org
            System.println("args is a Dictionary type.");
            var keys = args.keys();
            mMessage = "";
            
            for( var i = 0; i < keys.size(); i++ ) {
                //mMessage += Lang.format("$1$: $2$\n", [keys[i], args[keys[i]]]);
                mMessage += args[keys[i]] +"\n";
            }
        }
        
        Ui.requestUpdate();
    }
}
