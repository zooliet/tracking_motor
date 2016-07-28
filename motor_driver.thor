
require 'tracking_motor'
require 'timers'

class App < Thor
  include Thor::Actions

  desc "example", "an example task"
  def example
    puts "Hello, thor"
  end

  desc "motor", "Usage: thor app:motor [repeat] [x] [y] [duration]"
  def motor(repeat = 1, x = 255, y = 255, dur = 1000000)

    devs = [Dir.glob("/dev/tty.usb*"), Dir.glob("/dev/ttyACM*")].flatten
    if devs.size > 0
      motor = TrackingMotor::Motor.new(dev = devs[0])
    else
      puts "[Warning] Motor controller does not exist."
      exit
    end

    timers = Timers::Group.new
    periodic_timer = timers.now_and_every(dur.to_f / 1000000) do
      motor.move(x.to_i, y.to_i, dur.to_i)
    end

    start_time = Time.now.strftime("%H:%M:%S:%L")
    repeat.to_i.times do |n|
      if (n+1) % 100 == 0
        print("|#{n+1}\n")
      else
        print(".")
      end

      timers.wait
    end
    periodic_timer.cancel
    end_time = Time.now.strftime("%H:%M:%S:%L")
    puts "#{start_time} to #{end_time}"
  end
end
