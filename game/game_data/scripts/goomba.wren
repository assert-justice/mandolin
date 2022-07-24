import "sprite" for Sprite
import "vmath" for Vector3

class Goomba is Sprite {
    construct new(parent, tileMap, player){
        super(parent, 3 * 24, 2 * 24, 24, 24)
        _tileMap = tileMap
        _gravity = 10
        _speed = 120
        _dx = -1
        _vel = Vector3.new(0,0,0)
        _player = player
        _radius = 12
    }

    bounce(){
        _dx = -_dx
        hflip = !hflip
    }

    update(deltaTime){
        _vel.x = _dx * _speed * deltaTime
        _vel.y = _vel.y + _gravity * deltaTime
        var newPos = _tileMap.collide(transform.position, _vel, 24, 24)
        if(newPos.x == transform.position.x) bounce()
        if(newPos.y == transform.position.y) _vel.y = 0
        var probe = transform.position.copy()
        probe.x = probe.x + 12
        var cell = _tileMap.getCellAtPosition(probe)
        if(!_tileMap.solid(cell[0] + _dx, cell[1] + 2)) bounce()
        transform.position = newPos
        var dis = _player.transform.position.copy()
        dis.x = dis.x - transform.position.x
        dis.y = dis.y - transform.position.y
        if(dis.length < _radius){
            _player.hit()
        }
        super.update(deltaTime)
    }
}