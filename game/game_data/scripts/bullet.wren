import "sprite" for Sprite
import "vmath" for Vector3, Vector2

class Bullet is Sprite{
    construct new(parent, offset, dimensions, velocity){
        super(parent, offset.x, offset.y, dimensions.x, dimensions.y)
        _velocity = velocity
    }
    velocity{_velocity}
    velocity=(val){_velocity = val}
    update(deltaTime){
        transform.position.addVector(_velocity.copy().mulScalar(deltaTime))
        if(transform.position.y > 400) sleep()
        if(transform.position.x > 400) sleep()
        super.update(deltaTime)
    }
}