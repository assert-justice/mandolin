import "engine" for Engine
import "node" for Node
import "input" for Input
import "renderer" for Renderer
import "vmath" for VMath, Vector2, Vector3
import "random" for Random
import "player" for Player
import "map_manager" for MapManager
import "fs" for FileSystem
import "json" for Json
import "tilemap" for TileMap

class Game is Node {
    loadJson(fname){
        if(!FileSystem.fileExists(fname)) Fiber.abort("no file found at '%(fname)'")
        return Json.parse(FileSystem.read(fname))
    }
    construct new(){
        super(null)
        var tracker = 0
        var fnames = [
            "game_data/sprites/characters_packed.png",
            "game_data/sprites/tiles_packed.png",
            "game_data/sprites/kenny_mini_square_mono_12x9.png",
        ]
        Renderer.blitFileToAtlas("game_data/sprites/characters_packed.png", 0, 0)
        Renderer.blitFileToAtlas("game_data/sprites/tiles_packed.png", 234, 0)
        Renderer.blitFileToAtlas("game_data/sprites/dice.png", 0, 72)
        Renderer.blitFileToAtlas("game_data/sprites/kenny_mini_square_mono_12x9.png", 0, 88)

        // load maps
        var tileMap = TileMap.new(this, 27, 15, 18, 18, 0, 234)
        var tileset = loadJson("game_data/map/tileset.json")
        var solid = {}
        for (tile in tileset["tiles"].where{|ent| ent["properties"].count > 0}) {
            solid[tile["id"]] = true
        }
        tileMap.addTemplate(1024-18,1024-18,false)
        for(i in 0...tileset["tilecount"]){
            var id = i
            var cellY = (id / 20).floor
            var cellX = id % 20
            tileMap.addTemplate(cellX * 18 + 234, cellY * 18, solid.containsKey(id))
        }

        _random = Random.new()
        _player = Player.new(null, _tileMap, _random)
        _player.transform.position.x = 4*18
        _player.transform.position.y = 2

        _mapManager = MapManager.new(this, _player, tileMap)
        _mapManager.addMap(loadJson("game_data/map/map.json"))

    }
    update(deltaTime){
        if(Input.getButtonPressed("ui_cancel", 0)){
            Engine.quit()
        }
        super.update(deltaTime)
    }
}