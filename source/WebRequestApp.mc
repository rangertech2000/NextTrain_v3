using Toybox.Application as App;
var direction, directionString;
var station1, station2;
var startStation, endStation;
    
class WebRequestApp extends App.AppBase {
    hidden var mView;

    function initialize() {
        App.AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        mView = new WebRequestView();
        return [mView, new WebRequestDelegate(mView.method(:onReceive))];
    }
}