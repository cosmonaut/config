-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
require("lib/mpd")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
-- The default is a dark theme
theme_path =  "/home/tron/.config/awesome/theme"
-- Uncommment this for a lighter theme
-- theme_path = "/usr/share/awesome/themes/sky/theme"

-- Actually load theme
beautiful.init(theme_path)

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}

-- Table of clients that should be set floating. The index may be either
-- the application class or instance. The instance is useful when running
-- a console app in a terminal like (Music on Console)
--    xterm -name mocp -e mocp
floatapps =
{
    -- by class
    ["MPlayer"] = true,
    ["pinentry"] = true,
    ["gimp"] = true,
    ["Gran Paradiso"] = true,
    ["tuxnes"] = true,
    ["feh"] = true,
    ["wireshark"] = true,
    -- by instance
    ["mocp"] = true
}

-- Applications to be moved to a pre-defined tag by class or instance.
-- Use the screen and tags indices.
apptags =
{
    -- ["Firefox"] = { screen = 1, tag = 2 },
    -- ["mocp"] = { screen = 2, tag = 4 },
}

-- Define if we want to use titlebar on all applications.
use_titlebar = false
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
   tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, awful.layout.suit.tile)
    --tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu,
                                     layout = awful.widget.layout.rightleft })
-- }}}


-- {{{ Wibox
-- Create a textbox widget

-- COSMONAUT WIDGETS
clockwi = widget({ type = "textbox", align = "right" })
-- Set the default text in textbox
clockwi.text = " " .. "FORTRAN!" .. " "
clockformat = "%a, %b %d %I:%M %p"

--debug
--debugwi = widget({ type = "textbox", align = "right" })


-- MPD
mpdwi = widget({ type = "textbox", align = "right" })
mpdwi.text = "applesauce"
mpdwi.width = 300

--srv = mpd.new()
srv = mpd.new()
mpc = { current = function (self) return srv end,
        srv = srv }

function read_mpd()
   local function timeformat(t)
      if tonumber(t) >= 60 * 60 then -- more than one hour!
         return os.date("%X", t)
      else
         return os.date("%M:%S", t)
      end
   end

   local function unknowize(x)
      return awful.util.escape(x or "(unknow)")
   end

   local function iunknowize(x)
      return italic(unknowize(x))
   end

   local now_playing, status, total_time, current_time, radio
   local where = string.format("MPD (%s)", unknowize(mpc:current().desc))
   local status = mpc:current():send("status")

   if status.errormsg then
      return widget_base(widget_section(where, status.errormsg));
   end

   if status.state == "stop" then
      mpc.last_songid = nil
      mpdwi.text = "stopped"
      return widget_base(widget_section(where, "stopped."))
   end

   local zstats = mpc:current():send("playlistid " .. status.songid)

   if zstats.name then
      radio = true
      now_playing = unknowize(zstats.name)
   else
      radio = false
      now_playing = string.format("%s - %s - %s", unknowize(zstats.artist),
                                  unknowize(zstats.album), unknowize(zstats.title))
      current_time   = timeformat(status.time:match("(%d+):"))
      total_time     = timeformat(status.time:match("%d+:(%d+)"))
   end

   if status.state ~= "play" then
      now_playing = now_playing .. " (" .. status.state .. ")"
   end

   if use_naughty then
      if mpc.last_songid ~= status.songid then
         local t
         mpc.last_songid = status.songid
         if radio then
            t = string.format("\n%s: %s\n",
                              bold("stream"), iunknowize(zstats.name))
         else
            t = string.format("%s: %s\n%s:  %s\n%s: %s",
                              bold("artist"), iunknowize(zstats.artist),
                              bold("album"),   unknowize(zstats.album),
                              bold("title"),   unknowize(zstats.title))
         end
         naughty.notify {
            opacity = use_composite and beautiful.opacity.naughty or 1,
            icon   = awful.util.getdir("config") .. "/themes/sonata.png",
            timeout = 3,
            text    = t,
            margin = 10,
         }
      end
   end

   if radio then
      return widget_base( widget_section(where, now_playing,
                                         widget_section("Vol", status.volume)))
   else
      mpdwi.text = now_playing
      --return widget_base(widget_section(where, now_playing,
      --                                  widget_section("Time", widget_value(current_time, total_time),
      --                                                  widget_section("Vol", status.volume))))
   end
end

 -- }}}






