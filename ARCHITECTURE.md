# Architecture Diagram

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      macOS System                                │
│                                                                   │
│  ┌────────────────┐         ┌────────────────┐                  │
│  │ Menu Bar       │         │ Logic Pro X    │                  │
│  │ (User UI)      │         │                │                  │
│  └────────┬───────┘         └────────┬───────┘                  │
│           │                          │                           │
│           │                          │                           │
│           │                          │ Control Surface Setup     │
│           │                          │ (recognizes as Mackie     │
│           │                          │  Control)                 │
│           │                          │                           │
│  ┌────────▼──────────────────────────▼───────┐                  │
│  │                                            │                  │
│  │      GatedMuteController.app               │                  │
│  │                                            │                  │
│  │  ┌──────────────────────────────────────┐ │                  │
│  │  │  AppDelegate                         │ │                  │
│  │  │  - Menu bar UI                       │ │                  │
│  │  │  - Device selection                  │ │                  │
│  │  │  - Status display                    │ │                  │
│  │  └──────────┬───────────────────────────┘ │                  │
│  │             │                              │                  │
│  │  ┌──────────▼───────────────────────────┐ │                  │
│  │  │  MIDIController                      │ │                  │
│  │  │                                      │ │                  │
│  │  │  ┌────────────────────────────────┐ │ │                  │
│  │  │  │ Virtual MIDI Destination       │ │ │                  │
│  │  │  │ "Gated Mute Controller"        │◄┼─┼──── Logic connects
│  │  │  │ (Appears as Mackie Control)    │ │ │     here
│  │  │  └────────────────────────────────┘ │ │                  │
│  │  │                                      │ │                  │
│  │  │  ┌────────────────────────────────┐ │ │                  │
│  │  │  │ MIDI Input Port                │ │ │                  │
│  │  │  │ (Listens to selected device)   │◄┼─┼──── KeyLab sends
│  │  │  │ Channel 16 only                │ │ │     here
│  │  │  └────────────────────────────────┘ │ │                  │
│  │  │                                      │ │                  │
│  │  │  ┌────────────────────────────────┐ │ │                  │
│  │  │  │ Note Mapper                    │ │ │                  │
│  │  │  │ KeyLab (36-59) → Mackie (8-27)│ │ │                  │
│  │  │  └────────────────────────────────┘ │ │                  │
│  │  │                                      │ │                  │
│  │  │  ┌────────────────────────────────┐ │ │                  │
│  │  │  │ Gated Logic                    │ │ │                  │
│  │  │  │ Note On  → Toggle              │ │ │                  │
│  │  │  │ Note Off → Toggle              │ │ │                  │
│  │  │  └────────────────────────────────┘ │ │                  │
│  │  │                                      │ │                  │
│  │  │  ┌────────────────────────────────┐ │ │                  │
│  │  │  │ Mackie Control Protocol        │ │ │                  │
│  │  │  │ Send: Note On (127) + Off (0)  │ │ │                  │
│  │  │  └────────────────────────────────┘ │ │                  │
│  │  └──────────────────────────────────────┘ │                  │
│  └────────────────────────────────────────────┘                  │
│                                                                   │
│  ┌────────────────────────────────────────────┐                  │
│  │          CoreMIDI Framework                │                  │
│  │  (macOS MIDI subsystem)                    │                  │
│  └────────────────────────────────────────────┘                  │
│           ▲                          │                           │
│           │                          │                           │
│           │ MIDI In                  │ MIDI Out                  │
│           │ (Note On/Off)            │ (Mackie Commands)         │
└───────────┼──────────────────────────┼───────────────────────────┘
            │                          │
            │                          │
    ┌───────▼──────┐          ┌───────▼──────┐
    │ Arturia      │          │ Logic Pro X  │
    │ KeyLab       │          │ Control      │
    │ Essential 49 │          │ Surface      │
    │              │          │ Engine       │
    │ Channel 16   │          │ (Mackie)     │
    └──────────────┘          └──────────────┘
```

---

## Data Flow Diagram

### 1. Key Press Flow

```
User presses C1 on KeyLab
         │
         ▼
