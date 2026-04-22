import { AbsoluteFill, interpolate, useCurrentFrame } from 'remotion';
import { COLORS, FONTS } from '../theme';

const FULL_TEXT = 'What if your phone       to reach you?';
const FOUGHT_START_CHAR = 'What if your phone '.length;
const FOUGHT_END_CHAR = FOUGHT_START_CHAR + 'FOUGHT'.length;

export const ThePivot: React.FC = () => {
  const frame = useCurrentFrame();

  // Type out the text over first ~50 frames
  const charsVisible = Math.floor(interpolate(frame, [0, 50], [0, FULL_TEXT.length], {
    extrapolateRight: 'clamp',
  }));

  // "FOUGHT" reveals from frame 55–65, scales up frame 65–80
  const foughtReveal = interpolate(frame, [55, 65], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const foughtScale = interpolate(frame, [65, 85, 120], [1, 2.2, 2], {
    extrapolateRight: 'clamp',
  });
  const foughtGlow = interpolate(frame, [65, 80], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const foughtShake = Math.sin(frame * 1.2) * Math.max(0, 1 - Math.abs(frame - 70) / 5) * 4;

  // Cursor blinks
  const showCursor = frame % 24 < 12 && frame < 60;

  return (
    <AbsoluteFill
      style={{
        backgroundColor: COLORS.black,
        overflow: 'hidden',
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      <div
        style={{
          fontFamily: FONTS.display,
          fontWeight: 900,
          color: COLORS.white,
          fontSize: 80,
          letterSpacing: -2,
          lineHeight: 1.2,
          textAlign: 'center',
          maxWidth: '70%',
        }}
      >
        {/* Before "FOUGHT" */}
        <span>{FULL_TEXT.slice(0, Math.min(charsVisible, FOUGHT_START_CHAR))}</span>

        {/* "FOUGHT" — appears as one piece at frame 55+ */}
        {frame >= 55 && (
          <span
            style={{
              display: 'inline-block',
              color: COLORS.red,
              fontSize: 80 * foughtScale,
              textShadow: `0 0 ${20 + foughtGlow * 40}px rgba(255,59,48,${0.6 + foughtGlow * 0.4})`,
              transform: `translate(${foughtShake}px, ${foughtShake * 0.4}px)`,
              opacity: foughtReveal,
              verticalAlign: 'middle',
              marginLeft: 12,
              marginRight: 12,
            }}
          >
            FOUGHT
          </span>
        )}

        {/* After "FOUGHT" — " to reach you?" reveals after the fought impact */}
        {charsVisible > FOUGHT_END_CHAR && frame >= 75 && (
          <span>{FULL_TEXT.slice(FOUGHT_END_CHAR, charsVisible)}</span>
        )}

        {showCursor && (
          <span style={{ display: 'inline-block', width: 6, height: '1em', background: COLORS.white, verticalAlign: 'middle', marginLeft: 4 }} />
        )}
      </div>
    </AbsoluteFill>
  );
};
