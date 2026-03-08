import wave, struct, math, random

# Audio settings
sample_rate = 44100

def generate_noise_sweep(filename, duration, start_vol, end_vol):
    num_samples = int(sample_rate * duration)
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1) # mono
        wav_file.setsampwidth(2) # 2 bytes
        wav_file.setframerate(sample_rate)
        
        for i in range(num_samples):
            # Create a swish sound using colored noise and envelope
            progress = i / num_samples
            envelope = (1.0 - progress) ** 2 # Fast decay
            vol = start_vol + (end_vol - start_vol) * progress
            
            sample = (random.random() * 2 - 1) * 32767.0 * envelope * vol
            
            # Apply a simple low pass filter effect (very rudimentary)
            wav_file.writeframes(struct.pack('h', int(sample)))

def generate_flip_sound(filename, duration):
    num_samples = int(sample_rate * duration)
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        
        # A quick low pitch thump
        start_freq = 150
        end_freq = 50
        for i in range(num_samples):
            progress = i / num_samples
            freq = start_freq + (end_freq - start_freq) * progress
            envelope = math.sin(progress * math.pi) # bump envelope
            
            sample = math.sin(2.0 * math.pi * freq * (i / sample_rate)) * 32767.0 * envelope * 0.5
            wav_file.writeframes(struct.pack('h', int(sample)))

generate_noise_sweep('assets/audio/draw.wav', 0.15, 0.4, 0.0)
generate_flip_sound('assets/audio/flip.wav', 0.2)
print("Audio generation complete.")
