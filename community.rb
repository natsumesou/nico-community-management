# coding: utf-8

class NicoCommunityManagement
  class Community
    ENDPOINT = "http://com.nicovideo.jp/live_archives/"

    attr_reader :lives
    def initialize community_id
      @client = HTTPClient.new
      @lives = Array.new
      @community_id = community_id
      @page = 1

      crawler
    end

    def crawler
      response = @client.get(community_url, params)
      puts "crawler... page #{@page}"

      if response.status == 200
        new_lives = parse response.body
        if new_lives.size > 0
          @lives.concat(new_lives)
          @page += 1
          sleep 1
          crawler
        else
          puts "end"
          @lives
        end
      else
        puts "HTTP STATUS ERROR / #{response.status} / request #{community_url} / params #{params}"
      end
    end

    def parse html
      data = Nokogiri::HTML.parse(html, nil)
      history = data.at_xpath("//table[@class='live_history']")
      if history
        lives = history.xpath("//tr")
        parse_lives lives
      else
        Array.new
      end
    end

    def parse_lives lives
      parsed_lives = Array.new
      lives.each do |live|
        x_date = live.at_xpath(".//td[@class='date']")
        next unless x_date
        date = x_date.children.text.gsub(/\s/, "").sub(/開演：/, " ")
        url = live.at_xpath(".//td[@class='title']//a")["href"]
        detail = live_info url
        parsed_lives.push({
          date: Time.parse(date),
          user: live.at_xpath(".//td[@class='user']//div").children.text.gsub(/\n\t*/, ''),
          title: live.at_xpath(".//td[@class='title']//div").children.text.gsub(/\n\t*/, ''),
          description: live.at_xpath(".//td[@class='desc']//div").children.text,
          views: detail[:views],
          comments: detail[:comments],
          url: url,
        })
        sleep 1
      end
      parsed_lives
    end

    def live_info url
      response = @client.get(url)
      if response.status == 200
        if /http:\/\/live.nicovideo.jp\/watch\/(?<live_id>lv[0-9]+)/ =~ url
          parse_live_info(response.body, live_id)
        end
      else
        puts "HTTP STATUS ERROR / #{response.status} / request #{url}"
      end
    end

    def parse_live_info(html, live_id)
      live_info = Nokogiri::HTML.parse(html, nil)
      info = live_info.at_xpath("//div[@class='blbox']//div[@class='hmf']//div[@id='comment_area#{live_id}']").text.gsub(/\s/, '')
      if /来場者数：(?<views>[0-9]+)人コメント数：(?<comments>[0-9]+)/ =~ info
      end
      {
        views: views.to_i,
        comments: comments.to_i,
      }
    end

    def community_url
      File.join(ENDPOINT, @community_id)
    end

    def params
      {
        page: @page,
        bias: 0,
      }
    end
  end
end
