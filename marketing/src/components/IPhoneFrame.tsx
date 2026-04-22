import React from 'react';
import { COLORS } from '../theme';

interface IPhoneFrameProps {
  width?: number;
  glowIntensity?: number; // 0-1, drives red glow around the frame
  children?: React.ReactNode;
  style?: React.CSSProperties;
}

export const IPhoneFrame: React.FC<IPhoneFrameProps> = ({
  width = 320,
  glowIntensity = 0,
  children,
  style,
}) => {
  const height = width * 2.08; // iPhone-ish aspect
  const borderRadius = width * 0.14;
  const glowSize = 80 + glowIntensity * 120;

  return (
    <div
      style={{
        width,
        height,
        background: COLORS.black,
        borderRadius,
        border: `3px solid ${COLORS.dimGrey}`,
        padding: 12,
        boxShadow: glowIntensity > 0
          ? `0 0 ${glowSize}px rgba(255, 59, 48, ${0.3 + glowIntensity * 0.5}), inset 0 0 0 1px rgba(255,255,255,0.05)`
          : '0 20px 60px rgba(0,0,0,0.5)',
        position: 'relative',
        overflow: 'hidden',
        boxSizing: 'border-box',
        ...style,
      }}
    >
      <div
        style={{
          height: 14,
          width: '30%',
          background: '#000',
          borderRadius: 8,
          margin: '0 auto 10px',
        }}
      />
      <div style={{ position: 'relative' }}>
        {children}
      </div>
    </div>
  );
};
