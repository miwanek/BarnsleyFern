.data
.globl main
	
rozmiar:	.space 4		# rozmiar pliku bmp
szerokosc:	.space 4		# szerokosc pliku bmp
wysokosc:	.space 4		# wysokosc pliku bmp
offset:		.space 4		# offset - przesuniecie pocz¹tku tablicy pikseli wzglêdem pocz¹tku pliku
buff:		.space 4		# bufor wczytywania

witaj:		.asciiz	"Paproc Barnsleya\nPodaj liczbe iteracji algorytmu: "
input:		.asciiz	"input.bmp"
output:		.asciiz "output.bmp"
blad:		.asciiz "Blad odczytu pliku \n"


.text	
main:	la $a0, witaj			# wczytujemy adress stringa witaj do rejestru a0
	li $v0, 4			# syscall 4: wypisanie stringa
	syscall				# wypisanie na ekranie zawartosci stringa hello
	li $v0,5			# syscall 5: wczytanie inta
	syscall
	move $s0,$v0			# kopiujemy liczbe iteracji do dalszego u¿ytku
	
wczytaj_plik:
	la $a0, input			# wczytujemy nazwy pliku do otwarcia
	li $a1, 0			# flagi otwarcia
	li $a2, 0			# tryb otwarcia
	li $v0, 13			# syscall 13: otwarcie pliku 
	syscall				#  w $v0 mamy   deskryptor
	
	move $t0, $v0			# kopiujemy deskryptora do rejestru t0
	
	bltz $t0, blad_otwarcia		# przechodzimy do blad_otwarcia jesli wczytywanie sie nie powiodlo

	move $a0, $t0			# kopiujemy deskryptora do a0
	la $a1, buff			# ³adujemy adres bufora wczytywania
	li $a2, 2			# ustawiamy odczytu 2 pierwszych bajtow (BM)
	li $v0, 14			# syscall 14: odczyt z pliku 
	syscall			
	
	move $a0, $t0			# kopiujemy deskryptora do a0
	la $a1, rozmiar			# ³adujemy adres zmiennej do przechowywania wczytanych danych
	li $a2, 4			# ustawaimy odczytu 4 bajtow
	li $v0, 14			# syscall 14: odczyt z pliku 
	syscall			
	
	lw $t7, rozmiar			# kopiujemy rozmiaru pliku do rejestru t7
	
	move $a0, $t7			# kopiujemy rozmiaru pliku do a0
	li $v0, 9			# syscall 9: alokujemy pamiêæ na stercie
	syscall				
	move $t1, $v0			# kopiujemy adres zaalokowanej pamieci do rejestru t1
	
	move $a0, $t0			# kopiujemy deskryptora do a0
	la $a1, buff			# ³adujemy adres bufora wczytywania
	li $a2, 4			# ustawiamy odczytu 4 bajtow zarezerwowanych ( nic nam nie mówi¹)
	li $v0, 14			# syscall 14: odczyt z pliku 
	syscall				# przechodzimy o 4 bajty od przodu
	
	move $a0, $t0			# kopiujemy deskryptor do a0
	la $a1, offset			# ³¹dujemy adres zmiennej do przechowywania offsetu
	li $a2, 4			# istawiamy odczyt 4 bajtow offsetu
	li $v0, 14			# syscall 14: odczyt z pliku 
	syscall				# wczytujemy offsetu do offset	
	
	move $a0, $t0			# kopiujemy deskryptor do a0
	la $a1, buff			# ³adujemy adres bufora wczytywania
	li $a2, 4			# ustawiamy odczyt 4 bajtow - wielkosci naglowka informacyjnego
	li $v0, 14			# syscall 14: odczyt z pliku 
	syscall				# przechodzimy o 4 bajty od przodu
	
	move $a0, $t0			# kopiujemy deskryptor do a0
	la $a1, szerokosc		# ³adujemy adres zmiennej do przechowywania szerokosci
	li $a2, 4			# ustawiamy odczyt 4 bajtow - szerokosci
	li $v0, 14			# syscall 14: odczyt z pliku 
	syscall				# wczytujemy szerokosci bitmapy
	
	
	move $a0, $t0			# kopiujemy deskryptor do a0
	la $a1, wysokosc		# ³adujemy adres zmiennej do przechowywania wysokosci
	li $a2, 4			# ustawiamy odczyt 4 bajtow - wysokosci
	li $v0, 14			# syscall 14: odczyt z pliku 
	syscall			 	# wczytujemy wysokosc bitmapy
	
	
	move $a0, $t0			# kopiujemy deskryptor pliku do a0
	li $v0, 16			# syscall 16: zamkniêcie pliku 
	syscall				# zamkniecie pliku o deskryptorze w a0
	
