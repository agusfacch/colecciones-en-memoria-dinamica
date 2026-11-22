# Nombre: Agustin Facchiano
# DNI: 47659632

.data
slist:		.word 0
cclist: 	.word 0
wclist: 	.word 0
shedv:		.space 32
menu:		.ascii "Colecciones de objetos categorizados...\n"
		.ascii "====================================\n"
		.ascii "<> 1. Nueva categoria.\n"
		.ascii "<> 2. Siguiente categoria.\n"
		.ascii "<> 3. Categoria anterior.\n"
		.ascii "<> 4. Listar categorias.\n"
		.ascii "<> 5. Borrar categoria actual.\n"
		.ascii "<> 6. Insertar objeto en la categoria actual.\n"
		.ascii "<> 7. Listar objetos de la categoria.\n"
		.ascii "<> 8. Borrar objeto de la categoria.\n"
		.ascii "<> 0. Salir del programa.\n"
		.asciiz	"<> Ingrese una opcion: "		
error:		.asciiz ".Error: "
return:		.asciiz "\n"
nameCat:	.asciiz "\n.Ingrese el nombre de la categoria: "
selCat:		.asciiz "\n.Se ha seleccionado la categoria: "
selMark: 	.asciiz "> "
nameObj:	.asciiz "\n.Ingrese el nombre del objeto: "
idMsj:		.asciiz	"ID: "
idObj:		.asciiz "\n.Ingrese el ID del objeto a eliminar: "
notFound:	.asciiz	"\nID de objeto no encontrado."
succes:		.asciiz "\nLa operacion se ha realizado con exito.\n\n"
exit:		.asciiz "\nSaliendo del programa..."


.text
.globl main
main:
	# Inicializa shedv
	la	$s0, shedv		# $s0 = function dispatcher
		
	la	$t0, newcategory	
	sw	$t0, 0($s0)
	la	$t0, nextcategory
	sw	$t0, 4($s0)
	la	$t0, prevcategory
	sw	$t0, 8($s0)
	la	$t0, listcategories
	sw	$t0, 12($s0)
	la	$t0, delcategory
	sw	$t0, 16($s0)
	la	$t0, newobject
	sw	$t0, 20($s0)
	la	$t0, listobjects
	sw	$t0, 24($s0)
	la	$t0, delobject
	sw	$t0, 28($s0)
	
main_loop:
	la	$a0, menu		# Dispara el menú
	li	$v0, 4
	syscall	
	
	li	$v0, 5			# Lee entero por teclado
	syscall
	
	move	$a0, $v0		# Validación
	jal 	validation
	beq 	$v0, 101, main_error_101
	
	beqz	$v0, main_end		# Si lo que se ingresó es 0, sale del programa
	
	move	$t1, $v0		# $t1 = numero ingresado
	addi	$t1, $t1, -1		# Pasaje a lenguaje array
	sll	$t1, $t1, 2		# 2 a la 2 = 4, es como multipicar por 4 (paso a bytes el numero seleccionado, es el offset)
	add	$t2, $s0, $t1		# base + offset = dirección de la función
	lw	$t2, 0($t2)		# antes era &shedv[i], ahora con esta línea es shedv[i] -> dirección de la función
	jalr	$t2	


	beqz 	$v0, main_print_succesful
	bgtz	$v0, main_error_x
		
	la	$a0, return
	li	$v0, 4
	syscall	
	
	la	$a0, return
	li	$v0, 4
	syscall	
		
	j 	main_loop
	
main_print_succesful:
	la	$a0, return
	li	$v0, 4
	syscall
	
	la	$a0, succes
	li	$v0, 4
	syscall
	
	la	$a0, return
	li	$v0, 4
	syscall
	
	j	main_loop
	
main_error_x:
	move	$t3, $v0
	
	la	$a0, return
	li	$v0, 4
	syscall
	
	la	$a0, error
	li	$v0, 4
	syscall
	
	move	$a0, $t3
	li	$v0, 1
	syscall	
	
	la	$a0, return
	li	$v0, 4
	syscall	
	
	la	$a0, return
	li	$v0, 4
	syscall	
	
	j 	main_loop
		
