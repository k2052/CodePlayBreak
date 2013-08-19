class ViewWindow : Gtk.Window
{
  public ViewWindow() 
  {
    set_title("View SVG Window");
    add(new SVGView());
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

