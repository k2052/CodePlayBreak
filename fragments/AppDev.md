Before we dive into app dev on Linux lets setup a quality dev environemtn. I know most developers 
prefer to script things in Python. But I massively prefer Lua. I like to bend a scripting language to my
will and Lua is the only popular scripting language (with the exception of lisp) that is easy to modify.
If we run into issues we can morph it and extend it. 

It's possible to extend languages like python and ruby with c extensions but it's not easy. The C API
for Lua is damn easy to use. If we are looking for the best combination of flexibility, community and power
a Lua based app is the best way to go.

We can code any performance heavy parts in C and code up anything else Lua. Lua is even felxible enough that
it we can use a coffeescript like language to write, making things damn flexible. Will do the same with any C code at write it in "better C" a lang also known as VALA. Vala takes code that strongly resembles C# and Java and processes into C that uses GOBJECT.

So our final platform is Lua + Vala + GTK. Lets get started getting ourselves setup.

First Lua:

```sh
sudo apt-get install liblua5.1-0 
sudo apt-get install liblua5.1-dev
sudo apt-get install lua5.1 
```

Delight:
	Many many things in Ubuntu use Lua 5.1. Luarocks (the Lua package manager) has trouble running with two versions of Lua right now, so it's best to stick with it for now.
	At least during development we will stick with the most robust version.

Lets test our install by doing the following.

```sh
lua -v
```

We should get back.

```sh
Lua 5.1.5  Copyright (C) 1994-2012 Lua.org, PUC-Rio
```

Lets write a quick hello world to see if things are working.

```lua
#!/usr/bin/lua

print("Hello World!")
```

Put this in a file named helloworld.lua. Then run it using:

```sh
lua helloworld.lua
```

You should get back:

```sh
Hello World!
```

Now we need LuaRocks the package management system for Lua:

```sh
sudo apt-get install luarocks
```

Now we need lgi the bindings for lug to gtk. To get these we first need to install gobject-introspection.
GOBJECt is GTKs' object handling system. It brings object oriented programming to C.

```sh
sudo apt-get install gobject-introspection
sudo apt-get install libgirepository1.0-dev
```

Delight:
	gobject-introspeciton is often abbreviated as `gir` in the repositories. Searching for both will help
	find stuff. 

```sh
sudo luarocks install lgi
```

Lua is kinda an ugly language but thankfully there is moonscript. Which is basically coffeescript for Lua.

Now let us get moonscript.

```sh
sudo luarocks install moonscript
```

Lets test it. Create a new file called helloworld.moon:

```moonscript
print "Hello World!"
```

Then run:

```sh
moon helloworld.moon
```

Delight:
	You can leave out the extension when passing files to moon:

	```sh
	moon helloworld
	```

As with the helloworld.lua example you should get back `Hello World!`

Delight:
   
  If you get something about lpeg.so this is paths conflict caused by two versions of lua.
  The error will look a little like it:

	```sh
	lpeg.so: undefined symbol: lua_tointeger
	stack traceback
	```

	Uninstall one of the versions of Lua, it's a good bet that the one you should uninstall 
	is 5.2. Too many popular packages use Lua 5.1 (Rhythm box and vlc) so you're best off 
	using 5.1 and removing 5.2

Before we move one lets get some syntax highlighting in our editor.

```sh
cd '~/.config/sublime-text-2/Packages'
git clone https://github.com/ecornell/Sublime-MoonScript.git MoonScript
```

## A brief introduction to Moonscript

Moonscript is mostly easy to understand just like Coffeescript is easy to understand 
if you know JS. Moonscript is just a fancy easier to use version of Lua. I'll skip
most parts and just go over the critical bits.

## Assignment

To do assignment skip local e.g:

Moonscript

```moonscript
hello = "Hello World"
a,b,c = 1, 2, 3
hello = 123
```

Lua

```lu
local hello = "Hello World world"
local a, b, c = 1, 2, 3
hello = 123
```

## Tables

Unlike Lua, assigning a value to a key in a table is done with : (instead of =).

MoonScript

