
require 'tracking_motor'

class App < Thor
  include Thor::Actions

  desc "example", "an example task"
  def example
    puts "Hello, thor"
  end

  desc "motor", "Usage: thor app:motor [dev] [repeat] [x] [y] [duration]"
  def motor(dev="/dev/tty.usbmodem1411", repeat = 1, x = 255, y = 255, dur = 1000000)
    # puts "#{repeat}, #{x}, #{y}, #{dur}"
    m = TrackingMotor::Motor.new(dev)
    # sleep 5 # 5 sec
    start_time = Time.now.strftime("%H:%M:%S:%L")
    repeat.to_i.times do |n|
      if (n+1) % 100 == 0
        print("|#{n+1}\n")
      else
        print(".")
      end
      # p n
      m.move(x.to_i, y.to_i, dur.to_i)
      sleep(dur.to_f / 1000000)
      # sleep(dur.to_f / 1000000)
      # m.move(-x.to_i, -y.to_i, dur.to_i)
    end
    end_time = Time.now.strftime("%H:%M:%S:%L")
    puts "#{start_time} to #{end_time}"
  end
end
