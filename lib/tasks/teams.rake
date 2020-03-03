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
          gs += 1
        elsif q1 == 'Middle'
          bs += 1
        elsif q1 == 'Front'
          rs += 1
        else

        end

        # Q2
        q2 = app['custom_fields']['personality_crowd']
        if q2 == 'My personal bubble is at least 5 ft wide'
          bs += 1
        elsif q2 == 'I don\'t really care'
          gs += 1
        elsif q2 == 'Yay! People!'
          rs += 1
        else

        end

        # Q3
        q3 = app['custom_fields']['personality_assignments']
        if q3 == 'The minute the professor announces it in class'
          gs += 1
        elsif q3 == '2 days before it was assigned'
          bs += 1
        elsif q3 == 'Right before class starts'
          rs += 1
        else

        end

        # Q4
        q4 = app['custom_fields']['personality_icecream']
        if q4 == 'The same thing I always get'
          bs += 1
        elsif q4 == 'The craziest, most colorful, flavor they have'
          rs += 1
        elsif q4 == 'Depends on my mood'
          gs += 1
        else

        end

        # Q5
        q5 = app['custom_fields']['personality_hackathons']

        if q5 == 'Hacking'
          rs += 1
        elsif q5 == 'Free stuff'
          gs += 1
        elsif q5 == 'Workshops'
          bs += 1
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
