pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Clipboard history service. A `wl-paste --watch` child shell mirrors every
// selection change into the cache dir (one file per clip) and reports it back
// as a 4-line record: kind+types, file, md5, base64 first-line preview.
// Nothing but metadata crosses into QML, so copy-back has no size limits.
Singleton {
    id: root

    readonly property int maxEntries: 50
    property var entries: []
    readonly property string cachePath: Quickshell.cacheDir + "/symbiont-clip"

    // One line per clip, fields joined by ASCII 037 (unit separator):
    //   kind(T/I) US types US file US md5 US base64-first-line-preview
    // SplitParser mangles empty lines, so the protocol must never emit them.
    readonly property string watchScript:
        "mkdir -p '" + root.cachePath + "' || exit; " +
        "types=$(wl-paste --list-types 2>/dev/null | tr '\\n' ',' | sed 's/,$//'); " +
        "[ -n \"$types\" ] || exit; " +
        "case \"$types\" in " +
        "*image/*) " +
        "f=\"" + root.cachePath + "/clip-$(date +%s%N).png\"; " +
        "wl-paste --type image/png > \"$f\" 2>/dev/null; " +
        "[ -s \"$f\" ] || { rm -f \"$f\"; exit; }; " +
        "printf 'I\\037%s\\037%s\\037%s\\037\\n' \"$types\" \"$f\" \"$(md5sum \"$f\" | cut -d' ' -f1)\";; " +
        "*) " +
        "f=\"" + root.cachePath + "/clip-$(date +%s%N).txt\"; " +
        "wl-paste -n > \"$f\" 2>/dev/null; " +
        "[ -s \"$f\" ] || { rm -f \"$f\"; exit; }; " +
        "printf 'T\\037%s\\037%s\\037%s\\037' \"$types\" \"$f\" \"$(md5sum \"$f\" | cut -d' ' -f1)\"; " +
        "sed -n '1p' \"$f\" | head -c 200 | base64 -w0; printf '\\n';; " +
        "esac; " +
        "find '" + root.cachePath + "' -name 'clip-*' -type f | sort | head -n -100 | xargs -r rm -f"

    function _onCapture(line) {
        if (line.length < 4)
            return
        const kind = line.charAt(0) === "I" ? "image" : "text"
        const parts = line.split("\u001F")
        if (parts.length < 4 || parts[2].length === 0 || parts[3].length === 0)
            return
        root._commit(kind, parts[1], parts[2], parts[3], Qt.atob(parts[4]))
    }

    function _commit(kind, types, file, hash, preview) {
        const next = [ {
            kind: kind,
            types: types,
            file: file,
            hash: hash,
            preview: preview,
            timestamp: Date.now()
        } ]
        for (let i = 0; i < root.entries.length; ++i) {
            if (root.entries[i].hash !== hash)
                next.push(root.entries[i])
        }
        root.entries = next.slice(0, root.maxEntries)
    }

    function copyToClipboard(entry) {
        if (!entry || entry.file.length === 0)
            return
        copyProc.command = entry.kind === "image"
            ? ["sh", "-c", 'wl-copy --type image/png < "$1"', "sh", entry.file]
            : ["sh", "-c", 'wl-copy < "$1"', "sh", entry.file]
        copyProc.running = true
    }

    Process {
        id: watcher
        running: true
        command: ["wl-paste", "--watch", "sh", "-c", root.watchScript]
        stdout: SplitParser {
            onRead: line => root._onCapture(line)
        }
    }

    // Mirror whatever is on the clipboard right now into the history.
    Process {
        id: probe
        running: true
        command: ["sh", "-c", root.watchScript]
        stdout: SplitParser {
            onRead: line => root._onCapture(line)
        }
    }

    Process {
        id: copyProc
    }
}