main_error_101:
	la	$a0, error
	li	$v0, 4
	syscall
	
	li	$a0, 101
	li	$v0, 1
	syscall
	
	la	$a0, return
	li	$v0, 4
	syscall	
	
	la	$a0, return
	li	$v0, 4
	syscall	
	
	j main_loop
	
main_end:
	la 	$a0, exit
	li	$v0, 4
	syscall

	li	$v0, 10
	syscall	
	
#START VALIDATION
# $a0 = ingreso por teclado, correspondiente a la selección del menú
validation:
	bltz	$a0, validation_error
	bgt	$a0, 8, validation_error
	move	$v0, $a0
	j 	validation_end
validation_error:
	li	$v0, 101
validation_end:	
	jr	$ra		
#END VALIDATION
			

#START NEWCATEGORY
# Sin parámetros.
newcategory:
	addi 	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	la	$a0, nameCat		# Carga en $a0 dirección del mensaje a imprimir dentro de la función getblock		
	jal 	getblock
	
	la	$a0, cclist		# $a0 = puntero a cclist
	li	$a1, 0			# $a1 = NULL
	move	$a2, $v0		# $a2 = *char, al nombre de la categoría
	jal 	addnode
	
	# En estas lineas verifica si el cursor es nulo, si lo es quiere decir que no había nada en la lista por lo tanto
	# carga en wclist el nuevo nodo, pero si ya había algo lo ignora y no cambia el cursor.
	lw	$t0, wclist		
	bnez 	$t0, newcategory_end
	sw 	$v0, wclist
	
newcategory_end:
	li	$v0, 0			# Retorno exitoso
	
	lw 	$ra, 0($sp)		
	addi	$sp, $sp, 4
	jr	$ra	
#END NEWCATEGORY


#START PREVCATEGORY
# Sin parámetros
prevcategory:
	lw 	$t0, wclist		# Cargo el puntero cursor en $t0
	beqz 	$t0, prevcategory_empty_list	# Si wclist es 0 = NULL, lista vacía, error 201
	
	lw	$t1, 0($t0)
	beq 	$t1, $t0, prevcategory_self_node	# Si wclist tiene un solo nodo, nodo único, error 202
	
 	sw 	$t1, wclist
 	
	la 	$a0, selCat
	li 	$v0, 4
	syscall
	
	lw 	$a0, 8($t1)
	li 	$v0, 4
	syscall	
	
	li	$v0, 0			# Retorno exitoso
	j 	prevcategory_end
	
prevcategory_empty_list:
	li 	$v0, 201		# Código de error 201
	j 	prevcategory_end
	
prevcategory_self_node:
	li 	$v0, 202		# Código de error 202
	
prevcategory_end:	
	jr 	$ra
#END PREVCATEGORY		
		
	
#START NEXTCATEGORY			
# Sin parámetros	
nextcategory:
	lw	$t0, wclist
	beqz	$t0, nextcategory_empty_list	
	
	lw 	$t1, 12($t0)
	beq	$t1, $t0, nextcategory_self_node
	
	sw	$t1, wclist
	
	la 	$a0, selCat
	li 	$v0, 4
	syscall	
	
	lw	$a0, 8($t1)
	li	$v0, 4
	syscall
	
	li	$v0, 0			# Retorno exitoso
	j	nextcategory_end
	
nextcategory_empty_list:
	li 	$v0, 201
	j	nextcategory_end
	
nextcategory_self_node:
	li	$v0, 202
	
nextcategory_end:
	jr $ra		
#END NEXTCATEGORY			 			 	


#START LISTCATEGORIES
listcategories:
	la	$a0, return		
	li	$v0, 4
	syscall

	lw	$t0, cclist		# Puntero que quedará inmovil
	beqz	$t0, listcategories_empty_list	# Lista vacía?	
	
	lw	$t1, cclist		# Puntero móvil (para el loop)
	lw 	$t2, wclist	
		
	j	listcategories_loop
	
listcategories_empty_list:
	li 	$v0, 301
	j	listcategories_end
		
listcategories_loop:
	beq	$t1, $t2, listcategories_print_selected
	
	lw 	$a0, 8($t1)
	li	$v0, 4
	syscall
	
	j 	listcategories_next
		
listcategories_print_selected:
	la	$a0, selMark
	li	$v0, 4
	syscall	
	
	lw 	$a0, 8($t1)
	li	$v0, 4
	syscall	
	
