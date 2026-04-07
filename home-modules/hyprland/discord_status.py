import json
import dbus
import dbus.service
import sys
import fcntl
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib


LOCK_FILE = "/tmp/discord_noctalia.lock"
STATE_FILE = "/tmp/discord_noctalia.json"


def emit(count):
    count_int = int(count) if count else 0
    data = {
        "text": f"󰙯 {count_int}" if count_int > 0 else "",
        "tooltip": f"{count_int} unread messages" if count_int > 0 else ""
    }
    with open(STATE_FILE, "w") as f:
        f.write(json.dumps(data) + "\n")
    sys.stdout.write(json.dumps(data) + '\n')
    sys.stdout.flush()


def on_signal(*args):
    emit(args[1].get('count', 0))


DBusGMainLoop(set_as_default=True)
f_lock = open(LOCK_FILE, "w")


try:
    fcntl.lockf(f_lock, fcntl.LOCK_EX | fcntl.LOCK_NB)

    bus = dbus.SessionBus()
    bus_name = dbus.service.BusName("com.canonical.Unity", bus=bus)
    obj = dbus.service.Object(bus_name, "/com/canonical/Unity/LauncherEntry")

    bus.add_signal_receiver(
        on_signal,
        signal_name="Update",
        dbus_interface="com.canonical.Unity.LauncherEntry"
    )
    emit(0)
    GLib.MainLoop().run()


except BlockingIOError:
    import subprocess
    process = subprocess.Popen(
        ["tail", "-f", "-n", "+1", STATE_FILE],
        stdout=subprocess.PIPE
    )
    while True:
        line = process.stdout.readline()
        if not line:
            break
        sys.stdout.write(line.decode())
        sys.stdout.flush()
