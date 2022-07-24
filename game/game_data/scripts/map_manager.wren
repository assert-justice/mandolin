import "tilemap" for TileMap
import "node" for Node
import "vmath" for Vector2, Vector3
import "pool" for Pool
import "goomba" for Goomba
import "slider" for Slider
import "text_box" for TextBox
import "audio_source" for AudioSource
import "checkpoint" for Checkpoint

class MapManager is Node {
    //
    construct new(parent, player, tileMap){
        // 
        super(parent)
        _tileMap = tileMap
        _player = player
        _player.manager = this
        _player.tileMap = _tileMap
        _rooms = {}
        _roomX = 0
        _roomY = 0
        _currentRoomIdx = 0
        _currentRoom = null
        _state = 0 // 0: idle, 1: clearing, 2: building
        _animTime = 0.001
        _animClock = 0
        _animX = 0
        _animY = 0
        _enemyPool = Pool.new(0){Goomba.new(this, _tileMap, player)}
        _sliderPool = Pool.new(0){Slider.new(this, _tileMap, player)}
        _checkpointPool = Pool.new(0){Checkpoint.new(this, this, player)}
        _aliveCheckpoints = []
        _activeEnemies = []
        _checkpointData = "0_1_100_100"
        _textBox = TextBox.new(this, 200, 100, Vector2.new(800, 200), "")
        _music = AudioSource.new(this,"game_data/music/cute_track.mp3",true)
        _winMusic = AudioSource.new(this,"game_data/music/victory_music.mp3",true)
        _music.looping = true
        _music.play()
    }