alokacja_plik:
	la $a0, input			# wczytujemy nazwe pliku do otwarcia
	li $a1, 0			# flagi otwarcia
	li $a2, 0			# tryb otwarcia
	li $v0, 13			# syscall 13:  otwieranie pliku
	syscall				# otwieramy plik,  w $v0 dostajemy jego deskryptor
	
	move $t0, $v0			# kopiujemy deskryptor do rejestru t0
	
	bltz $t0, blad_otwarcia		# przeskakujemy do blad_otwarcia jesli wczytywanie sie nie powiodlo
	
	move $a0, $t0			# kopiujemy deskryptor 
	la $a1, ($t1)			# ³adujemy adres wczesniej zaalokowanej pamieci jako miejsca do wczytania
	la $a2, ($t7)			# ³adujemy odczyt tylu bajtow ile ma plik
	li $v0, 14			# syscall  14:  odczyt z pliku
	syscall
	
	lw $t7, rozmiar			# ponowne wczytanie rozmiaru pliku do rejestru t7
	
	move $a0, $t0			# kopiujemy deskryptora 
	li $v0, 16			# syscall 16: zamkniecie pliku
	syscall				# zamkniecie pliku o deskryptorze w a0

padding:
	lw $t4,szerokosc 		# ³adujemy szerokoœæ mapy
	mul $t4,$t4,3 			# mno¿ymy x3 bo ka¿dy piksel zajmuje 3 bajty
	and  $t4,$t4,3 			# sprawdzamy resztê
	beqz $t4,start 			# jeœli reszta wychodzi zero to nasz myk by nie wyszed³
	li $t5,4 			# wrzucamy do rejestru pomocnicz¹ 4
	sub $t5,$t5,$t4 		# odejmujemy od 4 reszte z dzielenia i dostajemy liczbe bitów paddingu
	
start:	
	li $s5,0 			# wspó³rzedna x
	li $s6,0 			# wspó³rzêdna y

losujemy:
	ble $s0,0,zapisz_plik		# sprawdzamy warunek   pêtli
 	subi $s0,$s0,1 			# zmniejszamy licznik losowania punktów
	li $v0,42 			# wywo³ujemy generator liczb pseudolosowych
	li $a1,100 			# zakres 0-99
	syscall
	li $s1,85 			# wybor pierwszej funkcji
	li $s2,92 			# wybor drugiej funkcji
	li $s3,99 			# wybor trzeciej funkcji
	li $s4,100 			# wybor czwartej funkcji
	blt $a0,$s1,pierwsza_funkcja 	# skok warunkowy do pierwszej funkcji
	blt $a0,$s2,druga_funkcja  	# skok warunkowy do drugiej funkcji
	blt $a0,$s3,trzecia_funkcja  	# skok warunkowy do trzeciej funkcji
	blt $a0,$s4,czwarta_funkcja 	# skok warunkowy do czwartek funkcji
	