-- Battery
battxt = widget({ type = "textbox", align = "right"})
battxt.text = " bat: "

batwi = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft })
batwi:set_width(7)
batwi:set_height(17)
batwi:set_vertical(true)
batwi:set_border_color('#000000')
batwi:set_color('#FFFFFF')
batwi:set_background_color('#222222')

blink = 0
warned = 0

function read_bat()
   local limit = 0.2
   local crit = 0.1

   local ac_path = "/proc/acpi/ac_adapter/ADP1/state"
   local bat_path = "/home/tron/.config/awesome/bat_stat.txt"

   local ac_f = io.open(ac_path, "r")
   local ac_text = ac_f:read("*a")
   ac_f:close()
   local bat_f = io.open(bat_path, "r")
   local bat_text = bat_f:read("*a")
   bat_f:close()

   local ac = ac_text:match("state:%s+(%a+%p%a+)")
   local charging = bat_text:match("charging state:%s+(%a+)")
   --print(charging)
   local capacity = bat_text:match("design capacity:%s+(%d+)")
   local current = bat_text:match("remaining capacity:%s+(%d+)")

   local charge = (current/capacity)

   if ac == "on-line" then
      
      batwi:set_color('#3388cc')
      batwi:set_border_color('#000000')
      warned = 0
   else
      if charge < limit then
         if charge < crit and warned == 0 then
            bat_warn()
            warned = 1
         end
         batwi:set_color('#ff4500')
         if blink == 1 then
            batwi:set_border_color('#000000')
            blink = 0
         else
            batwi:set_border_color('#ff4500')
            blink = 1
         end
      elseif charge > limit and charge < 0.5 then
         batwi:set_color('#ffff22')
         batwi:set_border_color('#000000')
         warned = 0
      else
         batwi:set_color('#99ff77')
         batwi:set_border_color('#000000')
         warned = 0
      end
   end

   batwi:set_value(charge)
end


function bat_warn()
   naughty.config.height = 180
   naughty.config.width = 350
   naughty.config.icon_size = 180
   naughty.config.font = beautiful.font
   
   naughty.notify({
                     text = "i can has power plox?",
                     icon = "/home/tron/Desktop/mudkip1.jpg",
                     bg = "#222222",
                     timeout = 99                 
                  })
end


-- Memory
memtxt = widget({ type = "textbox", align = "right" })
memtxt.text = " mem: "

memwi = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft })
--memwi = widget({ type = "progressbar", align = "right" })
memwi:set_width(7)
memwi:set_height(17)
--memwi:set_gap(1)
memwi:set_vertical(true)
memwi:set_border_color('#000000')
memwi:set_color('#FFFFFF')
memwi:set_background_color('#222222')

memwis = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft })
--memwi = widget({ type = "progressbar", align = "right" })
memwis:set_width(7)
memwis:set_height(17)
--memwi:set_gap(1)
memwis:set_vertical(true)
memwis:set_border_color('#000000')
memwis:set_color('#FFFFFF')
memwis:set_background_color('#222222')


--memwi:bar_properties_set('mem', {border_color = '#000000'})
--memwi:bar_properties_set('swp', {border_color = '#000000'})


function read_mem()
   local mem_f = io.open("/proc/meminfo")
   local mem_f_text = mem_f:read("*a")
   mem_f:close()

   local mem_tot = tonumber(mem_f_text:match("MemTotal:%s+(%d+)"))
   local mem_free = tonumber(mem_f_text:match("MemFree:%s+(%d+)"))
   local swap_tot = tonumber(mem_f_text:match("SwapTotal:%s+(%d+)"))
   local swap_free = tonumber(mem_f_text:match("SwapFree:%s+(%d+)"))

   local pct_mem = (1 - mem_free/mem_tot)
   local pct_swap = (1 - swap_free/swap_tot)

   memwi:set_value(pct_mem)
   memwis:set_value(pct_swap)
