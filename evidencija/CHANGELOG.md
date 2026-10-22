## 1.47.0
- Skupni lov iz kalendara – bez dvostrukog poziva: termin vrste *Skupni lov* na dan lova ima gumb 🎯 Počni skupni lov (voditelj s pravom Skupni lov).

## 1.46.3
- Sigurnosno upozorenje (PHP2Shell): administratori na početnoj vide upozorenje ako poslužitelj radi na ranjivoj verziji PHP-a (CVE-2026-109618, CVE-2026-109619) – s objašnjenjem da PHP mora ažuri

## 1.46.2.1
- Sigurnost: PHP 8.3.36 (službena slika) – ispravak PHP2Shell (CVE-2026-109618, CVE-2026-109619); session.upload_progress isključen.

## 1.46.2
- Lovište strogo po sekcijama: Karta lovišta, Danas u lovištu, Kvarovi i Lovački dnevnik sada gledaju samo uloge koje daju pravo za lovište (nadzor, uređivanje, dnevnik) i njihove sekcije.

## 1.46.1
- Iskaznice (PDF A4, 10 po stranici): razmak između iskaznica – 6 mm lijevo/desno i 3,5 mm gore/dolje – lakše rezanje nakon ispisa (prije su se dodirivale).

## 1.46.0
- Početna – novi gumbi (odabir u *Sustav → Početna stranica*):

