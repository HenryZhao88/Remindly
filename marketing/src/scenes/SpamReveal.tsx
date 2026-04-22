import { AbsoluteFill, interpolate, useCurrentFrame, spring, useVideoConfig } from 'remotion';
import { COLORS, FONTS } from '../theme';
import { IPhoneFrame } from '../components/IPhoneFrame';
import { GrainOverlay } from '../components/GrainOverlay';

// Scene runs for 270 frames. Plan:
//   0-30:    single phone appears, first notification fades in
//   30-180:  notifications multiply on accelerating beat (targets:
//            1, 2, 3, 5, 8, 12, 18, 25, 30 at set frames)
//   180-240: peak — caption "nonstop. until you respond." appears
//   240-270: hold at peak, prepare for STOP cut in scene 5

const NOTIF_SCHEDULE = [
  { frame: 10,  count: 1  },
  { frame: 30,  count: 2  },
  { frame: 55,  count: 3  },
  { frame: 80,  count: 5  },
  { frame: 105, count: 8  },
  { frame: 130, count: 12 },
  { frame: 150, count: 18 },
  { frame: 170, count: 25 },
  { frame: 190, count: 30 },
];

function countAtFrame(frame: number): number {
  let c = 0;
  for (const step of NOTIF_SCHEDULE) {
    if (frame >= step.frame) c = step.count;
  }
  return c;
}

// Deterministic positions for flying notification copies around the phone
const FLYING_POSITIONS = [
  { x: 15, y: 20, rot: -7 },
  { x: 85, y: 25, rot: 6 },
  { x: 12, y: 75, rot: 4 },
  { x: 88, y: 80, rot: -5 },
  { x: 20, y: 45, rot: 3 },
  { x: 80, y: 55, rot: -8 },
  { x: 25, y: 15, rot: 9 },
  { x: 75, y: 90, rot: -3 },
];

export const SpamReveal: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const count = countAtFrame(frame);
  const glowIntensity = Math.min(1, count / 25);

  // Screen vibrate intensifies with count
  const shakeAmount = Math.min(8, count * 0.25);
  const shakeX = Math.sin(frame * 2.3) * shakeAmount;
  const shakeY = Math.cos(frame * 2.7) * shakeAmount * 0.6;

  // Phone entrance
  const phoneEntrance = spring({
    frame,
    fps,
    config: { damping: 12, stiffness: 130 },
  });
  const phoneScale = interpolate(phoneEntrance, [0, 1], [0.4, 1]);

  // Caption appears at frame 180
  const captionOpacity = interpolate(frame, [180, 210], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const captionY = interpolate(frame, [180, 210], [30, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  // Background red pulse
  const bgPulse = glowIntensity * (0.3 + 0.3 * Math.sin(frame * 0.4));

  // How many rows to show on the phone (clamped to 8 for space)
  const rowsOnPhone = Math.min(8, count);

  return (
    <AbsoluteFill
      style={{
        backgroundColor: COLORS.black,
        overflow: 'hidden',
      }}
    >
      {/* Background red pulse */}
      <div
        style={{
          position: 'absolute',
          inset: 0,
          background: `radial-gradient(ellipse at 50% 45%, rgba(255,59,48,${bgPulse}) 0%, transparent 55%)`,
        }}
      />

      <GrainOverlay opacity={0.08} showScanlines={false} />

      {/* Flying notification copies around the phone */}
      {FLYING_POSITIONS.slice(0, Math.min(FLYING_POSITIONS.length, count - 1)).map((p, i) => {
        const appearFrame = 30 + i * 18;
        const inStroke = interpolate(frame, [appearFrame, appearFrame + 10], [0, 1], {
          extrapolateLeft: 'clamp',
          extrapolateRight: 'clamp',
        });
        const jitter = Math.sin((frame + i * 13) * 0.3) * 4;
        return (
          <div
            key={i}
            style={{
              position: 'absolute',
              left: `${p.x}%`,
              top: `${p.y}%`,
              transform: `translate(-50%, -50%) rotate(${p.rot}deg) translateY(${jitter}px) scale(${inStroke})`,
              background: COLORS.red,
              color: COLORS.white,
              fontFamily: FONTS.system,
              fontSize: 20,
              fontWeight: 800,
              padding: '8px 16px',
              borderRadius: 12,
              opacity: inStroke,
              boxShadow: `0 4px 16px rgba(255,59,48,0.5)`,
              whiteSpace: 'nowrap',
            }}
          >
            🔔 Meeting w/ Sam
          </div>
        );
      })}

      {/* Phone center */}
      <div
        style={{
          position: 'absolute',
          left: '50%',
          top: '50%',
          transform: `translate(-50%, -50%) translate(${shakeX}px, ${shakeY}px) scale(${phoneScale})`,
        }}
      >
        <IPhoneFrame width={360} glowIntensity={glowIntensity}>
          {/* Spam banner */}
          <div
            style={{
              background: `linear-gradient(180deg, ${COLORS.red}, ${COLORS.redDeep})`,
              color: COLORS.white,
              fontFamily: FONTS.system,
              fontSize: 15,
              fontWeight: 800,
              padding: '8px 10px',
              borderRadius: 6,
              display: 'flex',
              alignItems: 'center',
              gap: 6,
              marginBottom: 8,
            }}
          >
            <span>🔔</span>
            <span>{count} active alert{count === 1 ? '' : 's'}</span>
          </div>

          {/* Notification rows */}
          {Array.from({ length: rowsOnPhone }).map((_, i) => (
            <div
              key={i}
              style={{
                background: '#1c0a0a',
                padding: '6px 8px',
                borderRadius: 5,
                marginBottom: 4,
                border: `1px solid ${COLORS.redDeep}`,
              }}
            >
              <div
                style={{
                  fontFamily: FONTS.system,
                  fontSize: 10,
                  fontWeight: 800,
                  color: COLORS.red,
                  letterSpacing: 1,
                }}
              >
                HIGH URGENCY
              </div>
              <div
                style={{
                  fontFamily: FONTS.system,
                  fontSize: 12,
                  color: '#eee',
                  marginTop: 2,
                }}
              >
                Meeting w/ Sam
              </div>
              <div
                style={{
                  fontFamily: FONTS.system,
                  fontSize: 10,
                  color: COLORS.midGrey,
                }}
              >
                now
              </div>
            </div>
          ))}
        </IPhoneFrame>
      </div>

      {/* Caption at bottom */}
      <div
        style={{
          position: 'absolute',
          bottom: '8%',
          left: 0,
          right: 0,
          textAlign: 'center',
          fontFamily: FONTS.display,
          fontWeight: 900,
          color: COLORS.white,
          fontSize: 64,
          letterSpacing: -1,
          opacity: captionOpacity,
          transform: `translateY(${captionY}px)`,
          textShadow: '0 4px 20px rgba(0,0,0,0.8)',
        }}
      >
        nonstop. until you respond.
      </div>
    </AbsoluteFill>
  );
};