┌─────────────────────┐
│ KeyLab sends:       │
│ Note On 36 (C1)     │
│ Channel 16          │
│ Velocity 100        │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ CoreMIDI receives   │
│ → Input Port        │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ MIDIController      │
│ handleMIDIEvents()  │
│ - Filter Ch 16? ✓   │
│ - Parse: 0x90 36    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ handleNoteOn(36)    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ mapNoteToMackie()   │
│ 36 → (16, "mute")   │
│ (Track 1 Mute)      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ sendMackieToggle()  │
│ 1. Send: 0x90 16 7F │ ← Note On 127
│ 2. Wait 5ms         │
│ 3. Send: 0x90 16 00 │ ← Note Off
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Virtual Destination │
│ → Logic receives    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Logic Pro X:        │
│ Track 1 MUTES       │
└─────────────────────┘
```

### 2. Key Release Flow

```
User releases C1
         │
         ▼
┌─────────────────────┐
│ KeyLab sends:       │
│ Note Off 36         │
│ Channel 16          │
│ Velocity 0          │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ MIDIController      │
│ handleMIDIEvents()  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ handleNoteOff(36)   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ mapNoteToMackie()   │
│ 36 → (16, "mute")   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ sendMackieToggle()  │
│ 1. Send: 0x90 16 7F │ ← Toggle again
│ 2. Wait 5ms         │
│ 3. Send: 0x90 16 00 │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Logic Pro X:        │
│ Track 1 UNMUTES     │
└─────────────────────┘
```

**Net Result**: Track mutes while key held, unmutes when released = **GATED**

---

## Class Diagram

```
┌─────────────────────────────────────────────────┐
│              AppDelegate                        │
│  (NSApplicationDelegate)                        │
├─────────────────────────────────────────────────┤
│ Properties:                                     │
│  - statusItem: NSStatusItem                     │
│  - menu: NSMenu                                 │
│  - midiController: MIDIController               │
├─────────────────────────────────────────────────┤
│ Methods:                                        │
│  + applicationDidFinishLaunching()              │
│  + setupMenu()                                  │
│  + selectInputDevice(_:)                        │
│  + showMappings()                               │
│  + updateStatusMessage(_:)                      │
└────────────────┬────────────────────────────────┘
                 │ owns
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│           MIDIController                        │
├─────────────────────────────────────────────────┤
│ Properties:                                     │
│  - midiClient: MIDIClientRef                    │
│  - virtualDestination: MIDIEndpointRef          │
│  - inputPort: MIDIPortRef                       │
│  - selectedInputDeviceID: MIDIUniqueID          │
│  - isActive: Bool                               │
│  - statusCallback: ((String) -> Void)?          │
├─────────────────────────────────────────────────┤
│ Setup:                                          │
│  - setupMIDIClient()                            │
│  + getAvailableInputDevices()                   │
│  + selectInputDevice(withID:)                   │
├─────────────────────────────────────────────────┤
│ MIDI Handling:                                  │
│  - handleMIDIEvents(_:)                         │
│  - handleNoteOn(note:)                          │
│  - handleNoteOff(note:)                         │
├─────────────────────────────────────────────────┤
│ Mapping:                                        │
│  - mapNoteToMackieControl(note:)                │
│    Returns: (note: UInt8, type: String)?        │
├─────────────────────────────────────────────────┤
│ Mackie Protocol:                                │
│  - sendMackieControlToggle(note:type:)          │
│  - sendMackieControlNote(note:velocity:)        │
├─────────────────────────────────────────────────┤
│ Cleanup:                                        │
│  - cleanup()                                    │
└─────────────────────────────────────────────────┘
```

---

## State Machine: Gated Behavior

```
Track State Transitions

Initial State: UNMUTED
    │
    │ User presses key
    ▼
┌─────────────────┐
│ UNMUTED         │
│                 │
│ Send toggle     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ MUTED          │◄──── Key is held
│                 │
│ (Track silent)  │
└────────┬────────┘
         │
         │ User releases key
         ▼
