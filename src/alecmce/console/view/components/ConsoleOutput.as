package alecmce.console.view.components
{
    import alecmce.ui.api.UIResizes;

    import flash.display.Sprite;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.utils.Dictionary;

    import org.osflash.signals.Signal;

    final public class ConsoleOutput extends Sprite implements UIResizes
    {
        private const PATTERN:RegExp = /\[0x(.+)\:(.+)\]/ig;
        private const HTML_TEMPLATE:String = "<font color='#$1'>$2</font>";

        private var textfield:TextField;

        private var logged:Array;
        private var lastSource:Signal;
        private var delegateMap:Dictionary;

        public function ConsoleOutput()
        {
            logged = [];
            delegateMap = new Dictionary();

            addChild(textfield = new TextField());
            textfield.defaultTextFormat = new TextFormat("_sans", 14, 0xFFFFFF);
            textfield.selectable = false;
            textfield.multiline = true;

            mouseEnabled = false;
        }

        public function log(data:String):void
        {
            data = data.replace(PATTERN, HTML_TEMPLATE);

            lastSource = null;
            logged.push(data);
            updateOutputText();
        }

        public function clear():void
        {
            logged.length = 0;
            lastSource = null;
            textfield.htmlText = "";
        }

        public function resize(rectangle:Rectangle):void
        {
            var h:int = rectangle.height - ConsoleInput.HEIGHT;
            if (h < 0)
                h = 0;

            x = rectangle.x;
            y = rectangle.y;

            textfield.width = rectangle.width;
            textfield.height = h;

            graphics.clear();
            graphics.beginFill(0x006600, 0.8);
            graphics.drawRect(0, 0, width, height);
            graphics.endFill();
        }

        private function updateOutputText():void
        {
            textfield.htmlText = logged.join("\r");
        }
    }
}