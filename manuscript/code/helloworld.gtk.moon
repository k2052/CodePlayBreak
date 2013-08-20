--
-- Sample GTK Hello program
--
-- Based on test from LuiGI code. Thanks Adrian!
--

lgi = require 'lgi'
Gtk = lgi.require 'Gtk'

window = Gtk.Window{
	title:           'window'
	default_width:   400
	default_height:  300
	on_destroy:      Gtk.main_quit
}

toolbar = Gtk.Toolbar!
toolbar\insert(Gtk.ToolButton({
	stock_id: 'gtk-quit'
	on_clicked: -> 
		window\destroy()
}), -1)

vbox = Gtk.VBox!
vbox\pack_start(toolbar, false, false, 0)
vbox\pack_start(Gtk.Label({label: 'Contents'}), true, true, 0)
window\add(vbox)

window\show_all()
Gtk\main()