listcategories_next:
	
	lw 	$t1, 12($t1)
	beq	$t1, $t0, listcategories_end_loop
	
	j 	listcategories_loop
	
listcategories_end_loop:
	li	$v0, -1		# Esto es para que no imprima el mensaje de operación exitosa
		
listcategories_end:
	jr 	$ra
#END LISTCATEGORIES		
				
								
#START DELCATEGORY 
delcategory:
	addi 	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$s0, 4($sp)
	sw	$s1, 0($sp)
	
	lw	$t0, cclist		# $t0 = Puntero a la lista de categorías
	beqz 	$t0, delcategory_empty
	
	lw 	$s0, wclist		# $t1 = Puntero a la categoría actual
	lw	$t2, 4($s0)		# $t2 = Campo de lista de objetos del nodo seleccionado
	beqz	$t2, delcategory_object_empty	# Caso en que lista de objetos es vacía
	
delcategory_with_object:
	# Parte iterativa, la lista tiene un objeto o más
	lw   $s1, 4($s0)        	# $s1 = head objetos
	
delcategory_loop:
	beqz 	$s1, delcategory_object_empty

	move	$a0, $s1		# $a0 = nodo objeto a borrar
	addi	$a1, $s0, 4		# $a1 = dirección donde comienza la lista de objetos (head)
	jal 	delnode	
		
	lw	$s1, 4($s0)
	
	j 	delcategory_loop	
	# Fin de la parte iterativa
	
delcategory_object_empty:
	lw 	$t3, 12($s0)		# Ahora $t3 = siguiente categoría a la seleccionada
	beq 	$t3, $s0, delcategory_last_node		# Consulta si la categoría a eliminar es la única en la lista
	
	sw	$t3, wclist		# El next del nodo a eliminar pasa a ser el selccionado	
	
	move	$a0, $s0
	la	$a1, cclist
	jal	delnode
	
	li	$v0, 0			# Retorno exitoso
	j 	delcategory_end	
			
delcategory_last_node:
	move 	$a0, $s0
	la 	$a1, cclist
	jal 	delnode
	
	# Nulifico los punteros luego de dejar la lista vacía
	sw	$zero, cclist		
	sw	$zero, wclist
	
	li	$v0, 0			# Retorno exitoso
	j 	delcategory_end
	
delcategory_empty:
	li	$v0, 401
	
delcategory_end:
	lw	$s1, 0($sp)
	lw	$s0, 4($sp)
	lw	$ra, 8($sp)
	addi	$sp, $sp, 12
	jr	$ra		
#FIN DELCATEGORY	


#START NEWOBJECT
newobject:
	addi	$sp, $sp, -4		# Guardo el retorno en la pila para preservarlo ante posteriores llamadas
	sw	$ra, 0($sp)
	
	lw	$t0, cclist		# $t0 = Puntero a la lista de categorías
	beqz	$t0, newobject_empty_list	# Si no existe categoría, no puedo agregar objeto (cclist vacío)
	
	lw	$t1, wclist		# $t1 = Puntero al nodo en curso (seleccionado)
	lw	$t2, 4($t1)		# lista de objetos de $t1
	beqz	$t2, newobject_empty_object
	
	lw	$t3, 0($t2)
	lw	$t4, 4($t3)
	addi	$t4, $t4, 1		# Nuevo ID a insertar en el nuevo nodo objeto
	
	j	newobject_ready_id
	
newobject_empty_object:
	li	$t4, 1			# 1 por que antes no había ningún ID, ya que era lista vacía
	
newobject_ready_id:	
	la	$a0, nameObj
	jal 	getblock		# $v0 = string (nombre del objeto)
	
	addi	$a0, $t1, 4		# $a0 = dirección de memoria de la lista de objetos
	move	$a1, $t4		# $a1 = numero de ID
	move 	$a2, $v0		# $a2 = string con nombre del objeto
	jal 	addnode
	
	li 	$v0, 0			# Retorno exitoso
	j	newobject_end
		
newobject_empty_list:
	li	$v0, 501
	
newobject_end:
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
#END NEWOBJECT		
						

#LISTOBJECTS
listobjects:
	lw	$t0, cclist
	beqz	$t0, listobjects_empty_categories	# Lista de categorías vacía?
	
	lw	$t1, wclist
	lw	$t2, 4($t1)
	beqz	$t2, listobjects_empty_objects		# Hay categorías, pero, hay objetos?
	
	la	$a0, return
	li	$v0, 4
	syscall
	
