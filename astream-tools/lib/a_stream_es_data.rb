#!/usr/bin/env ruby

require 'elasticsearch'
require 'jbuilder'
require 'hashie'

#该类的search函数，可以根据传入参数查询es，并返回一个array
#参数形式： 140708 'sf' 'uc' 20140707000000 20140708000000 true
#normal: response为200表示查询正确的请求，false 表示非200
class A_stream_es_data 
  def search(yymmdd, product, service, from, to,normal)
    @index = "chart_stats-"+yymmdd.to_s
    @type  = "chart_stats"
    @product = product
    @service = service
    @from = turnToUnixTimeStamp(from)
    @to   = turnToUnixTimeStamp(to)
    #@timeout = timeout
    @res = 200
    #@terms = { :request => "/v?/events*", :verb => 200}
    @terms = {:response => @res}
    @query_a = buildJson(normal)
    @query_a2 = buildJson(normal)
    @es_client = Elasticsearch::Client.new log: false, url: 'http://10.57.7.78:8200/'
    @response = @es_client.indices.get_settings index: "#{@index}"
    @response_a = @es_client.search index: @index, type: @type, body: @query_a
    @map_a = Hashie::Mash.new @response_a
    #puts  @query_a 
    #puts  @map_a.hits.hits.class
    #puts  @map_a.hits.hits
    #puts  @map_a.hits.hits.size
    return @map_a.hits.hits  # return result array
  end
  #将输入的20140708000000 时间转换成unix 时间戳
  #turn input time to unix timestamp
  def turnToUnixTimeStamp(time)
    if time.to_s.length == 14
      time_s = time.to_s
      y = time_s[0..3]
      m = time_s[4..5]
      d = time_s[6..7]
      h = time_s[8..9]
      min = time_s[10..11]
      s = time_s[12..13]
      ti  = Time.local(y,m,d,h,min,s)		
      return ti.to_i*1000	
    end
  end
  #build json 根据参数，构建查询es的json
  def buildJson(normal)
    @returnterms = ["agent_time","request","response","response_time"]
    @normal = normal  #200 or ohers, normal or innormal
    if @prodect != "" 
      if @service != ""
        @message={ :message =>  "product=#{@product}&service=#{@service}",:request => "events" }
      else 
        @message = {:message => "product=#{@product}",:request => "events"}
      end
    else 
      @message = {:request => "events"}
    end
    query = Jbuilder.encode do |json|
      json.from 0
      json.size 10000000 # shouble be a very big num,for test 100    
      json.query do
        json.bool do
          if @normal != nil && @normal == true
            json.must do
              json.array! @terms do |key, value|
                json.term do
                  json.set! key,value
                end
              end
            end
          else
            json.must_not do
              json.array! @terms do |key, value|
                json.term do
                  json.set! key,value
                end
              end
            end
          end
          json.must do
            json.array! @message do |key ,value|
              json.match_phrase do
                  json.set! key,value
              end 
            end
          end
        end  
      end
      json.filter do
        json.range do # in_time  agent_time
          json.agent_time do
            json.gte @from
            json.lte @to
          end
        end
      end
      json._source @returnterms
    end
      return query
    end
end	
