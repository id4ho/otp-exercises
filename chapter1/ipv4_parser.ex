defmodule ParseIpv4 do
  def parse(packet) do
    {ipv4_packet_as_int, ""} = Integer.parse(packet, 2)
    binary_ipv4 = :binary.encode_unsigned(ipv4_packet_as_int)
    <<
      version :: size(4),
      ihl :: size(4),
      dscp :: size(6),
      ecn :: size(2),
      total_length :: binary-size(2),
      identification :: binary-size(2),
      flags :: size(3),
      fragment_offset :: size(13),
      ttl :: size(8),
      protocol :: size(8),
      checksum :: size(16),
      source :: size(32),
      dest :: size(32),
    >> = binary_ipv4

    IO.puts "Version: #{version}"
    IO.puts "Internet Header Length: #{ihl}"
    IO.puts "Differentiated Services Code Point (Type of Service): #{dscp}"
    IO.puts "Explicit Congestion Notification: #{ecn}"
    IO.puts "Total Length of Packet: #{total_length}"
    IO.puts "Identification: #{inspect(identification)}"
    IO.puts "Flags: #{flags}"
    IO.puts "Fragment Offset: #{fragment_offset}"
    IO.puts "Time to Live: #{ttl}"
    IO.puts "Protocol: #{protocol}"
    IO.puts "Header Checksum: #{checksum}"
    IO.puts "Source: #{source}"
    IO.puts "Destination: #{dest}"
  end
end

ipv4_packet = "0100010100000000000000000110110010010010110011000000000000000000001110000000011000000000000000001001001010010101101110100001010010101001011111000001010110010101"
ParseIpv4.parse(ipv4_packet)
