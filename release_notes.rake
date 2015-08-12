desc 'Output relase notes'
task release_notes: :environment do
  last_tag = `git describe --abbrev=0 --tags`.strip
  puts "Previous Tag: #{last_tag}\n"

  def user_for_name(name)
    begin
      name.gsub!(/[^a-zA-Z0-9]+/, ' ').strip
      uri = URI("https://api.github.com/search/users")
      params = {q: name}
      uri.query = URI.encode_www_form(params)
      response = Net::HTTP.get(uri)
      JSON.parse(response)['items'].first['login']
    rescue
      nil
    end
  end

  lines = `git shortlog --no-merges #{last_tag}..HEAD`.split("\n")
  lines.reject! {|x| x.empty? }
  lines.each do |x|
    x.strip!
    if x =~ / \(\d\)/
      puts ""
      x.gsub!(/ \(\d\):/,"")
      if username = user_for_name(x)
        puts "@#{username}"
      else
        puts x
      end
    else
      puts x
    end
  end
end
