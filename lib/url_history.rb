module URLHistory
   
  def get_url_history(cookie_name, capacity = URL_HISTORY_SIZE)
    str = cookies[cookie_name.to_sym]
    return URLHistoryContainer.new(str, capacity, cookie_name.to_sym)
  end
  
  def save_url_history(cookie_name, path, history)
     cookies[cookie_name.to_sym] = {
        :value =>  history.encode,
        :path => path,
        :httponly => true
      }
  end

  class URLHistoryContainer
  
    URL_HISTORY_SIZE = 5
  
    #
    # The "URL History" contains the last URL_HISTORY_SIZE
    # urls visited.  It is circular and never fills up, when it 
    # would otherwise be full, the oldest url is overwritten.
    # The cache itself is contained in a cookie whose name is
    # specified (as a symbol) when this class is instantiated.
    #
    # The cookie value is a string of the form:
    #
    #   next_insert|count|capacity|url1|url2|...
    #
    # where
    # 
    # count:: is the number of URLs in the history
    # next_insert:: is the index to insert the next URL
    # capacity:: is the maximum number of URLS in the history
    #
    def initialize(str, capacity, cookie_name)
      @cookie_name = cookie_name
      if str
        decode(str)
      else
        @capacity = capacity
        reset
      end
    end
  
    # Empty the URL history.
    def reset
      @url_buf = []
      @count = 0
      @next_insert = 0
    end
      
    # Add a new URL to the top of the history, but only if it is not
    # already on the top.
    def push_if_new(url)
      unless peek == url
        push url
      end
    end
    
    def push(url)
      @url_buf[@next_insert] = url
      @count = [@count + 1, @capacity].min
      @next_insert = (@next_insert + 1) % @capacity
    end
  
    # Remove the top URL in the history and return it.
    def pop
      if @count > 0
        @next_insert = (@next_insert - 1) % @capacity
        url = @url_buf[@next_insert]
        @url_buf[@next_insert] = nil
        @count -= 1
        return url
      else
        return nil
      end
    end
  
    # Get the top URL in the history.
    def peek
      if @count > 0
        index = (@next_insert - 1) % @capacity
        return @url_buf[index]
      else
        return nil
      end
    end
  
    # Get the second from the top element in the history.
    def peek2
      if @count >= 2
        index = (@next_insert - 2) % @capacity
        return @url_buf[index]
      end
      if @cookie_name == :admin_url_history
        return "/admin/home" # A bad hack.
      else
        return "/"
      end
    end
    
    # Load the state of the URLHistory instance from a string.
    def decode(str)
      @url_buf = str.split('|')
      @next_insert = Integer(@url_buf.shift)
      @count = Integer(@url_buf.shift)
      @capacity = Integer(@url_buf.shift)
    end
    
    # Dump all the state of the URLHistory instance to a string.
    def encode
      encoded = @url_buf.clone
      encoded.unshift String(@capacity)
      encoded.unshift String(@count)
      encoded.unshift String(@next_insert)
      encoded.join('|')
    end
    
    def debug(logger)
      logger.info "History: count=#{@count}, next_insert=#{@next_insert}, " +
        "capacity=#{@capacity}"
      start = (@next_insert - @count) % @capacity
      @count.times do |i|
        index = (start + i) % @capacity
        logger.info "History: [#{index}] ====> #{@url_buf[index]}"
      end
    end
    
  end
end
  
