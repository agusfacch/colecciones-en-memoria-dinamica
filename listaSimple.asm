# En este codigo, cada nodo de la lista va a contener dos words, uno contiene el dato y el otro contiene la referencia al siguiente.
# 
.data 
slist:	.word 0 		# Inicializa el siguiente en NULL
numbers: .word 1,2,3		# vector que contiene los datos

.text
.globl main
main:	la $s0, numbers
	li $s1, 3
loop:
	lw $a0, ($s0)
	jal newnode	
	addi $s0, $s0, 4
	addi $s1, $s1, -1
	bnez $s1, loop
	
	li $a0, 10
	syscall	


newnode:
	move $t0, $a0		# Mueve a $t0 el dato pasado por parámetro
	
	# Este bloque de acá reserva los 8 bytes correspondientes a los dos words que hay en un nodo
	li $v0, 9
	li $a0, 8
	syscall
	
	sw $t0, ($v0) 		# Guarda el dato en el primero word del nodo
	lw $t1, slist 		# Cargo en $t1 el valor de slist, el cual corresponde al valor del anterior nodo, que puede ser 0
	beq $t1, $0, void_list		# Si $t1 es igual a 0 quiere decir que es NULL, osea que hay list vacía
	sw $t1, 4($v0)			# Inserta en el siguiente del nuevo nodo, la referencia al siguiente
	sw $v0, slist		# Actualiza lista
	jr $ra
void_list: 
	sw $0, 4($v0)		# Referencia al siguiente NULL, ya que aun no hay nodos que enlazar
	sw $v0, slist		# Carga la referencia de $v0 en slist, como si fuera el primer nodo
	jr $ra	



		