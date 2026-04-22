import { AbsoluteFill, Series } from 'remotion';
import { ColdOpen } from './scenes/ColdOpen';
import { TheProblem } from './scenes/TheProblem';
import { ThePivot } from './scenes/ThePivot';
import { SpamReveal } from './scenes/SpamReveal';
import { StopAndShowcase } from './scenes/StopAndShowcase';
import { Close } from './scenes/Close';
import { COLORS, sceneDuration } from './theme';

export const RemindlyVideo: React.FC = () => {
  return (
    <AbsoluteFill style={{ backgroundColor: COLORS.black }}>
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
    </AbsoluteFill>
  );
};
