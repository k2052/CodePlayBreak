local lgi = require('lgi')
local Gtk = lgi.require('Gtk')
local window = Gtk.Window({
  title = 'window',
  default_width = 400,
  default_height = 300,
  on_destroy = Gtk.main_quit
})
local toolbar = Gtk.Toolbar()
toolbar:insert(Gtk.ToolButton({
  stock_id = 'gtk-quit',
  on_clicked = function()
    return window:destroy()
  end
}), -1)
local vbox = Gtk.VBox()
vbox:pack_start(toolbar, false, false, 0)
vbox:pack_start(Gtk.Label({
  label = 'Contents'
}), true, true, 0)
window:add(vbox)
window:show_all()
return Gtk:main()
