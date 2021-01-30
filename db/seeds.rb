# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#
agent = Mechanize.new
agent.user_agent_alias = 'Linux Firefox'

# categories = [39, 40, 5, 6, 8, 9, 10, 11, 66, 82]
# categories.each do |n|
#   agent.get("http://localhost:90/vb/forumdisplay.php?#{n}") do |page|
#     category = Category.create name: page.title.encode!('windows-1256')
#     @page_stickies =  page.search("ol.stickies")
#
#     @page_stickies.children.each do |c|
#       unless c.at_css('a.title').nil?
#         c.at_css('a.title').text.encode('windows-1256', invalid: :replace, undef: :replace, replace: '?')
#         Post.create category_id: category.id, title: c.at_css('a.title').text.encode('windows-1256', invalid: :replace, undef: :replace, replace: '?'), link: c.at_css('a.title')['href'].split('-').first
#       end
#     end
#     @page_threads =  page.search("ol.threads")
#     @page_threads.children.each do |c|
#       unless c.at_css('a.title').nil?
#         c.at_css('a.title').text.encode('windows-1256', invalid: :replace, undef: :replace, replace: '?')
#         Post.create category_id: category.id, title: c.at_css('a.title').text.encode('windows-1256', invalid: :replace, undef: :replace, replace: '?'), link: c.at_css('a.title')['href'].split('-').first
#       end
#     end
#
#   end
# end
@posts = Post.all
@posts.each do |post|
  agent.get("http://localhost:90/vb/#{post.link}") do |page|
    @page =  page.search("ol.posts")
    @title = page.title.encode('windows-1256', invalid: :replace, undef: :replace, replace: '')

    post_child = @page.children[1]
    if post_child.at_css('a.username strong').present?
      post.update(title: @title,
                  content: post_child.at_css('blockquote.postcontent'),
                  user_name: post_child.at_css('a.username > strong').text.encode!('windows-1256'))
    end


    @page.children[2..-1].each do |comment|
      if comment.at_css('a.username strong').present?
        post.comments.create(content: comment.at_css('blockquote.postcontent'),
                    user_name: comment.at_css('a.username > strong').text.encode!('windows-1256'))
      end
    end
  end

end