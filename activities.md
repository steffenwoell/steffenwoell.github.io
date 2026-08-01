---
layout: page
title: Activities
description: Talks, conferences, teaching, research travel, collaboration, service, and other academic activities by Steffen Wöll.
image: /img/cat/act.webp
header_class: activities-header
integrated_header: true
hide_avatar: true
---

{% assign today = site.time | date: "%Y-%m-%d" %}
{% assign conferences_by_date = site.data.conferences | sort: "start" %}
{% assign has_upcoming_conferences = false %}
{% for conference in conferences_by_date %}
  {% if conference.end >= today %}
    {% assign has_upcoming_conferences = true %}
  {% endif %}
{% endfor %}

<div class="activity-header">
<div class="activity-statement">
<div class="activity-section-label"><i class="fas fa-calendar-alt" aria-hidden="true"></i> Activities</div>
<h1>Academic work beyond publication</h1>
<img class="activity-header-image" src="{{ page.image | relative_url }}" alt="">
</div>

<section class="activity-contents" aria-labelledby="activity-contents-title">
<div id="activity-contents-title" class="activity-section-label"><i class="fas fa-list-ul" aria-hidden="true"></i> Browse by Type</div>
<nav aria-label="Activity types">
<ul>
<li><a href="#conferences" aria-label="Talks and Conferences"><span class="category-label-full">Talks &amp; Conferences</span><span class="category-label-short" aria-hidden="true">Talks</span></a></li>
<li><a href="#panels-workshops" aria-label="Panels and Workshops"><span class="category-label-full">Panels & Workshops</span><span class="category-label-short" aria-hidden="true">Panels</span></a></li>
<li><a href="#teaching" aria-label="Teaching"><span class="category-label-full">Teaching</span><span class="category-label-short" aria-hidden="true">Teaching</span></a></li>
<li><a href="#thesis-supervision" aria-label="Supervision"><span class="category-label-full">Supervision</span><span class="category-label-short" aria-hidden="true">Supervision</span></a></li>
<li><a href="#fieldwork-archives" aria-label="Research Travel"><span class="category-label-full">Research Travel</span><span class="category-label-short" aria-hidden="true">Travel</span></a></li>
<li><a href="#memberships" aria-label="Academic Memberships"><span class="category-label-full">Academic Memberships</span><span class="category-label-short" aria-hidden="true">Memberships</span></a></li>
<li><a href="#academic-service" aria-label="Academic Service"><span class="category-label-full">Academic Service</span><span class="category-label-short" aria-hidden="true">Service</span></a></li>
<li><a href="#grants-awards" aria-label="Grants and Awards"><span class="category-label-full">Grants & Awards</span><span class="category-label-short" aria-hidden="true">Grants</span></a></li>
<li><a href="#volunteering" aria-label="Community Engagement"><span class="category-label-full">Community Engagement</span><span class="category-label-short" aria-hidden="true">Engagement</span></a></li>
</ul>
</nav>
</section>
</div>

{% if has_upcoming_conferences %}
<section class="activity-category activity-category--upcoming" aria-labelledby="upcoming">
<header class="activity-category-header"><h2 id="upcoming">Upcoming Talks</h2></header>
<div class="activity-category-body gold">
{% for conference in conferences_by_date %}
{% if conference.end >= today %}
<p><strong class="hl hl-act">{{ conference.title }}</strong> {{ conference.event }}. {{ conference.location }}. {{ conference.date_text }}. <a href="{{ conference.url }}">{{ conference.role }}<i class="fas fa-external-link-alt" role="presentation"></i></a>
<button
  class="activity-calendar-button calendar-download"
  type="button"
  data-calendar-title="{{ conference.title | strip_html | escape }}"
  data-calendar-event="{{ conference.event | strip_html | escape }}"
  data-calendar-location="{{ conference.location | strip_html | escape }}"
  data-calendar-start="{{ conference.start }}"
  data-calendar-end="{{ conference.end }}"
  data-calendar-url="{{ conference.url | escape }}"
><i class="fas fa-calendar-plus" aria-hidden="true"></i> <span data-calendar-label>Add to calendar</span></button></p>
{% endif %}
{% endfor %}
</div>
</section>
{% endif %}

