#include <stdio.h>
#include <stdlib.h>
#include <math.h>

double ascender(double tx) {
  double oct = tx / 16.0;
  if (oct < 10.0)
    return exp(oct * log(2.0));
  else
    return 0.0;
}

double fader(double tx) {
  double tx2 = tx * tx;
  return tx2 / (1.0 + tx2 * tx2);
}

double dsp(int tn) {
  double tx0 = tn / 44100.0;
  double amp = 0.0;
  double pi2 = 2.0 * acos(-1.0);
  int tones = 1 + ((int) tx0) / 16;
  for (int i = 0; i < tones; i++) {
    double tx = tx0 - 16.0 * i;
    double freq = ascender(tx);
    double ax = fader(tx);
    amp += 1.8 * ax * sin(pi2 * (0.1 * i + 20.0 * freq * tx));
  }
  if (amp > 1.0) amp = 1.0;
  if (amp < -1.0) amp = -1.0;
  return amp;
}

void fputi(int x, int nbytes, FILE *f) {
  for (int i = 0; i < nbytes; i++) {
    fputc((x >> (i << 3)) & 0xFF, f);
  }
}

int main(int argc, char *argv[]) {
  int samplerate = 44100;
  int nsamples = samplerate * 240;
  int bytesize = nsamples * 2;

  fprintf(stdout, "RIFF");
  fputi(bytesize + 36, 4, stdout); // ChunkSize
  fprintf(stdout, "WAVE");

  fprintf(stdout, "fmt ");
  fputi(16, 4, stdout); // SubChunkSize
  fputi(1, 2, stdout); // AudioFormat
  fputi(1, 2, stdout); // NumChannels
  fputi(samplerate, 4, stdout); // SampleRate
  fputi(samplerate * 2, 4, stdout); // ByteRate
  fputi(2, 2, stdout); // BlockAlign
  fputi(16, 2, stdout); // BitsPerSample

  fprintf(stdout, "data");
  fputi(bytesize, 4, stdout);

  int maxAmplitude = 0;

  for (int tn = 0; tn < nsamples; tn++) {
    int sample = (int) (32767 * dsp(tn));
    int asample = abs(sample);
    if (asample > maxAmplitude) maxAmplitude = asample;
    fputi(sample, 2, stdout);
  }
  fprintf(stderr, "%d", maxAmplitude);
  return 0;
}

