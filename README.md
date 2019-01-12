# README

This repository represents three main service scripts for collecting data from different platforms.

Things you may want to cover:

* Uses Ruby version 2.4.2 or newwest

* Configuration: all three applications need their own configurations

* Database: run `$ rails db:migrate && rails db:migrate` for google_cal
* Browser:  install Mozilla/chrome webdriver to run watir for urls_pros
* FacebookAPI: configure facebook account to get token for fb_pros

* No tests

* Services:
 Can be run directly by instance methods
  - `ScrapGoogleCal.new.perform`
  - `ScrapFbPros.new.perform`
  - `ScrapUrlsPros.new.perform`

* Deployment instructions
  - Voir heroku scheduler(jobs)
  - Voir Configuration de watir

* ...

# Collectes des Événements depuis les sites professionnels, Facebook et Google Calendar


# Tutoriel des fonctionnalités:

## fichiers importants:
```
/app/services/scrap_fb_pros.rb
/app/services/scrap_urls_pros.rb
/app/services/scrap_google_cal.rb
/config/application.yml
```
 <!-- ENV["token"]
# :client_id => ENV["FIRST_APP_ID"]
# :secret_id => Figaro.env.secret_id
# :redirect_uri => ENV["FACEBOOK_redirect_uri"]
# :scope => ENV["FACEBOOK_scopes_auths2"]
# ENV["FACEBOOK_EMAIL"]
# ENV["FACEBOOK_MDP"]

# ENV["LOCAL_OR_HEROKU"]
# "client_id": ENV["GOOGLE_client_id"]
# "client_secret": ENV["GOOGLE_client_secret"]
# "refresh_token": ENV["GOOGLE_refresh_token"]
# "redirect_uri": ENV["GOOGLE_redirect_uri"]

# ENV["SPEADSHEET_LIENS_ET_IDS"] -->

```
/app/views/scrappings/home.html.erb
/app/views/scrappings/search.html.erb
/app/views/scrappings/search2.html.erb

/app/models/evenement.rb
/db/schema.rb
```

## gems utilisées:
```ruby
*/Gemfile*
gem 'activerecord-diff'           #ajout
gem "figaro"			                #ajout

gem "google_drive"                #ajout  google account connection
gem 'watir'                       #ajout  for web automation/simulation
gem 'nokogiri'           	        #ajout  for web Parsing

gem "koala"			                  #ajout  gem facebook
```

## requêtes exécutés:
```ruby
/config/routes.rb
get  'scrappings/search2'
get  'scrappings/search'
root 'scrappings#home'
```


## Démarche pour récupérer les événements sur facebook:
* étape n°0 :avoir les variable d'environnement définies
* étape n°1 :récupérer/Avoir un token valide:                     ScrapFbPros.new.get_token(ou par un autre moyen possible)
* étape n°2 :créer une table de BDD suivant le modèle Evenement   rails db:create
* étape n°3 :Lancer le programme principal:                       ScrapFbPros.new.perform


## Pour récupérer un token via ScrapFbPros.new.get_token:

```ruby
1 mettre ses identifiant Facebook
            ENV["FACEBOOK_EMAIL"]
            ENV["FACEBOOK_MDP"]
2 copié le nouveau token et remplacer l'ancien token de la variable environnement ENV["token"] par le nouveau token récupéré. Ce token est valide pendant 6mois.
            2 bis possibilité d'utiliser le token disponible via l'interface API graph facebook, celui-ci est valide pendant 1 heure.
```

# Les Scripts:


* 1 : scrap_fb_pros.rb
* 2 : scrap_google_cal.rb
* 3 : scrap_urls_pros.rb
