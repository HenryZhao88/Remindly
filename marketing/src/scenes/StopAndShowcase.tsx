import { AbsoluteFill } from 'remotion';
import { COLORS, FONTS } from '../theme';

export const StopAndShowcase: React.FC = () => (
  <AbsoluteFill style={{ backgroundColor: COLORS.nearBlack, alignItems: 'center', justifyContent: 'center' }}>
    <div style={{ color: COLORS.white, fontFamily: FONTS.display, fontSize: 72, letterSpacing: 8 }}>
      SCENE 5 · SHOWCASE
    </div>
  </AbsoluteFill>
);
