Lets define the app we are creating. We want to take a SVG and display it. Thats it. Not bad
for our first app right? Wait till the world sees this! Riches and fame here we come!

Will need two parts a window (the app container) and a surface to display the SVG. Then a button
to load said SVG. Lets get started.

First up the window:

To declare a window we need to inherit from Gtk.Window
```vala
class ViewWindow : Gtk.Window
{
}
```

We need a main function which initiliazes the window

```vala
public static int main(string[] args) 
{
  Gtk.init(ref args);
  new ViewWindow();
  Gtk.main();

  return 0;
}
```

A destroy function which closes the window when we quit the app (will rely on default stop lights stuff for now
no other closing button):

```vala
public override void destroy() 
{
  Gtk.main_quit();
}
```

We need to actually show our window, which we can do in the constructor:

```vala
public ViewWindow() 
{
  set_title("View SVG Window");
  show_all();
}
```

The complete code then looks like this:

```vala
class ViewWindow : Gtk.Window
{
  public ViewWindow() 
  {
    set_title("View SVG Window");
    show_all();
  }

  public override void destroy() 
  {
    Gtk.main_quit();
  }

  public static int main(string[] args) 
  {
    Gtk.init(ref args);
    new ViewWindow();
    Gtk.main();

    return 0;
  }
}
```

Lets compile that and get it running:

```sh 
valac ViewWindow.vala
```
We are going to get some errors back:

```sh
ViewWindow.vala:1.20-1.22: error: The symbol `Gtk' could not be found
class ViewWindow : Gtk.Window
                   ^^^
Compilation failed: 1 error(s), 0 warning(s)
```

What is happening here? Well, we don't have gtk available. Lets make it available. We do this through 
`--pkg` switches passed to valac.

Delight: 
	You may be asking yourself two questions; 1. What is the speed of an unladen penguin? and 2. How do I manage these pkg
	switches in a real world project. The answer is Autotools. Place your config in Autotools file and voila just 
	pressing ./configure and make and things will be built. See the chapter on Autotools for more details.

So to compile we do this:

```sh
valac ViewWindow.vala --pkg gtk+-3.0
```

Delight:
	If you get an error like 

	```sh
	error: gtk+-3.0 not found in specified Vala API directories or GObject-Introspection GIR directories
	```

	Your Vala version might be out of date. Check by running:

	```sh
	valac --version
	```

	```sh
	fatal error: gtk/gtk.h: No such file or directory
	```

	Might need to install dev packages for gtk.
  
  ```sh
	sudo apt-get install libgtk-3-dev
	```

Then run using:

```sh
./ViewWindow
```

Awesome huh? So now we need a view to display our SVGs. Lets create the class first: 

```vala
class SVGView : Gtk.DrawingArea
{
}
```

We have inherited from Gtk.DrawingArea which is a widget for custom drawing areas. What exactly can
we do with this? And more importantly, what do we want to do with it?

The DrawingArea widget is a blank canvas for drawing shit and it's backed by Cario. The key thing 
to understand is that this is a widget which means it will respond to widget API standard.
Like a Rack app has `app.call(env)` or http has `GET` and `POST`. So what is the API of Gtk widget then?

It's quite simple and you may have even anticipated it, if not your about to hit your head like Curly hits Moe.
All widgets respond to a draw method and to override the custom draw we override the draw method.

Delight:
  Methods that can be overridden are called virtual methods. This naming convention takes it's
  conventionism from the 1980's hilt film Tron a film about a stolen trophy wife. When Kevin
  Flynn is mistaken for a billionaire software developer he is sucked into a computer world
  where he must battle it out with virtual foes in the thunderdome while riding jet skis, as the 
  virtual world has become indudidted with water because of recently invented water cooling.
  When one over-rides a jets ski it is said to be virtual, as physical jets skis when 
  over-ridden break. 

  Okay, I made that all up. Virtual can also mean "as nearly described" not just something digital.
  Words are a funny thing, said The Dude.

So to get something going we are going to have override the draw method.
Now before you rush off into the great wide open and say try the following:

```vala
class SVGView : Gtk.DrawingArea
{
  public bool draw() 
  {
  }
}
```

We need to learn about the override keyword in Vala. Any function we override in Vala needs the override keyword
so like this:

```val
public override bool draw() 
{
}
```

But why does Vala need this, the curious human asks. Well, curious human, there is a reason.
Lets discover it together. We need to remember that Vala is just a preprocessor for C code. And 
to override methods in a GObject we have to tell Gobject. It looks like this:

```c
static void
maman_derived_ibaz_do_action (MamanIbaz *ibaz)
{
  MamanDerivedBaz *self = MAMAN_DERIVED_BAZ (ibaz);
  g_print ("DerivedBaz implementation of Ibaz interface Action\n");
}

static void
maman_derived_ibaz_interface_init (MamanIbazInterface *iface)
{
  /* Override the implementation of do_action */
  iface->do_action = maman_derived_ibaz_do_action;

  /*
   * We simply leave iface->do_something alone, it is already set to the
   * base class implementation.
   */
}

