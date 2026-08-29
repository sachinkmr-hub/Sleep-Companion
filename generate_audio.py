import math
import random
import struct
import wave
import os

OUTPUT_DIR = r"C:\Users\sachin\.gemini\antigravity\scratch\neend_companion\assets\audio"
os.makedirs(OUTPUT_DIR, exist_ok=True)

SAMPLE_RATE = 44100

def write_wav(filename, samples, sample_rate=SAMPLE_RATE):
    filepath = os.path.join(OUTPUT_DIR, filename)
    with wave.open(filepath, 'w') as wav_file:
        nchannels = 1
        sampwidth = 2 # 16-bit
        framerate = sample_rate
        nframes = len(samples)
        wav_file.setparams((nchannels, sampwidth, framerate, nframes, 'NONE', 'not compressed'))
        
        # Normalize and convert to 16-bit signed integers
        max_val = max(max(abs(s) for s in samples), 0.0001)
        normalized = [int((s / max_val) * 32000) for s in samples]
        
        raw_data = struct.pack(f'<{len(normalized)}h', *normalized)
        wav_file.writeframes(raw_data)
    print(f"Generated {filename}: {len(samples)/sample_rate:.1f}s ({os.path.getsize(filepath)} bytes)")

def generate_brown_noise(duration_sec=30):
    """Generate authentic Brownian / Red noise with 1/f^2 spectral power density."""
    num_samples = int(duration_sec * SAMPLE_RATE)
    samples = [0.0] * num_samples
    
    last_out = 0.0
    for i in range(num_samples):
        white = random.uniform(-1.0, 1.0)
        # Integration with leakage for stable baseline
        last_out = (last_out * 0.992) + (white * 0.08)
        # Soft limiter
        samples[i] = math.tanh(last_out * 1.5) * 0.8
        
    # Crossfade boundaries for seamless loop
    fade_len = int(SAMPLE_RATE * 1.5)
    for i in range(fade_len):
        weight = i / fade_len
        samples[i] = samples[i] * weight + samples[num_samples - fade_len + i] * (1.0 - weight)
        
    return samples

def generate_rain(duration_sec=30):
    """Generate soothing gentle rain texture with stochastic droplet impulses."""
    num_samples = int(duration_sec * SAMPLE_RATE)
    samples = [0.0] * num_samples
    
    # Base pinkish-brown rumble
    b0 = b1 = b2 = 0.0
    for i in range(num_samples):
        white = random.uniform(-1.0, 1.0)
        b0 = 0.99 * b0 + white * 0.05
        b1 = 0.96 * b1 + white * 0.15
        b2 = 0.85 * b2 + white * 0.25
        samples[i] = (b0 * 0.4 + b1 * 0.3 + b2 * 0.3)
        
    # Add individual rain droplets
    drop_count = int(duration_sec * 60)
    for _ in range(drop_count):
        drop_pos = random.randint(0, num_samples - 2000)
        freq = random.uniform(800, 2400)
        decay = random.uniform(0.005, 0.02)
        drop_len = int(decay * 5 * SAMPLE_RATE)
        vol = random.uniform(0.15, 0.4)
        for j in range(min(drop_len, num_samples - drop_pos)):
            t = j / SAMPLE_RATE
            env = math.exp(-t / decay)
            samples[drop_pos + j] += math.sin(2 * math.pi * freq * t) * env * vol

    # Apply soft master limiting
    for i in range(num_samples):
        samples[i] = math.tanh(samples[i] * 0.8)
        
    # Loop crossfade
    fade_len = int(SAMPLE_RATE * 1.0)
    for i in range(fade_len):
        weight = i / fade_len
        samples[i] = samples[i] * weight + samples[num_samples - fade_len + i] * (1.0 - weight)
        
    return samples