```moonscript
cat = {
  name: "Luis",
  age: 200, -- in cat years
  likes: 'modifying the pump on washers, for efficiency',
  gods: {'self'},
  owner: 'rick'
}
```

Lua

```lua
local cat = {
  name = "Luis",
  age = 200,
  likes = 'modifying the pump on washers, for efficiency',
  gods = {
    'self'
  },
  owner = 'rick'
}
```

## Methods

Access methods of a class using a `\` e.g

Moonscript
```moonscript
class Maniac
	add_gun: (gun) ->
		table.insert @armory, gun

man = Maniac!
man\add_gun "bazooka"
```
	
Lua
```lua
-- class handling here...
local man = Maniac()
return man:add_gun("bazooka")
```

The `\` is necessary to determine the method name. If you familiar with Lua you
know classes are implemented via metatables (like overloading methods). Any failed attempt
to lookup a function will be passed to index, which can look up the function in the table.
Class functions are actually defined as part of a scoped table. See http://lua-users.org/wiki/SimpleLuaClasses if you're confused.

Delight:
	When passing a new object into a method be careful to close the parenthesis.
	Here is what I mean.

	```moonscript
	toolbar:insert(Gtk.ToolButton{
		stock_id: 'gtk-quit'
		on_clicked: -> 
			window\destroy()
	}, -1)
	```

	Will fail. EXPLAIN why it fails here. The problem Moonscript doesn't close the call to Gtk.ToolButton. Change it to this:

	```moonscript
	toolbar:insert(Gtk.ToolButton({
		stock_id: 'gtk-quit'
		on_clicked: -> 
			window\destroy()
	}), -1)
	```

	Now all is well. 

Now that we installed lets do some classic hello worlds. First in GTK and then in clutter.

## GTK Hello World

First create the file:

```sh
touch helloworld.gtk.moon
```

Lets load the required files:

```moonscript
lgi = require 'lgi'
Gtk = lgi.require 'Gtk'
```

Now lets add our window:

```moonscript
window = Gtk.Window{
	title:           'window'
	default_width:   400
	default_height:  300
	on_destroy:      Gtk.main_quit
}
```
Now what else do we need to make this work? We need a button to close the window and some code to handle it.

```moonscript
toolbar = Gtk.Toolbar!
toolbar\insert(Gtk.ToolButton({
	stock_id: 'gtk-quit'
	on_clicked: -> 
		window\destroy()
}), -1)
```
Now we have to add that button to do this we will need a view. Lets use a vbox:

```moonscript
vbox = Gtk.VBox!
vbox\pack_start(toolbar, false, false, 0)
vbox\pack_start(Gtk.Label({label: 'Contents'}), true, true, 0)
window\add(vbox)
```

Finally we need to show the window and start the main event loop:

```moonscript
window\show_all()
Gtk\main()
```

You might be wondering what is 

```moonscript
Gtk\main()
```

It's a main event loop. A main event loop is typically in pretty much all modern app frameworks. What a loop does is sit and wait for events, looping endlessly, all the while watching like a creepy neighbor, until the app is killed. Don't worry, only the stupid jock app is killed, all the smart cute ones survive until the end when they get the cute adorkable girl played by Kirsten Dunst. Manic App Girl.

People forget that nothing is truly event driven. An event oriented language at it's core is just a language designed with a endlessly running loop at its heart. This is interesting as many Applications when courting another applications say "You make event loop go woop woop." or "I feel you in my event loop." or "I want to share your events.". 
The sign of a declining relationship between two apps is when they're take their event sharing for granted.

Just remember these two things;

1. That all click events first bubble through the main event loop, which passes them off on down until they trigger the event on relevant elements.
2. You need to destroy the main event loop when destroying the app. If you don't then your memories will leak all over the OS like an Alzheimer's patient telling stories.
Destroy the main event loop in GTK looks like this: 

```moonscript
window = Gtk.Window{
	on_destroy:      Gtk.main_quit
}
```

Define: 
	Destory verb;
		1. To destroy a story
		2. The dyslexic version of 'destroy'

Live your life like a Blue Macaw. Keep the things you love up high, swoop down on the things you hate, show the world how colorful you are, ride tennis balls, make cool sound effects.

