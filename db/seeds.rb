

puts "Creating "
bob = User.create!(
  email: "bob@mail.com",
  password: "secret",
)

roadmap = <<~ROADMAP
  TODO: ici on fait comme si c etait l assistant qui avait repondu
ROADMAP

plan_1 = Plan.create!(
  title: "",
  theme: "",
  pricing: "",
  user: bob,
  roadmap: roadmap,
  number_persons: 4,
  city: "",
  context: "",
  event_lenght: "",
  roadmap_date: "2025-11-25"
)
