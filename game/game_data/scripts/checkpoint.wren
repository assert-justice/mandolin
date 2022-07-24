import "sprite" for Sprite
import "audio_source" for AudioSource

class Checkpoint is Sprite {
    construct new(parent, manager, player){
        super(parent, 306, 54, 18, 18)
        _active = false
        _manager = manager
        _player = player
        _radius = 12
        _roomX = 0
        _roomY = 0
        _audioSource = AudioSource.new(this, "game_data/sfx/Powerup__006.wav", false)
    }
    setRoom(x,y){
        _roomX = x
        _roomY = y
    }
    active{_active}
    active=(val){
        _active = val
        offset.x = val ? 342 : 306
    }
    getData(){
        return "%(_roomX)_%(_roomY)_%(transform.position.x-3)_%(transform.position.y-8)"
    }
    update(deltaTime){
        if(!_active){
            var dis = _player.transform.position.copy()
            dis.x = dis.x - transform.position.x
            dis.y = dis.y - transform.position.y
            if(dis.length < _radius){
                _manager.setCheckpoint(getData())
                _audioSource.play()
            }
        }
        super.update(deltaTime)
    }
    wake(){
        _active = false
        super.wake()
    }
}