import { AbsoluteFill } from 'remotion';
import { COLORS, FONTS } from '../theme';

export const SpamReveal: React.FC = () => (
  <AbsoluteFill style={{ backgroundColor: COLORS.black, alignItems: 'center', justifyContent: 'center' }}>
    <div style={{ color: COLORS.red, fontFamily: FONTS.display, fontSize: 72, letterSpacing: 8 }}>
      SCENE 4 · SPAM REVEAL
    </div>
  </AbsoluteFill>
);