<section class="activity-category" aria-labelledby="conferences">
<header class="activity-category-header"><h2 id="conferences">Past Talks &amp; Conferences</h2></header>
<div class="activity-category-body gold">
{% assign past_conferences = conferences_by_date | reverse %}
{% for conference in past_conferences %}
{% if conference.end < today %}
<p><strong class="hl hl-act">{{ conference.title }}</strong> {{ conference.event }}. {{ conference.location }}. {{ conference.date_text }}. <a href="{{ conference.url }}">{{ conference.role }}<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
{% endif %}
{% endfor %}
<p><strong class="hl hl-act">Seeing, Speaking, Touching, Dying: Transforming the Body through (Visual) Language in David Cronenberg&#8217;s Videodrome.</strong> Expressivity, Bodies and Language in the Twenty-First Century. Université Paul-Valéry Montpellier. 20-21 November 2025. <a href="https://expressivity.sciencesconf.org/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Democratic Frontiers, Nazi Natives, and Postwar Masculinities: Western Novels and German Identities.</strong> Facing West: Thinking, Living, Outliving the American West. AISNA XXVIII Biennial Conference. Bergamo. 11-13 September 2025. <span class="activity-link-inactive" aria-disabled="true">Presentation</span></p>
<p><strong class="hl hl-act">Archiving America / American Archives.</strong> 71st Annual Meeting of the German Association for American Studies. Siegen, Germany. 12-14 June 2025. <a href="https://www.uni-siegen.de/phil/anglistik/dgfa2025/">Attendee<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Waves of Conquest, Currents of Dissent: Liquifying America&#8217;s Transoceanic Empire.</strong> A Water&#8217;s History of the United States. Roosevelt Institute for American Studies. Middelburg, The Netherlands. 21-23 May 2025. <a href="https://www.roosevelt.nl/en/nieuws/conference-a-waters-history-of-the-united-states/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Overflowing Continental Frames: The Liquid Visual Vocabularies of American Empire.</strong> Visual Americas: Image, Text, Performance. 12th IASA World Congress. Ankara. 14-16 May 2025. <a href="https://iasa-world.org/12th-iasa-world-congress-2025/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">From Canvas to Cartography: Visual Regimes of Colonialism and Resistance in the Industrial Age.</strong> American Historical Association Annual Meeting. New York. 4 January 2025. <a href="https://www.historians.org/annual-meeting/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Engaging (in) Visions of Belonging: Communal Placemaking through Maps and Material Culture.</strong> Grounded Engagements in American Studies. American Studies Association Annual Meeting. Baltimore. 14 November 2024. <a href="https://www.theasa.net/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">From Narrowcasts to Deepfakes: Media Consumption and Social Transformation in David Cronenberg&#8217;s Videodrome.</strong> Northeast Popular Culture Association Annual Conference. Dudley, Massachusetts / online. 3-5 October 2024. <span class="activity-link-inactive" aria-disabled="true">Presentation</span></p>
<p><strong class="hl hl-act">Digital Humanities and the Power of Maps: Navigating Identity, Algocracy, and Resistance in the Age of AI.</strong> Digitorium: University of Alabama Digital Humanities Conference. Tuscaloosa / online. 12-14 September 2024. <a href="https://adhc.lib.ua.edu/digitorium/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Rolling the Dice with Cthulhu: Exploring Lovecraftian Play Spaces in the Arkham Horror Tabletop RPG.</strong> Le jeu: Gambling, Gaming and Play in Literature. 10th Congress of the European Society of Comparative Literature. Sorbonne Université Paris. 5 September 2024. <span class="activity-link-inactive" aria-disabled="true">Presentation</span></p>
<p><strong class="hl hl-act">From Peripheral Visions to Global Trajectories: Spatial Imaginations and Cultural Vocabularies of US Imperialism, 1898-1945.</strong> Authors&#8217; Workshop: Handbook American Globalization. Leipzig / online. 12 July 2024. <a href="https://research.uni-leipzig.de/~sfb1199/event-category/workshop/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Race and the Politics of Survival in the Chthulucene: The Case of Dark Corners of the Earth.</strong> Playing the Field IV: Video Games and Politics. Dortmund. 12 July 2024. <a href="https://islk.kuwi.tu-dortmund.de/ptf4/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Visual Ingestion and the New Flesh: Re-viewing Global Image Economies in David Cronenberg&#8217;s Videodrome (1983).</strong> Images Deluge & Globalization. Visual Contagions: Art, Images, and the Globalization of Cultures from the Printed Era to the Internet (1890-today). Geneva. 21 June 2024. <a href="https://www.unige.ch/visualcontagions/conferences-new/Images-Deluge-Globalization">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Truth, Space, and AI: Navigating Geographies of Identity, Algocracy, and Resistance.</strong> Information, Media and Truth in the Post-Truth and Artificial Intelligence Era. Faculty of Mass Communication, AAB College. Pristina / online. 14 June 2024. <a href="https://aab-edu.net/en/conference/information-media-and-truth-in-the-post-truth-and-artificial-intelligence-era/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">X-treme Sounds: Hardcore Punk, Sonic Activism, and Black Resilience.</strong> American Soundscapes. 70th Annual Meeting of the German Association for American Studies. Oldenburg, Germany. 25 May 2024. <a href="https://uol.de/en/english-american/dgfa-70th-annual-meeting-23-25-may-2024">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Facing Time: Mugshots, Social Discipline, and Popular Culture.</strong> Guilty Pleasures: Examining Crime in Popular Culture. Popular Culture Research Network (PopCRN) Symposium. Sydney / online. 3 May 2024. <a href="https://www.une.edu.au/about-une/faculty-of-humanities-arts-social-sciences-and-education/hass/humanities-arts-and-social-sciences-research/une-popular-culture-research-network">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">The Ocean at Home: Philip Henry Gosse and the Victorian Aquarium Frenzy.</strong> Home/Bodies: 6th Biennial NEXUS Interdisciplinary Conference. Knoxville / online. 7 April 2024. <a href="https://nexus.utk.edu/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Mapping Migrant Bodies: Surveillance, Algocracy, and Cartographic Resistance.</strong> 1924-2024: The American Immigrant Narrative Revisited. European Association of American Studies Biennial Conference. Munich. 6 April 2024. <span class="activity-link-inactive" aria-disabled="true">Presentation</span></p>
<p><strong class="hl hl-act">Imperial Torrents and Literary Undertows: Liquifying America&#8217;s Transoceanic Empire.</strong> Narratives of Water: Flows, Routes, Crises in the Atlantic World. Turin. 22 March 2024. Presentation</p>
<p><strong class="hl hl-act">Revolutionary Geographies: Identity, Algocracy, and Resistance in the Age of AI.</strong> 2nd International Humanities - Society - Identity Congress (HSIC): Evolution/Revolution. University of Warsaw. 6 December 2023. <a href="https://hsic.wn.uw.edu.pl/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Remapping Human Geographies: Spatial Imaginations and the Social Agency of Mapmaking.</strong> Comparative Literature: The Imaginaire and (Re)Shaping the World. Department of English Language and Literature. Cairo. 15 November 2023. <a href="https://www.academia.edu/88401985/CFP_The_15th_International_Symposium_on_Comparative_Literature_The_Imaginaire_and_Re_Shaping_the_World_14_16_November_2023">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Making Space for Solidarity: Maps as Agents of Affective Reterritorialization and Social Change.</strong> Crises and Turns: Continuities and Discontinuities in American Culture. American Studies Association Annual Meeting. Montreal. 3 November 2023. <a href="https://www.theasa.net/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Visualizing Vulnerabilities in R.H. Dana&#8217;s Californian Travel Literature.</strong> Vulnerabilities: Weaknesses, Threats, Resilience in the U.S.A. and in Global Perspective. AISNA XXVII Biennial Conference. Narni, Italy. 21 September 2023. <span class="activity-link-inactive" aria-disabled="true">Presentation</span></p>
<p><strong class="hl hl-act">America and Ownership: Territory, Slavery, Jubilee.</strong> 69th Annual Meeting of the German Association for American Studies. Rostock, Germany. 1-3 June 2023. <a href="https://www.iaa.uni-rostock.de/dgfa-conference/dgfa-conference/">Attendee<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Cannibalizing Continuities: Narrative Crises and the Undead.</strong> Crises and Turns: Continuities and Discontinuities in American Culture. 27th Biennial NAAS Conference. Uppsala. 26 May 2023. Presentation</p>
<p><strong class="hl hl-act">You Can&#8217;t Beat Cthulhu: Lovecraftian Ludic Labyrinths in the Arkham Horror TTRPG.</strong> Faites vos jeux: Game and space in texts and of texts. PhD Course in Language and Literary Studies, XXXVI cycle. Udine, Italy. 23 March 2023. <a href="https://sites.google.com/view/giocoudine2023">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">&#8220;Der Held ist das ganze Volk&#8221;: Revolution, Demokratie und deutsch-amerikanische Bildungspolitik in Charles Sealsfields frühen Wildwestromanen.</strong> »Go West!« Die Idee des »Westens« in bildungshistorischer Perspektive. Münster, Germany. 23 November 2022. <a href="https://www.hsozkult.de/event/id/event-129827">Lecture Series<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">From Daguerreotype to DNA: Mugshots as Cultural Expressions of Discipline, Bias, and Protest.</strong> Mid-Atlantic Popular & American Culture Association Annual Conference. Online. 12 November 2022. <a href="https://mapaca.net/conference/2022">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">The Young Republic and Young Germany: Charles Sealsfield&#8217;s Transatlantic Narrative Politics.</strong> Master of the World? Charles Sealsfield&#8217;s America between Emancipation, Exceptionalism and Globalization. Dortmund. 23 September 2022. <a href="https://islk.kuwi.tu-dortmund.de/institut/veranstaltungen/details/charles-sealsfield-symposium-12237/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">&#8220;The whitest God makes &#8217;em&#8221;: Postbellum Racial Politics and the White Elephant War of 1884.</strong> Animals in the US Popular Imagination. PopMeC / Austrian Association for Cultural Studies, Cultural History, and Popular Culture. Online. 15 September 2022. <a href="https://popular-animals.com/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Imperial Spatializations and Archipelagic Counter-Geographies.</strong> American Comparative Literature Association Annual Conference | Comparative Archipelagoes. Taipei. 16 June 2022. With Gabriele Pisarz-Ramirez. <a href="https://www.acla.org/sites/default/files/files/ACLA_Program.pdf">Presentation<i class="fas fa-file-pdf" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Approaching Zero-Point: Radical Environmentalism, Eco-Apocalypticism, and Anti-Capitalist Disaster Culture in the United States.</strong> Disaster Discourse: Representations of Catastrophe. Bucharest / online. 2 June 2022. <a href="https://engleza.lls.unibuc.ro/aiced2022l2/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Region, Nation, and Empire: Scaling Spatial Semantics in American Literature.</strong> Collaborative Research Centre 1199 Colloquium. Leipzig. 11 May 2022. <a href="https://research.uni-leipzig.de/~sfb1199/app/uploads/2022/04/SFB_Colloquium_SS2022_Druckversion-1.pdf">Presentation<i class="fas fa-file-pdf" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Archipelagic Thinking and the Transcultural Space of Mapping.</strong> Transferts Culturels - Kulturtransfers - Intercultural Transfers. Online. 11 February 2022. <a href="https://research.uni-leipzig.de/transfertsculturels/de/programm/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">&#8220;The Great Seatsfield&#8221;: The Transatlantic Politics of the Early Western.</strong> Mid-Atlantic Popular & American Culture Association Annual Conference. Online. 11 November 2021. <a href="https://mapaca.net/conference/2021">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Doing Nature&#8217;s Work: Subaltern Economies and Socialist Social Darwinism in Jack London&#8217;s Writings.</strong> Swiss Association for North American Studies Biennial Conference. St. Gallen / online. 5-6 November 2021. Presentation</p>
<p><strong class="hl hl-act">Oceans of Dissent: Liquefying the Trans-hemispheric Empire in Fin de Siècle Literature.</strong> American Studies Association Annual Conference. San Juan / online. 12 October 2021. Presentation</p>
<p><strong class="hl hl-act">Unma(s)king Maps, Unmapping Empires: Archipelagic Cartographies as Epistemic Mobilities.</strong> Archipelagic Imperial Spaces and Mobilities. Leipzig / online. 17 July 2021. <a href="https://enmma.carrd.co/#events">International Workshop<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">No Single Logic: Reassembling Human Geographies of the Louisiana Territory Through Biographies and Life Writing.</strong> Assemblages of Empire: An American Studies Symposium. University of Texas, Austin. 4-5 March 2021. <a href="https://utamsconference.wordpress.com/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Der Raum zwischen Ozeanen / The Space Between Oceans: Mobilizing America&#8217;s Transoceanic Empire.</strong> Forschungskonferenz der Philologischen Fakultät Leipzig. Online. 26 January 2021. Presentation</p>
<p><strong class="hl hl-act">The Space Between Oceans: Mobilizing America&#8217;s Transoceanic Empire.</strong> Fifth Annual Conference of the SFB 1199: Mobilities under the Global Condition from the 19th Century to the Present. Leipzig / online. 8 October 2020. <a href="https://research.uni-leipzig.de/~sfb1199/annual-conference/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">The Naturalists&#8217; Frontier: Ethnic Mobilities in Jack London&#8217;s Literary Geographies.</strong> American Literature Association Annual Conference. San Diego. 21-24 May 2020. <a href="https://americanliteratureassociation.org/wp-content/uploads/2020/07/ALA2020_Cancellation.pdf">Presentation<i class="fas fa-file-pdf" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Mapping Discourse in Richard Henry Dana&#8217;s Two Years Before the Mast.</strong> Mapping Space - Mapping Time - Mapping Texts: A Virtual One-Day Conference. Online. 29 September 2020. <span class="activity-entry-actions"><a href="https://www.flickr.com/photos/189983859@N08/50294560072/">Poster<i class="fas fa-file-image" role="presentation"></i></a><a href="https://www.lancaster.ac.uk/chronotopic-cartographies/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></span></p>
<p><strong class="hl hl-act">Mapping Discourse in Richard Henry Dana&#8217;s Two Years Before the Mast.</strong> DoktorandInnen Posterkonferenz der Philologischen Fakultät. Leipzig. 28 January 2020. <a href="https://www.philol.uni-leipzig.de">Poster Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">The Rocky Roads of Empire: The Rocky Mountains as Hemispheric Nexus and Barrier to Manifest Destiny in Nineteenth-Century American Literature.</strong> Mediating Mountains. 46th Austrian Association for American Studies Conference. Innsbruck. 23 November 2019. <span class="activity-link-inactive" aria-disabled="true">Presentation</span></p>
<p><strong class="hl hl-act">&#8220;True Places Never Are&#8221;: Navigating Spatial Imaginations in Moby-Dick.</strong> Over_Seas: Melville, Whitman and all the Intrepid Sailors. Lisbon. 3 July 2019. Presentation</p>
<p><strong class="hl hl-act">Figuring and Refiguring the Spatial Embodiment of Empire.</strong> Nuestra América: Justice and Inclusion: Latin American Studies Association Annual Conference. Boston. 25 May 2019. <a href="https://lasaweb.org/en/lasa2019/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Muddying the Waters: Colliding Visions of the Louisiana Territory.</strong> Research Academy Leipzig / Graduate School Global and Area Studies. Neudietendorf. 2 February 2019. Presentation</p>
<p><strong class="hl hl-act">Key Concepts and Future Projects.</strong> European Network for Minor Mobilities in the Americas. Erlangen. 31 January 2019. <a href="https://enmma.carrd.co/#events">Workshop<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Inertia and Movement: The Spatialization of the Native Northland in Jack London&#8217;s Short Stories.</strong> American Im/Mobilities: 45th Austrian Association for American Studies Conference. Vienna. 17 November 2018. <a href="https://aaas2018.univie.ac.at/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">&#8220;Feeling New York&#8221;: Public Urban Geographies and Private Capitalist Reconciliation in Horatio Alger&#8217;s Ragged Dick.</strong> St. Kliment Ohridski Sofia University | Traditions and Transitions. Sofia. 28-30 September 2018. <a href="https://ttconference2018.wordpress.com">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Reimagining the American West: Spirituality, (Im)Mobilities, and Nationalistic Transcendence in Popular and Private Literature.</strong> 16th International Summer School of the Graduate School Global and Area Studies and the Graduate Centre Humanities and Social Science of the Research Academy Leipzig. Leipzig. 12 June 2018. <a href="https://research.uni-leipzig.de/~sfb1199/events/16th-international-summer-school/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Mapping Discourse in Richard Henry Dana&#8217;s Two Years Before the Mast (1840).</strong> Visualization of Processes of Spatialization Seminar. Leipzig. 6 June 2018. <a href="https://research.uni-leipzig.de/~sfb1199/events/visualization-of-processes-of-spatialization/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Rewriting the Margins: Minor Mobilities at the Southern and Northern Borderlands in the Literary Geographies of Jack London.</strong> European Network for Minor Mobilities in the Americas Workshop. Vienna. 3 May 2018. <a href="https://enmma.carrd.co/#events">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Nativism, Foreign Bodies, and Racial Hybridity in H.P. Lovecraft&#8217;s &#8220;The Shadow over Innsmouth.&#8221;</strong> Foreign Bodies and Native Sons: Irish Association for American Studies Annual Conference. Dublin. 28 April 2018. <a href="https://iaas.ie/iaas-annual-conference/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">&#8220;The Whole Extent of That Coast Will Be Covered with Free and Independent Americans&#8221;: Separatist Movements, Bio-Regionalism, and Anti-Nationalist Visions in Oregon Country and California.</strong> Reinventing the Social: Movements and Narratives of Resistance, Dissension, and Reconciliation in the Americas / International Association of Inter-American Studies Annual Conference. Coimbra. 24 March 2018. <a href="https://www.interamericanstudies.net/?p=6481">Presentation<i class="fas fa-lock-open" role="presentation"></i><i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Feeling New York: Classless Urban Geographies and Affective Capitalist Reconciliation in Horatio Alger&#8217;s Ragged Dick.</strong> Scottish Association for the Study of America Annual Conference. St. Andrews. 3 March 2018. <a href="https://aisna-graduates.online/2017/12/31/cfp-scottish-association-for-the-study-of-america-2018-annual-conference/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Utopianism, Regionalism, and Local Color Nostalgia in the Literature of the Old Northwest.</strong> Research Academy Leipzig / Graduate School Global and Area Studies. Wittenberg. 3 February 2018. Presentation</p>
<p><strong class="hl hl-act">Geographies of Empire: Der transpazifische und zirkumkaribische Raum in der Literatur der USA.</strong> With Gabriele Pisarz-Ramirez. Collaborative Research Centre 1199. Leipzig. 3 January 2018. <a href="https://research.uni-leipzig.de/~sfb1199/events/dual-presentation-gabriele-pisarz-ramirez-philipp-clart-and-nikolas-broy/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Horrendous Hybridity: Spatial and Linguistic Representations of the Occult Orientalist Other in H.P. Lovecraft&#8217;s &#8220;The Shadow Over Innsmouth.&#8221;</strong> The Politics of Space and the Humanities. Thessaloniki. 16 December 2017. <a href="https://www.enl.auth.gr/helaas/2017/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Border-Crossings in the Americas: Mobilities, Migrations, Narratives in the 21st Century.</strong> Forum for the Study of the Global Condition. Leipzig. 23-24 November 2017. <a href="https://www.forum-global-condition.de/veranstaltung/border-crossings-in-the-americas-mobilities-migrations-narratives-in-the-21st-century/">Workshop<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Globe, Region, and Periphery: The Spatialization of the American West in Antebellum US Literature.</strong> Global Frontiers. Tübingen. 17 November 2017. <a href="https://uni-tuebingen.de/en/fakultaeten/philosophische-fakultaet/fachbereiche/geschichtswissenschaft/seminareinstitute/neuere-geschichte/wiss-veranstaltungen/konferenzen-und-workshops/archiv/sommer-und-winterkurse/archiv/global-frontiers-15-17-nov-2017/">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Exceptional Spaces: Pop-Cultural Debris and the Spatial (Re)Construction of American Exceptionalism in Alfonso Cuarón&#8217;s Gravity.</strong> Midwest Popular Culture Association Annual Conference. St. Louis. 22 October 2017. Funded by DAAD. Presentation</p>
<p><strong class="hl hl-act">Horrendous Hybridity: Spatial and Linguistic Representations of the Occult Orientalist Other in H.P. Lovecraft&#8217;s &#8220;The Shadow Over Innsmouth.&#8221;</strong> Society of Early Americanists 10th Biennial Conference. Tulsa. 2 March 2017. <a href="https://sea2017.wordpress.com">Presentation<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Globe, Region, and Periphery: The Spatialization of the American West in Antebellum US Literature.</strong> Collaborative Research Centre 1199. Leipzig. 4 January 2017. Presentation</p>
<p><strong class="hl hl-act">Space and Place in American Studies.</strong> Urban America: Mediating City Space as Place. American Studies Leipzig Graduate Conference. Leipzig. 2 April 2016. <a href="https://americanstudies.uni-leipzig.de/asl-gradconference-2016">Keynote Address<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
</div>
</section>