G_DEFINE_TYPE_WITH_CODE (MamanDerivedBaz, maman_derived_baz, MAMAN_TYPE_BAZ,
                         G_IMPLEMENT_INTERFACE (MAMAN_TYPE_IBAZ,
                                                maman_derived_ibaz_interface_init)

static void
maman_derived_baz_class_init (MamanDerivedBazClass *klass)
{

}

static void
maman_derived_baz_init (MamanDerivedBaz *self)
{

}
```

Code example taken from: https://developer.gnome.org/gobject/stable/howto-interface-override.html
As you can see a lot of extra stuff goes into an override so Vala needs some way to know to generate it.
The above might not be so clear so lets see what happens when we generate some code with and without an
override.

Save the following:

```vala
class SVGView : Gtk.DrawingArea
{
  public bool draw() 
  {
  }
}
```

When we run 

```sh
valac -C --pkg gtk+-3.0 NoOverrideOverride.vala
```

We will get back the following errors and warnings:

```sh
NoOverrideOverride.vala:3.3-3.18: warning: SVGView.draw hides inherited method `Gtk.Widget.draw'. Use the `new' keyword if hiding was intentional
  public bool draw() 
  ^^^^^^^^^^^^^^^^
NoOverrideOverride.vala:3.3-3.18: warning: method `SVGView.draw' never used
  public bool draw() 
  ^^^^^^^^^^^^^^^^
NoOverrideOverride.vala:3.3-3.18: error: missing return statement at end of subroutine body
  public bool draw() 
  ^^^^^^^^^^^^^^^^
Compilation failed: 1 error(s), 2 warning(s)
```

The first one warns us that we are not correctly overriding the method. The next two tell us to fix the
method. First the lets fix the error by making sure we return something:

```vala
class SVGView : Gtk.DrawingArea
{
  public bool draw() 
  {
    return false;
  }
}
```

Compile again and you should only get some warnings and it should compile. Lets look at the C file:

```c
gboolean svg_view_draw (SVGView* self);

gboolean svg_view_draw (SVGView* self) {
  gboolean result = FALSE;
  g_return_val_if_fail (self != NULL, FALSE);
  result = FALSE;
  return result;
}
```

Just a simple method definition. Now what happens if we add a new keyword as the warning suggested?
Lets try it:

```vala
class SVGView : Gtk.DrawingArea
{
  public new bool draw() 
  {
    return false;
  }
}
```

Now save and run:

```sh
valac -C --pkg gtk+-3.0 NewKeywordMethod.vala
```

Looking at the C file something strange is revealed. Nothing has changed! Apparently the new keyword just 
tells valac stuff so it doesn't throw up.

This brings us to the override keyword:

```vala
class SVGView : Gtk.DrawingArea
{
  public override bool draw() 
  {
    return false;
  }
}
```

Now save and run:

```sh
valac -C --pkg gtk+-3.0 OverrideKeywordMethod.vala
```

Now we get something a little confusing back:

```sh
OverrideKeywordMethod.vala:3.3-3.27: error: overriding method `SVGView.draw' is incompatible with base method `Gtk.Widget.draw': too few parameters.
  public override bool draw() 
  ^^^^^^^^^^^^^^^^^^^^^^^^^
OverrideKeywordMethod.vala:3.3-3.27: error: SVGView.draw: no suitable method found to override
  public override bool draw() 
  ^^^^^^^^^^^^^^^^^^^^^^^^^
Compilation failed: 2 error(s), 0 warning(s)
```

This is telling us the signature for our method is wrong. Incompatible with what it is overriding. So what should it look like. Lets see what the docs for Gtk.DrawingArea says:

```apidoc
void                gtk_widget_draw                     (GtkWidget *widget,
                                                         cairo_t *cr);
```

So it expect two params. Lets tranlate this into Vala. First remember that all GObject functions 
take themselves as the first argument. The second param will always be the first in Vala.
Lets try the following then:

```val
class SVGView : Gtk.DrawingArea
{
  public override bool draw(cairo_t ctx)  
  {
    return false;
  }
}
```

And we get back:

```sh
OverrideKeywordMethod.vala:3.28-3.34: error: The type name `cairo_t' could not be found
  public override bool draw(cairo_t ctx)  
                            ^^^^^^^
Compilation failed: 1 error(s), 0 warning(s)
```

Seems cario_t is a C thing. We need to figure what is in Vala.  First lets figure out what the hell
`cario_t` is. Turns out after some googling that cairomm is what the GoBject version of cario. 
So if we utlize the same cario_t docs where cairo_t is defined the main context for drawing, we
discover that Cairo::Context is the equivalent.

Which leaves us with the following:

```vala
class SVGView : Gtk.DrawingArea
{                          
  public override bool draw(Cairo.Context ctx)  
  {
    return false;
  }
}
```

Compilation should now return no errors. Now returning to our original mission, lets figure out what the 
override did. Take a look at the generated C code:

```c
static gboolean svg_view_real_draw (GtkWidget* base, cairo_t* ctx);

static gboolean svg_view_real_draw (GtkWidget* base, cairo_t* ctx) {
  SVGView * self;
  gboolean result = FALSE;
  self = (SVGView*) base;
  g_return_val_if_fail (ctx != NULL, FALSE);
  result = FALSE;
  return result;
}
```

We now have two extra things occurring; 

1. Our method is now abbreviated with `real_`. This is a convention gobject uses to 
extrapolate the chain of overridden methods a

2. We set self to point to the base. Which I imagine is the parent class. This means we end up
calling the methods in the chain. i.e super() gets called before our method. Magic.

Now we understand a bit more of the workings we can continue onward. 
We need to somehow draw when enter this method, to actually display our SVG.
To do this we are going to need a Cario surface upon which we can draw things, and widgets, gadgets,
all the little mermaid collections really. Anything we can sing, we can draw.

How do we create a surface? This is pretty easy and mirrors the C++ (mm.cario) for Cario:

~~~ c++
static RefPtr<ImageSurface> Cairo::ImageSurface::create   (   unsigned char *   data,
    Format    format,
    int   width,
    int   height,
    int   stride   
  )       [static]
~~~

So to create it using Vala we do the following:

~~~ c++
surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, 400, 300);
~~~


