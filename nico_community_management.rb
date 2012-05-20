# coding: utf-8
require './community'

class NicoCommunityManagement
  @@google_user
  @@google_pass
  @@google_sheet_key
  @@nico_community

  DATE = "放送開始日時"
  USER = "ユーザ名"
  TITLE = "タイトル"
  DESCRIPTION = "説明"
  VIEWS = "再生数"
  COMMENTS = "コメント数"
  URL = "url"

  def self.run
    management = self.new
    if File.exist?("#{@@nico_community}.tsv")
      lives = Array.new
      puts "./#{@@nico_community}.tsv"
      CSV.open("./#{@@nico_community}.tsv", "r", "\t") do |row|
        puts row
      end
    else
      community = NicoCommunityManagement::Community.new @@nico_community
      lives = community.lives
      management.create_tsv lives
    end
    management.create lives
  end

  def create_tsv lives
    tsv = ""
    lives.each do |live|
      tsv += "#{live[:date].strftime("%Y/%m/%d %X")}\t#{live[:user]}\t#{live[:title]}\t#{live[:description]}\t#{live[:views]}\t#{live[:comments]}\t#{live[:url]}\n"
    end
    file = open("#{@@nico_community}.tsv", "w")
    file.write(tsv)
    file.close
  end

  def create lives
    session = GoogleDrive.login(@@google_user, @@google_pass)
    ws = session.spreadsheet_by_key(@@google_sheet_key).worksheets[0]
    reset_sheet ws
    lives.each_with_index do |live, i|
      ws[ i + 2, 2] = live[:date].strftime("%Y/%m/%d %X")
      ws[ i + 2, 3] = live[:user]
      ws[ i + 2, 4] = live[:title]
      ws[ i + 2, 5] = live[:description]
      ws[ i + 2, 6] = live[:views]
      ws[ i + 2, 7] = live[:comments]
      ws[ i + 2, 8] = live[:url]
    end
    ws.save
  end

  def reset_sheet ws
    ws[1, 2] = DATE
    ws[1, 3] = USER
    ws[1, 4] = TITLE
    ws[1, 5] = DESCRIPTION
    ws[1, 6] = VIEWS
    ws[1, 7] = COMMENTS
    ws[1, 8] = URL
  end

  def self.configure=(config)
    @@google_user = config["google_user"]
    @@google_pass = config["google_pass"]
    @@google_sheet_key = config["google_sheet"]
    @@nico_community = config["nico_community"]
  end
end