<div class="anchor" id="panels-workshops" aria-hidden="true"></div>

<section class="activity-category" aria-labelledby="panels-workshops-title">
<header class="activity-category-header"><h2 id="panels-workshops-title">Panels &amp; Workshops</h2></header>
<div class="activity-category-body gold">
<p><strong class="hl hl-act">Global Coalitions Endgame.</strong> American Studies Association Annual Meeting. New Orleans. 4 November 2022. <a href="https://asa.press.jhu.edu/program22/program.pdf">Panel Chair<i class="fas fa-file-pdf" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Archipelagic Imperial Spaces and Mobilities.</strong> Leipzig / online. 30 March-1 April 2022. Second International Workshop. With Gabriele Pisarz-Ramirez, Alexandra Ganser, and Barbara Gföllner. <a href="https://research.uni-leipzig.de/~sfb1199/events/13_sfb_event_workshop_archipelagic-spaces-ii-08-03-2022/">Co-Organizer<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">The Seeds and Seeding of Empire.</strong> American Studies Association Annual Conference. San Juan / online. 14 October 2021. <a href="https://asa.press.jhu.edu/program21/program.pdf">Panel Chair<i class="fas fa-file-pdf" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Archipelagic Imperial Spaces and Mobilities.</strong> Leipzig / online. 15-17 July 2021. First International Workshop. With Gabriele Pisarz-Ramirez, Alexandra Ganser, and Barbara Gföllner. <a href="https://enmma.carrd.co/#events">Co-Organizer<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Spatial Narratives of Resistance and Dissension at US Peripheries During the Nineteenth Century.</strong> Reinventing the Social: Movements and Narratives of Resistance, Dissension, and Reconciliation in the Americas (International Association of Inter-American Studies). Coimbra. 24 March 2018. With Gabriele Pisarz-Ramirez and Deniz Bozkurt. <a href="https://www.interamericanstudies.net/?page_id=6447">Panel Co-Chair<i class="fas fa-lock-open" role="presentation"></i><i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Regional Colloquium for American Studies.</strong> Leipzig. 13 January 2017. Co-Organizer.</p>
<p><strong class="hl hl-act">Urban America: Mediating City Space as Place.</strong> American Studies Leipzig Graduate Conference. Leipzig. 2 April 2016. <a href="https://americanstudies.uni-leipzig.de/asl-gradconference-2016">Co-Organizer<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
</div>
</section>

