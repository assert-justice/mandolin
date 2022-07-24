import "sprite" for Sprite
import "node" for Node
import "vmath" for VMath, Vector2, Vector3
import "input" for Input
import "audio_system" for AudioSystem
import "pool" for Pool
import "bullet" for Bullet
import "dice" for Dice
import "text_box" for TextBox
import "audio_source" for AudioSource

class Player is Node {
    construct new(parent, tileMap, random){
        super(parent)
        _sprite = Sprite.new(this, 0, 0, 24, 24)
        _sprite.transform = transform
        _tileMap = tileMap
        _vel = Vector3.new(0,0,0)
        _speed = 200
        _climbSpeed = 100
        _gravity = 10
        _jumpSpeed = 400
        _jumps = 0
        _maxJumps = 1
        // _audioHandle = AudioSystem.addAudioSource()
        // AudioSystem.loadAudioSource(_audioHandle, "game_data/sfx/Climb_Rope_Loop_00.wav", false)
        _pool = Pool.new(0){Bullet.new(null, Vector2.new(7*18,72+18*3), Vector2.new(18,18), Vector3.new(0,0,0))}
        _random = random
        _statUpdatePending = false
        _onGround = false
        _jumpSfx = AudioSource.new(this, "game_data/sfx/Jump__009.wav",false)
        _ouchSfx = AudioSource.new(this, "game_data/sfx/Ouch__003.wav",false)
        var statNames = [
            // ["health", 3],
            ["speed", 4],
            ["jump power", 2],
            ["air jumps", 1],
        ]
        _dice = []
        for (i in 0...statNames.count) {
            var name = statNames[i][0]
            var val = statNames[i][1]
            var die = Dice.new(this, _random)
            die.transform.position.x = 25
            die.transform.position.y = 25 + i * 30
            die.value = val

            _textBox = TextBox.new(this, 100, 50, Vector2.new(0, 88 + 36 + i * 30), name)
            _textBox.transform.position.x = 35
            _textBox.transform.position.y = die.transform.position.y - 5
            _dice.add(die)
        }
        statUpdate()
    }

    tileMap=(val){_tileMap = val}

    update(deltaTime){
        var move = Input.getAxis2("move", 0)
        move.mulScalar(_speed * deltaTime)
        _vel.x = move.x
        _vel.y = _vel.y + _gravity * deltaTime
        if(_vel.y > 100) _vel.y = 100
        if(Input.getButtonPressed("jump", 0)) {
            var jumping = false
            if(_onGround){
                jumping = true
            } else if (_jumps > 0){
                jumping = true
                _jumps = _jumps - 1
            }
            if (jumping) {
                _vel.y = -_jumpSpeed * deltaTime
                _jumpSfx.play()
            }
        }
        if(Input.getButtonPressed("fire", 0)) {
            // _dice[2].value = _dice[2].value + 1
            // statUpdate()
            for (die in _dice) {
                die.roll()
            }
            _statUpdatePending = true
            // AudioSystem.playAudioSource(_audioHandle)
            // var bullet = _pool.get(this)
            // bullet.transform.position.x = transform.position.x
            // bullet.transform.position.y = transform.position.y
            // bullet.velocity.x = 400
        }
        if (_statUpdatePending){
            statUpdate()
        }
        if (_vel.x > 0){_sprite.hflip = true}
        if (_vel.x < 0){_sprite.hflip = false}
        var probe = transform.position.copy()
        probe.x = probe.x + 12
        probe.y = probe.y - 8
        var ladderProbe = transform.position.copy()
        ladderProbe.x = ladderProbe.x + 12
        ladderProbe.y = ladderProbe.y + 24
        var cell = _tileMap.getCellAtPosition(probe)
        var ladderCell = _tileMap.getCellAtPosition(ladderProbe)
        var old = _onGround
        _onGround = _vel.y >= 0 && _tileMap.solid(cell[0], cell[1] + 2)
        _onLadder = ladderCell[2] == 72
        // System.print(cell[2])
        if (_onGround) {
            _vel.y = 0
            _jumps = _maxJumps
        }
        if (_onLadder){
            _vel.y = move.y * _climbSpeed * deltaTime
            _jumps = _maxJumps
        }
        var newPos = _tileMap.collide(transform.position, _vel, 24, 24)
        transform.position = newPos
        super.update(deltaTime)
    }
    statUpdate(){
        var ready = true
        for(die in _dice){
            if (die.rolling) ready = false
        }
        if (ready){
            _speed = 50 * _dice[0].value
            var options = [0,200,250,300,325,340,375,]
            _jumpSpeed = options[_dice[1].value]
            _maxJumps = _dice[2].value
            _statUpdatePending = false
        }
    }
    hit(){
        _ouchSfx.play()
        for (die in _dice) {
            die.roll()
        }
        _statUpdatePending = true
        _manager.hit()
    }
    manager=(val){_manager = val}
}