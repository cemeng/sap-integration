#!/Users/cemeng/.rubies/jruby-9.0.5.0/bin/jruby -w

require 'ruby-sapjco'
require 'yaml'
require 'pry'

SapJCo::Configuration.configure(default_destination: :test)

rfc = SapJCo::Function.new('/RBR1/P_AU_RFC_IW41'.to_sym)
out = rfc.execute do |params, tables|
  params[:TESTRUN] = ''
  tables[:TIMETICKETS] = [
    {
      ORDERID: '000004125822',
      OPERATION: '0020',
      PLANT: 'SG10',
      ACT_WORK: 4.5,
      UN_WORK: 'H',
      PERS_NO: '16100042'
    }
  ]
end
puts out

