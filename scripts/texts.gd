class_name Texts

# animals: bunny cat chick frog bear pig | colors: red yellow blue green pink purple
# shapes: ball square triangle star heart | count: 1..5
const DATA := {
	"tr": {
		"animals": ["Tavşana dokun!", "Kediye dokun!", "Civcive dokun!", "Kurbağaya dokun!", "Ayıcığa dokun!", "Domuzcuğa dokun!"],
		"colors": ["Kırmızı çiçeği bul!", "Sarı çiçeği bul!", "Mavi çiçeği bul!", "Yeşil çiçeği bul!", "Pembe çiçeği bul!", "Mor çiçeği bul!"],
		"shapes": ["Topu bul!", "Kareyi bul!", "Üçgeni bul!", "Yıldızı bul!", "Kalbi bul!"],
		"count": ["Bir elma topla!", "İki elma topla!", "Üç elma topla!", "Dört elma topla!", "Beş elma topla!"],
		"numbers": ["Bir", "İki", "Üç", "Dört", "Beş"],
		"balloons": "Balonları patlat!", "watch": "Çiçekleri izle!", "repeat": "Şimdi sıra sende!",
		"order": "Küçükten büyüğe dokun!", "praise": ["Aferin!", "Harikasın!", "Süper!"]},
	"en": {
		"animals": ["Tap the bunny!", "Tap the cat!", "Tap the chick!", "Tap the frog!", "Tap the bear!", "Tap the pig!"],
		"colors": ["Find the red flower!", "Find the yellow flower!", "Find the blue flower!", "Find the green flower!", "Find the pink flower!", "Find the purple flower!"],
		"shapes": ["Find the ball!", "Find the square!", "Find the triangle!", "Find the star!", "Find the heart!"],
		"count": ["Pick one apple!", "Pick two apples!", "Pick three apples!", "Pick four apples!", "Pick five apples!"],
		"numbers": ["One", "Two", "Three", "Four", "Five"],
		"balloons": "Pop the balloons!", "watch": "Watch the flowers!", "repeat": "Now it's your turn!",
		"order": "Tap from small to big!", "praise": ["Well done!", "Amazing!", "Great!"]},
	"es": {
		"animals": ["¡Toca el conejito!", "¡Toca el gatito!", "¡Toca el pollito!", "¡Toca la ranita!", "¡Toca el osito!", "¡Toca el cerdito!"],
		"colors": ["¡Busca la flor roja!", "¡Busca la flor amarilla!", "¡Busca la flor azul!", "¡Busca la flor verde!", "¡Busca la flor rosa!", "¡Busca la flor morada!"],
		"shapes": ["¡Busca la pelota!", "¡Busca el cuadrado!", "¡Busca el triángulo!", "¡Busca la estrella!", "¡Busca el corazón!"],
		"count": ["¡Recoge una manzana!", "¡Recoge dos manzanas!", "¡Recoge tres manzanas!", "¡Recoge cuatro manzanas!", "¡Recoge cinco manzanas!"],
		"numbers": ["Uno", "Dos", "Tres", "Cuatro", "Cinco"],
		"balloons": "¡Explota los globos!", "watch": "¡Mira las flores!", "repeat": "¡Ahora te toca a ti!",
		"order": "¡Toca de pequeño a grande!", "praise": ["¡Muy bien!", "¡Genial!", "¡Estupendo!"]},
	"pt": {
		"animals": ["Toque no coelhinho!", "Toque no gatinho!", "Toque no pintinho!", "Toque no sapinho!", "Toque no ursinho!", "Toque no porquinho!"],
		"colors": ["Encontre a flor vermelha!", "Encontre a flor amarela!", "Encontre a flor azul!", "Encontre a flor verde!", "Encontre a flor rosa!", "Encontre a flor roxa!"],
		"shapes": ["Encontre a bola!", "Encontre o quadrado!", "Encontre o triângulo!", "Encontre a estrela!", "Encontre o coração!"],
		"count": ["Pegue uma maçã!", "Pegue duas maçãs!", "Pegue três maçãs!", "Pegue quatro maçãs!", "Pegue cinco maçãs!"],
		"numbers": ["Um", "Dois", "Três", "Quatro", "Cinco"],
		"balloons": "Estoure os balões!", "watch": "Olhe as flores!", "repeat": "Agora é a sua vez!",
		"order": "Toque do menor para o maior!", "praise": ["Muito bem!", "Incrível!", "Ótimo!"]},
	"fr": {
		"animals": ["Touche le lapin !", "Touche le chat !", "Touche le poussin !", "Touche la grenouille !", "Touche l'ourson !", "Touche le cochon !"],
		"colors": ["Trouve la fleur rouge !", "Trouve la fleur jaune !", "Trouve la fleur bleue !", "Trouve la fleur verte !", "Trouve la fleur rose !", "Trouve la fleur violette !"],
		"shapes": ["Trouve la balle !", "Trouve le carré !", "Trouve le triangle !", "Trouve l'étoile !", "Trouve le cœur !"],
		"count": ["Cueille une pomme !", "Cueille deux pommes !", "Cueille trois pommes !", "Cueille quatre pommes !", "Cueille cinq pommes !"],
		"numbers": ["Un", "Deux", "Trois", "Quatre", "Cinq"],
		"balloons": "Éclate les ballons !", "watch": "Regarde les fleurs !", "repeat": "À toi de jouer !",
		"order": "Touche du plus petit au plus grand !", "praise": ["Bravo !", "Super !", "Génial !"]},
	"de": {
		"animals": ["Tippe auf den Hasen!", "Tippe auf die Katze!", "Tippe auf das Küken!", "Tippe auf den Frosch!", "Tippe auf den Bären!", "Tippe auf das Schweinchen!"],
		"colors": ["Finde die rote Blume!", "Finde die gelbe Blume!", "Finde die blaue Blume!", "Finde die grüne Blume!", "Finde die rosa Blume!", "Finde die lila Blume!"],
		"shapes": ["Finde den Ball!", "Finde das Quadrat!", "Finde das Dreieck!", "Finde den Stern!", "Finde das Herz!"],
		"count": ["Pflücke einen Apfel!", "Pflücke zwei Äpfel!", "Pflücke drei Äpfel!", "Pflücke vier Äpfel!", "Pflücke fünf Äpfel!"],
		"numbers": ["Eins", "Zwei", "Drei", "Vier", "Fünf"],
		"balloons": "Lass die Ballons platzen!", "watch": "Schau dir die Blumen an!", "repeat": "Jetzt bist du dran!",
		"order": "Tippe von klein nach groß!", "praise": ["Gut gemacht!", "Toll!", "Super!"]},
	"ar": {
		"animals": ["المسي الأرنب!", "المسي القطة!", "المسي الكتكوت!", "المسي الضفدع!", "المسي الدب!", "المسي الخنزير الصغير!"],
		"colors": ["ابحثي عن الزهرة الحمراء!", "ابحثي عن الزهرة الصفراء!", "ابحثي عن الزهرة الزرقاء!", "ابحثي عن الزهرة الخضراء!", "ابحثي عن الزهرة الوردية!", "ابحثي عن الزهرة البنفسجية!"],
		"shapes": ["ابحثي عن الكرة!", "ابحثي عن المربع!", "ابحثي عن المثلث!", "ابحثي عن النجمة!", "ابحثي عن القلب!"],
		"count": ["اقطفي تفاحة واحدة!", "اقطفي تفاحتين!", "اقطفي ثلاث تفاحات!", "اقطفي أربع تفاحات!", "اقطفي خمس تفاحات!"],
		"numbers": ["واحد", "اثنان", "ثلاثة", "أربعة", "خمسة"],
		"balloons": "فرقعي البالونات!", "watch": "شاهدي الزهور!", "repeat": "الآن دورك!",
		"order": "المسي من الصغير إلى الكبير!", "praise": ["أحسنتِ!", "رائع!", "ممتاز!"]},
	"ru": {
		"animals": ["Нажми на зайчика!", "Нажми на котика!", "Нажми на цыплёнка!", "Нажми на лягушку!", "Нажми на мишку!", "Нажми на поросёнка!"],
		"colors": ["Найди красный цветок!", "Найди жёлтый цветок!", "Найди синий цветок!", "Найди зелёный цветок!", "Найди розовый цветок!", "Найди фиолетовый цветок!"],
		"shapes": ["Найди мячик!", "Найди квадрат!", "Найди треугольник!", "Найди звёздочку!", "Найди сердечко!"],
		"count": ["Сорви одно яблоко!", "Сорви два яблока!", "Сорви три яблока!", "Сорви четыре яблока!", "Сорви пять яблок!"],
		"numbers": ["Один", "Два", "Три", "Четыре", "Пять"],
		"balloons": "Лопни шарики!", "watch": "Смотри на цветы!", "repeat": "Теперь твоя очередь!",
		"order": "Нажимай от маленького к большому!", "praise": ["Молодец!", "Отлично!", "Здорово!"]},
}