end


-- Temp
temptxt = widget({ type = "textbox", align = "right" })
temptxt.text = " temp: "

-- tempwi = awful.widget.progressbar()
-- --tempwi = widget({ type = "progressbar", align = "right" })
-- --tempwi.width = 15
-- tempwi.width = 32
-- tempwi.height = 0.85
-- tempwi.gap = 1
-- tempwi.vertical = true
-- tempwi:bar_properties_set('tmp0', {border_color = '#000000'})
-- tempwi:bar_properties_set('fan0', {border_color = '#000000'})
-- tempwi:bar_properties_set('tmp1', {border_color = '#000000'})
-- tempwi:bar_properties_set('fan1', {border_color = '#000000'})

-- function read_temp()
--    local temp0_f = io.open("/sys/devices/platform/coretemp.0/temp1_input")
--    local temp0_f_text = temp0_f:read("*a")
--    temp0_f:close()
--    local temp1_f = io.open("/sys/devices/platform/coretemp.1/temp1_input")
--    local temp1_f_text = temp1_f:read("*a")
--    temp1_f:close()
--    local fan0_f = io.open("/sys/devices/platform/applesmc.768/fan1_output")
--    local fan0_txt = fan0_f:read("*a")
--    fan0_f:close()
--    local fan1_f = io.open("/sys/devices/platform/applesmc.768/fan2_output")
--    local fan1_txt = fan1_f:read("*a")
--    fan1_f:close()

--    local temp0 = tonumber(temp0_f_text:match("(%d+)"))/1000
--    local temp1 = tonumber(temp1_f_text:match("(%d+)"))/1000

--    if temp0 <= 60 then
--       tempwi:bar_properties_set('tmp0', {fg = '#99ff77'})
--    elseif temp0 > 60 and temp0 < 75 then
--       tempwi:bar_properties_set('tmp0', {fg = '#ffff22'})
--    else 
--       tempwi:bar_properties_set('tmp0', {fg = '#ff4500'})
--    end

--    if temp1 <= 60 then
--       tempwi:bar_properties_set('tmp1', {fg = '#99ff77'})
--    elseif temp1 > 60 and temp1 < 75 then
--       tempwi:bar_properties_set('tmp1', {fg = '#ffff22'})
--    else 
--       tempwi:bar_properties_set('tmp1', {fg = '#ff4500'})
--    end

--    local fan0 = (tonumber(fan0_txt) - 2000)/40
--    local fan1 = (tonumber(fan1_txt) - 2000)/40

--    tempwi:bar_data_add('tmp0', temp0)
--    tempwi:bar_data_add('tmp1', temp1)
--    tempwi:bar_data_add('fan0', fan0)
--    tempwi:bar_data_add('fan1', fan1)
-- end


-- CPU
cputxt = widget({ type = "textbox", align = "right" })
cputxt.text = " cpu: "

cpuwi = awful.widget.graph({ layout = awful.widget.layout.horizontal.rightleft })
--cpuwi = widget ({ type = "graph", align = "right" })
cpuwi:set_width(60)
cpuwi:set_height(17)
--cpuwi.grow = 'right'
cpuwi:set_border_color('#000000')
cpuwi:set_color('#FFFFFF')
cpuwi:set_background_color('#222222')
cpuwi:set_gradient_colors({'#555555', '#999999', '#ffffff'})
cpuwi:set_gradient_angle(180)
cpuwi:set_max_value(100)

-- cpuwi:plot_properties_set('cpu', {
--                              fg = '#555555',
--                              fg_center = '#999999',
--                              fg_end = '#ffffff',
--                              vertical_gradient = true
--                           })

prev_usr = 0
prev_nice = 0
prev_sys = 0
prev_idle = 0

