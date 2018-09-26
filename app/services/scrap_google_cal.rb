END {   puts "Terminating du Programme de Scan des events google calendar"}
BEGIN {   puts "Initialition du programme de scan des événements Google Calendar"}

class ScrapGoogleCal

      def initialize
          @all_events = []
          @true_link = nil
          @database_model = EvenementGoogle
          @msg_elmt_inexistant = "no object present during scan"
          @class_elmt__viewAgenda_buttton = "ui-rtsr-unselected ui-rtsr-last-tab ui-rtsr-name"
          @string_part_seached_into_iframes ="https://calendar.google.com/calendar"
          @database_model.destroy_all
          @nbr_next_click = 7
      end

      def scrap_google_calendar(list_of_urls)
          browser = ScrapUrlsPros.new.set_browser_session
              list_of_urls.each do |page_pro|
                  browser.goto(page_pro)
                  browser.iframes.each { |iframe| @true_link = iframe.src; if (iframe.src.include?(@string_part_seached_into_iframes)) then p "perfect"; break end}
                  redirect_link_to_google_calendar = @true_link
                  browser.goto(redirect_link_to_google_calendar)

                  browser.elements(:class => @class_elmt_viewAgenda_buttton)[0].click		 #or	 	#browser.execute_script("gcal$func$[0]('agenda')")
                  @nbr_next_click.times do sleep(1); browser.element(:class => "agenda-more", :text => "Rechercher des événements après cette date").click end
                       	#or    #browser.execute_script("gcal$func$[12](true);")       5.fois
                        #sleep(1) not necessary, this line can be deleted or changed


                  browser.elements(:class => "event-summary").each{|event| event.click}

                  scan_elmts ||=  Proc.new do |event_class, obj_scanned|              #procedure utilisé pour simplifier/optimiser le code
                                  if event_class.element(:class=>obj_scanned).present? then event_class.element(:class=>obj_scanned).text  else p "there are problems"; @msg_elmt_inexistant end
                  end

                  browser.elements(:class => "event").each do |event|
                      if event.parent.id[4..-1] >= (Date.today+0).strftime("%Y%m%d") then
                          heure = scan_elmts.call(event, "event-time")
                          titre = scan_elmts.call(event, "event-title")
                          quand = scan_elmts.call(event, "event-when") + ", " + event.parent.id[4..-1]
                          lieu  = scan_elmts.call(event, "event-where")
                          map   = event.element(:class=> "event-where").a(:class=>"menu-link").href unless lieu == @msg_elmt_inexistant
                          desc  = scan_elmts.call(event, "event-description")

                          @InfosEvent ||= Struct.new(:site, :heure, :titre, :date, :lieu, :map, :description)
                          hash_infos = @InfosEvent.new(page_pro, heure, titre, quand, lieu , map, desc).to_h

                          @all_events << hash_infos
                      end
                  end
              end
          browser.close
      end

      def get_google_links
          ["http://www.lolm.eu/ci-paris/", "https://omar5rythmes.wordpress.com/calendrier/"]
      end

      def save_in_database(database_model)
          @all_events.each do |event|
              database_model.create(event)
          end
      end

      def data_enrichment
          @all_events.each do |event|
              lieu = event.lieu.remove("(plan)").strip
              # Geocoder.search(lieu) # if we want for more details
              gps = Geocoder.coordinates(lieu)
              lieu = lieu.split(",")
              lieu_dit  = lieu[0]
              adresse  = lieu[1]
              code_postal = lieu[2]
              pays  = lieu[3]

              date = event.date.split(",").last.to_date
              heures = date.scan(/\d+:\d+/)
              datetime1 = (date + " " + heures[0]).to_datetime
              datetime2 = (date + " " + heures[1]).to_datetime
              distance  = Time.at(datetime2 - datetime1).utc.strftime("%H:%M:%S")

              @InfosEventBonus ||= Struct.new(:lieu_dit, :adresse, :code_postal, :pays, :lattitude, :lontitude, :date_debut, :date_fin, :duree)
              hash_infos_sup = @InfosEventBonus.new(lieu_dit, adresse, code_postal, pays, gps[0], gps[1], datetime1, datetime2, distance).to_h

              event.merge(hash_infos_sup)
          end
      end

      def perform
          links = self.get_google_links
          self.scrap_google_calendar links
          self.save_in_database(@database_model)
          @all_events
      end
end
# ScrapGoogleCal.new.perform
# rails generate model EvenementGoogle site heure titre date lieu map description
