#!/usr/bin/env ruby
$:.push("gen-rb")

# 特定的product_service_period 组合的详细信息
#a particular product_service_period combination
class Product_service_info                                                                            
  def initialize(pro, ser, per, total, ave_res, ave_ser, delay_pv, ave_delay, max, min, ave_ser_per)
    @product = pro
    @service = ser
    @period  = per  # 1 or 60 
    @total_pv = total
    @ave_response_time = ave_res
    @ave_search_period = ave_ser
    @delay_pv_per = delay_pv
    @delay_pv_num = 0
    @ave_delay_pv_response_time = ave_delay 
    @max_delay_response_time = max
    @min_delay_response_time = min
    @ave_delay_search_period = ave_ser_per
  end
  #calculate result 
  def calResult
    @delay_pv_num = @delay_pv_per
    if @delay_pv_per !=nil && @delay_pv_per != 0
      @ave_delay_search_period /=@delay_pv_per
      @ave_delay_pv_response_time /= @delay_pv_per.to_f
    end 
    if @total_pv !=nil && @total_pv != 0
      @ave_response_time /= @total_pv
      @ave_search_period /= @total_pv
      @delay_pv_per /= @total_pv.to_f
    end
    # 
    #formatAllNum
  end
  def formatAllNum
    @ave_response_time = formatOneNum(@ave_response_time)
    @ave_search_period = formatOneNum(@ave_search_period)
    @delay_pv_per      = formatOneNum(@delay_pv_per)
    @ave_delay_pv_response_time = formatOneNum(@ave_delay_pv_response_time)
    @ave_delay_search_period    = formatOneNum(@ave_delay_search_period)
  end
  #4 decimal places 0.0001
  def formatOneNum(num)
    if num.class == Float
      num = num.to_s
      if num.length < 5
        return num 
      end
      flag = num.index(".")
      return  num[0..flag+4]
    else 
      return num 
    end
  end
  attr_accessor:product,:service,:period,:total_pv,:ave_response_time
  attr_accessor:ave_search_period,:delay_pv_num,:ave_delay_pv_response_time                                                             
  attr_accessor:max_delay_response_time,:min_delay_response_time,:ave_delay_search_period,:delay_pv_per
  def to_s 
    return "total_pv: #{@total_pv},ave_response_time: #{@ave_response_time},ave_search_period: #{@ave_search_period},"+
           "delay_pv_num: #{@delay_pv_num} ,delay_pv_per: #{@delay_pv_per},ave_delay_pv_response_time: #{@ave_delay_pv_response_time},"+
           "max_delay_response_time: #{@max_delay_response_time},min_delay_response_time: #{@min_delay_response_time},"+
           "ave_delay_search_period: #{@ave_delay_search_period}"
  end
end

