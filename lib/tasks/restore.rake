namespace :restore do
    desc "restore lost apps"
    task :restore_apps => :environment do
        file = File.open("missing_apps.txt")
        file_data = file.readlines.map(&:chomp)
        file_data.each do |u|
            z = u.split("|")
            x = JSON.parse z[1].sub(/\"resume\"=>.*application\/pdf\\r\\n\">,/, "").gsub('=>', ':')
            user = User.find(z[0].to_i)

            @application = EventApplication.new(x)
            @application.user = user
            puts "Restored #{user.email}"
        end
    end
  end