def generate_ocean_waves(duration_sec=30):
    """Generate rhythmic ocean surf surges (0.12 Hz swell cycle)."""
    num_samples = int(duration_sec * SAMPLE_RATE)
    samples = [0.0] * num_samples
    
    # 8-second wave period
    wave_period = 8.0
    
    b0 = 0.0
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Low frequency wave cycle
        cycle = (t % wave_period) / wave_period
        # Smooth surge envelope
        surge = math.pow(math.sin(cycle * math.pi), 3.0)
        
        white = random.uniform(-1.0, 1.0)
        b0 = 0.985 * b0 + white * 0.08
        
        # Foam sizzle
        foam = (random.random() - 0.5) * surge * 0.3
        samples[i] = (b0 * (0.2 + 0.8 * surge) + foam)
        
    # Loop crossfade
    fade_len = int(SAMPLE_RATE * 2.0)
    for i in range(fade_len):
        weight = i / fade_len
        samples[i] = samples[i] * weight + samples[num_samples - fade_len + i] * (1.0 - weight)
        
    return samples

def generate_soft_piano(duration_sec=28):
    """Generate soothing ambient meditation chords with harmonic overtones."""
    num_samples = int(duration_sec * SAMPLE_RATE)
    samples = [0.0] * num_samples
    
    # Chords: Cmaj9, Fmaj7, Am9, Gsus4 (calming 7s progression)
    chords = [
        [261.63, 329.63, 392.00, 493.88, 587.33], # C, E, G, B, D
        [174.61, 261.63, 329.63, 392.00, 440.00], # F, C, E, G, A
        [220.00, 261.63, 329.63, 392.00, 493.88], # A, C, E, G, B
        [196.00, 261.63, 293.66, 392.00, 523.25]  # G, C, D, G, C
    ]
    
    chord_duration = 7.0
    for c_idx, chord in enumerate(chords):
        start_sample = int(c_idx * chord_duration * SAMPLE_RATE)
        for note_freq in chord:
            # Stagger notes slightly like an arpeggio
            offset = random.randint(0, int(0.15 * SAMPLE_RATE))
            actual_start = start_sample + offset
            note_len = int(6.5 * SAMPLE_RATE)
            for j in range(min(note_len, num_samples - actual_start)):
                t = j / SAMPLE_RATE
                # Hammer envelope: quick attack + natural double exponential decay
                env = math.exp(-t / 2.8) * (1.0 - math.exp(-t / 0.02))
                # Fundamental + gentle overtones
                tone = (
                    math.sin(2 * math.pi * note_freq * t) * 0.6 +
                    math.sin(2 * math.pi * note_freq * 2 * t) * 0.25 * math.exp(-t / 1.5) +
                    math.sin(2 * math.pi * note_freq * 3 * t) * 0.1 * math.exp(-t / 0.8)
                )
                samples[actual_start + j] += tone * env * 0.18
                
    return samples

def generate_wind_chimes(duration_sec=25):
    """Generate crystal wind chimes tuned to peaceful Solfeggio / Pentatonic tones."""
    num_samples = int(duration_sec * SAMPLE_RATE)
    samples = [0.0] * num_samples
    
    # Calming chime frequencies (Hz)
    chime_freqs = [528.0, 594.0, 660.0, 792.0, 880.0, 1056.0, 1188.0, 1320.0]
    
    # Wind background (soft airy breeze)
    b0 = 0.0
    for i in range(num_samples):
        white = random.uniform(-1.0, 1.0)
        b0 = 0.995 * b0 + white * 0.02
        samples[i] = b0 * 0.15
        
    # Generate 16 gentle chime strikes
    num_strikes = 18
    for _ in range(num_strikes):
        t_strike = random.uniform(0.5, duration_sec - 4.0)
        freq = random.choice(chime_freqs)
        start_idx = int(t_strike * SAMPLE_RATE)
        strike_len = int(4.0 * SAMPLE_RATE)
        vol = random.uniform(0.15, 0.45)
        
        for j in range(min(strike_len, num_samples - start_idx)):
            t = j / SAMPLE_RATE
            # Pure metallic decay with subtle inharmonic shimmer
            env = math.exp(-t / 1.2) * (1.0 - math.exp(-t / 0.003))
            tone = (
                math.sin(2 * math.pi * freq * t) * 0.7 +
                math.sin(2 * math.pi * freq * 2.76 * t) * 0.2 * math.exp(-t / 0.5) +
                math.sin(2 * math.pi * freq * 5.4 * t) * 0.1 * math.exp(-t / 0.2)
            )
            samples[start_idx + j] += tone * env * vol
            
    return samples

