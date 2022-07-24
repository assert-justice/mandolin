

class CollisionSystem {
    construct new(){
        _groups = {}
    }
    addGroup(name){
        _groups[name] = []
    }
    getGroup(name){_groups[name]}
    static boxCollide(x1,y1,w1,h1, x2,y2,w2,h2){
        return x1 < x2 + w2 && x1 + w1 > x2 && y1 < y2 + h2 && y1 + h1 > y2
    }
}