function read_cpu()
   local cpu_f = io.open("/proc/stat")
   local cpu_f_text = cpu_f:read("*a")
   cpu_f:close()

   local usr = tonumber(cpu_f_text:match("cpu%s+(%d+)"))
   local nice = tonumber(cpu_f_text:match("cpu%s+%d+%s+(%d+)"))
   local sys = tonumber(cpu_f_text:match("cpu%s+%d+%s+%d+%s+(%d+)"))
   local idle = tonumber(cpu_f_text:match("cpu%s+%d+%s+%d+%s+%d+%s+(%d+)"))

   local usr_diff = usr - prev_usr
   local nice_diff = nice - prev_nice
   local sys_diff = sys - prev_sys
   local idle_diff = idle - prev_idle

   local pct_cpu = 100*(1 - (idle_diff/(usr_diff + nice_diff + sys_diff + idle_diff)))

   cpuwi:add_value(pct_cpu)

   prev_usr = usr
   prev_nice = nice
   prev_sys = sys
   prev_idle = idle

end


-- NET                
nettxt = widget({ type = "textbox", align = "right" })
nettxt.text = " net: "

netwi = awful.widget.graph({ layout = awful.widget.layout.horizontal.rightleft})
--netwi = widget ({ type = "graph", align = "right" })
netwi:set_width(60)
netwi:set_height(17)
--netwi.grow = 'right'
netwi:set_border_color('#000000')
netwi:set_background_color('#222222')
netwi:set_color('#33ff44')
netwi:set_max_value(300)

-- netwi:plot_properties_set('tx', {
--                              fg = '#ff4500',
--                              style = 'line',
--                              max_value = 300
--                           })

-- netwi:plot_properties_set('rx', {
--                              fg = '#33ff44',
--                              style = 'line',
--                              max_value = 300
--                           })

prev_rxeth = 0
prev_txeth = 0
prev_uptime = 0

function read_net()
   local net_f = io.open("/proc/net/dev")
   local net_f_text = net_f:read("*a")
   net_f:close()
   local uptime_f = io.open("/proc/uptime")
   local uptime_f_text = uptime_f:read("*a")
   uptime_f:close()

   local rxeth = net_f_text:match("wlan0:%s*(%d+)")
   local txeth = net_f_text:match("wlan0:%s*%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+(%d+)")
   --local txeth = net_f_text:match("eth0:%s*%d+(%s+)*")
   local uptime = uptime_f_text:match("(%d+%p%d+)")

   local rxeth_diff = rxeth - prev_rxeth
   local txeth_diff = txeth - prev_txeth
   local uptime_diff = uptime - prev_uptime

   local rxrate = (rxeth_diff/uptime_diff)/1024
   local txrate = (txeth_diff/uptime_diff)/1024

   netwi:add_value(rxrate)
   --tcrate
   --netwi:plot_data_add('rx', rxrate)
   --netrxwi.text = " <span color='#33ff44'>" .. string.format('%.2f', rxrate) .. "</span> "
   --nettxwi.text = " <span color='#ff4500'>" .. string.format('%.2f', txrate) .. "</span> "
   --print(string.format('%.2f', rxrate))

   prev_rxeth = rxeth
   prev_txeth = txeth
   prev_uptime = uptime

end

linkwi = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft})
--linkwi = widget({ type = "progressbar", align = "right" })
linkwi:set_width(7)
linkwi:set_height(17)
linkwi:set_vertical(true)
linkwi:set_border_color('#000000')
linkwi:set_background_color('#222222')
linkwi:set_color('#FFFFFF')

--linkwi:bar_properties_set('signal', {border_color = '#000000'})

function read_wifi()
   local iwconf_f = io.popen('iwconfig wlan0')
   local iwconf_text = iwconf_f:read("*a")
   iwconf_f:close()

   local signal = tonumber(iwconf_text:match("Link Quality=(%d+)"))
   local signal_max = tonumber(iwconf_text:match("Link Quality=%d+%p(%d+)"))
   local quality = 0

   if signal then      
      quality = (signal/signal_max)
   else
      quality = 0
   end
   linkwi:set_value(quality)
end

--volume 