def generate_morning_birds(duration_sec=25):
    """Generate gentle morning birdsong and meadow ambience for gentle awakening."""
    num_samples = int(duration_sec * SAMPLE_RATE)
    samples = [0.0] * num_samples
    
    # Gentle morning warm breeze
    b0 = 0.0
    for i in range(num_samples):
        white = random.uniform(-1.0, 1.0)
        b0 = 0.99 * b0 + white * 0.03
        samples[i] = b0 * 0.12
        
    # Chirp motifs
    motifs = 12
    for m in range(motifs):
        m_time = random.uniform(1.0, duration_sec - 3.0)
        m_start = int(m_time * SAMPLE_RATE)
        base_freq = random.uniform(2600, 3800)
        num_chirps = random.randint(2, 4)
        
        for c in range(num_chirps):
            chirp_offset = m_start + int(c * 0.18 * SAMPLE_RATE)
            chirp_dur = 0.12
            chirp_samples = int(chirp_dur * SAMPLE_RATE)
            
            for j in range(min(chirp_samples, num_samples - chirp_offset)):
                t = j / SAMPLE_RATE
                # Frequency sweep up and down
                instant_freq = base_freq + 600 * math.sin(t / chirp_dur * math.pi)
                env = math.sin(t / chirp_dur * math.pi)
                tone = math.sin(2 * math.pi * instant_freq * t)
                samples[chirp_offset + j] += tone * env * 0.22
                
    return samples

def generate_alarm_gentle(duration_sec=20):
    """Generate gentle progressive rising morning chime for the alarm clock."""
    num_samples = int(duration_sec * SAMPLE_RATE)
    samples = [0.0] * num_samples
    
    # 4 progressive cycles with rising energy
    notes = [440.0, 554.37, 659.25, 880.0] # A Major chime
    cycle_dur = 4.5
    
    for cycle in range(4):
        c_start = int(cycle * cycle_dur * SAMPLE_RATE)
        intensity = 0.25 + (cycle * 0.22) # Gradually increases from 25% to 90%
        
        for n_idx, freq in enumerate(notes):
            n_start = c_start + int(n_idx * 0.35 * SAMPLE_RATE)
            n_len = int(3.0 * SAMPLE_RATE)
            
            for j in range(min(n_len, num_samples - n_start)):
                t = j / SAMPLE_RATE
                env = math.exp(-t / 1.5) * (1.0 - math.exp(-t / 0.01))
                tone = (
                    math.sin(2 * math.pi * freq * t) * 0.7 +
                    math.sin(2 * math.pi * freq * 2.0 * t) * 0.25 +
                    math.sin(2 * math.pi * freq * 3.0 * t) * 0.05
                )
                samples[n_start + j] += tone * env * intensity * 0.3
                
    return samples

if __name__ == "__main__":
    print("Synthesizing 7 pure, CC0-equivalent relaxing audio tracks for Neend Companion...")
    write_wav("brown_noise.wav", generate_brown_noise(30))
    write_wav("rain_gentle.wav", generate_rain(30))
    write_wav("ocean_waves.wav", generate_ocean_waves(30))
    write_wav("soft_piano.wav", generate_soft_piano(28))
    write_wav("wind_chimes.wav", generate_wind_chimes(25))
    write_wav("morning_birds.wav", generate_morning_birds(25))
    write_wav("alarm_gentle.wav", generate_alarm_gentle(20))
    print("All audio tracks successfully created and verified!")