┌─────────────────┐
│ MUTED           │
│                 │
│ Send toggle     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ UNMUTED         │◄──── Back to original state
│                 │
│ (Track playing) │
└─────────────────┘
```

**Key Insight**: Each toggle flips the state. Two toggles = return to original.

---

## Mapping Tables

### KeyLab → Mackie Control Note Mapping

#### Mute Controls

| KeyLab Note | Note Name | MIDI # | → | Mackie Note | MIDI # | Logic Track |
|-------------|-----------|--------|---|-------------|--------|-------------|
| C1          | C1        | 36     | → | E0          | 16     | Track 1     |
| C#1         | C#1       | 37     | → | F0          | 17     | Track 2     |
| D1          | D1        | 38     | → | F#0         | 18     | Track 3     |
| D#1         | D#1       | 39     | → | G0          | 19     | Track 4     |
| E1          | E1        | 40     | → | G#0         | 20     | Track 5     |
| F1          | F1        | 41     | → | A0          | 21     | Track 6     |
| F#1         | F#1       | 42     | → | A#0         | 22     | Track 7     |
| G1          | G1        | 43     | → | B0          | 23     | Track 8     |
| G#1         | G#1       | 44     | → | C1          | 24     | Track 9 *   |
| A1          | A1        | 45     | → | C#1         | 25     | Track 10 *  |
| A#1         | A#1       | 46     | → | D1          | 26     | Track 11 *  |
| B1          | B1        | 47     | → | D#1         | 27     | Track 12 *  |

*Tracks 9-12 use extended protocol (may need testing)

#### Solo Controls

| KeyLab Note | Note Name | MIDI # | → | Mackie Note | MIDI # | Logic Track |
|-------------|-----------|--------|---|-------------|--------|-------------|
| C2          | C2        | 48     | → | G#-1        | 8      | Track 1     |
| C#2         | C#2       | 49     | → | A-1         | 9      | Track 2     |
| D2          | D2        | 50     | → | A#-1        | 10     | Track 3     |
| D#2         | D#2       | 51     | → | B-1         | 11     | Track 4     |
| E2          | E2        | 52     | → | C0          | 12     | Track 5     |
| F2          | F2        | 53     | → | C#0         | 13     | Track 6     |
| F#2         | F#2       | 54     | → | D0          | 14     | Track 7     |
| G2          | G2        | 55     | → | D#0         | 15     | Track 8     |
| G#2         | G#2       | 56     | → | E0          | 16     | Track 9 *   |
| A2          | A2        | 57     | → | F0          | 17     | Track 10 *  |
| A#2         | A#2       | 58     | → | F#0         | 18     | Track 11 *  |
| B2          | B2        | 59     | → | G0          | 19     | Track 12 *  |

---

## MIDI Message Format

### Input from KeyLab (Channel 16)

```
┌─────────┬─────────┬──────────┐
│ Status  │ Data 1  │ Data 2   │
├─────────┼─────────┼──────────┤
│ 0x9F    │ 36-59   │ 0-127    │
│ (Ch 16) │ (Note)  │ (Vel)    │
└─────────┴─────────┴──────────┘

Examples:
- Note On C1:  9F 24 64  (Channel 16, Note 36, Vel 100)
- Note Off C1: 9F 24 00  (Channel 16, Note 36, Vel 0)
- OR:          8F 24 40  (Note Off message, Vel 64)
```

### Output to Logic (Channel 1, Mackie Control)

```
┌─────────┬─────────┬──────────┐
│ Status  │ Data 1  │ Data 2   │
├─────────┼─────────┼──────────┤
│ 0x90    │ 8-27    │ 127/0    │
│ (Ch 1)  │ (Note)  │ (On/Off) │
└─────────┴─────────┴──────────┘

Examples:
- Track 1 Mute ON:  90 10 7F  (Channel 1, Note 16, Vel 127)
- Track 1 Mute OFF: 90 10 00  (Channel 1, Note 16, Vel 0)
```

---

## Timing Diagram

```
Time (ms)  │  Event
───────────┼────────────────────────────────────────
0          │  User presses C1
1          │  KeyLab sends: Note On 36 Ch16
2          │  ─┐
3          │   │ MIDIController receives & processes
4          │   │ - Filter Channel 16 ✓
5          │   │ - Map 36 → 16 (Mute Track 1)
6          │  ─┘
7          │  Send: 0x90 16 7F (Mackie Note On)
8          │  ─┐
9          │   │ 5ms delay (usleep)
10         │   │
11         │   │
12         │  ─┘
13         │  Send: 0x90 16 00 (Mackie Note Off)
14         │  Logic receives toggle → Track 1 MUTES
───────────┼────────────────────────────────────────
           │  ... key held ...
