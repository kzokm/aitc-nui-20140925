class @Vector2D
  constructor: (x, y)->
    if x? && !y?
      if x instanceof Array
        [x, y] = x
      else if x.x?
        {x, y} = x
      else if x.left?
        {left: x, top: y} = x
    @x = x || 0
    @y = y || 0

  _add: (other)->
    @x += other.x
    @y += other.y
    @

  add: (other)->
    new @constructor @
      ._add other

  _subtract: (other)->
    @x -= other.x
    @y -= other.y
    @

  subtract: (other)->
    new @constructor @
      ._subtract other

  _multiply: (scalar)->
    @x *= scalar
    @y *= scalar
    @

  multiply: (scalar)->
    new @constructor @
      ._multiply scalar

  _divide: (scalar)->
    @x /= scalar
    @y /= scalar
    @

  divide: (scalar)->
    new @constructor @
      ._divide scalar

  @sum: ->
    sum = new @
    for p in arguments
      sum._add p
    sum

  @average: ->
    @sum.apply @, arguments
      ._divide arguments.length

  innerProduct: (other)->
    @x * other.x + @y * other.y

  outerProduct: (other)->
    @x * other.y - @y * other.x


class @Vector3D extends Vector2D
  constructor: (x, y, z)->
    super x, y
    if x && !y?
      if x instanceof Array
        z = x[2]
      else if x.x?
        z = x.z
    @z = z || 0

  _add: (other)->
    @z += other.z
    super other

  _subtract: (other)->
    @z -= other.z
    super other

  _multiply: (scalar)->
    @z *= scalar
    super scalar

  _divide: (scalar)->
    @z /= scalar
    super scalar

  innerProduct: (other)->
    (super other) + @z * other.z

  outerProduct: (other)->
    new @constructor @y * other.z - @z * other.y,
      @z * other.x - @x * other.z,
      super other