Now we need to somehow and add this surface to our Cario contaxt object. We do this by setting the source
surface to our surface and then calling paint on the cairo context:

~~~ vala
surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, 400, 300);

ctx.set_source_surface(surface, 0, 0);
ctx.clip();
ctx.paint();
~~~

Now we aren't nearly done we need to load an svg first, add it to the surface, and then display it.
The contexts should handle everything automatically, when we render the svg to the surface it should be reflected in the display; rendering should just be a matter of loading the SVG onto the surface. To load svgs on a cario surface we have to use librsvg.

Lets start with an svg handler:

~~~ vala
handle = new Rsvg.Handle.from_file('./svgs/test.svg');
~~~

This will allow us to handle our svg and do things with it, while keeping a handle on it.
What we want to do, and I know this sounds bad, is render it. Don't worry it doesn't hurt the svg
and is complete painless: Lets do it:

~~~ vala
handle.render_cairo(ctx);
~~~

Our class now looks like: 

~~~ vala
class SVGView : Gtk.DrawingArea
{                          
  public override bool draw(Cairo.Context ctx)  
  {
    surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, 400, 300);

    ctx.set_source_surface(surface, 0, 0);
    ctx.clip();
    ctx.paint();

    handle = new Rsvg.Handle.from_file('./svgs/test.svg');
    handle.render_cairo(ctx);
    
    return false;
  }
}
~~~

We need to do one last thing, modify the ViewWindow class so it uses svg view:

~~~ vala
public ViewWindow() 
{
  set_title("View SVG Window");
  add(new SVGView());
  show_all();
}
~~~

Theoretically we should be done, but experience tells me everything will blow up. Lets compile it though
and see what happens:

~~~ sh
valac SVGView.vala ViewWindow.vala --pkg librsvg-2.0 --pkg gtk+-3.0
~~~

We get an error back:

~~~ sh
SVGView.vala:11.41-11.41: error: invalid character literal
    handle = new Rsvg.Handle.from_file('./svgs/test.svg');
~~~

This is telling us that we need to use double quotes for the filename. To fix change line 11 to:

~~~ vala
handle = new Rsvg.Handle.from_file("./svgs/test.svg");
~~~

Compiling again returns four errors the first one is:

~~~ sh
SVGView.vala:5.3-5.9: error: The name `surface' does not exist in the context of `SVGView.draw'
    surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, 400, 300);
    ^^^^^^^
~~~

This is warning us that we haven't actually defined these objects yet. We could need to define their type when declaring them just like C code:

~~~ vala
Cairo.ImageSurface surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, 400, 300);
Rsvg.Handle handle = new Rsvg.Handle.from_file("./svgs/test.svg");
~~~

The function now looks like:

~~~ vala
public override bool draw(Cairo.Context ctx)  
{
  Cairo.ImageSurface surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, 400, 300);

  ctx.set_source_surface(surface, 0, 0);

  Rsvg.Handle handle = new Rsvg.Handle.from_file("./svgs/test.svg");
  handle.render_cairo(ctx);

  return false;
}
~~~

Delight:
  If you get:

  ~~~ sh
  Fatal error: librsvg/rsvg.h: No such file or directory
  ~~~

  Make sure to inst libsrvg:

  ~~~ sh
  sudo apt-get install gir1.2-rsvg-2.0  librsvg2-dev librsvg2-bin
  ~~~

We now get:

~~~ sh
valac SVGView.vala ViewWindow.vala --pkg librsvg-2.0 --pkg gtk+-3.0
SVGView.vala:11.24-11.67: warning: unhandled error `GLib.Error'
    Rsvg.Handle handle = new Rsvg.Handle.from_file("./svgs/test.svg");
~~~

THis is a problem in the vapi files and can only be fixed with a fork. A soluton should appea by the fitm this is published.

Run it:

~~~ sh
./SVGView
~~~

Now we get:

IMAGE HERE
