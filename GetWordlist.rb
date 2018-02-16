=begin
  File to communicate with shanbei.com with current word books. Return information
  in the form of a hash where the word spelling maps to its meaning.

  @bookname
   parameter for the name of book for words.

  File written by Yuzhao Li.
=end

require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'set'



  agent = Mechanize.new do |a|
    a.user_agent_alias = "Mac Safari"
  end
=begin
  page = agent.get('https://www.shanbay.com/wordbook/category/103/')

  page = agent.page.link_with(:text => '人教版小学四年级上').click

  page = agent.page.link_with(:text => '人教版小学四年级上---1').click
=end





  page = agent.get('https://www.shanbay.com/wordbook/category/103/')

  shanbei = 'https://www.shanbay.com'
  second_page_table = Array.new
  page.links.each do |link|

    if link.text == '更多'
      bookpage = shanbei + link.uri.to_s
      item = Array.new
      second_page = agent.get(bookpage)
      second_page_html = Nokogiri::HTML(second_page.body)
      nodeset = second_page_html.css('div#wordbook-wordlist-container a[href]')
      # only one word list in this book
      if nodeset.size == 1
        booktitle = second_page.title.to_s
        modified_booktitle = "#{booktitle[5..-1]}"
        wordlist_url = second_page.uri.to_s

        out_file = File.new(modified_booktitle.chop! + ".txt", "w")
        out_file.puts modified_booktitle
        nodeset.each do |node|
          puts node['href']
          url = 'https://www.shanbay.com/' + node['href'].to_s + '?page='
          number = 1
          i = 1
          while number < 30 do
            third_page = agent.get(url+number.to_s)
            html = Nokogiri::HTML(third_page.body)
            wordtable = html.search('table').first

            wordtable.css('tr').each do |row|
              row.css('td').each do |data|
                out_file.puts i
                if i.odd?
                  out_file.puts 'spelling'
                  out_file.puts data.text
                else
                  out_file.puts 'meaning'
                  if data.text[0] == ' '
                    out_file.puts "#{data.text[1..-1]}"
                  else
                    out_file.puts data.text
                  end
                end
                i +=1
              end
            end
            number += 1
          end

          out_file.close





        end
      else
        
      end


      # more than one word list in this book


      # nodeset.each do |node|
      #   puts node['href']
      #   puts node.text
      # end
    end
  end


  # item = Array.new
  # page = agent.get("https://www.shanbay.com/wordbook/203065/")
  # doc = Nokogiri::HTML(page.body)
  #
  # nodeset = doc.css('div#wordbook-wordlist-container a[href]')
  #
  # nodeset.each do |node|
  #   puts node['href']
  #   puts node.text
  # end


=begin
  url = 'https://www.shanbay.com/wordlist/203068/623647/?page='
  number = 1
  i = 1
  while number < 12 do
    page = agent.get(url+number.to_s)
    html = Nokogiri::HTML(page.body)
    wordtable = html.search('table').first

    wordtable.css('tr').each do |row|
      row.css('td').each do |data|
        out_file.puts i
        if i.odd?
          out_file.puts 'spelling'
          out_file.puts data.text
        else
          out_file.puts 'meaning'
          out_file.puts data.text
        end
        i +=1
      end
    end
    number += 1
  end

  out_file.close
=end