## 1.45.1
- Početna – gumb 🌲 Danas u lovištu: broj na gumbu je sada koliko ih trenutno sjedi u lovištu – isti za sve (prije samo nepročitane obavijesti za nadzor, pa ga lovočuvar bez tog prava nije vi

## 1.45.0
- ⚙️ Sustav → 🏠 Početna stranica: administrator za svaku ulogu (i za članove bez uloge) kvačicama bira što se vidi na početnoj, a strelicama redoslijed.

## 1.44.0
- Kalendar: vrsta termina „Zajednički lov“ sada se zove „Skupni lov“ (postojeći termini preimenovani).

## 1.43.0
- Skupni lov – voditelj lova automatski je na popisu sudionika (oznaka *voditelj lova*).

## 1.42.0
- Skupni lov – potpis članova na popisu:

## 1.40.0
- ✍ Osobni potpis: *Moj profil → ✍ Moj potpis* – svaki funkcionar potpiše se prstom (ili fotografija potpisa) i sam ga može obrisati; nitko drugi ga ne postavlja.

## 1.39.0
- Oružni listovi kod člana: Članovi → član → kartica *Podaci* → Oružni listovi – neograničeno upisa (broj + oružje, opis nije obavezan).

## 1.38.0
- 📷 Mobilna stanica – upis skeniranjem članskih iskaznica (uz suglasnost lovne inspekcije):

## 1.37.1
- „Grupni lov“ je sada „Skupni lov“ – u izborniku, pozivima, push obavijestima, pravima, modulima, popisu sudionika, PDF-u i uputama.

## 1.37.0
- Ista početna za sve: lovnik, lovočuvar, tajnik, blagajnik i ostali s pravima gore imaju iste velike gumbe kao lovci (📷 Skeniraj QR, 🗺️ Karta lovišta, 🌲 Danas u lovištu),

## 1.36.2
- ← Početna i na stranicama Karta lovišta, Danas u lovištu i Kvarovi na napravama.

## 1.36.1
- Ispravak – Imenik: lovci bez posebnih prava sada vide fotografije drugih članova (prije prazna slika / „slika nije pronađena“).

## 1.36.0
- Nova početna za lovce: na vrhu veliki gumbi za ono što je u lovu važno – 📷 Skeniraj QR (dezinfekcija), 🗺️ Karta lovišta i 🌲 Danas u lovištu.

## 1.35.1
- Tražilice isključene: Google, Bing i ostale tražilice više ne prikazuju vašu evidenciju u rezultatima pretrage (ni stranicu za prijavu, ni PDF-ove, slike ili kalendar).

## 1.35.0
- 🔒 Šifrirane sigurnosne kopije: novo u *Sustav → Sigurnosne kopije* – lozinka kopije. Svaka kopija koja se preuzima (kompletna i kopija baze) šifrirana je njome (AES-256 ZIP, otvara se i 7-Zip

## 1.34.2
- Sigurnija nadogradnja baze: kad nakon ažuriranja više članova istovremeno otvori aplikaciju, nadogradnju baze sada radi samo jedan – ostali kratko pričekaju.

## 1.34.1
- Popusti u trgovinama u demo verziji (primjeri trgovina, bez Oglasnika lovaca).

## 1.34.0
- 🏷️ Popusti u trgovinama – zajednički za sve udruge (kao Oglasnik lovaca): trgovine su na poslužitelju Oglasnika, pa lovci svih udruga vide iste popuste.

## 1.33.1
- 🏷️ Popusti – novo pravo „Popusti u trgovinama – uređivanje“ (Sustav → Uloge i prava, stupac *Popusti trgovine*): trgovine dodaje i uređuje samo tko ima to pravo.

## 1.33.0
- 🏷️ Popusti u trgovinama (novi modul): trgovine koje članovima udruge daju popust – administrator ih dodaje jednu po jednu (+ Nova trgovina:

## 1.31.0
- 🐕 Što pas radi (umjesto samo „radi krvni trag“): kod svakog psa kvačice – 🩸 potraga (krvni trag), 📯 pogon (gonič), 🐇 lov na sitnu divljač,

## 1.30.2
- 🦌 Logo programa Lovačka Evidencija (odvojeno od loga udruge): dno izbornika (s verzijom, vodi na Pomoć), ispod prijave, stranica Pomoć i kontakt, banner na GitHubu.

## 1.30.1
- ← Sustav gumb na svim stranicama Sustava (Podaci o udruzi, Korisnici, Uloge, Kopije …) i na postavkama modula otvorenim iz Sustava (vrste radnih akcija, postavke lovišta, stanice dezinfekcije).

## 1.30.0
- ⚙️ Sustav na jednom mjestu: u izborniku umjesto duge liste samo ⚙️ Sustav – otvara pregled u karticama po skupinama

## 1.29.2
- Grupni lov – karta: u popisu desno samo tko je u lovu (dolazi, na karti, SOS) i tko je 📋 na popisu sudionika (skeniran / ručno upisan).

## 1.29.1
- 🗑 Brisanje završenih grupnih lovova: gumb uz svaki završeni lov, u detalju lova, i Obriši sve završene (s popisima sudionika).

## 1.29.0
- 🪪 Članska iskaznica s QR kodom (format bankovne kartice 85,6 × 54 mm): logo i naziv udruge, fotografija, ime i prezime, sekcija, „član od“ i QR kod – sve na jednoj strani.

## 1.28.1
- 📖 Upute za korištenje ažurirane na trenutno stanje: zajednički Oglasnik lovaca (ulaz bez lozinke, interno/javno, moderacija, pravila za oružje),

## 1.28.0
- 🏡 Lovački domovi (novo u izborniku): domovi za cijelu udrugu ili za sekciju (sekcije i ovdje odvojene – dom sekcije vide i rezerviraju samo njezini članovi).

## 1.27.2
- Ispravka: u Uloge i prava dodan stupac Grupni lov – organizacija.

## 1.27.1
- SOS u grupnom lovu stiže svima koji su u lovu: organizatoru, Lovniku na licu mjesta i svim sudionicima; „Idem pomoći“.

## 1.27.0
- 🎯 Grupni lov – karta uživo i SOS: poziv „Dolazim / Ne dolazim“, položaj sudionika uživo, gubitak signala, SOS, kraj lova u 23:00.

## 1.26.2
- Bodove radnih akcija određuju samo postavke: u Novoj radnoj akciji (grupni unos) osnovni bodovi i bodovi dodatne opreme više se ne mogu upisivati – prikazuju se iz

## 1.26.1
- Ispravka: grupni unos radne akcije (Udruga → Nova radna akcija, i upis iz kalendara) više se ne odobrava sam – ide na odobrenje s predloženim bodovima (osnovni + oprema),

## 1.26.0
- 🧰 Dodatna oprema kod radnih akcija: u Sustav → Vrste radnih akcija uz svaku vrstu upisujete opremu s dodatnim bodovima (npr. Košnja: Traktor +5, Trimer +2, Motorna pila +3).

## 1.25.0
- 🔔 Push obavijesti na mobitel (Moje → Push obavijesti): stižu i kad je aplikacija zatvorena – besplatno, preko push servisa preglednika (bez SMS-a, bez dodatne aplikacije).

## 1.24.0
- 🔧 Kvarovi na lovnim napravama: na karti lovišta dodir na napravu → Prijavi kvar (opis, po želji fotografija s mobitela).

## 1.23.0
- 📖 Upute za korištenje (izbornik Program): kratke upute za svaki dio programa – prvi koraci, Moje, Kalendar, upis dezinfekcije, Lovište, Imenik/Poruke/Oglasnik, česta pitanja.

## 1.22.0
- 📢 Obavijesti s obaveznom potvrdom čitanja (Članovi → Obavijesti, i na vrhu stranice Poruke).

## 1.21.4
- Fotografije se smanjuju prije slanja; zaštita poslužitelja od prevelikih slika.

## 1.21.3
- Početna: bez gumba Inventura (samo u izborniku).

## 1.21.2
- Pomoć i kontakt: podrška razvoju samo gumbom PayPal.

## 1.21.1
- Pomoć i kontakt: dobrovoljna podrška razvoju putem PayPala.

## 1.21.0
- Inventura po sekcijama: grupiranje i filtar (sve / cijela udruga / sekcija), ispis PDF-a za sve, sekciju, jednu ili odabrane mape.

## 1.20.1
- Inventura: odvojena prava „Inventura – pregled“ (samo gledanje i PDF) i „Inventura – uređivanje“.

## 1.20.0
- 📦 Inventura: mape (dom, hranilišta, oprema…) po udruzi ili sekciji, stavke „treba“ / „stvarno“, manjak crveno / višak zeleno, PDF lista za popis s praznim stupcem.

## 1.19.1
- Izbornik: ikone uz sve stavke; „Statut i pravilnici“ ispod oglasa.

## 1.19.0
- Statut i pravilnici: dokumenti udruge (tekst, PDF, fotografije papira) za sve članove, uređuje administrator (Sustav → Statut i pravilnici).

## 1.18.2
- Oglasnik lovaca: prijava i registracija rade usprkos zaštiti od botova na hostingu Oglasnika; Oglasnik se otvara u novoj kartici.

## 1.18.1
- Oglasnik lovaca: ispravka povratnih poveznica iza Tailscale Funnela („Zahtjev nije poslan“).

## 1.18.0
- Oglasnik lovaca: zajednički oglasnik svih udruga (Sustav → Oglasnik lovaca) – registracija udruge zahtjevom, prijava članova bez lozinke, pravila udruge (samo udruga / sve udruge), novo pravo „Oglasnik – moderacija“. Zadano isključeno.
- Add-on: dodano PHP proširenje sodium.

## 1.17.0
- Vodiči pasa: popis članova s lovačkim psom (potraga, ispiti), kontakt prema dijeljenju člana ili poruka u aplikaciji.

## 1.16.4
- Lovački pas: broj rodne knjige, boja, dlaka, datum oštenja.

## 1.16.3
- Sustav → Podaci o udruzi: adresa, mjesto i OIB udruge (zaglavlja PDF-ova, izjava za inspekciju, uplatnica).
- Neutralni primjeri u poljima.

## 1.16.1
- Oglasnik: glavna slika uvijek u istom okviru 4:3.

## 1.16.0
- Gmail čarobnjak za slanje e-pošte (lozinka aplikacije, proba prije spremanja) i razumljive greške pri slanju.

## 1.15.3
- Tekst kvačice psa: „radi potragu (krvni trag)“.

## 1.15.2
- Pas: kvačica „radi potragu (krvni trag)“ za svaku pasminu.

## 1.15.1
- Moj profil: član sam upisuje svoje lovačke pse i ispite.

## 1.15.0
- Zajednički lov: član pri potvrdi dolaska označi psa; dan nakon lova radna akcija „Pas na lovu“ na čekanju.
- Nova vrsta „Potraga s psom (krvni trag)“, bodovna lista za pse, radne akcije povezane sa psom.

## 1.14.0
- Članovi → Lovački psi: psi, pasmina, ispiti; 1. siječnja automatski godišnji bodovi za psa (radna akcija na čekanju odobrenja).
- Članovi → Podaci: registarske oznake vozila za knjigu dezinfekcije.

## 1.13.0
- Uplatnice HUB-3A s 2D kodom za članarinu (jednokratno ili po ratama): Sustav → Uplatnica (IBAN), član vidi samo svoju uplatnicu (skeniranje / pokazivanje na šalteru / ispis), blagajnik šalje odabranima ili svima.
- Dvofaktorska prijava (Google Authenticator) obavezna za administratore.

## 1.12.3
- Ispravak lažnog upozorenja „baza je javno dostupna“.

## 1.12.2
- Interne pripreme; za korisnike nema promjena.

## 1.11.1
- Izvještaj radnih akcija: e-pošta samo odabranom primatelju s popisa; član dobiva samo svoje radne akcije i bodove, cijeli izvještaj samo uprava s pravom na izvještaje.

## 1.11.0
- Rad bez signala: stranica „📷 Skeniraj QR stanice“ (skener u aplikaciji, upisi na čekanju, spremljene stanice) – bez interneta se aplikacija otvara na njoj.
- Slanje spremljenih upisa u pozadini (Android), brisanje spremljenih stranica pri promjeni korisnika / odjavi, upozorenje kad sat mobitela nije točan.

## 1.10.0
- Ažuriranje iz aplikacije: glavni admin vidi novu verziju i ažurira jednim klikom (Sustav → Ažuriranje programa). Prije toga automatska kopija baze; add-on se ažurira preko Supervisora.

## 1.9.5
- Upozorenje kod pozivnice: *.ts.net (Tailscale Funnel) se smatra javnom adresom.

## 1.9.4
- Lovački dnevnik samo uz novo pravo „Lovište – lovački dnevnik“ (Sustav → Uloge i prava); pri nadogradnji ga dobivaju uloge sa svim pravima i „Lovište – nadzor“.

## 1.9.3
- Gumb „Trenutna adresa“ (javna adresa) ispravljen; upozorenje kod pozivnice/samoprijave ako poveznica vodi na privatnu (npr. Tailscale) ili drugu adresu.

## 1.9.2
- Izjava za inspekciju: pravni temelj za elektronički oblik evidencije (eIDAS čl. 46.).

## 1.9.1
- PDF knjige dezinfekcije sigurno i za velika razdoblja (ZIP po mjesecima); bez ograničenja 5000 upisa.

## 1.9.0
- Kompletna kopija (ZIP) sadrži i gotove PDF-ove knjige dezinfekcije (po mjesecima) i izjave za inspekciju.

## 1.8.9
- Granice lovišta (KML) u bazi – uključene u sigurnosne kopije i vraćanje na novom poslužitelju.

## 1.8.8
- Početak rada: brisanje svih probnih upisa dezinfekcije (i lovišta) uz sigurnosnu kopiju – glavni admin.

## 1.8.7
- Izjava za inspekciju: bez broja verzije, automatski potpisi sekcija i predsjednika; gumb u knjizi dezinfekcije.

## 1.8.6
- Mobilna stanica: pri zatvaranju organizirana dezinfekcija pri odlasku za sve bez upisanog odlaska (s potvrdom i imenima dežurnih).

## 1.8.5
- Inspekcija: izjava o vođenju evidencije dezinfekcije (pravni temelj, zaštita od promjena) – pregled i PDF; kopija programa (ZIP) za provjeru.

## 1.8.4
- Lovački dnevnik: dolazak bez odlaska prikazan samo s vremenom dolaska.

## 1.8.3
- Lovački dnevnik: lov bez čeke iz dezinfekcije kao pirš / obilazak, bez dvostrukih upisa.

## 1.8.2
- Lovački dnevnik: PDF umjesto Excela (CSV).

## 1.8.1
- Lovački dnevnik: i dolasci iz knjige dezinfekcije (radna akcija, hranjenje…), izbornik Aktivnost.

## 1.8.0
- Novo: **Lovište** – karta lovišta (granice iz KML-a), lovne naprave sa sličicama (odabir dodirom, uvoz fotografija s GPS-om),
  zauzimanje čeke (i za gosta), automatsko oslobađanje u 03:00, obavijesti lovočuvarima sekcije, Danas u lovištu, lovački dnevnik.
- Dezinfekcija: QR oznaka za ispis bez web adrese.

## 1.7.3
- Tolerancija GPS-a najviše 1000 m izvan radijusa.

## 1.7.1
- Odgovorna osoba i potpis po sekciji.

## 1.7.0
- Potpis odgovorne osobe na PDF-u evidencije dezinfekcije.

## 1.6.0
- Fotografije papirnatih lista dezinfekcije (lovci bez mobitela) u knjizi, PDF-u i pregledu za inspekciju.

## 1.5.0
- Upis za drugog lovca na dezinfekcijskoj stanici (lovočuvar i ovlašteni).

## 1.4.1
- Trajno brisanje poništenih (probnih) upisa dezinfekcije – glavni admin.

## 1.4.0
- Mobilna dezinfekcijska stanica za skupni lov (aktivacija na licu mjesta, praćenje uživo, zasebna knjiga i PDF).
- Upis dezinfekcije i bez signala – šalje se automatski kad ima interneta.

## 1.3.0
- Knjiga dezinfekcije (ASK): QR oznaka na stanici svake sekcije, provjera lokacije (GPS), dolazak/odlazak, razlog, reg. oznaka, suputnici i gosti.
- Pregled po sekcijama, PDF, e-pošta, naknadni upis, poništavanje; pristup za inspekciju (QR + lozinka).
- Moja vozila u profilu; sklopivi izbornik.

## 1.2.3
- Pomoć i kontakt u izborniku (prijava greške, prijedlog, pitanje autoru).

## 1.2.2
- Brisanje vlastitih poruka i cijelih razgovora (članovi i oglasnik).

## 1.2.1
- Članarina: postojećim zaduženjima bez plana jednim klikom dodijeliti plan plaćanja.

## 1.2.0
- Kalendar termina (po sekcijama), „dolazim / ne dolazim“, pretplata u kalendar mobitela.
- Članarina u ratama (1–12, vlastiti iznosi i datumi), plan po članu, diskretan podsjetnik članu.
- Početna stranica za članove (mobitel), imenik s dijeljenjem kontakata po izboru člana, poruke među članovima.
- Viber uz WhatsApp, „Dodaj na početni zaslon“ (Android, iPhone).
- Baza se nadograđuje automatski pri prvom pokretanju (nove tablice); postojeći podaci ostaju.

## 1.1.1
- Ispravak: poruke Tailscalea (poveznica za prijavu) ponovno vidljive u Logu.

## 1.1.0
- Aplikacija sada radi na **PHP verziji** (ista kao na GitHubu daxemann/lovacka-evidencija) – manja, brža za pokretanje, ista baza, fotografije i lozinke.
- Novo: **Samoprijava** – jedna zajednička poveznica za sve članove (npr. WhatsApp grupa), administrator povezuje i odobrava.
- Nakon nadogradnje: svi se jednom ponovno prijave; lozinku za e-poštu (SMTP) treba jednom ponovno upisati u Sustav → E-pošta i adresa.

## 1.0.2
- Moje radne akcije: preglednije na mobitelu.

## 1.0.1
- Vraćanje kompletne kopije i za glavnog admina (Sustav → Sigurnosne kopije).
- Preuzimanje kompletne kopije bez dvostrukog skidanja.

## 1.0.0
- Prva verzija: evidencija članova, radne akcije, članarina, oglasnik, postavke udruge, vraćanje kompletne kopije, Tailscale Funnel.
