// qrc:/KeyDash_NX1000/errors/Errors.js
.pragma library

// Code ranges (just a suggestion)
// 0x1000–0x10FF : Bluetooth & discovery
// 0x1100–0x11FF : Connection/session
// 0x1200–0x12FF : Address/format/input
// 0x1300–0x13FF : Permissions/OS
// 0x1F00–0x1FFF : Unknown/internal

var CATALOG = {
  0x1001: { key: "BT_NOT_PAIRED", msg: "Bluetooth not paired. Pair ECUMaster in system settings first." },
  0x1002: { key: "SCAN_TIMEOUT", msg: "Scan timed out after {timeout} ms." },
  0x1003: { key: "NO_DEVICES_FOUND", msg: "No devices found. Ensure the ECU is powered and discoverable." },

  0x1101: { key: "CONNECT_FAILED", msg: "Failed to connect to {target}. Try again." },
  0x1102: { key: "DISCONNECTED", msg: "Disconnected from ECU." },
  0x1103: { key: "RECONNECT_ATTEMPTS_EXCEEDED", msg: "Auto-reconnect failed after {tries} tries." },

  0x1201: { key: "ADDR_INVALID", msg: "Invalid Bluetooth address format: {addr}." },
  0x1202: { key: "ADDR_EMPTY", msg: "Bluetooth address is required." },

  0x1301: { key: "OS_PERMISSION", msg: "Bluetooth permission denied by the OS." },

  0x1F01: { key: "UNKNOWN", msg: "Unknown error." }
};

// simple template fill: replaces {name} with params.name
function fill(template, params) {
  if (!params) return template;
  return template.replace(/\{(\w+)\}/g, function(_, k){ return (k in params) ? String(params[k]) : "{" + k + "}"; });
}

function exists(code) {
  return CATALOG.hasOwnProperty(code);
}

function text(code, params) {
  if (!exists(code)) return "Unrecognized error 0x" + Number(code).toString(16).toUpperCase();
  return fill(CATALOG[code].msg, params);
}

function key(code) {
  return exists(code) ? CATALOG[code].key : "UNRECOGNIZED";
}

// exported API
var Codes = {
  BT_NOT_PAIRED:               0x1001,
  SCAN_TIMEOUT:                0x1002,
  NO_DEVICES_FOUND:            0x1003,

  CONNECT_FAILED:              0x1101,
  DISCONNECTED:                0x1102,
  RECONNECT_ATTEMPTS_EXCEEDED: 0x1103,

  ADDR_INVALID:                0x1201,
  ADDR_EMPTY:                  0x1202,

  OS_PERMISSION:               0x1301,

  UNKNOWN:                     0x1F01
};

function describe(code) { // helpful for docs/logging
  if (!exists(code)) return { code: code, hex: "0x" + Number(code).toString(16).toUpperCase(), key: "UNRECOGNIZED", msg: "" };
  var c = CATALOG[code];
  return { code: code, hex: "0x" + Number(code).toString(16).toUpperCase(), key: c.key, msg: c.msg };
}

// make functions accessible to QML
var API = { text: text, key: key, exists: exists, Codes: Codes, describe: describe };
