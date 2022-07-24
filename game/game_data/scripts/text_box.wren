import "sprite" for Sprite
import "vmath" for Vector2
import "renderer" for Renderer

class TextBox is Sprite {
    construct new(parent, sprWidth, sprHeight, textOffset, text){
        // 18
        _brushSprite = Renderer.addSprite()
        _textOffset = textOffset
        setText(text)
        var width = 9
        var height = 12
        // var cursorX = 0
        // var cursorY = 0
        // var maxWidth = 0
        // var maxHeight = height

        // for (c in text) {
        //     var idx = alpha.indexOf(c)
        //     if(idx == -1){
        //         if (c == "\n"){
        //             // newline
        //             maxHeight = maxHeight + height
        //             cursorX = 0
        //             cursorY = cursorY + height
        //         }
        //     } else{
        //         if (cursorX + width > maxWidth) maxWidth = cursorX + width
        //         var brushPosition = textOffset.copy()
        //         brushPosition.x = brushPosition.x + cursorX
        //         brushPosition.y = brushPosition.y + cursorY
        //         var brushOffset = Vector2.new(0,88)
        //         if(idx > 18){
        //             brushOffset.y = brushOffset.y + height
        //             idx = idx - 19
        //         }
        //         brushOffset.x = brushOffset.x + idx * width
        //         Renderer.setSpriteDimensions(_brushSprite, brushOffset.x, brushOffset.y, width, height)
        //         Renderer.setSpriteTransform(_brushSprite, brushPosition.x, brushPosition.y, 0, width, height, 0)
        //         Renderer.blitSpriteToAtlas(_brushSprite)
        //     }
        //     if(c != "\n") cursorX = cursorX + width
        // }
        Renderer.setSpriteTransform(_brushSprite, -100, 0, 0, width, height, 0)
        super(parent, textOffset.x, textOffset.y, sprWidth, sprHeight)
    }
    clear(){
        var width = 9
        var height = 12

        Renderer.setSpriteDimensions(_brushSprite, 1024-width, 1024-height, width, height)
        for(x in 0...(dimensions.x/width)){
            for(y in 0...(dimensions.y/height)){
                Renderer.setSpriteTransform(_brushSprite, x * width + _textOffset.x, y * height + _textOffset.y, 0, width, height, 0)
                Renderer.blitSpriteToAtlas(_brushSprite)
            }
        }
    }
    setText(text){
        var alpha = "0123456789!?(){}[]$abcdefghijklmnopqrstuvwxyz"
        var width = 9
        var height = 12
        var cursorX = 0
        var cursorY = 0
        var maxWidth = 0
        var maxHeight = height

        for (c in text) {
            var idx = alpha.indexOf(c)
            if(idx == -1){
                if (c == "\n"){
                    // newline
                    maxHeight = maxHeight + height
                    cursorX = 0
                    cursorY = cursorY + height
                }
            } else{
                if (cursorX + width > maxWidth) maxWidth = cursorX + width
                var brushPosition = _textOffset.copy()
                brushPosition.x = brushPosition.x + cursorX
                brushPosition.y = brushPosition.y + cursorY
                var brushOffset = Vector2.new(0,88)
                if(idx > 18){
                    brushOffset.y = brushOffset.y + height
                    idx = idx - 19
                }
                brushOffset.x = brushOffset.x + idx * width
                Renderer.setSpriteDimensions(_brushSprite, brushOffset.x, brushOffset.y, width, height)
                Renderer.setSpriteTransform(_brushSprite, brushPosition.x, brushPosition.y, 0, width, height, 0)
                Renderer.blitSpriteToAtlas(_brushSprite)
            }
            if(c != "\n") cursorX = cursorX + width
        }
    }
}