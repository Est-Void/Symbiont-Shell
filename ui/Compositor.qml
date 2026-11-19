pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: comp

    readonly property bool isNiri:
        String(Quickshell.env("NIRI_SOCKET") || "").length > 0 ||
        /niri/i.test(String(Quickshell.env("XDG_CURRENT_DESKTOP") || ""))

    readonly property bool isHyprland:
        !comp.isNiri && (
            String(Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") || "").length > 0 ||
            /hyprland/i.test(String(Quickshell.env("XDG_CURRENT_DESKTOP") || ""))
        )

    readonly property string kind:
        comp.isNiri ? "niri" : (comp.isHyprland ? "hyprland" : "unknown")
}
