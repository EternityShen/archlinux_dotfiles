pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    property bool isLuaMode: true

    function dispatch(payload) {
        console.log(`[hypr-overview] DISPATCH: ${payload}`)
        _dispatchProcess.command = ["hyprctl", "dispatch", payload]
        _dispatchProcess.running = true
    }

    Process {
        id: _dispatchProcess
    }

    function moveToWorkspace(address, ws, silent) {
        return `hl.dsp.window.move({workspace="${ws}",follow=${!silent},window="address:${address}"})`;
    }

    function swapWindows(address, targetAddress) {
        return `hl.dsp.window.swap({target="address:${targetAddress}",window="address:${address}"})`;
    }

    function moveToPixel(address, x, y) {
        return `hl.dsp.window.move({x=${x},y=${y},relative=false,window="address:${address}"})`;
    }

    function focusWindow(address) {
        return `hl.dsp.focus({window="address:${address}"})`;
    }

    function closeWindow(address) {
        return `hl.dsp.window.close({window="address:${address}"})`;
    }

    function focusWorkspace(selector) {
        return `hl.dsp.focus({workspace="${selector}"})`;
    }

    function cursorMove(x, y) {
        return `hl.dsp.cursor.move({x=${x},y=${y}})`;
    }

    property var _swapPending: null
    property string _cursorBuf: ""

    function swapWindowsPreservingCursor(srcAddr, targetAddr, afterSwap) {
        if (root._swapPending) {
            if (afterSwap)
                afterSwap();
            return;
        }
        root._swapPending = { src: srcAddr, target: targetAddr, afterSwap: afterSwap };
        root._cursorBuf = "";
        _cursorProc.running = true;
    }

    Process {
        id: _cursorProc
        command: ["hyprctl", "cursorpos"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => { root._cursorBuf += data; }
        }
        onExited: (exitCode, exitStatus) => {
            const pending = root._swapPending;
            const buf = root._cursorBuf;
            root._swapPending = null;
            root._cursorBuf = "";
            if (!pending)
                return;

            const swapCmd = root.swapWindows(pending.src, pending.target);
            console.log(`[hypr-overview] SWAP: ${swapCmd}`);
            root.dispatch(swapCmd);

            if (exitCode === 0) {
                const m = buf.match(/(-?\d+)\s*,\s*(-?\d+)/);
                if (m) {
                    root.dispatch(root.cursorMove(parseInt(m[1], 10), parseInt(m[2], 10)));
                }
            }

            if (pending.afterSwap)
                pending.afterSwap();
        }
    }
}