class Seed
  attr_reader :user_counter

  def initialize
    @user_counter = 0
  end

  def self.start
    seed = Seed.new
    seed.drop_tables
    seed.generate_users
    seed.generate_trails
    sleep 2
    seed.generate_events
    sleep 2
    seed.generate_trails
    sleep 2
    seed.generate_events
    sleep 2
    seed.generate_trails
    sleep 2
    seed.generate_events
    sleep 2
    seed.most_active_user_events
  end

  def drop_tables
    Event.destroy_all
    Trail.destroy_all
    User.destroy_all
  end

  def generate_users
    20.times do |i|
      user = User.create!(
        username: Faker::Name.name,
        email: Faker::Internet.email,
        password: 'password'
      )
      puts "User #{i}: #{user.username} created!"
    end
    admin = User.create!(
      username: 'admin',
      email: 'admin@admin.com',
      password: 'password',
      role: 'admin'
    )
  end

  def generate_trails
    10.times do |i|
      trail = Trail.create!(
        name: "#{Faker::Hobbit.location}, #{Faker::Address.community}",
        description: Faker::Hobbit.quote,
        difficulty: %w(white, blue, green, black diamond, double black diamond).sample,
        distance: %w(5,10,15,20,25,50,100).sample,
        rating: %w(1,2,3,4).sample,
        longitude: longitude,
        latitude: latitude
      )
      puts "User #{i}: #{trail.name} created!"
    end
  end

  def generate_events
    10.times do |i|
      trail = Trail.order('Random()').first
      user = User.order('Random()').first
      event = Event.create(
        trail_id: trail.id,
        name: Faker::Space.agency,
        description: Faker::Hobbit.quote,
        date: Faker::Date.between(Date.today, 1.year.from_now)
      )
      user.event_roles.create(event_id: event.id, role: 1)
      assign_guests(event)
      puts "Event #{i}: #{event.name} created!"
    end
  end

  def most_active_user_events
    user = User.create!(username: "Mr. Popular", email: "mrpopular@gmail.com", password: "password")
    user_b = User.create!(username: "Mr. UnPopular", email: "mrunpopular@gmail.com", password: "password")
    5.times do |i|
      trail = Trail.order('Random()').first
      upcoming_host_event = Event.create(
        trail_id: trail.id,
        name: Faker::Space.agency,
        description: Faker::Hobbit.quote,
        date: Faker::Date.between(Date.today, 1.year.from_now)
      )
      archived_host_event = Event.create(
        trail_id: trail.id,
        name: Faker::Space.agency,
        description: Faker::Hobbit.quote,
        date: Faker::Date.between(Date.today, 1.year.from_now),
        archived: true
      )
      upcoming_guest_event = Event.create(
        trail_id: trail.id,
        name: Faker::Space.agency,
        description: Faker::Hobbit.quote,
        date: Faker::Date.between(Date.today, 1.year.from_now)
      )
      archived_guest_event = Event.create(
        trail_id: trail.id,
        name: Faker::Space.agency,
        description: Faker::Hobbit.quote,
        date: Faker::Date.between(Date.today, 1.year.from_now),
        archived: true
      )
      EventRole.create(event_id: upcoming_host_event.id, user_id: user.id, role: 0)
      EventRole.create(event_id: archived_host_event.id, user_id: user.id, role: 0)
      EventRole.create(event_id: upcoming_host_event.id, user_id: user_b.id, role: 1)
      EventRole.create(event_id: archived_host_event.id, user_id: user_b.id, role: 1)
      EventRole.create(event_id: upcoming_guest_event.id, user_id: user.id, role: 1)
      EventRole.create(event_id: archived_guest_event.id, user_id: user.id, role: 1)
    end
  end

  def assign_guests(event)
    5.times do |i|
      users = User.offset(i).to_a
      EventRole.create(event_id: event.id, user_id: users.pop.id)
      puts "Assigned #{i} users to #{event.name}"
    end
  end

  def latitude
    (37.74..40.74).step(0.01).to_a.sample
  end

  def longitude
    (-105.99...-102.99).step(0.01).to_a.sample
  end
end

Seed.start