listobjects_with_objects:
	move	$t3, $t2		# $t3 = es un puntero móvil, para el loop
	
listobjects_loop:	
	lw	$a0, 8($t3)		# Imprime el nombre del objeto
	li	$v0, 4
	syscall
	
	la	$a0, idMsj		# Imprmie mensaje de ID del objeto
	li	$v0, 4
	syscall
	
	lw	$t4, 4($t3)	
	move	$a0, $t4		# Imprime ID del objeto
	li	$v0, 1
	syscall
	
	la	$a0, return		
	li	$v0, 4
	syscall
	
	la	$a0, return		
	li	$v0, 4
	syscall
	
	lw	$t3, 12($t3)
	beq	$t3, $t2, listobjects_end_loop	
	j	listobjects_loop
	
listobjects_empty_categories:
	li	$v0, 601
	j 	listobjects_end
	
listobjects_empty_objects:
	li	$v0, 602	
	j 	listobjects_end
	
listobjects_end_loop:
	li $v0, -1
			
listobjects_end:
	jr	$ra	
#END LISTOBJECTS


#START DELOBJECT
delobject:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	lw	$t0, cclist
	beqz	$t0, delobject_empty_categories
	
	lw	$t1, wclist
	lw	$t2, 4($t1)
	beqz	$t2, delobject_id_not_found
	
delobject_with_object:
	la	$a0, idObj
	li	$v0, 4
	syscall
	
	li	$v0, 5
	syscall
	
	move 	$t5, $v0		# $t5 = valor de búsqueda ID ingresado por teclado
	
	move	$t3, $t2		# $t3 = puntero móvil para el loop, $t2 = puntero inmóvil
	
delobject_loop:
	lw	$t4, 4($t3)
	beq	$t5, $t4, delobject_delete_object
	
	lw	$t3, 12($t3)
	beq	$t3, $t2, delobject_id_not_found	# Llegó al final de la lista sin encontrar nada
	
	j	delobject_loop	
	
delobject_delete_object:
	move	$a0, $t3
	addi	$a1, $t1, 4
	jal	delnode	
	
	li	$v0, 0			# Retorno exitoso
	j 	delobject_end
	
delobject_empty_categories:
	li	$v0, 701		
	j	delobject_end	
	
delobject_id_not_found:	
	la	$a0, notFound
	li	$v0, 4
	syscall
	
	li	$v0, -1
	
delobject_end:
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra	
#END DELOBJECT


#START SMALLOC
smalloc: 
	lw 	$t0, slist 		# Cargo el valor que tiene el puntero slist, el cual contiene la lista simple con bloques
	beqz 	$t0, sbrk		# Verifica si el puntero es NULL, si lo es, pide memoria
	
	move 	$v0, $t0		# Acá devuelve la direccion el primer nodo de la lista simple (nodo a reutilizar)
	
	lw 	$t0, 12($t0)		# Ahora $t0 contiene el siguiente nodo del que apuntaba
	sw 	$t0, slist		# Este mismo ahora se vuelve la cabeza de slist
	jr 	$ra
sbrk:
	li 	$a0, 16
	li 	$v0, 9
	syscall
	
	jr 	$ra	
#END SMALLOC


#START SFREE
sfree:
	lw 	$t0, slist			
	sw 	$t0, 12($a0)			
	sw 	$a0, slist		# El nodo a liberar pasa al principio de la lista simple (inserta al principio)
	
	jr 	$ra