pierwsza_funkcja:  # wolne rejestry s1,s2,s3,s4. t2, t3, t8
	# move $s1, $s5 			# nowy x
	# move $s2, $s6 			# nowy y
	
	# produkujemy nowego X
	
	li $t8,0x6CCCCCC 
	mul $s1, $s5,$t8 		# mno¿ymy x przez 0.85
	mfhi $t2			# ³adujemy górn¹ czêœæ wyniku ( 10 cyfr ca³kowitych, 22 u³amka )
	mflo $t3			# ³adujemy doln¹ czêœæ wyniku (32 cyfry u³amka )
	sll $t2, $t2,5 			# odsuwamy piêæ miejsc w lewo, ¿eby dostaæ liczbê o 5 bitach ca³kowitych)
	srl $t3,$t3,27			# dosuwamy 27 miejsc w prawo, bo interesuje nas tylko 5 najbardziej znacz¹cych liczb w u³amku
	or $s1,$t2,$t3			# wrzucamy nasz sformatowany u³amek
	
	li $t8,0x51EB85	 
	mul $t2, $s6, $t8		# mno¿ymy y przez 0.04 
	mfhi $t2			# ³adujemy górn¹ czêœæ wyniku ( 10 cyfr ca³kowitych, 22 u³amka )
	mflo $t3			# ³adujemy doln¹ czêœæ wyniku (32 cyfry u³amka )
	sll $t2,$t2,5 			# odsuwamy piêæ miejsc w lewo, ¿eby dostaæ liczbê o 5 bitach ca³kowitych)
	srl $t3,$t3,27			# dosuwamy 27 miejsc w prawo, bo interesuje nas tylko 5 najbardziej znacz¹cych liczb w u³amku 
	or $s3,$t2,$t3			# wrzucamy nasz sformatowany u³amek  
	add $s1,$s1,$s3			# dodajemy elementy i otrzymujemy nowy x
	
	# produkujemy nowego Y
	
	li $t8,0x51EB85	 
	mul $s3,$s5,$t8			# zabieramy siê za y, na pcz¹tek mno¿ymy x* 0.04
	mfhi $t2			# ³adujemy górn¹ czêœæ wyniku ( 10 cyfr ca³kowitych, 22 u³amka )
	mflo $t3			# ³adujemy doln¹ czêœæ wyniku (32 cyfry u³amka )
	sll $t2,$t2,5 			# odsuwamy piêæ miejsc w lewo, ¿eby dostaæ liczbê o 5 bitach ca³kowitych)
	srl $t3,$t3,27			# dosuwamy 27 miejsc w prawo, bo interesuje nas tylko 5 najbardziej znacz¹cych liczb w u³amku
	or $s3,$t2,$t3			# wrzucamy nasz sformatowany u³amek
	
	li $t8,0x6CCCCCC	 
	mul $s2, $s6, $t8 		# mno¿ymy y przez 0.85
	mfhi $t2			# ³adujemy górn¹ czêœæ wyniku ( 10 cyfr ca³kowitych, 22 u³amka )
	mflo $t3			# ³adujemy doln¹ czêœæ wyniku (32 cyfry u³amka )
	sll $t2,$t2,5 			# odsuwamy piêæ miejsc w lewo, ¿eby dostaæ liczbê o 5 bitach ca³kowitych)
	srl $t3,$t3,27			# dosuwamy 27 miejsc w prawo, bo interesuje nas tylko 5 najbardziej znacz¹cych liczb w u³amku
	or $s2,$t2,$t3			# wrzucamy nasz sformatowany u³amek

	li $t8,0xCCCCCCC
	add $s2,$s2,$t8 		# dodajemy do y+ 1.6
	sub $s2,$s2, $s3		# dodajemy -0.04 x ( czyli odejmujemy 0.04 x )
	b zapis_piksela
	