sndtxt = widget({ type = "textbox", align = "right" })
sndtxt.text = " vol: "

sndlvl = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft})
--linkwi = widget({ type = "progressbar", align = "right" })
sndlvl:set_width(7)
sndlvl:set_height(17)
sndlvl:set_vertical(true)
sndlvl:set_border_color('#000000')
sndlvl:set_background_color('#222222')
sndlvl:set_color('#FFFFFF')

function read_vol()
   local snd_f = io.popen('amixer -c 0 sget Master')
   local snd_f_text = snd_f:read("*a")
   snd_f:close()
   
   local vol = snd_f_text:match("Mono: Playback %d+ %p(%d+)")

   sndlvl:set_value(vol/100)
end

--disk
disktxt = widget({ type = "textbox", align = "right" })
disktxt.text = " dsk: "



diskwi = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft})
--linkwi = widget({ type = "progressbar", align = "right" })
diskwi:set_width(7)
diskwi:set_height(17)
diskwi:set_vertical(true)
diskwi:set_border_color('#000000')
diskwi:set_background_color('#222222')
diskwi:set_color('#FFFFFF')

function read_dsk()
   local dskpct = io.popen('df -h')
   local dskpct_txt = dskpct:read("*a")
   dskpct:close()

   local pct = tonumber(dskpct_txt:match("/dev/sda3%s+%d+%a%s+%d+%a%s+%d+%a%s+(%d+)"))
   diskwi:set_value(pct/100)
end

mysystray = widget({ type = "systray" })
-- END COSMONAUT WIDGETS


-- -- {{{ Menu
-- -- Create a laucher widget and a main menu
-- myawesomemenu = {
--    { "manual", terminal .. " -e man awesome" },
--    { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
--    { "restart", awesome.restart },
--    { "quit", awesome.quit }
-- }

-- mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
--                                     { "open terminal", terminal }
--                                   }
--                         })

-- mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
--                                      menu = mymainmenu })
-- }}}


-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
           mylauncher,
           mytaglist[s],
           mypromptbox[s],
           layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        s == 1 and mysystray or nil,
        clockwi,
        s == 1 and batwi or nil,
        s == 1 and battxt or nil,
        s == 1 and memwis or nil,
        s == 1 and memwi or nil,
        s == 1 and memtxt or nil,
        s == 1 and diskwi or nil,
        s == 1 and disktxt or nil,
        s == 1 and temptxt or nil,
        s == 1 and cpuwi or nil,
        s == 1 and cputxt or nil,
        s == 1 and netwi or nil,
        s == 1 and linkwi or nil,
        s == 1 and nettxt or nil,
        s == 1 and sndlvl or nil,
        s == 1 and sndtxt or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}


-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show(true)        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    awful.key({ modkey },            "F1",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey, "Shift" }, 1, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}



-- -- {{{ Key bindings
-- globalkeys = awful.util.table.join(
--     awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
--     awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
--     awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

--     awful.key({ modkey,           }, "j",
--         function ()
--             awful.client.focus.byidx( 1)
--             if client.focus then client.focus:raise() end
--         end),
--     awful.key({ modkey,           }, "k",
--         function ()
--             awful.client.focus.byidx(-1)
--             if client.focus then client.focus:raise() end
--         end),
--     awful.key({ modkey,           }, "w", function () mymainmenu:show(true)        end),

--     -- Layout manipulation
--     awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1) end),
--     awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1) end),
--     awful.key({ modkey, "Control" }, "j", function () awful.screen.focus( 1)       end),
--     awful.key({ modkey, "Control" }, "k", function () awful.screen.focus(-1)       end),
--     awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
--     awful.key({ modkey,           }, "Tab",
--         function ()
--             awful.client.focus.history.previous()
--             if client.focus then
--                 client.focus:raise()
--             end
--         end),

--     -- Standard program
--     awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
--     awful.key({ modkey, "Control" }, "r", awesome.restart),
--     awful.key({ modkey, "Shift"   }, "q", awesome.quit),

