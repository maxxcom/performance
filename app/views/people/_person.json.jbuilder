json.extract! person, :id, :nome, :cognome, :matricola, :email, :created_at, :updated_at
json.url person_url(person, format: :json)
