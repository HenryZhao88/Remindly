import { AbsoluteFill } from 'remotion';
import { COLORS, FONTS } from '../theme';

export const TheProblem: React.FC = () => (
  <AbsoluteFill style={{ backgroundColor: COLORS.nearBlack, alignItems: 'center', justifyContent: 'center' }}>
    <div style={{ color: COLORS.white, fontFamily: FONTS.display, fontSize: 72, letterSpacing: 8 }}>
      SCENE 2 · THE PROBLEM
    </div>
  </AbsoluteFill>
);