--     awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
--     awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
--     awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
--     awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
--     awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
--     awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
--     awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
--     awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

--     -- Prompt
--     awful.key({ modkey }, "F1",
--               function ()
--                   awful.prompt.run({ prompt = "Run: " },
--                   mypromptbox[mouse.screen],
--                   awful.util.spawn, awful.completion.shell,
--                   awful.util.getdir("cache") .. "/history")
--               end),

--     awful.key({ modkey }, "x",
--               function ()
--                   awful.prompt.run({ prompt = "Run Lua code: " },
--                   mypromptbox[mouse.screen],
--                   awful.util.eval, nil,
--                   awful.util.getdir("cache") .. "/history_eval")
--               end)
-- )

-- -- Client awful tagging: this is useful to tag some clients and then do stuff like move to tag on them
-- clientkeys = awful.util.table.join(
--     awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
--     awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
--     awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
--     awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
--     awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
--     awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
--     awful.key({ modkey }, "t", awful.client.togglemarked),
--     awful.key({ modkey,}, "m",
--         function (c)
--             c.maximized_horizontal = not c.maximized_horizontal
--             c.maximized_vertical   = not c.maximized_vertical
--         end)
-- )

-- -- Compute the maximum number of digit we need, limited to 9
-- keynumber = 0
-- for s = 1, screen.count() do
--    keynumber = math.min(9, math.max(#tags[s], keynumber));
-- end

-- for i = 1, keynumber do
--     table.foreach(awful.key({ modkey }, i,
--                   function ()
--                         local screen = mouse.screen
--                         if tags[screen][i] then
--                             awful.tag.viewonly(tags[screen][i])
--                         end
--                   end), function(_, k) table.insert(globalkeys, k) end)
--     table.foreach(awful.key({ modkey, "Control" }, i,
--                   function ()
--                       local screen = mouse.screen
--                       if tags[screen][i] then
--                           tags[screen][i].selected = not tags[screen][i].selected
--                       end
--                   end), function(_, k) table.insert(globalkeys, k) end)
--     table.foreach(awful.key({ modkey, "Shift" }, i,
--                   function ()
--                       if client.focus and tags[client.focus.screen][i] then
--                           awful.client.movetotag(tags[client.focus.screen][i])
--                       end
--                   end), function(_, k) table.insert(globalkeys, k) end)
--     table.foreach(awful.key({ modkey, "Control", "Shift" }, i,
--                   function ()
--                       if client.focus and tags[client.focus.screen][i] then
--                           awful.client.toggletag(tags[client.focus.screen][i])
--                       end
--                   end), function(_, k) table.insert(globalkeys, k) end)
--     table.foreach(awful.key({ modkey, "Shift" }, "F" .. i,
--                   function ()
--                       local screen = mouse.screen
--                       if tags[screen][i] then
--                           for k, c in pairs(awful.client.getmarked()) do
--                               awful.client.movetotag(tags[screen][i], c)
--                           end
--                       end
--                    end), function(_, k) table.insert(globalkeys, k) end)
-- end

-- -- Set keys
-- root.keys(globalkeys)
-- -- }}}

