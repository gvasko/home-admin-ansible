import pigpio
import sys

# Get percentage from command line, default to 40 if not provided
percent = int(sys.argv[1]) if len(sys.argv) > 1 else 40

# Convert percentage (0-100) to pigpio duty cycle (0-1,000,000)
duty_cycle = percent * 10000

pi = pigpio.pi()

if not pi.connected:
    print("Could not connect to pigpio daemon!")
    sys.exit(1)

pi.set_mode(18, pigpio.OUTPUT)

# frequency = 25kHz
pi.hardware_PWM(18, 25000, duty_cycle)

print(f"PWM set to {percent}% on GPIO 18")

pi.stop()
