export const FPS = 30;
export const WIDTH = 1920;
export const HEIGHT = 1080;
export const TOTAL_FRAMES = 900; // 30 seconds at 30fps

export const COLORS = {
  black: '#070708',
  nearBlack: '#0a0a0c',
  red: '#FF3B30',
  redDeep: '#C4291F',
  redGlow: 'rgba(255, 59, 48, 0.6)',
  orange: '#FF9500',
  orangeDeep: '#FF6B00',
  green: '#34C759',
  purple: '#5E5CE6',
  white: '#ffffff',
  midGrey: '#666666',
  lightGrey: '#aaaaaa',
  dimGrey: '#2a2a2e',
} as const;

export const SCENES = {
  coldOpen:   { start: 0,   end: 90  }, // 0:00–0:03
  theProblem: { start: 90,  end: 270 }, // 0:03–0:09
  thePivot:   { start: 270, end: 390 }, // 0:09–0:13
  spamReveal: { start: 390, end: 660 }, // 0:13–0:22
  showcase:   { start: 660, end: 810 }, // 0:22–0:27
  close:      { start: 810, end: 900 }, // 0:27–0:30
} as const;

export type SceneKey = keyof typeof SCENES;

export const sceneDuration = (s: SceneKey): number =>
  SCENES[s].end - SCENES[s].start;

export const FONTS = {
  display: "'Arial Black', 'Helvetica Neue', sans-serif",
  system: "-apple-system, 'SF Pro Display', system-ui, sans-serif",
} as const;