druga_funkcja:
	# produkujemy nowego X
	li $t8,0x1333333
	mul $s3, $s5,$t8		# mno¿ymy x przez 0.15
	mfhi $t2			# ³adujemy górn¹ czêœæ wyniku ( 10 cyfr ca³kowitych, 22 u³amka )
	mflo $t3			# ³adujemy doln¹ czêœæ wyniku (32 cyfry u³amka )
	sll $t2,$t2,5 			# odsuwamy piêæ miejsc w lewo, ¿eby dostaæ liczbê o 5 bitach ca³kowitych)
	srl $t3,$t3,27			# dosuwamy 27 miejsc w prawo, bo interesuje nas tylko 5 najbardziej znacz¹cych liczb w u³amku
	or $s3,$t2,$t3			# wrzucamy nasz sformatowany u³amek

	li $t8,0x23D70A3
	mul $t2, $s6, $t8		# mno¿ymy y przez 0.28 
	mfhi $t2			# ³adujemy górn¹ czêœæ wyniku ( 10 cyfr ca³kowitych, 22 u³amka )
	mflo $t3			# ³adujemy doln¹ czêœæ wyniku (32 cyfry u³amka )
	sll $t2,$t2,5 			# odsuwamy piêæ miejsc w lewo, ¿eby dostaæ liczbê o 5 bitach ca³kowitych)
	srl $t3,$t3,27			# dosuwamy 27 miejsc w prawo, bo interesuje nas tylko 5 najbardziej znacz¹cych liczb w u³amku 
	or $s4,$t2,$t3			# wrzucamy nasz sformatowany u³amek  
	
	sub $s1,$s4,$s3			# dodajemy elementy i otrzymujemy nowy x
	
	# produkujemy nowego Y
	
	li $t8,0x1D70A3D
	mul $s3,$s5,$t8			# zabieramy siê za y, na pcz¹tek mno¿ymy x* 0.23
	mfhi $t2			# ³adujemy górn¹ czêœæ wyniku ( 10 cyfr ca³kowitych, 22 u³amka )
	mflo $t3			# ³adujemy doln¹ czêœæ wyniku (32 cyfry u³amka )
	sll $t2,$t2,5 			# odsuwamy piêæ miejsc w lewo, ¿eby dostaæ liczbê o 5 bitach ca³kowitych)
	srl $t3,$t3,27			# dosuwamy 27 miejsc w prawo, bo interesuje nas tylko 5 najbardziej znacz¹cych liczb w u³amku
	or $s3,$t2,$t3			# wrzucamy nasz sformatowany u³amek
	
	li $t8,0x1C28F5C
	mul $s4, $s6,$t8		# mno¿ymy y przez 0.22
	mfhi $t2			# ³adujemy górn¹ czêœæ wyniku ( 10 cyfr ca³kowitych, 22 u³amka )
	mflo $t3			# ³adujemy doln¹ czêœæ wyniku (32 cyfry u³amka )
	sll $t2,$t2,5 			# odsuwamy piêæ miejsc w lewo, ¿eby dostaæ liczbê o 5 bitach ca³kowitych)
	srl $t3,$t3,27			# dosuwamy 27 miejsc w prawo, bo interesuje nas tylko 5 najbardziej znacz¹cych liczb w u³amku
	or $s4,$t2,$t3			# wrzucamy nasz sformatowany u³amek

	add $s2,$s3, $s4		# dodajemy czêœc od x i od y
	li $t8, 0x3851EB8
	add  $s2,$s2,$t8 		# dodajemy do y+ 0.44
	b zapis_piksela
	
