require 'faker'

20.times do
    User.create(
      fname: Faker::Name.first_name,
      lname: Faker::Name.last_name,
      email: Faker::Internet.email,
      birthday: Faker::Name.last_name,
      password: Faker::Name.first_name,
    )
end











=begin
users = [
  {fname: 'Jon', lname: 'Doe', email: 'jodo@example.com', birthday: '01/01/70', password: 'spam'},
  {fname: 'Jane', lname: 'Doe', email: 'jado@example.com', birthday: '01/02/70', password: 'spam'}
]

users.each do |u|
  User.create(u)
end
=end