<section class="activity-category" aria-labelledby="teaching">
<header class="activity-category-header"><h2 id="teaching">Teaching</h2></header>
<div class="activity-category-body gold">
<p><strong class="hl hl-act">Killer Content: Crime as Spectacle in American Media.</strong> Media, Society, and Culture. Leipzig University. Summer Term 2026. <a href="/doc/MSC-Seminar-Syllabus-SoSe-2026.pdf">Seminar<i class="fas fa-file-pdf" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Utopian Futures in American Literature.</strong> Literature and Culture II. Leipzig University. Summer Term 2026. <a href="/doc/LC-II-Seminar-Syllabus-SoSe-2026.pdf">Seminar<i class="fas fa-file-pdf" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Oceans as Boundaries & Connections.</strong> Ethnicity and Diversity in US Culture. Leipzig University. Winter Term 2025/26. <a href="/doc/ED-Seminar-Syllabus-WS-25-26.pdf">Seminar<i class="fas fa-file-pdf" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Captivity - Enslavement - Incarceration - Liberation.</strong> Ethnicity and Diversity in US Culture. Leipzig University. Winter Term 2024/25. <a href="/doc/ED-Seminar-Syllabus-WS-24-25.pdf">Seminar<i class="fas fa-file-pdf" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Race & Consumption.</strong> Ethnicity and Diversity in US Culture II. Leipzig University. Summer Term 2024. <a href="/doc/ED-II-Seminar-Syllabus-SoSe-2024.pdf">Seminar<i class="fas fa-file-pdf" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Visual Discourses of Race and Ethnicity.</strong> Ethnicity and Diversity in US Culture. Leipzig University. Winter Term 2023/24. <a href="/doc/ED-Seminar-Syllabus-WS-23-24.pdf">Seminar<i class="fas fa-file-pdf" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Unfilmable / Unwatchable: Cinematic Depictions of Identity, Conformity, and Neurodiversity.</strong> Media and Society. Leipzig University. Summer Term 2023. <a href="/doc/MaS-Seminar-Syllabus-SoSe-2023.pdf">Seminar<i class="fas fa-file-pdf" role="presentation"></i></a></p>
<p><strong class="hl hl-act">African American History, Culture, and Literature until the Civil War.</strong> Ethnicity and Diversity in US Culture. Leipzig University. 24 October 2022. <a href="/doc/ED-Guest-Lecture-WS-22-23.pdf">Guest Lecture<i class="fas fa-file-pdf" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Youth Cultures, Ethnicity, and Protest in the United States.</strong> Ethnicity and Diversity in US Culture. Leipzig University. Winter Term 2022/23. <a href="/doc/ED-Seminar-Syllabus-WS-22-23.pdf">Seminar<i class="fas fa-file-pdf" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Illuminating Race, Class, and Gender: The Cultural Dynamics of Mugshots and Passport Photography.</strong> Prison and Literature. Julius Maximilian University of Würzburg. 22 June 2022. <a href="https://www.neuphil.uni-wuerzburg.de/anglistik/aktuelles/single/news/illuminating-race-class-and-gender-the-cultural-dynamics-of-mugshots-and-passport-photography/">Guest Lecture<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">The Spectacle of Monsters: Crime, Deviance, and the Media in American Culture.</strong> Literature and Culture II. Leipzig University. Summer Term 2022. <a href="/doc/LC-II-Seminar-Syllabus-SoSe-2022.pdf">Seminar<i class="fas fa-file-pdf" role="presentation"></i></a></p>
<p><strong class="hl hl-act">&#8220;A technical white elephant&#8221;: Whiteness and (Post-)Racial Representations in US Visual and Material Culture.</strong> Ethnicity and Diversity in US Culture. Leipzig University. Winter Term 2021/22. <a href="/doc/ED-Seminar-Syllabus-WS-21-22.pdf">Seminar<i class="fas fa-file-pdf" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Reading the Transpacific: Asian American Cultures and Identities.</strong> Ethnicity and Diversity in US Culture. Leipzig University. Winter Term 2020/21. <a href="/doc/ED-Seminar-Syllabus-WS-20-21.pdf">Seminar<i class="fas fa-file-pdf" role="presentation"></i></a></p>
<p><strong class="hl hl-act">ASL Research Bash</strong> American Studies Leipzig. 25 June 2019. <a href="/doc/Research-Bash-Summer-2019.pdf">Material<i class="fas fa-file-pdf" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Racial Mixture as a Monstrous Threat in H.P. Lovecraft&#8217;s &#8220;The Shadow over Innsmouth.&#8221;</strong> Mixed Race America in U.S. Literature. Leipzig University. 13 June 2018. <span class="activity-link-inactive" aria-disabled="true">Guest Lecture</span></p>
<p><strong class="hl hl-act">Mapping Diversity: Imaginations of Race and Space in Historical and Contemporary US Literature.</strong> Ethnicity and Diversity in US Culture. Leipzig University. Winter Term 2017/18. <a href="/doc/ED-Seminar-Syllabus-WS-17-18.pdf">Seminar<i class="fas fa-file-pdf" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Racial Mixture as a Monstrous Threat in H.P. Lovecraft&#8217;s &#8216;The Shadow over Innsmouth.&#8217;</strong> Mixed Race America in U.S. Literature. Leipzig University. 8 June 2016. <span class="activity-link-inactive" aria-disabled="true">Guest Lecture</span></p>
</div>
</section>