trzecia_funkcja:

	li $t8, 0x1999999
	mul $s3, $s5,$t8		# mno¿ymy x przez 0.20
	mfhi $t2			# ³adujemy górn¹ czêœæ wyniku ( 10 cyfr ca³kowitych, 22 u³amka )
	mflo $t3			# ³adujemy doln¹ czêœæ wyniku (32 cyfry u³amka )
	sll $t2,$t2,5 			# odsuwamy piêæ miejsc w lewo, ¿eby dostaæ liczbê o 5 bitach ca³kowitych)
	srl $t3,$t3,27			# dosuwamy 27 miejsc w prawo, bo interesuje nas tylko 5 najbardziej znacz¹cych liczb w u³amku
	or $s3,$t2,$t3			# wrzucamy nasz sformatowany u³amek
	
	li $t8, 0x2147AE1
	mul $t2, $s6, $t8		# mno¿ymy y przez 0.26 
	mfhi $t2			# ³adujemy górn¹ czêœæ wyniku ( 10 cyfr ca³kowitych, 22 u³amka )
	mflo $t3			# ³adujemy doln¹ czêœæ wyniku (32 cyfry u³amka )
	sll $t2,$t2,5 			# odsuwamy piêæ miejsc w lewo, ¿eby dostaæ liczbê o 5 bitach ca³kowitych)
	srl $t3,$t3,27			# dosuwamy 27 miejsc w prawo, bo interesuje nas tylko 5 najbardziej znacz¹cych liczb w u³amku 
	or $s4,$t2,$t3			# wrzucamy nasz sformatowany u³amek  
	
	sub $s1,$s3,$s4			# dodajemy elementy i otrzymujemy nowy x
	
	# produkujemy nowego Y
	
	li $t8, 0x2147AE1
	mul $s3,$s5,$t8			# zabieramy siê za y, na pcz¹tek mno¿ymy x* 0.26
	mfhi $t2			# ³adujemy górn¹ czêœæ wyniku ( 10 cyfr ca³kowitych, 22 u³amka )
	mflo $t3			# ³adujemy doln¹ czêœæ wyniku (32 cyfry u³amka )
	sll $t2,$t2,5 			# odsuwamy piêæ miejsc w lewo, ¿eby dostaæ liczbê o 5 bitach ca³kowitych)
	srl $t3,$t3,27			# dosuwamy 27 miejsc w prawo, bo interesuje nas tylko 5 najbardziej znacz¹cych liczb w u³amku
	or $s3,$t2,$t3			# wrzucamy nasz sformatowany u³amek
	
	li $t8, 0x1EB851E
	mul $s4, $s6, $t8 		# mno¿ymy y przez 0.24
	mfhi $t2			# ³adujemy górn¹ czêœæ wyniku ( 10 cyfr ca³kowitych, 22 u³amka )
	mflo $t3			# ³adujemy doln¹ czêœæ wyniku (32 cyfry u³amka )
	sll $t2,$t2,5 			# odsuwamy piêæ miejsc w lewo, ¿eby dostaæ liczbê o 5 bitach ca³kowitych)
	srl $t3,$t3,27			# dosuwamy 27 miejsc w prawo, bo interesuje nas tylko 5 najbardziej znacz¹cych liczb w u³amku
	or $s4,$t2,$t3			# wrzucamy nasz sformatowany u³amek

	add $s2,$s3, $s4		# dodajemy czêœc od x i od y
	li $t8, 0xCCCCCCC
	add  $s2,$s2,$t8	 	# dodajemy do y+ 1.6
	b zapis_piksela
	
czwarta_funkcja:
	li $s1,0 			# zerujemy x
	li $t8, 0x1EB851E
	mul $s4, $s6,$t8 		# mno¿ymy y przez 0.16
	mfhi $t2			# ³adujemy górn¹ czêœæ wyniku ( 10 cyfr ca³kowitych, 22 u³amka )
	mflo $t3			# ³adujemy doln¹ czêœæ wyniku (32 cyfry u³amka )
	sll $t2,$t2,5 			# odsuwamy piêæ miejsc w lewo, ¿eby dostaæ liczbê o 5 bitach ca³kowitych)
	srl $t3,$t3,27			# dosuwamy 27 miejsc w prawo, bo interesuje nas tylko 5 najbardziej znacz¹cych liczb w u³amku
	or $s4,$t2,$t3			# wrzucamy nasz sformatowany u³amek
	move $s2,$s4			# przesy³amy do miejsca sk³adowania nowego Y
	b zapis_piksela
	
