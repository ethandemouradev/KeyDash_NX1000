// ==============================================
// 2) components/LogReplayController.qml
// ==============================================
// A headless engine that loads frames and advances time.
// Place at: qrc:/KeyDash_NX1000/components/LogReplayController.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../scripts/LogParser.js" as LP

Item {
    id: replay
    // PUBLIC API
    property url sourceUrl: ""           // file:/// or qrc:/
    property bool playing: false
    property bool loop: false
    property real speed: 1.0              // 0.25, 0.5, 1, 2, 4, 8

    // time in ms
    property int position: 0              // current playhead
    readonly property int duration: _duration

    // frames
    readonly property int frameIndex: _frameIndex

    // emitted once per step with the current frame object
    signal frameAdvanced(var frame)
    signal loaded(int frameCount, int durationMs)
    signal ended()

    // PRIVATE STATE
    property var _frames: []
    property int _duration: 0
    property int _frameIndex: 0
    property double _lastTickMs: 0

    function clear() {
        _frames = []; _duration = 0; _frameIndex = 0; position = 0; playing = false;
    }

    function loadFromText(text) {
        clear();
        const res = LP.LogParser.parse(text);
        _frames = res.frames;
        _duration = res.duration | 0;
        _frameIndex = 0;
        position = _frames.length ? _frames[0].t : 0;
        loaded(_frames.length, _duration);
    }

    function _pickFR() {
        // try all common context names
        if (typeof fileReader !== "undefined" && fileReader.readTextUrl) return fileReader
        if (typeof FileReader !== "undefined" && FileReader.readTextUrl) return FileReader
        if (typeof Fs !== "undefined" && Fs.readTextUrl) return Fs
        return null
    }

    function load() {
        if (!sourceUrl) return
        const u = Qt.resolvedUrl(sourceUrl)

        // Local file: use the C++ helper (no XHR)
        if (String(u).startsWith("file:")) {
            const fr = _pickFR()
            if (fr) {
                const txt = fr.readTextUrl(u)   // ← UTF-8 safe
                loadFromText(txt || "")
            } else {
                console.warn("FileReader not available; cannot read local files")
            }
            return
        }

        // qrc:/ or http(s): XHR works fine
        const xhr = new XMLHttpRequest()
        xhr.open("GET", u, true)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                loadFromText(xhr.responseText || "")
            }
        }
        xhr.send()
    }

    function play() {
        if (!_frames.length) return;
        playing = true;
        _lastTickMs = Date.now();
    }
    function pause() { playing = false; }
    function stop() { pause(); seek(0); }

    function seek(ms) {
        if (!_frames.length) { position = 0; _frameIndex = 0; return; }
        position = Math.max(0, Math.min(_duration, ms|0));
        // find nearest frame <= position (linear scan; logs are small; could binary-search later)
        let i = _frameIndex;
        if (i >= _frames.length) i = _frames.length - 1;
        if (_frames[i].t > position) {
            while (i > 0 && _frames[i-1].t > position) i--;
        } else {
            while (i + 1 < _frames.length && _frames[i+1].t <= position) i++;
        }
        _frameIndex = i;
        frameAdvanced(_frames[_frameIndex]);
    }

    function step(dtMs) {
        if (!_frames.length) return;
        position = Math.min(_duration, position + Math.max(0, dtMs) * Math.max(0, speed));
        // advance frame index to latest frame with t <= position
        while (_frameIndex + 1 < _frames.length && _frames[_frameIndex + 1].t <= position) {
            _frameIndex++;
        }
        frameAdvanced(_frames[_frameIndex]);
        if (position >= _duration) {
            if (loop) { seek(0); } else { playing = false; ended(); }
        }
    }

    Timer {
        id: tick
        running: replay.playing
        repeat: true
        interval: 16 // ~60hz UI, independent of source sampling rate
        onTriggered: {
            const now = Date.now();
            const dt = now - replay._lastTickMs;
            replay._lastTickMs = now;
            replay.step(dt);
        }
    }
}