<div class="anchor" id="thesis-supervision" aria-hidden="true"></div>

<section class="activity-category" aria-labelledby="thesis-supervision-title">
<header class="activity-category-header"><h2 id="thesis-supervision-title">Thesis Supervision <span class="activity-category-qualifier">(Selection)</span></h2></header>
<div class="activity-category-body gold">
<p><strong class="hl hl-act">Beautiful Violence: The Aestheticization and Commodification of
Violence in American Media.</strong> BA Thesis. American Studies Leipzig. 2026.</p>
<p><strong class="hl hl-act">Race, Environment, and (Eco-)Cosmic Horror in Lovecraft and
Annihilation.</strong> BA Thesis. American Studies Leipzig. 2026.</p>
<p><strong class="hl hl-act">Environmental Racism and its Health Effects in Chicago’s African-American Community
in the Late Twentieth Century.</strong> BA Thesis. American Studies Leipzig. 2026.</p>
</div>
</section>

<div class="anchor" id="fieldwork-archives" aria-hidden="true"></div>

<section class="activity-category" aria-labelledby="fieldwork-archives-title">
<header class="activity-category-header"><h2 id="fieldwork-archives-title">Research Travel</h2></header>
<div class="activity-category-body gold">
<p><strong class="hl hl-act">Tulane University Libraries.</strong> Tulane University, New Orleans. 2022. Funded by Deutsche Forschungsgemeinschaft.</p>
<p><strong class="hl hl-act">Nettie Lee Benson Latin American Studies Collection.</strong> University of Texas at Austin. 2022. Funded by Deutsche Forschungsgemeinschaft.</p>
<p><strong class="hl hl-act">Otto G. Richter Library.</strong> University of Miami. 2022. Funded by Deutsche Forschungsgemeinschaft.</p>
<p><strong class="hl hl-act">The Huntington Library.</strong> The Huntington, San Marino. 2020. Funded by Deutsche Forschungsgemeinschaft.</p>
<p><strong class="hl hl-act">Dornsife College of Letters, Arts and Sciences.</strong> University of Southern California, Los Angeles. 2020. Funded by Deutsche Forschungsgemeinschaft.</p>
<p><strong class="hl hl-act">Special Collections Library.</strong> University of Oregon, Eugene. 2020. Funded by Deutsche Forschungsgemeinschaft.</p>
<p><strong class="hl hl-act">Bancroft Library Western Americana Collection.</strong> University of California, Berkeley. 2017. Funded by Deutsche Forschungsgemeinschaft.</p>
<p><strong class="hl hl-act">Religion in American Society.</strong> 2015. Atlanta, Birmingham, Nashville, Chicago. American Studies Leipzig and Institute of American Studies and Polish Diaspora, Jagiellonian University Krakow. Funded by VolkswagenStiftung. With Hartmut Keil. <a href="https://studytour2015.wordpress.com">Co-Organizer<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
</div>
</section>