zapis_piksela:
	 #po³o¿enie X w tablicy pikseli

	lw $s7,szerokosc 		# ³aduje szerokoœæ
	move $s3,$s1 			# ³adujemy x do rejestru
	addi $s3,$s3,0x18000000		# przesuwamy go o 3, bo nie chcemy ujemnych adresów
	mul $s3,$s3,$s7 		# mno¿ymy razy liczba pikseli
	mfhi $t2			# ³adujemy górn¹ czêœæ wyniku 
	mflo $t3			# ³adujemy doln¹ czêœæ wyniku 5 cyfr ca³kowitych i 27 u³amka
	sll $t2,$t2,5 			# odsuwamy piêæ miejsc w lewo, ¿eby zrobiæ miejsce na resztê bitów ca³kowitych
	srl $t3,$t3,27			# dosuwamy 27 miejsc w prawo, bo interesuje nas tylko 5 najbardziej znacz¹cych bitów w u³amku
	or $s3,$t2,$t3			# wrzucamy nasz sformatowany u³amek
	div $s3,$s3,6 			# dzielimy przez 6, bo mamy podzia³kê d³ugoœci 6

	 
	 #po³o¿enie y w tablicy pikseli

	lw $s7,wysokosc 		# ³aduje wysokoœæ pliku w pikselach
	move $s4,$s2 			# ³adujemy y do rejestru
	mul $s4,$s4,$s7 		# mno¿ymy razy liczba pikseli
	mfhi $t2			# ³adujemy górn¹ czêœæ wyniku 
	mflo $t3			# ³adujemy doln¹ czêœæ wyniku 5 cyfr ca³kowitych i 27 u³amka
	sll $t2,$t2,5 			# odsuwamy piêæ miejsc w lewo, ¿eby zrobiæ miejsce na resztê bitów ca³kowitych
	srl $t3,$t3,27			# dosuwamy 27 miejsc w prawo, bo interesuje nas tylko 5 najbardziej znacz¹cych bitów w u³amku
	or $s4,$t2,$t3			# wrzucamy nasz sformatowany u³amek
	div $s4,$s4,10 			# dzielimy przez 10, bo taka jest podzialka
	move $t9,$s4 			# zapamiêtujemy sobie naszego y, aby potem móc dodaæ padding
	mul $t9,$t9,$t5			# wyliczamy dodatkowe przesuniêcie ze wzglêdu na padding
	
	 #numer piksela do obrobienia
	 
	lw $s7,szerokosc 		# wczytujemy szerokoœæ naszego obrazka w pikselach
	mul $s4,$s4,$s7 		# Y* szerokoœæ dostajemy ile pikseli trzeba przesun¹æ
	add $s4,$s4,$s3 		# += X dorzucamy piksele w wierszu
	
	#³adujemy kolejno barwy
	
	la $t6,($t1) 			# ³adujemy adres pocz¹tkowy pamiêci
	mul  $s4,$s4,3 			# ka¿dy piksel zajmuje 3 bajty
	lw $s7,offset			# ³adujemy przesuniêcie tablicy pikseli wzglêdem pocz¹tku pliku
	add $t6,$t6,$s4 		# przesuwamy wskaŸnik na piksel do pomalowania
	add $t6,$t6,$s7			# przesuwamy, ¿eby uwzglêdniæ offset tablicy pikseli
	add $t6,$t6,$t9			# przesuwamy, ¿eby uwzglêdniæ padding
	li $t3,60 			# niebieski
	sb $t3,($t6) 			# wpisujemy poziom czerwonej barwy
	addi $t6,$t6,1			# przechodzimy do kolejnej barwy
	li $t3,20 			# zielony
	sb $t3,($t6) 			# wpisujemy kolor zielonej barwy
	addi $t6,$t6,1 			# przechodzimy do kolejnej barwy
	li $t3,200 			# czerwony
	sb $t3,($t6)  			# wpisujemy kolor niebieskiej barwy
	move $s5,$s1 			# wrzucamy now¹ wartoœæ
	move $s6,$s2 			# wrzucamy now¹ wartoœæ
	b losujemy

zapisz_plik:


	la $a0, output			# wczytanie nazwy pliku do otwarcia
	li $a1, 1			# flagi otwarcia
	li $a2, 0			# tryb otwarcia
	li $v0, 13			# syscall 13:  otwarcie pliku
	syscall				# otwieramy  plik,  w $v0  mamy jego deskryptora
	
	move $t0, $v0			# kopiujemy deskryptor do rejestru v0
	lw $t7, rozmiar			# ³adujemy rozmiar bitmapy
	bltz $t0, blad			# przechodzimy do blad_otwarcia jesli wczytywanie sie nie powiodlo
	move $a0, $t0			# kopiujemy deskryptora do a0
	la $a1, ($t1)			# ³adujemy adres wczesniej zaalokowanej pamieci jako danych do zapisania
	la $a2, ($t7)			# ³adujemy  tyle bajtow do zapisu ile ma plik
	li $v0, 15			# syscall 15 : zapis do pliku 
	syscall				
	
zamknij_plik:
	move $a0, $t0			# kopiujemy deskryptor pliku do a0
	li $v0, 16			# syscal 16: zamkniecie pliku
	syscall				

koniec:	li $v0, 10			# syscall 10: exit
	syscall				# wychodzimy z programu
	
blad_otwarcia:
	la $a0, blad
	li $v0, 4
	syscall
	b koniec



	

