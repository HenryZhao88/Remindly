import { AbsoluteFill, interpolate, useCurrentFrame, spring, useVideoConfig } from 'remotion';
import { COLORS, FONTS } from '../theme';
import { IPhoneFrame } from '../components/IPhoneFrame';

// Scene runs for 150 frames.
//   0-18:    STOP button slam (thumb press)
//   18-25:   flash to white, screen calms
//   25-80:   three phones fly in (staggered)
//   80-140:  caption "Five urgency levels. One you can't miss."
//   140-150: hold

export const StopAndShowcase: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // STOP button press
  const stopPress = spring({ frame, fps, config: { damping: 10, stiffness: 200 } });
  const stopPressScale = interpolate(stopPress, [0, 1], [1.4, 1]);
  const stopButtonVisible = frame < 22;

  // Flash to white
  const flashOpacity = interpolate(frame, [15, 20, 26], [0, 1, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  // Phones fly in
  const phoneSpring = (startFrame: number) =>
    spring({
      frame: frame - startFrame,
      fps,
      config: { damping: 14, stiffness: 130 },
    });

  const leftPhoneProgress = phoneSpring(25);
  const centerPhoneProgress = phoneSpring(35);
  const rightPhoneProgress = phoneSpring(45);

  // Caption
  const captionOpacity = interpolate(frame, [80, 100], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        background: `linear-gradient(135deg, ${COLORS.dimGrey} 0%, ${COLORS.nearBlack} 100%)`,
        overflow: 'hidden',
      }}
    >
      {/* STOP button (phase 1) */}
      {stopButtonVisible && (
        <div
          style={{
            position: 'absolute',
            left: '50%',
            top: '50%',
            transform: `translate(-50%, -50%) scale(${stopPressScale})`,
            background: COLORS.red,
            color: COLORS.white,
            fontFamily: FONTS.display,
            fontWeight: 900,
            fontSize: 120,
            letterSpacing: 12,
            padding: '40px 100px',
            borderRadius: 20,
            boxShadow: `0 0 ${60 * stopPress}px rgba(255,59,48,0.8)`,
          }}
        >
          STOP
        </div>
      )}

      {/* Flash */}
      <div
        style={{
          position: 'absolute',
          inset: 0,
          background: COLORS.white,
          opacity: flashOpacity,
          pointerEvents: 'none',
        }}
      />

      {/* Three phones */}
      {frame >= 25 && (
        <div
          style={{
            position: 'absolute',
            inset: 0,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: 60,
          }}
        >
          {/* LEFT: Calendar */}
          <div
            style={{
              transform: `translateY(${(1 - leftPhoneProgress) * 80}px) rotate(-6deg) scale(${0.8 + leftPhoneProgress * 0.2})`,
              opacity: leftPhoneProgress,
            }}
          >
            <IPhoneFrame width={240} style={{ background: '#fff', border: '2px solid #e0e0e0' }}>
              <MiniCalendar />
            </IPhoneFrame>
          </div>

          {/* CENTER: List */}
          <div
            style={{
              transform: `translateY(${(1 - centerPhoneProgress) * 80}px) scale(${0.9 + centerPhoneProgress * 0.2})`,
              opacity: centerPhoneProgress,
              zIndex: 2,
            }}
          >
            <IPhoneFrame width={260} style={{ background: '#fff', border: '2px solid #e0e0e0' }}>
              <MiniList />
            </IPhoneFrame>
          </div>

          {/* RIGHT: Urgency Picker */}
          <div
            style={{
              transform: `translateY(${(1 - rightPhoneProgress) * 80}px) rotate(6deg) scale(${0.8 + rightPhoneProgress * 0.2})`,
              opacity: rightPhoneProgress,
            }}
          >
            <IPhoneFrame width={240} style={{ background: '#fff', border: '2px solid #e0e0e0' }}>
              <MiniUrgencyPicker />
            </IPhoneFrame>
          </div>
        </div>
      )}

      {/* Caption */}
      <div
        style={{
          position: 'absolute',
          bottom: '6%',
          left: 0,
          right: 0,
          textAlign: 'center',
          fontFamily: FONTS.display,
          fontWeight: 900,
          color: COLORS.white,
          fontSize: 54,
          letterSpacing: -1,
          opacity: captionOpacity,
          lineHeight: 1.1,
        }}
      >
        Five urgency levels.
        <br />
        <span style={{ color: COLORS.red }}>One you can't miss.</span>
      </div>
    </AbsoluteFill>
  );
};