<section class="activity-category" aria-labelledby="memberships">
<header class="activity-category-header"><h2 id="memberships">Academic Memberships</h2></header>
<div class="activity-category-body gold">
<p><strong class="hl hl-act">American Comparative Literature Association</strong> <a href="https://www.acla.org">ACLA<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">American Historical Association</strong> <a href="https://historians.org">AHA<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">American Studies Association</strong> <a href="https://theasa.net">ASA<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Deutsche Gesellschaft für Amerikastudien / German Association for American Studies</strong> <a href="https://dgfa.de">DGfA / GAAS<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">European Network for the Study of Minor Mobilities in the Americas</strong> <a href="https://enmma.carrd.co/">ENMMA<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Latin American Studies Association</strong> <a href="https://lasaweb.org/en/">LASA<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Mid-Atlantic Popular & American Culture Association</strong> <a href="https://mapaca.net">MAPACA<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Northeast Popular & American Culture Association</strong> <a href="https://www.northeastpca.org/">NEPCA<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Society of Early Americanists</strong> <a href="https://www.societyofearlyamericanists.org">SEA<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
</div>
</section>

<div class="anchor" id="academic-service" aria-hidden="true"></div>

<section class="activity-category" aria-labelledby="academic-service-title">
<header class="activity-category-header"><h2 id="academic-service-title">Academic Service</h2></header>
<div class="activity-category-body gold">
<p id="activity-peer-reviewer-anglistik"><strong class="hl hl-act">Peer reviewer</strong><a href="https://angl.winter-verlag.de">Anglistik: International Journal of English Studies<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p id="activity-peer-reviewer-anq"><strong class="hl hl-act">Peer reviewer</strong><a href="https://www.tandfonline.com/journals/vanq20">ANQ: A Quarterly Journal of Short Articles, Notes, and Reviews<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p id="activity-peer-reviewer-clio"><strong class="hl hl-act">Peer reviewer</strong><a href="https://www.pfw.edu/clio/">Clio: A Journal of Literature, History, and the Philosophy of History<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p id="activity-peer-reviewer-ejas"><strong class="hl hl-act">Peer reviewer</strong><a href="https://journals.openedition.org/ejas/">European Journal of American Studies<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p id="activity-peer-reviewer-island-studies-journal"><strong class="hl hl-act">Peer reviewer</strong><a href="https://islandstudiesjournal.org/">Island Studies Journal<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
</div>
</section>

