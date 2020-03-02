namespace :teams do
  desc "assign teams"


  task :assign_teams => :environment do

    @users = User.all
    count = 0
    r_count = 0
    g_count = 0
    b_count = 0

    @users.each do |user|
      if user.has_applied? == true
        count += 1

        rs = 0
        gs = 0
        bs = 0

        app = EventApplication.where(:user_id => user.id)

        # Q1
        q1 = app['custom_fields']['personality_classroom']
        if q1 == 'Back'

        elsif q1 == 'Middle'

        elsif q1 == 'Front'

        else

        end

        # Q2
        q2 = app['custom_fields']['personality_crowd']
        if q1 == 'Back'

        elsif q1 == 'Middle'

        elsif q1 == 'Front'

        else

        end

        # Q3
        q3 = app['custom_fields']['personality_assignments']

        if q1 == 'Back'

        elsif q1 == 'Middle'

        elsif q1 == 'Front'

        else

        end

        # Q4
        q4 = app['custom_fields']['personality_icecream']

        if q1 == 'Back'

        elsif q1 == 'Middle'

        elsif q1 == 'Front'

        else

        end

        # Q5
        q5 = app['custom_fields']['personality_hackathons']

        if q1 == 'Back'

        elsif q1 == 'Middle'

        elsif q1 == 'Front'

        else

        end

        # assign team based on highest score

      end
    end

    puts "#{count} assigned to red"
    puts "#{count} assigned to blue"
    puts "#{count} assigned to green"
    puts "#{count} total"

  end

end
