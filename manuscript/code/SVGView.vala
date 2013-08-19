class SVGView : Gtk.DrawingArea
{                          
	public override bool draw(Cairo.Context ctx)  
	{
		Cairo.ImageSurface surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, 400, 300);

		ctx.set_source_surface(surface, 0, 0);

		Rsvg.Handle handle = new Rsvg.Handle.from_file("./svgs/test.svg");
    handle.render_cairo(ctx);

    return false;
  }
}
