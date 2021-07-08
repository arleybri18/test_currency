require 'open-uri'
require 'net/http'
require 'nokogiri'
require 'byebug'
require 'pry'

class CurrencyService

  @@currencies = {}

  def self.values(from_date, to_date)
    if from_date && to_date
      url = "https://si3.bcentral.cl/Bdemovil/BDE/IndicadoresDiarios?fecha="
      start_date = Date.parse(from_date)
      end_date = Date.parse(to_date)

      (start_date..end_date).each do |day|
        date = day.strftime('%d-%m-%Y')
        unparsed_html = make_request(url + date)
        currency_values = scrape(unparsed_html)
        make_object(currency_values, date)
      end
      calculate_diff(start_date, end_date)
    end
    @@currencies
  end

  def self.make_request(url)
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)
    response.body
  end

  def self.scrape(unparsed_html)
    parsed_html = Nokogiri::HTML(unparsed_html)
    dolar = parsed_html.css('.tableUnits')[1].css('tr').first.css('td')[1].css('p').inner_text
    uf = parsed_html.css('.tableUnits')[0].css('tr').first.css('td')[1].css('p').inner_text
    [dolar, uf]
  end

  def self.make_object(currency_values, date)
    data = {}
    data[date] = {
      usd: {
        today: currency_values[0],
        diff: nil
      },
      uf: {
        today: currency_values[1],
        diff: nil
      }
    }
    @@currencies.merge!(data)
  end

  def self.calculate_diff(start_date, end_date)
    dates = []
    end_date.downto(start_date).each {|d| dates.push(d.strftime('%d-%m-%Y'))}
    if dates.size > 1
      dates.each_with_index do |date, index|
        next_index = index + 1
        if next_index < dates.size
          usd_current_value = @@currencies[date][:usd][:today].to_f
          usd_previous_value = @@currencies[dates[next_index]][:usd][:today].to_f
          uf_current_value = @@currencies[date][:uf][:today].to_f
          uf_previous_value = @@currencies[dates[next_index]][:uf][:today].to_f
          @@currencies[date][:usd][:diff] = (usd_current_value - usd_previous_value).to_s
          @@currencies[date][:uf][:diff] = (uf_current_value - uf_previous_value).to_s
        end
      end
    end
  end
end

=begin

.tableUnits table
https://si3.bcentral.cl/Bdemovil/BDE/IndicadoresDiarios?parentMenuName=Indicadores%20diarios&fecha=07-07-2021

UF  primera tabla > primer tr > segundo td > p

Dolar  segunda tabla > primer tr > segundo td > p

06-07-2021

UF 

USDCLP

1 USD - 732 CLP


1UF - x CLP





        "USDCLP": 732.699352,
        "USDCLF": 0.026554
=end
