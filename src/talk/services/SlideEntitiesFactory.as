package talk.services
{
    import alecmce.entitysystem.extensions.concepts.Position;
    import alecmce.entitysystem.extensions.concepts.Renderable;
    import alecmce.entitysystem.framework.Entity;
    import alecmce.fonts.BitmapFont;
    import alecmce.fonts.BitmapFonts;

    import flash.errors.IllegalOperationError;

    import talk.data.Slide;
    import talk.data.SlideText;

    public class SlideEntitiesFactory
    {
        [Inject]
        public var fonts:BitmapFonts;

        private var slide:Slide;
        private var slideText:SlideText;
        private var font:BitmapFont;
        private var text:String;
        private var list:Vector.<CharacterVO>;
        private var entities:Vector.<Entity>;
        private var x:Number;
        private var y:Number;

        public function make(slide:Slide):Vector.<Entity>
        {
            this.slide = slide;

            entities = new <Entity>[];

            makeTextEntities(slide.title);
            for each (var text:SlideText in slide.points)
                makeTextEntities(text);

            return entities;
        }

        private function makeTextEntities(slide:SlideText):void
        {
            this.slideText = slide;

            font = fonts.getFont(slide.font);
            text = slide.text;
            x = slide.x;
            y = slide.y;

            makeCharacterList();
            makeEntities();
        }

        private function makeCharacterList():void
        {
            list = new <CharacterVO>[];

            var characters:Array = text.split("");
            var max:int = characters.length - 1;
            for (var i:int = 0; i <= max; i++)
            {
                var character:String = characters[i];

                var vo:CharacterVO = new CharacterVO();
                vo.character = character;
                vo.kerning = i < max ? font.getKerning(character, characters[i + 1]) : 0;

                if (character != " ")
                {
                    vo.data = font.getCharacter(character);
                    if (vo.data == null)
                        throw new IllegalOperationError("You cannot render bitmap text including characters not present in the bitmap font");
                }
                else
                {
                    vo.kerning += font.getSpace();
                }

                list.push(vo);
            }
        }

        private function getLineWidth():int
        {
            var width:Number = 0;

            var max:int = list.length - 1;
            for (var i:int = 0; i <= max; i++)
                width += list[i].getWidth();

            return Math.ceil(width);
        }

        private function getLineHeight():int
        {
            var height:int = 0;

            var length:int = list.length;
            for (var i:int = 0; i < length; i++)
            {
                var h:int = list[i].getHeight();
                if (h > height)
                    height = h;
            }

            return height;
        }

        private function makeEntities():void
        {
            var length:int = list.length;
            for (var i:int = 0; i < length; i++)
            {
                var vo:CharacterVO = list[i];
                if (vo.character != " ")
                    makeEntity(vo);

                x += vo.getWidth();
            }
        }

        private function makeEntity(vo:CharacterVO):void
        {
            var renderable:Renderable = new Renderable(vo.data);
            var position:Position = new Position(x, y);

            var entity:Entity = new Entity();
            entity.add(position);
            entity.add(renderable);
            entity.add(slide);
            entity.add(slideText);

            entities.push(entity);
        }
    }
}

import flash.display.BitmapData;

class CharacterVO
{
    public var character:String;
    public var data:BitmapData;
    public var kerning:Number;

    public function getWidth():Number
    {
        return (data ? data.width : 0) + kerning;
    }

    public function getHeight():int
    {
        return data ? data.height : 0;
    }
}