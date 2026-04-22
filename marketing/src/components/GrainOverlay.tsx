import { useCurrentFrame } from 'remotion';

interface GrainOverlayProps {
  opacity?: number;
  showScanlines?: boolean;
}

export const GrainOverlay: React.FC<GrainOverlayProps> = ({
  opacity = 0.08,
  showScanlines = true,
}) => {
  const frame = useCurrentFrame();
  // Regenerate grain seed per frame for a live grain effect
  const grainOffset = (frame * 7) % 40;

  return (
    <>
      <div
        aria-hidden
        style={{
          position: 'absolute',
          inset: 0,
          pointerEvents: 'none',
          backgroundImage: `radial-gradient(circle at ${20 + grainOffset}% ${30 + grainOffset}%, rgba(255,255,255,0.05) 0px, transparent 1px),
                            radial-gradient(circle at ${70 - grainOffset}% ${60 + grainOffset}%, rgba(0,0,0,0.08) 0px, transparent 1px),
                            radial-gradient(circle at ${40 + grainOffset}% ${80 - grainOffset}%, rgba(255,255,255,0.04) 0px, transparent 1px)`,
          backgroundSize: '3px 3px, 5px 5px, 4px 4px',
          opacity,
          mixBlendMode: 'overlay',
        }}
      />
      {showScanlines && (
        <div
          aria-hidden
          style={{
            position: 'absolute',
            inset: 0,
            pointerEvents: 'none',
            backgroundImage:
              'repeating-linear-gradient(0deg, transparent 0 2px, rgba(255,255,255,0.025) 2px 3px)',
            mixBlendMode: 'overlay',
          }}
        />
      )}
    </>
  );
};
