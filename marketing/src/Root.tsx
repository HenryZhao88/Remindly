import { Composition } from 'remotion';
import { RemindlyVideo } from './RemindlyVideo';
import { FPS, HEIGHT, TOTAL_FRAMES, WIDTH } from './theme';

export const Root: React.FC = () => {
  return (
    <Composition
      id="RemindlyVideo"
      component={RemindlyVideo}
      durationInFrames={TOTAL_FRAMES}
      fps={FPS}
      width={WIDTH}
      height={HEIGHT}
    />
  );
};
