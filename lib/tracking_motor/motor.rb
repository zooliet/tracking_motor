module TrackingMotor
  class Motor
    attr_reader :sp

    TABLE = [
         0,  94, 188, 226,  97,  63, 221, 131, 194, 156, 126,  32, 163, 253,  31,  65,
        157, 195,  33, 127, 252, 162,  64,  30,  95,   1, 227, 189,  62,  96, 130, 220,
        35, 125, 159, 193,  66,  28, 254, 160, 225, 191,  93,   3, 128, 222,  60,  98,
        190, 224,   2,  92, 223, 129,  99,  61, 124,  34, 192, 158,  29,  67, 161, 255,
        70,  24, 250, 164,  39, 121, 155, 197, 132, 218,  56, 102, 229, 187,  89,   7,
        219, 133, 103,  57, 186, 228,   6,  88,  25,  71, 165, 251, 120,  38, 196, 154,
        101,  59, 217, 135,   4,  90, 184, 230, 167, 249,  27,  69, 198, 152, 122,  36,
        248, 166,  68,  26, 153, 199,  37, 123,  58, 100, 134, 216,  91,   5, 231, 185,
        140, 210,  48, 110, 237, 179,  81,  15,  78,  16, 242, 172,  47, 113, 147, 205,
        17,  79, 173, 243, 112,  46, 204, 146, 211, 141, 111,  49, 178, 236,  14,  80,
        175, 241,  19,  77, 206, 144, 114,  44, 109,  51, 209, 143,  12,  82, 176, 238,
        50, 108, 142, 208,  83,  13, 239, 177, 240, 174,  76,  18, 145, 207,  45, 115,
        202, 148, 118,  40, 171, 245,  23,  73,   8,  86, 180, 234, 105,  55, 213, 139,
        87,   9, 235, 181,  54, 104, 138, 212, 149, 203,  41, 119, 244, 170,  72,  22,
        233, 183,  85,  11, 136, 214,  52, 106,  43, 117, 151, 201,  74,  20, 246, 168,
        116,  42, 200, 150,  21,  75, 169, 247, 182, 232,  10,  84, 215, 137, 107,  53
    ].freeze

    def initialize(dev = '/dev/tty.usbmodem1431', baud = 115200)
      port_str = dev
      # /dev/tty.usbserial
      # /dev/ttyACM0
      baud_rate = baud.to_i
      data_bits = 8
      stop_bits = 1
      parity = SerialPort::NONE

      @sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
    end


    def move(x = 255, y = 255, t = 1000000, rel = 0xff)
      dur = t.to_s.reverse.gsub(/...(?=.)/, '\&,').reverse
      x_axis = x.to_s.reverse.gsub(/...(?=.)/, '\&,').reverse
      y_axis = y.to_s.reverse.gsub(/...(?=.)/, '\&,').reverse
      puts "Moving [x: #{x_axis}, y: #{y_axis}] in #{dur} µs"

      encoded = [x, y, t].pack("I*").unpack("C*")

      buffer = [
        0xd5, 0x1A, 0x8e,
        encoded[0], encoded[1], encoded[2], encoded[3],
        # (x & 0xff) , ((x >> 8) & 0xff), ((x >> 16) & 0xff), ((x >> 24) & 0xff),
        encoded[4], encoded[5], encoded[6], encoded[7],
        # (y & 0xff) , ((y >> 8) & 0xff), ((y >> 16) & 0xff), ((y >> 24) & 0xff),
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        encoded[8], encoded[9], encoded[10], encoded[11],
        # (t & 0xff) , ((t >> 8) & 0xff), ((t >> 16) & 0xff), ((t >> 24) & 0xff),
        rel, 0xFF
      ]

      send_packet(buffer)
    end

    def send_packet(buffer)
      data = buffer[2...-1].pack("c*")
      crc8 =  Digest::CRC81Wire.hexdigest(data)
      buffer[buffer.length-1] = crc8.hex

      # or
      # crc8 = self.crc8_calc(buffer[2...-1])
      # buffer[buffer.length-1] = crc8

      sp.write(buffer.pack("c*"))
    end

    def crc8_calc(data = [])
      crc8 = 0;

      if data.empty?
        test_data = [213, 26, 142, 255, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 64, 66, 15, 0, 0, 55]
        data = test_data[2...-1]
      end

      data.each_with_index do |data, i|
        crc8 = TABLE[crc8 ^ data]
      end
      crc8 #puts crc8.to_s(16)
    end

    def send_init
      buffer = [0xd5, 0x01, 0x01, 0xff]
      send_packet(buffer)
    end

    def axis_enable
      # puts "***All axes enabled"
      buffer = [0xd5, 0x02, 0x89, 0xff, 0xff]
      send_packet(buffer)
    end

    def send_is_finished
      buffer = [0xd5, 0x01, 0x0b, 0xff]
      send_packet(buffer)
    end

    def close
      self.close
    end
  end
end