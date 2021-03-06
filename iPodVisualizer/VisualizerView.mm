//
//  VisualizerView.m
//  iPodVisualizer
//

#import "VisualizerView.h"
#import <QuartzCore/QuartzCore.h>
#import "MeterTable.h"

@implementation VisualizerView {
  CAEmitterLayer *emitterLayer;
  CAEmitterCell   *cell;
  CAEmitterCell *childCell;
  CGFloat width;
  CGFloat height;
  MeterTable meterTable;
}

+ (Class)layerClass {
  return [CAEmitterLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setBackgroundColor:[UIColor blackColor]];
    
    //Generate cells
    emitterLayer = (CAEmitterLayer *)self.layer;
    
    width = MAX(frame.size.width, frame.size.height);
    height = MIN(frame.size.width, frame.size.height);
    emitterLayer.emitterPosition = CGPointMake(width/2, height/2);
    emitterLayer.emitterSize = CGSizeMake(width-80, height-100);
    emitterLayer.emitterShape = kCAEmitterLayerRectangle;
    emitterLayer.renderMode = kCAEmitterLayerAdditive;
    
    cell = [CAEmitterCell emitterCell];
    cell.name = @"cell";
    
    //Each cell emits child cells, generating more cells on screen
    childCell = [CAEmitterCell emitterCell];
    childCell.name = @"childCell";
    childCell.lifetime = 1.0f / 60.0f;
    childCell.birthRate = 75.0f;
    childCell.velocity = 0.0f;
    
    int cellNum = arc4random_uniform(18) + 1;
    childCell.contents = (id)[[UIImage imageNamed:[NSString stringWithFormat:@"%i.png", cellNum]] CGImage];
    
    cell.emitterCells = @[childCell];
    
    //Each cell changes colors as time progresses, this declares the range of colors and how quickly they change
    cell.color = [[UIColor colorWithRed:0.2f green:0.6f blue:0.8f alpha:0.7f] CGColor];
    cell.redRange = 0.8f;
    cell.greenRange = 0.4f;
    cell.blueRange = 0.2f;
    cell.alphaRange = 0.8f;
    
    cell.redSpeed = 0.5f;
    cell.greenSpeed = 0.7f;
    cell.blueSpeed = 0.4f;
    cell.alphaSpeed = 0.1f;
    
    //How big and small the cells can scale to, as well as how much they rotate
    cell.scale = 0.5f;
    cell.scaleSpeed = 0.2f;
    cell.scaleRange = 0.5f;
    cell.spin = 1;
    
    //How long cells live
    cell.lifetime = 1.25f;
    cell.lifetimeRange = .5f;
    cell.birthRate = 80;
    
    //How fast cells move
    cell.velocity = 100.0f;
    cell.velocityRange = 300.0f;
    cell.emissionRange = M_PI * 2;
    
    emitterLayer.emitterCells = @[cell];
    
    CADisplayLink *dpLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    [dpLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
  }
  return self;
}

- (void)update
{
  float scale = 0.5;
  if (_audioPlayer.playing )
  {
    [_audioPlayer updateMeters];
    
    //determine how loud the music is
    float power = 0.0f;
    for (int i = 0; i < [_audioPlayer numberOfChannels]; i++) {
      power += [_audioPlayer averagePowerForChannel:i];
    }
    power /= [_audioPlayer numberOfChannels];
    
    float level = meterTable.ValueAt(power);
    scale = level * ((int) 3 + arc4random() % 4);
    //Change color depending on how long the song has been playing
    cell.color = [[UIColor colorWithRed:[_audioPlayer currentTime] / 255.0f green:level blue:level alpha:0.7f] CGColor];
    
    if ((int) [_audioPlayer currentTime] % 10 == 0 && [_audioPlayer currentTime] > 3) {
      //Change cell image after a certain amount of time
      int cellNum = arc4random_uniform(18) + 1;
      childCell.contents = (id)[[UIImage imageNamed:[NSString stringWithFormat:@"%i.png", cellNum]] CGImage];
    }
    
    if ((int) [_audioPlayer currentTime] % 20 == 0 && [_audioPlayer currentTime] > 3) {
      int particleAnim = arc4random_uniform(3);
      switch (particleAnim) {
        case 0:
          //random (not really, more like floating) movement
          emitterLayer.emitterPosition = CGPointMake(width/2, height/2);
          cell.emissionRange = M_PI*2;
          cell.emissionLongitude = 0;
          cell.yAcceleration = 0;
          break;
        case 1:
          //fall down
          emitterLayer.emitterPosition = CGPointMake(width/2, 10);
          cell.emissionRange = M_PI;
          cell.emissionLongitude = M_PI_2;
          cell.yAcceleration = 150;
          break;
        case 2:
          //rise up
          emitterLayer.emitterPosition = CGPointMake(width/2, height-10);
          cell.emissionRange = M_PI;
          cell.emissionLongitude = M_PI_2;
          cell.yAcceleration = -150;
          break;
        default:
          break;
      }
    }
    
  }
  
  //Randomly update the range of colors of the cell
  srand48(3);
  cell.redRange = drand48();
  cell.greenRange = drand48();
  cell.blueRange = drand48();
  cell.alphaRange = drand48();
  
  cell.redSpeed = drand48();
  cell.greenSpeed = drand48();
  cell.blueSpeed = drand48();
  cell.alphaSpeed = drand48();
  
  //Each cell actually moves at a pace determined by the current time, with a range for variation between cells
  cell.velocity = [_audioPlayer currentTime];
  cell.velocityRange = 300.0f;
  
  [emitterLayer setValue:@(scale) forKeyPath:@"emitterCells.cell.emitterCells.childCell.scale"];
}

@end