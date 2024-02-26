.data 
RAM: .space 1000000
prompt1: .asciiz "Podaj ilosc wierszy: "
prompt2: .asciiz "Podaj ilosc kolumn: "
newline: .asciiz "\n"
prompt3: .asciiz "Zapis (1) czy odczyt (0)?"
prompt4: .asciiz "Podaj numer wiersza: "
prompt5: .asciiz "Podaj numer kolumny: "
prompt6: .asciiz "Podaj wartosc do zapisu: "
prompt7: .asciiz "Nieprawidlowa wartosc.\n"
.globl main
.text
main:
    # Prompt for the first number
    li $v0, 4
    la $a0, prompt1
    syscall
    
    # Read the first number
    li $v0, 5
    syscall
    move $t0, $v0   # Store the first number in $t0
    
    # Prompt for the second number
    li $v0, 4
    la $a0, prompt2
    syscall
    
    # Read the second number
    li $v0, 5
    syscall
    move $t1, $v0      # Store the second number in $t1
    
    la $s0, RAM
    li $t2, 0          #licznik inicjalizacja
    move $t3, $s0      #kopiuje wskaznik do t3
    move $t5, $t0      #kopiuje ilosc wierszy
    sll  $t5, $t5, 2   #razy 4
    add $t3, $t3, $t5  #na poczatek przesuwamy o ilosc wierszy
loopMemory:
beq $t2,$t0, continue #zarezerwuj adresy wierszy
    sw $t3, ($s0)     #zapis adresu
    li $t5, 0	      #t5=0
    add $t5, $t5, $t1 #+ilosc kolumn
    sll $t5, $t5, 2   #razy 4
    add $t3, $t3, $t5 #przesuwamy o wyliczony rozmiar
    addi $t2,$t2, 1   #i++
    addi $s0, $s0, 4  #przechodzimy na nasteony adres
    j loopMemory
continue:
    #Petla inicjalizujaca
    li $t2,0    #przechodzenie przez kolejne wiersze
    li $t3,0    #przechodzenie przez kolejne kolumny
    li $t4,0    #wartosc adresu
    li $t5,0    #wartosc do wpisania
    la $s0, RAM #adres tablicy
startLoop:
beq $t2, $t0, mainLoop
    lw $t4, ($s0)    #ladujemy pierwszy adres
    addi $s0, $s0, 4 #nastepny wiersz
    li   $t3, 0      #resetujemy licznik
wiersze:
beq $t3, $t1, goNext
    mul $t5, $t2,100  #t5=i*100
    add $t5, $t5, $t3 #t5=t5+j
    addi $t5, $t5, 1  #t5++;
    sw $t5, ($t4)     #zapisz do adresu
    addi $t4,$t4, 4   #przesuwamy adres
    addi $t3,$t3,1    #i++
    j wiersze         #i raz jeszcze
goNext:
    addi $t2, $t2, 1
    j startLoop
mainLoop:
    # Prompt zapis czy odczyt
    li $v0, 4
    la $a0, prompt3
    syscall
    # Wczytaj zapis/odczyt
    li $v0, 5
    syscall
    move $t0, $v0       # zapisz dana odczytu/zapisu w t0
blt $t0, 2, czyWieksze1 #czy prawidlowa wartosc(tj z <0,1>)-jesli nie, zasygnalizuj i wroc do petli
    li $v0, 4
    la $a0, prompt7
    syscall
    j mainLoop
czyWieksze1:
bgez $t0, czySpelnia
    li $v0, 4
    la $a0, prompt7
    syscall
    j mainLoop
czySpelnia:
    # Prompt wiersz
    li $v0, 4
    la $a0, prompt4
    syscall
    #wczytaj wiersz
    li $v0, 5
    syscall
    move $t1, $v0          
    # Prompt kolumna
    li $v0, 4
    la $a0, prompt5
    syscall
    #Wczytaj kolumne
    li $v0, 5
    syscall
    move $t2, $v0           
    la $s0, RAM             #laduje pierwszy adres
    li $t4, 0               #inicjalizacja licznika
findWiersz:
beq $t4, $t1, findColumn    #znajdz wiersz
    addi $s0,$s0,4          #zwieksz adres
    addi $t4,$t4,1          #zwieksz licznik
    j findWiersz
findColumn:
    li $t4, 0               #zresetuj 
    lw $t5, ($s0)           #zaladuj adres kolumny
repeatLoop:
beq $t4, $t2, doAction
    addi $t5, $t5, 4	    #zwieksz adres
    addi $t4, $t4, 1        #zwieksz licznik petli
    j repeatLoop
doAction:
    lw $t6, ($t5)           #wczytaj wartosc z tablicy
bne $t0, $zero,labelZapis
    # wypisz int
    li $v0, 1
    move $a0, $t6
    syscall
    #wypisz \n
    li $v0, 4
    la $a0, newline
    syscall
    j mainLoop
labelZapis:
    #wypisz String do wartosci zapisu
    li $v0, 4
    la $a0, prompt6
    syscall
    
    #zapisz wartosc do wskazanego miejsca w pamieci
    li $v0, 5
    syscall
    move $t7,$v0
    sw $t7, ($t5)
    j mainLoop
