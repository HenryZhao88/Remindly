import { AbsoluteFill, Img, interpolate, useCurrentFrame, spring, useVideoConfig, staticFile } from 'remotion';
import { COLORS, FONTS } from '../theme';

export const Close: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Scene runs for 90 frames.
  // 0-18:  icon drops in with bounce
  // 18-40: wordmark fades up
  // 30-55: tagline fades up
  // 45-70: App Store badge fades in
  // 70-90: hold, subtle red pulse

  const iconSpring = spring({ frame, fps, config: { damping: 9, stiffness: 140 } });
  const iconScale = interpolate(iconSpring, [0, 1], [0.3, 1]);
  const iconY = interpolate(iconSpring, [0, 1], [-40, 0]);

  const wordmarkOpacity = interpolate(frame, [18, 40], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const wordmarkY = interpolate(frame, [18, 40], [16, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const taglineOpacity = interpolate(frame, [30, 55], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const badgeOpacity = interpolate(frame, [45, 70], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const badgeY = interpolate(frame, [45, 70], [10, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const pulseIntensity = 0.25 + 0.15 * Math.sin(frame * 0.15);

  return (
    <AbsoluteFill
      style={{
        backgroundColor: COLORS.black,
        overflow: 'hidden',
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      {/* Red glow behind content */}
      <div
        style={{
          position: 'absolute',
          inset: 0,
          background: `radial-gradient(circle at 50% 45%, rgba(255,59,48,${pulseIntensity}) 0%, transparent 55%)`,
        }}
      />

      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          gap: 20,
          zIndex: 2,
        }}
      >
        {/* Icon */}
        <div
          style={{
            transform: `translateY(${iconY}px) scale(${iconScale})`,
            filter: `drop-shadow(0 0 30px rgba(255,59,48,${pulseIntensity * 2}))`,
          }}
        >
          <Img
            src={staticFile('icon.png')}
            style={{ width: 160, height: 160, borderRadius: 32 }}
          />
        </div>

        {/* Wordmark */}
        <div
          style={{
            fontFamily: FONTS.system,
            fontWeight: 700,
            fontSize: 92,
            color: COLORS.white,
            letterSpacing: -2,
            opacity: wordmarkOpacity,
            transform: `translateY(${wordmarkY}px)`,
            marginTop: 12,
          }}
        >
          Remindly.
        </div>

        {/* Tagline */}
        <div
          style={{
            fontFamily: FONTS.system,
            fontWeight: 400,
            fontSize: 32,
            color: COLORS.lightGrey,
            letterSpacing: 0.5,
            opacity: taglineOpacity,
          }}
        >
          The reminder you can't ignore.
        </div>

        {/* App Store badge */}
        <div
          style={{
            marginTop: 24,
            background: COLORS.white,
            color: COLORS.black,
            fontFamily: FONTS.system,
            fontWeight: 600,
            fontSize: 22,
            padding: '12px 32px',
            borderRadius: 40,
            display: 'flex',
            alignItems: 'center',
            gap: 10,
            opacity: badgeOpacity,
            transform: `translateY(${badgeY}px)`,
          }}
        >
          <span style={{ fontSize: 24 }}>⌘</span>
          Download on the App Store
        </div>
      </div>
    </AbsoluteFill>
  );
};
