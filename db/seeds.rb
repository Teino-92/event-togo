
Plan.destroy_all
User.destroy_all

puts "Creating user"

bob = User.create!(
  email: "bob@mail.com",
  password: "secret",
)

puts "Creating 3 plans"

roadmap = <<~ROADMAP
  Bien sûr ! Voici un programme pour un week-end romantique à Paris, comprenant hébergement, restaurants, et quelques activités pour profiter pleinement de la ville en amoureux.

  ---

  **Vendredi soir : arrivée et installation**

  **Hôtel recommandé :**
  *Hôtel Le Meurice* — un établissement de luxe situé face au Jardin des Tuileries, offrant un cadre élégant et romantique.

  **Dîner :**
  *Le Jules Verne* — restaurant étoilé situé au deuxième étage de la Tour Eiffel, avec une vue imprenable sur Paris. Pensez à réserver à l'avance.

  ---

  **Samedi : exploration romantique**

  **Matin :**
  - Petit-déjeuner à l’hôtel ou dans un café parisien traditionnel, comme *Café de Flore* ou *Les Deux Magots* à Saint-Germain-des-Prés.
  - Visite du Louvre ou promenade dans le Jardin des Tuileries.

  **Après-midi :**
  - Flânerie dans le Quartier Latin, avec ses ruelles charmantes.
  - Balade en bateau-mouche sur la Seine pour une vue unique de la ville (réservez une croisière en après-midi ou en début de soirée pour une ambiance magique).

  **Soir :**
  - Dîner dans un restaurant cosy et romantique : *Le Coupe Chou*, un bistrot traditionnel avec une ambiance chaleureuse.

  **Suggestion :**
  Après le dîner, une promenade main dans la main jusqu’à la place des Vosges ou le long de la Seine illuminée.

  ---

  **Dimanche : détente et découverte**

  **Matin :**
  - Petit-déjeuner à l’hôtel ou dans un salon de thé parisien, comme *Angelina* pour leur célèbre chocolat chaud et leurs pâtisseries.
  - Visite de Montmartre, la butte romantique avec la basilique du Sacré-Cœur et ses petites rues pavées.

  **Après-midi :**
  - Déjeuner dans un restaurant avec vue : *Le Moulin de la Galette*, à Montmartre.
  - Balade dans le quartier, visite de la place du Tertre, où artistes exposent leurs œuvres.

  **Fin d’après-midi :**
  - Retour à l’hôtel pour récupérer vos affaires, puis départ.

  ---

  **Conseils pratiques :**
  - Pensez à réserver vos restaurants et activités à l’avance, surtout pour le dîner à la Tour Eiffel.
  - N’oubliez pas votre appareil photo pour capturer ces moments romantiques.
  - Vérifiez les horaires d’ouverture et de réservation en fonction de la saison.

  ---
ROADMAP

plan_we = Plan.create!(
  title: "Week-end en amoureux",
  theme: "en couple",
  pricing: "650€", #price donné par l'IA
  user: bob,
  roadmap: roadmap,
  number_persons: 4,
  city: "Paris",
  context: "Organisation d'un week-end en amoureux. du samedi matin au dimanche soir, restaurants, hotels et lieux à visiter compris",
  event_lenght: "Week-end",
  roadmap_date: "2025-11-25"
)

plan_enfants = Plan.create!(
  title: "Après -midi avec 3 enfants",
  theme: "en famille",
  pricing: "200€", #price donné par l'IA
  user: bob,
  roadmap: nil,
  number_persons: 5,
  city: "Paris",
  context: "Sortie ludique à Paris avec 3 enfants un samedi aprés-midi",
  event_lenght: "Demie-journée",
  roadmap_date: "2025-11-23"
)

plan_amis = Plan.create!(
  title: "Soirée d'anniversaire",
  theme: "entre amis",
  pricing: "500€", #price donné par l'IA
  user: bob,
  roadmap: nil,
  number_persons: 10,
  city: "Paris",
  context: "Soirée d'anniversaire pas cher à Paris pour un groupe de 10 amis de longue date",
  event_lenght: "Demie-journée",
  roadmap_date: "2025-11-23"
)


puts "3 plans created"
