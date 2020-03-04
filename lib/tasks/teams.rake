namespace :teams do
  desc "assign teams"


  task :assign_teams => :environment do
    #puts "id, red, blue, green"
    @users = User.all
    count = 0
    prev = 0
    r_count = 0
    g_count = 0
    b_count = 0


    @users.each do |user|
      if user.has_applied? == true
        count += 1

        if user.team == "red"
          r_count += 1
          prev += 1
          next
        elsif user.team == "blue"
          b_count += 1
          prev += 1
          next
        elsif user.team == "green"
          g_count += 1
          prev += 1
          next
        end

        rs = 0
        gs = 0
        bs = 0

        app = EventApplication.where(:user_id => user.id)[0]

        # Q1
        q1 = app['custom_fields']['personality_classroom']

        if q1 == 'Back'
          gs += 1
        elsif q1 == 'Middle'
          bs += 1
        elsif q1 == 'Front'
          rs += 1
        else
          rs += 1
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
          bs += 1
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
          rs += 1
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
          gs += 1
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
          rs += 1
        end

        # assign team based on highest score, if there's a clear winner
        if rs > gs && rs > bs
          r_count += 1
          user.team = "red"
        elsif gs > rs && gs > bs
          g_count += 1
          user.team = "green"
        elsif bs > rs && bs > gs
          b_count += 1
          user.team = "blue"
        else

        # pass 2
        if rs == bs && rs != gs
          if r_count <= b_count
            r_count += 1
            user.team = "red"
          else
            b_count += 1
            user.team = "blue"
          end
        elsif rs == gs && rs != bs
          if r_count <= g_count
            r_count += 1
            user.team = "red"
          else
            g_count += 1
            user.team = "green"
          end
        elsif gs == bs && gs != rs
          if g_count <= b_count
            g_count += 1
            user.team = "green"
          else
            b_count += 1
            user.team = "blue"
          end
        else

        end


        end
        user.save(:validate => false)
      end
    end

    puts "#{r_count} assigned to red"
    puts "#{b_count} assigned to blue"
    puts "#{g_count} assigned to green"
    puts "#{count - r_count - b_count - g_count} unassigned"
    puts "#{prev} unchanged"
    puts "#{count} total"

  end

end