-- -- {{{ Hooks
-- -- Hook function to execute when focusing a client.
-- awful.hooks.focus.register(function (c)
--     if not awful.client.ismarked(c) then
--         c.border_color = beautiful.border_focus
--     end
-- end)

-- -- Hook function to execute when unfocusing a client.
-- awful.hooks.unfocus.register(function (c)
--     if not awful.client.ismarked(c) then
--         c.border_color = beautiful.border_normal
--     end
-- end)

-- -- Hook function to execute when marking a client
-- awful.hooks.marked.register(function (c)
--     c.border_color = beautiful.border_marked
-- end)

-- -- Hook function to execute when unmarking a client.
-- awful.hooks.unmarked.register(function (c)
--     c.border_color = beautiful.border_focus
-- end)

-- -- Hook function to execute when the mouse enters a client.
-- awful.hooks.mouse_enter.register(function (c)
--     -- Sloppy focus, but disabled for magnifier layout
--     if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
--         and awful.client.focus.filter(c) then
--         client.focus = c
--     end
-- end)

-- -- Hook function to execute when a new client appears.
-- awful.hooks.manage.register(function (c, startup)
--     -- If we are not managing this application at startup,
--     -- move it to the screen where the mouse is.
--     -- We only do it for filtered windows (i.e. no dock, etc).
--     awful.placement.no_overlap(c)
--     awful.placement.no_offscreen(c)

--     if not startup and awful.client.focus.filter(c) then
--         c.screen = mouse.screen
--     end

--     if use_titlebar then
--         -- Add a titlebar
--         awful.titlebar.add(c, { modkey = modkey })
--     end
--     -- Add mouse bindings
--     c:buttons(awful.util.table.join(
--         awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
--         awful.button({ modkey }, 1, awful.mouse.client.move),
--         awful.button({ modkey, "Shift" }, 1, awful.mouse.client.resize)
--     ))
--     -- New client may not receive focus
--     -- if they're not focusable, so set border anyway.
--     c.border_width = beautiful.border_width
--     c.border_color = beautiful.border_normal

--     -- Check if the application should be floating.
--     local cls = c.class
--     local inst = c.instance
--     if floatapps[cls] then
--         awful.client.floating.set(c, floatapps[cls])
--     elseif floatapps[inst] then
--         awful.client.floating.set(c, floatapps[inst])
--     end

--     -- Check application->screen/tag mappings.
--     local target
--     if apptags[cls] then
--         target = apptags[cls]
--     elseif apptags[inst] then
--         target = apptags[inst]
--     end
--     if target then
--         c.screen = target.screen
--         awful.client.movetotag(tags[target.screen][target.tag], c)
--     end

--     -- Do this after tag mapping, so you don't see it on the wrong tag for a split second.
--     client.focus = c

--     -- Set key bindings
--     c:keys(clientkeys)

--     -- Set the windows at the slave,
--     -- i.e. put it at the end of others instead of setting it master.
--     -- awful.client.setslave(c)

--     -- Honor size hints: if you want to drop the gaps between windows, set this to false.
--     c.size_hints_honor = false
-- end)

-- -- Hook function to execute when arranging the screen.
-- -- (tag switch, new client, etc)
-- awful.hooks.arrange.register(function (screen)
--     local layout = awful.layout.getname(awful.layout.get(screen))
--     if layout and beautiful["layout_" ..layout] then
--         mylayoutbox[screen].image = image(beautiful["layout_" .. layout])
--     else
--         mylayoutbox[screen].image = nil
--     end

--     -- Give focus to the latest client in history if no window has focus
--     -- or if the current window is a desktop or a dock one.
--     if not client.focus then
--         local c = awful.client.focus.history.get(screen, 0)
--         if c then client.focus = c end
--     end
-- end)

-- -- Hook called every minute
-- awful.hooks.timer.register(1, function ()
--     clockwi.text = " " .. os.date(clockformat) .. " "
--     read_bat()
--     read_temp()
--     read_mem()
--     read_dsk()
--     read_cpu()
--     read_net()
--     read_wifi()
--     read_vol()
-- end)
-- -- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { class = "feh" },
      properties = { floating = true } },

    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
                              
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })
    c.size_hints_honor = false
    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}


-- -- Hook called every minute
-- awful.hooks.timer.register(1, function ()
--     clockwi.text = " " .. os.date(clockformat) .. " "
--     read_bat()
--     read_temp()
--     read_mem()
--     read_dsk()
--     read_cpu()
--     read_net()
--     read_wifi()
--     read_vol()
-- end)
-- -- }}}

-- new widget hook.
mytimer = timer { timeout = 1 }
mytimer:add_signal("timeout", function() 
                                 clockwi.text = " " .. os.date(clockformat) .. " "
                                 read_bat()
                                 read_mem()
                                 read_cpu()
                                 read_net()
                                 read_wifi()
                                 read_vol()
                                 read_dsk()
                              end)
mytimer:start()
