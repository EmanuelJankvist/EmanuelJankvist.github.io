require 'net/http'
require 'json'
require 'uri'
require 'fileutils'
require 'time'

module Jekyll
  class LessWrongFetcher < Generator
    safe true
    priority :high

    def generate(site)
      puts "Fetching LessWrong posts..."
      
      posts = fetch_all_posts
      
      # Save posts data
      site.data['lesswrong_posts'] = posts
      
      # Filter high karma posts
      high_karma_posts = posts.select { |post| post['baseScore'] && post['baseScore'] >= 100 }
      site.data['lesswrong_high_karma_posts'] = high_karma_posts
      
      # Filter recent posts (last 7 days)
      one_week_ago = Time.now - (7 * 24 * 60 * 60)
      recent_posts = posts.select do |post|
        if post['createdAt']
          post_time = Time.parse(post['createdAt']) rescue nil
          post_time && post_time > one_week_ago
        else
          false
        end
      end
      site.data['lesswrong_recent_posts'] = recent_posts
      
      # Create JSON files for client-side access
      File.write(File.join(site.source, '_data', 'lesswrong_posts.json'), posts.to_json)
      File.write(File.join(site.source, '_data', 'lesswrong_high_karma_posts.json'), high_karma_posts.to_json)
      File.write(File.join(site.source, '_data', 'lesswrong_recent_posts.json'), recent_posts.to_json)
      
      # Also create static files that will be copied to the output
      site.static_files << Jekyll::StaticFile.new(site, site.source, "/assets", "lesswrong_posts.json")
      site.static_files << Jekyll::StaticFile.new(site, site.source, "/assets", "lesswrong_high_karma_posts.json")
      site.static_files << Jekyll::StaticFile.new(site, site.source, "/assets", "lesswrong_recent_posts.json")
      
      # Create the JSON files in assets directory
      FileUtils.mkdir_p(File.join(site.source, 'assets'))
      File.write(File.join(site.source, 'assets', 'lesswrong_posts.json'), posts.to_json)
      File.write(File.join(site.source, 'assets', 'lesswrong_high_karma_posts.json'), high_karma_posts.to_json)
      File.write(File.join(site.source, 'assets', 'lesswrong_recent_posts.json'), recent_posts.to_json)
      
      puts "Fetched #{posts.length} total posts, #{high_karma_posts.length} with 100+ karma, #{recent_posts.length} from last week"
    end

    private

    def fetch_all_posts
      posts = []
      offset = 0
      limit = 100
      
      begin
        loop do
          batch = fetch_posts_batch(limit, offset)
          break if batch.empty?
          
          posts.concat(batch)
          offset += limit
          
          # Limit total posts to avoid excessive API calls during development
          break if posts.length >= 1000
          
          sleep(0.5) # Be respectful to the API
        end
      rescue => e
        puts "Error fetching posts: #{e.message}"
        puts "Continuing with #{posts.length} posts fetched so far"
      end
      
      posts
    end

    def fetch_posts_batch(limit, offset)
      uri = URI('https://www.lesswrong.com/graphql')
      
      query = {
        query: <<~GRAPHQL
          query getPosts($limit: Int, $offset: Int) {
            posts(
              input: {
                terms: {
                  limit: $limit
                  offset: $offset
                  meta: null
                  filter: "frontpage"
                }
              }
            ) {
              results {
                _id
                title
                slug
                baseScore
                url
                createdAt
              }
            }
          }
        GRAPHQL,
        variables: {
          limit: limit,
          offset: offset
        }
      }

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      request = Net::HTTP::Post.new(uri.path)
      request['Content-Type'] = 'application/json'
      request.body = query.to_json
      
      response = http.request(request)
      
      if response.code == '200'
        data = JSON.parse(response.body)
        data.dig('data', 'posts', 'results') || []
      else
        puts "Error response: #{response.code} - #{response.body}"
        []
      end
    end
  end
end