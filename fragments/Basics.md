Vala is to C what Coffeescript is to Javascript. Of course to achieve this sort of preprocessor thing on
a C base we need some extra C code. Vala is thus built on GObject, Vala
code is process into C code using GObject.

Lets install it:

```sh
sudo apt-get install valac-0.18 
sudo apt-get install valac-0.18-dbg 
sudo apt-get install valac-0.18-vapi
```

Delight:
	Always make sure you get the latest valac. You can install via 

	```sh
	sudo apt-get install valac
	```
	and then check version using:

	```sh
	valac --version
	```

	Then search search the repos to see if there is a newer versions

	```sh
	apt-cache search valac
	```

Lets create a helloworld example

```vala
class HelloWorld : GLib.Object 
{
	public static int main(string[] args) 
	{
		stdout.printf("Hello, World\n");

		return 0;
	}
}
```

stdout.printf is a call to the internal libraries.

Before we move forward it's important to understand the basics of how Gobject works.
Gobject achieves it's magic through two means preprocessor magic and naming conventions.
You end up abbreviating all the function names with a classname eg.

```c
void log_add_message (Log* log, gchar* message)
{
	// Do things
}
```

So essentially you end up passing your instances everywhere. What Vala does is get rid of all that extra typing
and wrap it a cleaner structure. Lets take  look at this further by turning our vala into C code:

```sh
valac helloworld.vala -C
```

Lets look at the generated constructor 

```c
HelloWorld* hello_world_construct (GType object_type) {
	HelloWorld * self = NULL;
	self = (HelloWorld*) g_object_new (object_type, NULL);
	return self;
}
```

The first thing we notice is Vala has generated a struct for our class.

```c
#define TYPE_HELLO_WORLD (hello_world_get_type ())
#define HELLO_WORLD(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_HELLO_WORLD, HelloWorld))
#define HELLO_WORLD_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_HELLO_WORLD, HelloWorldClass))
#define IS_HELLO_WORLD(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_HELLO_WORLD))
#define IS_HELLO_WORLD_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_HELLO_WORLD))
#define HELLO_WORLD_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_HELLO_WORLD, HelloWorldClass))

typedef struct _HelloWorld HelloWorld;
typedef struct _HelloWorldClass HelloWorldClass;
typedef struct _HelloWorldPrivate HelloWorldPrivate;

struct _HelloWorld {
	GObject parent_instance;
	HelloWorldPrivate * priv;
};

struct _HelloWorldClass {
	GObjectClass parent_class;
};
```

There is a construct for both the instance and the static class. This means that instance methods 
will expect an HelloWorld type and our static methods will expect an HelloWorldClass:

```c
static void hello_world_class_init (HelloWorldClass * klass) {
	hello_world_parent_class = g_type_class_peek_parent (klass);
}

static void hello_world_instance_init (HelloWorld * self) {
}
```

Getting it now? I sure am. Lets continue onwards. First of all lets figure out this main crap. How does Vala know to use our main? If we define multiple mains in classes then what happens man?
The documentation is a bit difficult to find soe lets do some tests.
First can we define main outside of a class?

```vala
int main(string[] args) 
{
	stdout.printf("Hello, World\n");

	return 0;
}
```

```sh
valac -C mainoutsideofclass.vala
```

It seems it's smart enough to abbreviate any conflicting function names with _vala:

```c
gint _vala_main (gchar** args, int args_length1);

gint _vala_main (gchar** args, int args_length1) {
	gint result = 0;
	FILE* _tmp0_;
	_tmp0_ = stdout;
	fprintf (_tmp0_, "Hello, World\n");
	result = 0;
	return result;
}

int main (int argc, char ** argv) {
	g_type_init ();
	return _vala_main (argv, argc);
}
```

So what happens if we define a main method in two classes?

```vala
class HelloWorld : GLib.Object 
{
	public static int main(string[] args) 
	{
		stdout.printf("Hello, World\n");

		return 0;
	}
}

class BunnyWorld : GLib.Object 
{
	public static int main(string[] args) 
	{
		stdout.printf("Hello, World\n");

		return 0;
	}
}
```

Compile:

```sh
valac -C maintwoclasses.vala
```

And the answer is you can only have one main:

```sh
maintwoclasses.vala:13.2-13.23: error: program already has an entry point `HelloWorld.main'
	public static int main(string[] args) 
	^^^^^^^^^^^^^^^^^^^^^^
Compilation failed: 1 error(s), 0 warning(s)
```

So that takes of that. I imagine we can get creative with our main.

So from here where do go? Well we need to know all the basics to get things done. Lets start with 
constructors. You define the constructor by defining a method name with the same as your class:

public class Cat : GLib.Object 
{
	/* Fields */
	private int hairball_count = 0;

	/* Constructor */
	public TestClass() 
	{
		this.hairball_count = 5;
	}

	/* Method */
	public int getHairBallCount() 
	{
		return this.hairball_count;
	}
}
```

Use `new` to create a new instance:

```vala
cat t = new Cat();
```

Accessing methods look like this:

```vala
t.getHairBallCount();
```

## Comments

Vala supports the comment styles you might exepect

```vala
// One line comment

/* Delimiter comment */

/**
 * Doc block
 */
```

## Control Structures

In addition to the expected for loop Vala has a foreach:

```vala
foreach (int a in int_array) { stdout.printf("%d\n", a); }
```
## Anonymous Methods

```vala
(a) => { stdout.printf("%d\n", a); }
```

## Namespaces

```vala
using GLib;
```

## Interpreting Gobject stuff.

## Compiling

There is no such thing as require in Vala. You'll have to pass each file in the correct order to the compiler.