// --- Mini UI snippets ---

const MiniCalendar: React.FC = () => {
  const dayColor = (i: number): string => {
    const colors: Record<number, string> = {
      2: COLORS.green,
      4: COLORS.orange,
      8: COLORS.red,
      10: COLORS.purple,
      13: COLORS.orangeDeep,
      17: COLORS.green,
      19: COLORS.red,
    };
    return colors[i] ?? '#f5f5f7';
  };
  return (
    <div style={{ padding: 4 }}>
      <div style={{ fontFamily: FONTS.system, fontWeight: 700, fontSize: 14, color: '#1a1a1a', marginBottom: 6 }}>
        April 2026
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: 3 }}>
        {Array.from({ length: 28 }).map((_, i) => (
          <div
            key={i}
            style={{
              aspectRatio: 1,
              background: dayColor(i),
              borderRadius: 3,
            }}
          />
        ))}
      </div>
    </div>
  );
};

const MiniList: React.FC = () => {
  const items = [
    { title: 'Meeting w/ Sam',    time: 'Today, 2:00 PM',    color: COLORS.red,    bg: '#fff6f5' },
    { title: 'Flight to JFK',     time: 'Tomorrow, 6:30 AM', color: COLORS.orange, bg: '#fff9ee' },
    { title: 'Pick up groceries', time: 'Fri, 5:00 PM',      color: COLORS.green,  bg: '#f2fff4' },
    { title: 'Team standup',      time: 'Mon, 10:00 AM',     color: COLORS.purple, bg: '#f3f3ff' },
  ];
  return (
    <div style={{ padding: 4 }}>
      <div style={{ display: 'flex', gap: 4, marginBottom: 6 }}>
        {[COLORS.red, COLORS.green, COLORS.orange, COLORS.purple].map((c, i) => (
          <div
            key={i}
            style={{
              fontSize: 9,
              background: c,
              color: COLORS.white,
              padding: '3px 8px',
              borderRadius: 12,
              fontFamily: FONTS.system,
              fontWeight: 700,
            }}
          >
            ●
          </div>
        ))}
      </div>
      {items.map((item, i) => (
        <div
          key={i}
          style={{
            background: item.bg,
            borderLeft: `4px solid ${item.color}`,
            padding: 6,
            marginBottom: 4,
            borderRadius: 3,
          }}
        >
          <div style={{ fontFamily: FONTS.system, fontWeight: 600, fontSize: 11, color: '#1a1a1a' }}>
            {item.title}
          </div>
          <div style={{ fontFamily: FONTS.system, fontSize: 9, color: '#999' }}>
            {item.time}
          </div>
        </div>
      ))}
    </div>
  );
};

const MiniUrgencyPicker: React.FC = () => {
  const levels: Array<{ label: string; color: string; selected?: boolean }> = [
    { label: 'None', color: COLORS.green },
    { label: 'Low', color: COLORS.orange },
    { label: 'Meeting', color: COLORS.orangeDeep },
    { label: 'High', color: COLORS.red, selected: true },
    { label: 'Custom', color: COLORS.purple },
  ];
  return (
    <div style={{ padding: 4 }}>
      <div style={{ fontFamily: FONTS.system, fontWeight: 700, fontSize: 12, color: '#1a1a1a', marginBottom: 6 }}>
        Urgency
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
        {levels.map((lvl, i) => (
          <div
            key={i}
            style={{
              background: lvl.color,
              color: COLORS.white,
              fontFamily: FONTS.system,
              fontWeight: 700,
              fontSize: 11,
              padding: '6px 12px',
              borderRadius: 10,
              border: lvl.selected ? `2px solid ${COLORS.white}` : '2px solid transparent',
            }}
          >
            {lvl.label} {lvl.selected && '✓'}
          </div>
        ))}
      </div>
    </div>
  );
};
