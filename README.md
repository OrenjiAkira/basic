
# basic
A basic lua library for games. Contains many common data structures, like simple stacks and queues, and even a rectangle collision module.

## How to use
Well, you can clone it inside your project folder
and use any module in it by `require`.

Example:
```lua
-- let's say you need the vector module
local vector = require "basic.vector"

-- instancing the vector
local a = vector:new { 10, 20 }
```

Easy, right? I implemented a OOP-like code in the `prototype` module,
so many of these modules will need it to work.

There is a catch, though: the directory `basic` should be
directly inside the main directory of your running lua project.

For instance, let's say we are using [Love2D](https://love2d.org/).
A Love2D project's main directory is the one that holds the `main.lua` file.
So, your project's directory organisation should look somewhat like this:

```
/
  basic/
  main.lua
  conf.lua
  otherfile.lua
```

The important thing is that the `require` function should be able to get
any module from `basic` simply by receiving `basic.modulename` as its argument.

## Modules

So far, there are the following modules in this library:

### Classes

**prototype**  
Prototype class. Every class from this library inherits from this.
You can create your own classes based on `prototype` too. Just create
an instance of prototype using `prototype:new()` and pass it a table
with default values for your class. This will return your new class.
You can make an instance of it with the `new` method, the same way
you did with the `prototype` class. Just don't overwrite the `new` method,
or else any other instancing will stop working.

There are some magic methods you can define, though. The `__init()` method
is a constructor method, and it runs every time you call the `new` method.
It is called recursively, so it will run from top to bottom all constructors
of the classes the instanced object inherits from.

You can check the code to understand how it works. Also take a look at
[pil](http://www.lua.org/pil/13.html)'s metatable documentation.

**vector**  
Probably one of the most useful classes. It creates a 3D vector
(which can be used as a 2D vector without problem). It can handle
basic math operations (sum, subtraction, multiplication), both by
copy and without changing reference.

**matrix**  
Pretty useful. It even has an iterator of its own.

**stack**  
Well, duhh. Stacks things

**queue**  
Well, duhh (2). The queue is circular, and so
you should define an appropriate buffer size.

**rectangle**  
A rectangle. It has position and size.
Good for collisions and for map generation.

**signal**  
When you want a single signal to execute several
actions of different scopes, signal is your friend!
You register a listener to one or more functions, and emit the
signal when you want the function(s) called.

**timer**  
Great but needs steady FPS. Also, it uses coroutines, so try
to avoid creating an indefinite repeat timer to create other
coroutines, as that might explode your computer's memory.

### Special Classes
**physics**  
Not a class, just a table singleton.
It manages bodies, maps, and their collisions for you. Currently only
uses rectangles as shapes. This is the only module you should `require`
when using physics. It can create maps and bodies for you, and when
you use its creating methods it adds the objects to its management
lists so it can take care of collision and movement.

**map**  
Inherits from `prototype`.

**collision_object**  
Inherits from `prototype`.

**dynamic_body**  
Inherits from `collision_object`.

### Utility

**pack**  
Packs a folder to easily access all lua modules in it.
It won't hold the modules unless you call them.

**iterate**  
Contains some iterating functions. Can be useful.

**dice**  
Can simulate a dice. It uses the Lua's standard `math.random` function.
If you want, you can change it by changing the `dice.random` value to point
to your stronger pseudorandom number generation function.

**io**  
This is just a table-serialisation function and a writing-to-file function.

**logarithm**  
Contains the `logn` function. Use it for logarithm operations
in bases different from _e_ and 10.

**pool**  
Just some table insert and remove functions.
Does not preserve order but is more efficient.

**tableutility**  
Adds some utilities for Lua 5.1. Namely, it adds the `table.pack`,
`table.find`, and `table.copy` functions to the standard `table` module.

**unique**  
Just an id generator that will give you a different number every time!
...unless you manage to go over the maximum float value, which is insanely high.