<div class="anchor" id="grants-awards" aria-hidden="true"></div>

<section class="activity-category" aria-labelledby="grants-awards-title">
<header class="activity-category-header"><h2 id="grants-awards-title">Grants &amp; Awards</h2></header>
<div class="activity-category-body gold">
<p><strong class="hl hl-act">Scottish Association for the Study of America. Annual Conference Essay Prize 2018</strong></p>
<p><strong class="hl hl-act">DAAD Travel Stipend 2017</strong></p>
</div>
</section>

<section class="activity-category mbot" aria-labelledby="volunteering">
<header class="activity-category-header"><h2 id="volunteering">Community Engagement</h2></header>
<div class="activity-category-body gold">
<p><strong class="hl hl-act">Mentoring</strong><a href="https://www.uni-leipzig.de/forschung/wissenschaftliche-laufbahn/promotion/pre-doc-award">Leipzig University Pre-Doc Award<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">Kurzfilmwanderung Leipzig</strong> <a href="https://kurzfilmwanderung.de/">Supported by the Cultural Foundation of the Free State of Saxony<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
<p><strong class="hl hl-act">KulturLounge e.V. Leipzig</strong> <a href="https://kulturlounge.jimdofree.com/">Supported by the Federal Government Commissioner for Culture and the Media<i class="fas fa-external-link-alt" role="presentation"></i></a></p>
</div>
</section>