    setCheckpoint(data){
        _checkpointData = data
        for (checkpoint in _aliveCheckpoints) {
            checkpoint.active = data == checkpoint.getData()
        }
    }
    addMap(mapData){
        var tileLayer = mapData["layers"][0]
        var tileData = tileLayer["data"]
        var objectLayer = mapData["layers"][1]
        var mapWidthRooms = 4// (tileLayer["width"] / _tileMap.width).ceil
        var mapHeightRooms = 4// (tileLayer["height"] / _tileMap.height).ceil
        for(rx in 0...mapWidthRooms){
            for(ry in 0...mapHeightRooms){
                var room = {}
                var key = "%(rx)_%(ry)"
                var steps = []
                for(f in 0..._tileMap.height){
                    for(i in 0..._tileMap.width){
                        var cellX = rx * _tileMap.width + i
                        var cellY = ry * _tileMap.height + f
                        var idx = cellY * _tileMap.width * mapWidthRooms + cellX
                        var cellId = tileData[idx]
                        if(cellId != 0){
                            steps.add([cellId, i,f,1,1])
                        }
                    }
                }
                room["steps"] = steps
                _rooms[key] = room
            }
        }
        var spawnX = 0
        var spawnY = 0
        var spawned = false
        for (ent in objectLayer["objects"]){
            var x = ent["x"]
            var y = ent["y"]
            var roomWidth = _tileMap.width * 18
            var roomHeight = _tileMap.height * 18
            var rx = (x / roomWidth).floor
            var ry = (y / roomHeight).floor
            var name = ent["name"]
            if(name == "player_spawn"){
                spawnX = rx
                spawnY = ry
                _checkpointData = "%(rx)_%(ry)_%(x - rx * roomWidth)_%(y - ry * roomHeight)"
                System.print(_checkpointData)
                spawned = true
                continue
            }
            var key = "%(rx)_%(ry)"
            var room = _rooms[key]
            if (!room.containsKey("entities")) room["entities"] = []
            _rooms[key]["entities"].add([name, x - rx * roomWidth, y - ry * roomHeight,ent["type"]])
        }
        if(spawned) setRoom(spawnX, spawnY)
    }
    hit(){
        var data = _checkpointData.split("_").map{|n| Num.fromString(n)}.toList
        _player.transform.position.x = data[2].floor
        _player.transform.position.y = data[3].floor
        _player.update(0)
        setRoom(data[0], data[1])
    }
    setRoom(x, y){
        for (enemy in _activeEnemies) {
            enemy.transform.position.x = -100
            enemy.update(0)
            enemy.sleep()
        }
        _activeEnemies.clear()
        for (checkpoint in _aliveCheckpoints) {
            checkpoint.transform.position.x = -100
            checkpoint.update(0)
            checkpoint.sleep()
        }
        _aliveCheckpoints.clear()
        _roomX = x
        _roomY = y
        _currentRoomIdx = "%(x)_%(y)"
        _currentRoom = _rooms[_currentRoomIdx]
        _tileMap.clear()
        _tileMap.redraw()
        for(step in _currentRoom["steps"]){
            _tileMap.setArea(step[0],step[1],step[2],step[3],step[4])
        }
        _state = 2
        _player.setParent(null)
        _animX = 0
        _animY = 0
        _textBox.clear()
        if(_currentRoom["entities"]){
            for(ent in _currentRoom["entities"]){
                var name = ent[0]
                var x = ent[1]
                var y = ent[2]
                if(name == "goomba_spawner" || name == "thwump_spawner"){
                    var enemy = name == "goomba_spawner" ? _enemyPool.get(this) : _sliderPool.get(this)
                    _activeEnemies.add(enemy)
                    enemy.transform.position.x = x
                    enemy.transform.position.y = y
                    enemy.update(0)
                } else if(name == "win"){
                    _music.stop()
                    _winMusic.play()
                } else if(name == "text"){
                    _textBox.transform.position.x = x
                    _textBox.transform.position.y = y
                    _textBox.setText(ent[3].replace("~","\n"))
                } else if(name == "checkpoint"){
                    var checkpoint = _checkpointPool.get(this)
                    checkpoint.setRoom(_roomX, _roomY)
                    _aliveCheckpoints.add(checkpoint)
                    checkpoint.transform.position.x = x
                    checkpoint.transform.position.y = y - 18
                    checkpoint.update(0)
                }
            }
        }
    }
    lerp(a,b,t){
        return (b-a) * t + a
    }
    update(deltaTime){
        var door = null// [0,0,200,200]
        var maxX = _tileMap.width * 18
        var minX = 0
        var maxY = _tileMap.height * 18
        var minY = 0
        if(_player.transform.position.x > maxX - 12){
            door = [_roomX + 1, _roomY, _player.transform.position.x - maxX, _player.transform.position.y]
        } else if(_player.transform.position.y < minY - 24){
            door = [_roomX, _roomY - 1, _player.transform.position.x, _player.transform.position.y + maxY]
        } else if(_player.transform.position.x < minX - 12){
            door = [_roomX - 1, _roomY, _player.transform.position.x + maxX, _player.transform.position.y]
        } else if(_player.transform.position.y > maxY - 24){
            door = [_roomX, _roomY + 1, _player.transform.position.x, _player.transform.position.y - maxY]
        } else{
            door = null
        }
        if(door){
            setRoom(door[0],door[1])
            _player.transform.position.x = door[2]
            _player.transform.position.y = door[3]
            _player.update(0)
        }
        if(_state == 2){
            _animClock = _animClock - deltaTime
            if(_animClock < 0){
                _animClock = _animTime
                var placed = false
                var hack = false
                var time = deltaTime
                while(time > 0){
                    while(!placed){
                        var data = _tileMap.getCellData(_animX,_animY)
                        if(data && data[0] != 0){
                            placed = true
                            _tileMap.setTile(data[0],_animX,_animY)
                        }
                        _animX = _animX + 1
                        if(!_tileMap.onGrid(_animX, _animY)){
                            _animX = 0
                            _animY = _animY + 1
                            if(!_tileMap.onGrid(_animX, _animY)) {
                                placed = true
                                hack = true
                            }
                        }
                    }
                    time = time - _animTime
                }
                if(hack){
                    // if we are done drawing the map
                    _state = 0
                    _player.setParent(this)
                    for(enemy in _activeEnemies){
                        enemy.setParent(this)
                    }
                }
            }
        }
        super.update(deltaTime)
    }
}