───────────┼────────────────────────────────────────
1000       │  User releases C1
1001       │  KeyLab sends: Note Off 36 Ch16
1002-1006  │  Processing (same as above)
1007       │  Send: 0x90 16 7F
1012       │  (5ms delay)
1013       │  Send: 0x90 16 00
1014       │  Logic receives toggle → Track 1 UNMUTES
───────────┴────────────────────────────────────────

Total latency: ~7ms (press) + ~7ms (release) = ~14ms
Target: < 10ms per event ✓
```

---

## Component Interaction Sequence

```
┌────────┐  ┌────────────┐  ┌─────────────┐  ┌──────────┐
│ User   │  │ KeyLab     │  │ MIDIControl │  │ Logic    │
└───┬────┘  └─────┬──────┘  └──────┬──────┘  └────┬─────┘
    │             │                │              │
    │ Press C1    │                │              │
    ├────────────>│                │              │
    │             │ Note On 36 Ch16│              │
    │             ├───────────────>│              │
    │             │                │ Filter Ch16  │
    │             │                │ Map 36→16    │
    │             │                │              │
    │             │                │ Mackie Toggle│
    │             │                ├─────────────>│
    │             │                │              │ Track 1
    │             │                │              │ MUTES
    │             │                │              │
    ... Key held for 1 second ...               │
    │             │                │              │
    │ Release C1  │                │              │
    ├────────────>│                │              │
    │             │ Note Off 36    │              │
    │             ├───────────────>│              │
    │             │                │ Map 36→16    │
    │             │                │              │
    │             │                │ Mackie Toggle│
    │             │                ├─────────────>│
    │             │                │              │ Track 1
    │             │                │              │ UNMUTES
    │             │                │              │
```

---

## Error Handling Flow

```
┌─────────────────────┐
│ MIDI Event Received │
└──────────┬──────────┘
           │
           ▼
     ┌───────────┐
     │ Ch 16? ────┼─ NO ──> Ignore (silent drop)
     └─────┬─────┘
           │ YES
           ▼
     ┌────────────┐
     │ Note On/Off?────┼─ NO ──> Ignore (not Note msg)
     └─────┬──────┘
           │ YES
           ▼
     ┌────────────────┐
     │ In range 36-59?────┼─ NO ──> Ignore (out of range)
     └─────┬──────────┘
           │ YES
           ▼
     ┌────────────────┐
     │ Map to Mackie  │
     └─────┬──────────┘
           │
           ▼
     ┌────────────────┐
     │ Send Toggle    │
     └────────────────┘
```

**No Error Messages**: Design philosophy is silent filtering to avoid disrupting workflow.

---

## Memory Layout

```
┌─────────────────────────────────────────┐
│         MIDIController Instance          │
├─────────────────────────────────────────┤
│ midiClient: MIDIClientRef (8 bytes)     │
│ virtualDest: MIDIEndpointRef (8 bytes)  │
│ inputPort: MIDIPortRef (8 bytes)        │
│ deviceID: MIDIUniqueID (4 bytes)        │
│ isActive: Bool (1 byte)                 │
│ statusCallback: Closure (~16 bytes)     │
├─────────────────────────────────────────┤
│ Total: ~45 bytes                        │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│         AppDelegate Instance             │
├─────────────────────────────────────────┤
│ statusItem: NSStatusItem (~8 bytes)     │
│ menu: NSMenu (~8 bytes)                 │
│ midiController: MIDIController (45 bytes)│
├─────────────────────────────────────────┤
│ Total: ~61 bytes                        │
└─────────────────────────────────────────┘

Total app memory footprint: < 10MB (including frameworks)
```

---

This architecture prioritizes:
- **Low latency** (sub-10ms response)
- **Simplicity** (minimal code, clear logic)
- **Robustness** (silent error handling)
- **Efficiency** (lightweight memory footprint)
