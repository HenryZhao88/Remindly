import pkg from 'wavefile';
const { WaveFile } = pkg;
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const OUT_DIR = path.resolve(__dirname, '..', 'public', 'audio');
const SR = 44100;

fs.mkdirSync(OUT_DIR, { recursive: true });

function writeMonoWav(filename, floatSamples) {
  const int16 = new Int16Array(floatSamples.length);
  for (let i = 0; i < floatSamples.length; i++) {
    const s = Math.max(-1, Math.min(1, floatSamples[i]));
    int16[i] = Math.round(s * 32767);
  }
  const wav = new WaveFile();
  wav.fromScratch(1, SR, '16', int16);
  fs.writeFileSync(path.join(OUT_DIR, filename), wav.toBuffer());
  console.log(`  wrote ${filename} (${(floatSamples.length / SR).toFixed(2)}s)`);
}

// -----------------------------------------------------------------------------
// Impact: 150 Hz → 30 Hz sub-bass sweep with fast attack, exponential decay.
// -----------------------------------------------------------------------------
function genImpact() {
  const dur = 0.8;
  const n = Math.floor(dur * SR);
  const out = new Float32Array(n);
  let phase = 0;
  const dt = 1 / SR;
  for (let i = 0; i < n; i++) {
    const t = i * dt;
    const freq = 30 + 120 * Math.exp(-t / 0.08);
    phase += 2 * Math.PI * freq * dt;
    const attack = Math.min(1, t / 0.004);
    const decay = Math.exp(-t / 0.3);
    out[i] = Math.sin(phase) * attack * decay * 0.9;
  }
  return out;
}

// -----------------------------------------------------------------------------
// Glitch: bitcrushed noise pulse.
// -----------------------------------------------------------------------------
function genGlitch() {
  const dur = 0.3;
  const n = Math.floor(dur * SR);
  const out = new Float32Array(n);
  for (let i = 0; i < n; i++) {
    const t = i / SR;
    const gate = (i % 512) < 48 ? 1 : 0;
    let s = (Math.random() * 2 - 1) * gate;
    s = Math.round(s * 6) / 6; // ~4-bit quantize
    const env = Math.exp(-t / 0.1);
    out[i] = s * env * 0.5;
  }
  return out;
}

// -----------------------------------------------------------------------------
// Notification: two-tone chime (880 Hz → 1320 Hz with 40ms delay).
// -----------------------------------------------------------------------------
function genNotification() {
  const dur = 0.25;
  const n = Math.floor(dur * SR);
  const out = new Float32Array(n);
  for (let i = 0; i < n; i++) {
    const t = i / SR;
    const s1 = Math.sin(2 * Math.PI * 880 * t);
    const s2 = t > 0.04 ? Math.sin(2 * Math.PI * 1320 * (t - 0.04)) : 0;
    const attack = Math.min(1, t / 0.005);
    const decay = Math.exp(-t / 0.12);
    out[i] = (s1 * 0.5 + s2 * 0.4) * attack * decay * 0.7;
  }
  return out;
}

// -----------------------------------------------------------------------------
// Heartbeat: two low thumps (thump–thump pattern).
// -----------------------------------------------------------------------------
function genHeartbeat() {
  const dur = 1.5;
  const n = Math.floor(dur * SR);
  const out = new Float32Array(n);
  const thump = (t, offset) => {
    const td = t - offset;
    if (td < 0 || td > 0.2) return 0;
    const env = Math.exp(-td / 0.06);
    return Math.sin(2 * Math.PI * 60 * td) * env * 0.8;
  };
  for (let i = 0; i < n; i++) {
    const t = i / SR;
    out[i] = thump(t, 0) + thump(t, 0.28);
  }
  return out;
}

// -----------------------------------------------------------------------------
// Music bed: 30s cinematic drone.
// Layered detuned sines at A1 (55 Hz) + E2 (~82.4 Hz) with slow LFO tremolo,
// plus low-passed noise pad. Envelope shapes intensity to match scene beats.
// -----------------------------------------------------------------------------
function genMusicBed() {
  const dur = 30;
  const n = Math.floor(dur * SR);
  const out = new Float32Array(n);
  const dt = 1 / SR;
  let p1 = 0, p2a = 0, p2b = 0, pLfo = 0;
  let noiseLp = 0;

  const envelope = (t) => {
    if (t < 3)   return 0.25 + t * 0.05;              // cold open: quiet
    if (t < 9)   return 0.40 + (t - 3) * 0.04;        // problem: rising
    if (t < 13)  return 0.64 + (t - 9) * 0.04;        // pivot: tension
    if (t < 22)  return 0.80 + (t - 13) * 0.02;       // spam build: peak
    if (t < 24)  return 0.30;                          // STOP hard drop
    if (t < 27)  return 0.30 + (t - 24) * 0.10;       // showcase resolve
    return Math.max(0, 0.60 * (1 - (t - 27) / 3));    // close: fade out
  };

  for (let i = 0; i < n; i++) {
    const t = i * dt;
    const e = envelope(t);

    pLfo += 2 * Math.PI * 0.12 * dt;
    const lfo = 0.6 + 0.4 * Math.sin(pLfo);

    p1  += 2 * Math.PI * 55.00 * dt;
    p2a += 2 * Math.PI * 82.40 * dt;
    p2b += 2 * Math.PI * 82.90 * dt;

    const drone1 = Math.sin(p1) * 0.30 * lfo;
    const drone2 = (Math.sin(p2a) + Math.sin(p2b)) * 0.15;

    const white = Math.random() * 2 - 1;
    noiseLp = noiseLp * 0.993 + white * 0.007;
    const noise = noiseLp * 6 * 0.20;

    out[i] = (drone1 + drone2 + noise) * e * 0.45;
  }

  return out;
}

// -----------------------------------------------------------------------------
// Main
// -----------------------------------------------------------------------------
console.log(`Generating audio to ${OUT_DIR}`);
writeMonoWav('impact.wav', genImpact());
writeMonoWav('glitch.wav', genGlitch());
writeMonoWav('notification.wav', genNotification());
writeMonoWav('heartbeat.wav', genHeartbeat());
writeMonoWav('music-bed.wav', genMusicBed());
console.log('Done.');
