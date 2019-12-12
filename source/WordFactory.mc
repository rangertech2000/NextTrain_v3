using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

class WordFactory extends Ui.PickerFactory {
    var mWords = ["Narberth","Merion","Overbrk","Wisshckn"];
    var mStation = ["Narberth","Merion","Overbrook","Wissahickon"];
    var mFont= Gfx.FONT_MEDIUM;
    
    function initialize() {
        PickerFactory.initialize();
        }

    function getSize() {
        return mWords.size();
    }

    function getValue(index) {
        return mStation[index];
    }

    function getDrawable(index, selected) {
        return new Ui.Text({:text=>mWords[index], :color=>Gfx.COLOR_WHITE, :font=>mFont, :locX=>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_CENTER});
    }
}
