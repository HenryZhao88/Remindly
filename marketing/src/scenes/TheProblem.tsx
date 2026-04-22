import { AbsoluteFill, interpolate, useCurrentFrame, spring, useVideoConfig } from 'remotion';
import { COLORS, FONTS } from '../theme';
import { GrainOverlay } from '../components/GrainOverlay';

// Local frame-space — this scene runs for 180 frames (0-179 within it).
// Three words, one per ~60 frames: 0-60 MISSED, 60-120 FORGOT, 120-180 SLEPT THROUGH.
const WORDS = [
  { text: 'MISSED.',         tagLabel: '14 MISSED CALLS' },
  { text: 'FORGOT.',         tagLabel: 'GATE CLOSED'      },
  { text: 'SLEPT THROUGH.',  tagLabel: 'ALARM MUTED'      },
];

export const TheProblem: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const wordIndex = Math.min(2, Math.floor(frame / 60));
  const word = WORDS[wordIndex];
  const localFrame = frame - wordIndex * 60; // 0-59 per word

  const slam = spring({
    frame: localFrame,
    fps,
    config: { damping: 11, stiffness: 180 },
  });

  // Slight scale overshoot → settle
  const scale = interpolate(slam, [0, 1], [1.8, 1]);
  const opacity = interpolate(localFrame, [0, 8, 45, 60], [0, 1, 1, 0.6], {
    extrapolateRight: 'clamp',
  });
  const blur = interpolate(localFrame, [0, 10], [16, 0], { extrapolateRight: 'clamp' });

  return (
    <AbsoluteFill
      style={{
        backgroundColor: COLORS.nearBlack,
        overflow: 'hidden',
        filter: 'saturate(0.3)',
      }}
    >
      <div
        style={{
          position: 'absolute',
          inset: 0,
          background: 'linear-gradient(135deg, #1c1c20 0%, #08080a 100%)',
        }}
      />

      <GrainOverlay opacity={0.12} />

      {/* Context tag top-right */}
      <div
        style={{
          position: 'absolute',
          top: '10%',
          right: '8%',
          background: '#2a1a1a',
          color: COLORS.red,
          fontFamily: FONTS.system,
          fontSize: 22,
          fontWeight: 700,
          padding: '8px 14px',
          borderRadius: 4,
          letterSpacing: 2,
          opacity: opacity * 0.8,
        }}
      >
        {word.tagLabel}
      </div>

      {/* The word */}
      <div
        style={{
          position: 'absolute',
          inset: 0,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <div
          style={{
            fontFamily: FONTS.display,
            fontWeight: 900,
            color: COLORS.white,
            fontSize: 220,
            letterSpacing: -6,
            lineHeight: 0.9,
            transform: `scale(${scale})`,
            opacity,
            filter: `blur(${blur}px)`,
            textShadow: '0 6px 30px rgba(0,0,0,0.8)',
          }}
        >
          {word.text}
        </div>
      </div>

      {/* Heartbeat indicator bottom (visual cue that matches audio) */}
      <div
        style={{
          position: 'absolute',
          bottom: '8%',
          left: '50%',
          transform: 'translateX(-50%)',
          width: 18,
          height: 18,
          borderRadius: '50%',
          background: COLORS.red,
          opacity: 0.4 + 0.6 * Math.abs(Math.sin((frame / fps) * Math.PI * 1.8)),
          boxShadow: '0 0 20px rgba(255,59,48,0.6)',
        }}
      />
    </AbsoluteFill>
  );
};
