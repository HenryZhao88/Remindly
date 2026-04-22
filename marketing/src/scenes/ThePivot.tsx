import { AbsoluteFill } from 'remotion';
import { COLORS, FONTS } from '../theme';

export const ThePivot: React.FC = () => (
  <AbsoluteFill style={{ backgroundColor: COLORS.black, alignItems: 'center', justifyContent: 'center' }}>
    <div style={{ color: COLORS.white, fontFamily: FONTS.display, fontSize: 72, letterSpacing: 8 }}>
      SCENE 3 · THE PIVOT
    </div>
  </AbsoluteFill>
);
