/**
  * This sketch demonstrates a variety of sounds being passed
  * through a variety of filters. Sounds are generated using
  * an oscilator object or sampling I've done myself. By using 
  * the keyboard keys, you can change the sound/waveform being
  * used to make sound as well as the type of filters, like the
  * moog filter which uses, High, Low, and Band as options.
  */

//minim imports
import ddf.minim.*;
import ddf.minim.ugens.*;

// Need an object for the minim system
Minim       minim;
// Need an object for the output to the speakers
AudioOutput out;
// Need a unit generator for the oscillator
Oscil       wave;
// Need a sound file reader
Sampler     snd;

//Filters and effects (UGens)
//Flanger effect
Flanger flange;
//Moog Filter
MoogFilter moog;

void setup()
{
  // Width is the number of samples in the sample table
  size(512, 200);
  
  // Magic words to create an object for the audio system
  minim = new Minim(this);
  
  // Use the getLineOut method of the Minim object to get an AudioOutput object
  out = minim.getLineOut();
  
  // Sound file samplers, the 4 represents the number of concurrent "voices" that can exist for this sound
  snd = new Sampler ("Rimshot.wav", 4, minim);
  
  // Create a sine wave Oscil object, set to 440 Hz, at 0.5 amplitude
  wave = new Oscil( 440, 0.5f, Waves.SINE );
  
  //Set our wave's amplitude and frequency
  wave.setAmplitude( 0.9 );
  wave.setFrequency( 500 );
  
  //Set up our flanger
  flange = new Flanger( 1, 7.0f, 1, 0.9f, 0.2f, 0.2f);
  
  //Set up our moog filter and give it a default type
  moog = new MoogFilter( 1200, 0.5f );
  moog.type = MoogFilter.Type.HP;
  
  // Patch the Oscil to the output so we can hear it
  wave.patch(flange).patch(moog).patch( out );
}

// Use draw to display the waveform in green & the output in white
void draw()
{
  background(0);

  // Draw the waveform shape we are using in the oscillator
  stroke( 0, 255, 0 );  // Green
  strokeWeight(4);      // Big pixels
  for( int i = 0; i < width-1; ++i )
  {
    point( i, height/2.0 -
               height*0.49*wave.getWaveform().value((float)i/width) );
  }

  // Draw the actual waveform in real time
  stroke(255);          // White on black
  strokeWeight(1);  
  // Draw the waveform of the output in stereo
  for(int i = 0; i < out.bufferSize() - 1; i++)
  {
    line( i,  50-out.left.get(i)*50,  i+1,  50-out.left.get(i+1)*50 );
    line( i, 150-out.right.get(i)*50, i+1, 150-out.right.get(i+1)*50 );
  }
}

void mouseMoved()
{
  // Maps mouseY in range from 0 to height to the range 0.9 to 0 (0.0 to 0.9)
  float feedback = map( mouseY, 0, height, 0.9, 0 );
  //Set the falnger's feedback
  flange.feedback.setLastValue( feedback );
  
  // Maps mouseX in range from 0 to width to the range 0.9 to 0 (0.0 to 0.9)
  float resonance = map( mouseX, 0, width-1, 0.9, 0 );
  //Set the moog filter's resonance
  moog.resonance.setLastValue(resonance);
}

void keyPressed()
{ 
  // Use number keys to change the waveform for the wave object and the moog filter's pass type
  switch( key )
  {
    case 'q': 
      wave.setWaveform( Waves.SINE );
      break;
     
    case 'w':
      wave.setWaveform( Waves.TRIANGLE );
      break;
     
    case 'e':
      wave.setWaveform( Waves.SAW );
      break;
    
    case 'r':
      wave.setWaveform( Waves.SQUARE );
      break;
      
    case 'a':
      wave.setWaveform( Waves.QUARTERPULSE );
      break;
      
    case 's':
      moog.type = MoogFilter.Type.HP;
      break;
      
    case 'd':
      moog.type = MoogFilter.Type.LP;
      break;
      
    case 'f':
      moog.type = MoogFilter.Type.BP;
      break;
    
    case 'u':
      wave.unpatch( out );
      snd.patch( out );
      snd.trigger();
     
    default: break; 
  }
}

