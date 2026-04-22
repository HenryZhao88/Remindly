import { AbsoluteFill, Audio, Sequence, Series, staticFile } from 'remotion';
import { ColdOpen } from './scenes/ColdOpen';
import { TheProblem } from './scenes/TheProblem';
import { ThePivot } from './scenes/ThePivot';
import { SpamReveal } from './scenes/SpamReveal';
import { StopAndShowcase } from './scenes/StopAndShowcase';
import { Close } from './scenes/Close';
import { COLORS, SCENES, sceneDuration } from './theme';

// Audio cue schedule — all offsets in absolute frames from video start.
// Matches storyboard audio beats from the spec.
const IMPACTS_AT: number[] = [
  60,   // Scene 1 title reveal
  330,  // Scene 3 FOUGHT hit
  820,  // Scene 6 final impact
];

const HEARTBEATS_AT: number[] = [
  120,  // Scene 2 — under "MISSED"
  200,  // Scene 2 — under "FORGOT"
  290,  // Scene 3 — single thump before FOUGHT
];

const GLITCHES_AT: number[] = [
  10,   // Scene 1 open
  95,   // Scene 2 first cut
  155,  // Scene 2 second cut
  215,  // Scene 2 third cut
];

// Scene 4 notification cascade — accelerating beat, matches NOTIF_SCHEDULE in SpamReveal
const NOTIF_CHIMES_AT: number[] = [
  400,  // 1st notif (frame 10 of scene 4)
  420,  // 2nd
  445,  // 3rd
  470,  // 5 total
  495,  // 8
  520,  // 12
  540,  // 18
  560,  // 25
  580,  // 30 — peak
];

export const RemindlyVideo: React.FC = () => {
  return (
    <AbsoluteFill style={{ backgroundColor: COLORS.black }}>
      {/* ----- VISUAL TIMELINE ----- */}
      <Series>
        <Series.Sequence durationInFrames={sceneDuration('coldOpen')}>
          <ColdOpen />
        </Series.Sequence>
        <Series.Sequence durationInFrames={sceneDuration('theProblem')}>
          <TheProblem />
        </Series.Sequence>
        <Series.Sequence durationInFrames={sceneDuration('thePivot')}>
          <ThePivot />
        </Series.Sequence>
        <Series.Sequence durationInFrames={sceneDuration('spamReveal')}>
          <SpamReveal />
        </Series.Sequence>
        <Series.Sequence durationInFrames={sceneDuration('showcase')}>
          <StopAndShowcase />
        </Series.Sequence>
        <Series.Sequence durationInFrames={sceneDuration('close')}>
          <Close />
        </Series.Sequence>
      </Series>

      {/* ----- AUDIO TIMELINE ----- */}

      {/* Music bed — plays the full 30 seconds */}
      <Audio src={staticFile('audio/music-bed.wav')} volume={0.7} />

      {/* Impact hits */}
      {IMPACTS_AT.map((frame, i) => (
        <Sequence key={`impact-${i}`} from={frame} durationInFrames={30}>
          <Audio src={staticFile('audio/impact.wav')} volume={0.9} />
        </Sequence>
      ))}

      {/* Heartbeats */}
      {HEARTBEATS_AT.map((frame, i) => (
        <Sequence key={`heart-${i}`} from={frame} durationInFrames={50}>
          <Audio src={staticFile('audio/heartbeat.wav')} volume={0.6} />
        </Sequence>
      ))}

      {/* Glitches on hard cuts */}
      {GLITCHES_AT.map((frame, i) => (
        <Sequence key={`glitch-${i}`} from={frame} durationInFrames={12}>
          <Audio src={staticFile('audio/glitch.wav')} volume={0.45} />
        </Sequence>
      ))}

      {/* Notification cascade in Scene 4 — volume increases with count to build intensity */}
      {NOTIF_CHIMES_AT.map((frame, i) => {
        const intensity = 0.4 + (i / NOTIF_CHIMES_AT.length) * 0.4;
        return (
          <Sequence key={`notif-${i}`} from={frame} durationInFrames={12}>
            <Audio src={staticFile('audio/notification.wav')} volume={intensity} />
          </Sequence>
        );
      })}

      {/* Scene 6 final impact for logo drop */}
      <Sequence from={SCENES.close.start + 10} durationInFrames={30}>
        <Audio src={staticFile('audio/impact.wav')} volume={0.75} />
      </Sequence>
    </AbsoluteFill>
  );
};
