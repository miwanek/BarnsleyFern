.data
.globl main
	
rozmiar:		.space 4		# rozmiar pliku bmp
szerokosc:		.space 4		# szerokosc pliku bmp
wysokosc:		.space 4		# wysokosc pliku bmp
offset:			.space 4		# offset - przesuniecie pocz¹tku tablicy pikseli wzglêdem pocz¹tku pliku
buff:			.space 4		# bufor wczytywania

witaj:		.asciiz	"Paproc Barnsleya\nPodaj liczbe iteracji algorytmu: "
input:		.asciiz	"input.bmp"
output:		.asciiz "output.bmp"
blad:		.asciiz "Blad odczytu pliku \n"


.text	
main:	la $a0, iteration		# wczytujemy adress stringa witaj do rejestru a0
	li $v0, 4			# syscall 4: wypisanie stringa
	syscall				# wypisanie na ekranie zawartosci stringa hello
	li $v0,5			# syscall 5: wczytanie inta
	syscall
	move $s0,$v0			# kopiujemy liczbe iteracji do dalszego u¿ytku

wczytaj_plik:
	la $a0, input  			# wczytujemy nazwy pliku do otwarcia
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
	la $a0, input  			# wczytujemy nazwe pliku do otwarcia
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
		subi $s0,$s0,1 		# zmniejszamy licznik losowania punktów
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
	
pierwsza_funkcja:
	move $s1, $s5 			# nowy x
	move $s2, $s6 			# nowy y
	mul $s1,$s1,85 			# mno¿ymy x przez 0.85
	div $s1,$s1,100			# i wyrównujemy zera
	sll $s3,$s6,2			# mno¿ymy y przez 0.04 
	div $s3,$s3,100 		# i wyrównujemy zera
	add $s1,$s1,$s3 		# dostajemy nowego x
	mul $s3,$s5,-4 			# zabieramy siê za y, na pocz¹tek mno¿ymy x* -0.04
	div $s3,$s3,100 		# i wyrównujemy zera
	mul $s4,$s6,85 			# mno¿ymy y przez 0.85
	div $s4,$s4,100 		# i wyrównujemy zera
	add $s2,$s3,$s4 		# dodajemy sk³adowe x i y do nowej wspó³rzêdnej y
	addi $s2,$s2,160000 		# dodajemy do nowego y + 1.6
	b zapis_piksela
	
druga_funkcja:
	move $s1, $s5 			# nowy x
	move $s2, $s6 			# nowy y
	mul $s1,$s1,-15 		# mno¿ymy x przez -0.15
	div $s1,$s1,100 		# i wyrównujemy zera
	mul $s3,$s6,28 			# mno¿ymy y przez 0.28
	div $s3,$s3,100 		# i wyrównujemy zera
	add $s1,$s1,$s3 		# dostajemy nowego x
	mul $s3,$s5,26 			# zabieramy siê za y, na pocz¹tek mno¿ymy x* 0.26
	div $s3,$s3,100 		# i wyrównujemy zera
	mul $s4,$s6,24 			# mno¿ymy y przez 0.24
	div $s4,$s4,100 		# i wyrównujemy zera
	add $s2,$s3,$s4 		# dodajemy sk³adowe x i y do nowej wspó³rzêdnej y
	addi $s2,$s2,44000 		# dodajemy do nowego y + 0.44
	b zapis_piksela
	
trzecia_funkcja:
	move $s1, $s5 			# nowy x
	move $s2, $s6 			# nowy y
	mul $s1,$s1,20 			# mno¿ymy x przez 0.20
	div $s1,$s1,100 		# i wyrównujemy zera
	mul $s3,$s6,-26 		# mno¿ymy y przez -0.26
	div $s3,$s3,100 		# i wyrównujemy zera
	add $s1,$s1,$s3 		# dostajemy nowego x
	mul $s3,$s5,23 			# zabieramy siê za y, na pocz¹tek mno¿ymy x* 0.23
	div $s3,$s3,100 		# i wyrównujemy zera
	mul $s4,$s6,22 			# mno¿ymy y przez 0.22
	div $s4,$s4,100 		# i wyrównujemy zera
	add $s2,$s3,$s4 		# dodajemy sk³adowe x i y do nowej wspó³rzêdnej y
	addi $s2,$s2,160000 		# dodajemy do nowego y + 1.6
	b zapis_piksela
	
czwarta_funkcja:
	li $s1,0 			# zerujemy x
	mul $s2,$s6,16 			# mno¿ymy y przez 0.16
	div $s2,$s2,100 		# i wyrównujemy zera
	b zapis_piksela
	
zapis_piksela:
	 #po³o¿enie X w tablicy pikseli
	 
	lw $s7,szerokosc 		# ³aduje szerokoœæ
	move $s3,$s1 			# ³adujemy x do rejestru
	add $s3,$s3,300000 		# przesuwamy go o 3, bo nie chcemy ujemnych adresów
	mul $s3,$s3,$s7 		# mno¿ymy razy liczba pikseli
	div $s3,$s3,6 			# dzielimy przez 6, bo mamy podzia³kê d³ugoœci 6
	div $s3,$s3,100000 		# nie potrzebujemy ju¿ przecinka
	 
	 #po³o¿enie y w tablicy pikseli

	lw $s7,wysokosc 		# ³aduje wysokoœæ pliku w pikselach
	mul $s4,$s2,$s7 		# mno¿ymy naszego Y razy liczba pikseli
	div $s4,$s4,10 			# dzielimy przez 10, bo taka jest podzialka
	div $s4,$s4,100000 		# nie potrzebujemy ju¿ przecinka
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



	

