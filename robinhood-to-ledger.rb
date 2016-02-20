require 'optparse'
require 'csv'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: robinhood-to-ledger.rb [options]"
  opts.on('-t', '--trades FILE', 'CSV with trades') { |v| options[:trades] = v }
end.parse!

CSV.foreach(options[:trades], headers: true) do |trade|
  date = trade['created_at'][0..9].gsub('-','/')
  puts("#{date} #{trade['side']} #{trade['symbol']}")

  quantity = trade['cumulative_quantity'].to_i
  price = trade['price'].to_f.round(2)
  total = (quantity * price).round(2)
  symbol = trade['symbol']
  fees = trade['fees'].to_f

  if(trade['side'] == 'buy')
    puts("  assets:stocks:robinhood  #{quantity} #{symbol} @ $#{price}")
    puts("  assets:cash:robinhood    -$#{total}")
    puts(" ")
  elsif(trade['side'] == 'sell')
    total -= fees
    puts("  assets:cash:robinhood    $#{total}")
    puts("  assets:stocks:robinhood  -#{quantity} #{symbol} @ $#{price}")
    puts("  expenses:fees:robinhood  $#{fees}")
    puts(" ")
  end
end

