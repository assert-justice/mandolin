import "sprite" for Sprite

class Dice is Sprite {
    construct new(parent, random){
        super(parent, 0, 72, 16, 16)
        _value = 1
        _angleSpeed = 3
        _angleAccel = 0
        _random = random
        _randTime = 0.2
        _randClock = 0
        _rolling = false
        _nextValue = 0
        transform.origin.x = 7.5
        transform.origin.y = 7.5
        // transform.angle = 0.5
        // roll()
    }
    value{_value}
    value=(val){
        _value = val
        offset.x = 16 * (val-1)
        // transform.angle = 0
    }
    nextValue=(val){_nextValue = val}
    update(deltaTime){
        if (_rolling){
            var oldAngle = transform.angle
            transform.angle = transform.angle + _angleSpeed * deltaTime
            if (transform.angle > 4 * 3.14){
                transform.angle = 0
                _rolling = false
                if (_nextValue > 0) value = _nextValue
            }
            _randClock = _randClock - deltaTime
            if (_randClock < 0){
                _randClock = _randTime
                value = (_random.float() * 6).ceil
            }
        }
        super.update(deltaTime)
    }
    roll(){
        _rolling = true
        _angleSpeed = _random.float() * 2 + 4
    }
    rolling{_rolling}
}