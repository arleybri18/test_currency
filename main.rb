require_relative 'currency_service'

puts "Build object with currency information between two dates (start_date >= end_date)"

puts "Please enter start date format('YYYY/MM/DD')"
start_date = gets.chomp
puts "Please enter end date format('YYYY/MM/DD')"
end_date = gets.chomp
result = CurrencyService.values(start_date, end_date)
p result