#END SFREE	
	
	
#START ADDNODE	
# $a0 = dirección de memoria de la lista
# $a1 = si se añade en una categoría contendrá un NULL, ya que es una nueva y aún no contiene objetos y si se añade en una lista
# objetos aqui se cargará el numero de ID, obviamente se deduce que este registro irá a parar al campo 2 (offset 4)	
# $a2 = en caso de categoría nueva, nombre de categoría, en caso de objeto nuevo, nombre de objeto, (*char)
addnode:
	addi 	$sp, $sp, -8
	sw  	$ra, 4($sp)
	sw	$a0, 0($sp)
	
	jal 	smalloc 		
	move	$t9, $v0		# Carga en $t9 la direccion del nuevo nodo
	
	# Inicializacion defensiva del nodo, deja los puntero prev y next en NULL para que no contengan basura lógica de sbrk,
	# tampoco de haberlo reutilizado desde la lista simple que propone sfree.
	sw	$zero, 0($t9)
	sw	$zero, 12($t9)
	
	# En las dos sig lineas rellena con los datos respectivos los campos del medio del nodo.
	sw	$a1, 4($t9)		
	sw	$a2, 8($t9)	
	  
	lw	$a0, 0($sp)		# Recolecta de $sp el regitro $a0
	lw	$t0, 0($a0)	
	beqz	$t0, addnode_empty_list
	
addnode_to_end:
	lw	$t1, 0($t0)		# Carga la dirección de memoria del último nodo en $t1
	sw	$t1, 0($t9)		# Guarda en prev de nuevo nodo (último) el viejo último elemento de la lista
	sw 	$t0, 12($t9)		# Guarda en next de nuevo nodo (último) el primer nodo de la lista
	
	sw	$t9, 12($t1)		# Guarda en next del viejo último, el nuevo
	sw 	$t9, 0($t0)		# Guarda en prev del primer nodo de la lista, el nuevo nodo (último)
	
	j addnode_exit
	
addnode_empty_list: 
	# $t9 contiene la dirección de memoria del nodo creado
	# Acá el nuevo nodo se autoreferencia en prev y next, ya que es el único nodo de la lista
	sw 	$t9, 0($a0) 		
	sw	$t9, 0($t9)
	sw 	$t9, 12($t9)
	
addnode_exit:
	move	$v0, $t9		# Retorna la dirección del nuevo nodo ya creado
	
	lw 	$ra, 4($sp)
	addi 	$sp, $sp, 8
	jr 	$ra
#END ADDNODE


#START DELNODE
# $a0 = dirección del nodo a eliminar
# $a1 = dirección de la lista donde está el nodo a eliminar
delnode:
	addi 	$sp, $sp, -8
	sw 	$ra, 4($sp)
	sw	$a0, 0($sp)
	
	#lw	$a0, 8($a0) 		# Toma la dirección del bloque string
	#jal 	sfree			# Libera el bloque string del heap
	
	#lw	$a0, 0($sp)		# Restaura el argumento $a0 -> dirección del nodo a eliminar
	
node:
	lw	$t0, 12($a0)		# $t0 = dirección del siguiente nodo desde el elegido a eliminar
	beq	$a0, $t0, delnode_point_self	# Si hay un solo nodo en la lista, ramifica	
	
	lw 	$t1, 0($a0)		# $t1 = dirección del anterior nodo
	sw 	$t1, 0($t0)		# En prev de $t0, guarda a $t1
	sw	$t0, 12($t1)		# En next de $t1, guarda $t0
	
again:
	lw 	$t1, 0($a1)		# se carga en $t1 el primer nodo de la lista
	bne 	$a0, $t1, delnode_exit	# Se fija si $a0 era el primer nodo
	
	sw 	$t0, 0($a1)		# El next del nodo a eliminar pasa a ocupar su lugar en la lista / node = node->next
					# cclist = node->next
			
	j 	delnode_exit
	
delnode_point_self:
	sw 	$zero, 0($a1)
	
delnode_exit:
	jal 	sfree	
	
	lw 	$ra, 4($sp)
	addi 	$sp, $sp, 8
	jr 	$ra	
#END DELNODE


#START GETBLOCK
# $a0 = dirección del mensaje de petición de nombre de categoría u objeto	
getblock:
	addi 	$sp, $sp, -4
	sw 	$ra, 0($sp)
	
	li 	$v0, 4			# Muestra msj de solicitud de string
	syscall
	
	jal 	smalloc			# Devuelve en $v0 16 bytes para usar
	
	# En las tres lineas siguientes, preparo el syscall para leer un string por teclado
	move	$a0, $v0		# Dirección de memoria en la cual se insertarán los caracteres (buffer) 	
	li 	$a1, 16			# Tamaño del buffer
	li	$v0, 8
	syscall
	
	move 	$v0, $a0		# Muevo a $v0 (retorno) la direccion del buffer
			
	lw 	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
#END GETBLOCK			

									
						
			
