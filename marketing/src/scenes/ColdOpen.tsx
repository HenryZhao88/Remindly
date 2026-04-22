import { AbsoluteFill, interpolate, useCurrentFrame, spring, useVideoConfig } from 'remotion';
import { COLORS, FONTS } from '../theme';
import { GrainOverlay } from '../components/GrainOverlay';

export const ColdOpen: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Red glow pulses in 0-30, intensifies 30-60, holds 60-90
  const glowOpacity = interpolate(frame, [0, 30, 60, 90], [0, 0.55, 0.7, 0.65], {
    extrapolateRight: 'clamp',
  });

  // Title letters stagger fade in from frame 30
  const letters = 'REMINDLY'.split('');
  const letterSpread = (index: number) => {
    const letterStart = 30 + index * 4;
    return spring({
      frame: frame - letterStart,
      fps,
      config: { damping: 14, stiffness: 140 },
    });
  };

  // Subtle global blur-to-focus
  const globalBlur = interpolate(frame, [30, 70], [8, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill style={{ backgroundColor: COLORS.black, overflow: 'hidden' }}>
      {/* Red radial glow */}
      <div
        style={{
          position: 'absolute',
          inset: 0,
          background: `radial-gradient(circle at 50% 50%, rgba(255,59,48,${glowOpacity}) 0%, transparent 48%)`,
        }}
      />

      <GrainOverlay opacity={0.1} />

      {/* Title */}
      <div
        style={{
          position: 'absolute',
          inset: 0,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          filter: `blur(${globalBlur}px)`,
        }}
      >
        <div
          style={{
            fontFamily: FONTS.display,
            fontWeight: 900,
            color: COLORS.white,
            fontSize: 160,
            letterSpacing: 36,
            textShadow: `0 0 40px rgba(255,59,48,${glowOpacity})`,
            display: 'flex',
          }}
        >
          {letters.map((ch, i) => {
            const s = letterSpread(i);
            return (
              <span
                key={i}
                style={{
                  opacity: s,
                  transform: `translateY(${(1 - s) * 20}px)`,
                  display: 'inline-block',
                }}
              >
                {ch}
              </span>
            );
          })}
        </div>
      </div>
    </AbsoluteFill>
  );
};
