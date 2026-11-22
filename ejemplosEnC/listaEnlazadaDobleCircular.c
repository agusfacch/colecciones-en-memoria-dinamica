#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#define TAM_STRING 16

typedef struct objectNode{
	struct objectNode *prevObject;
	int id;
	char nameObject[TAM_STRING];
	struct objectNode *nextObject;
} ObjectNode;

typedef struct categoryNode{
	struct categoryNode *prevCategory;
	ObjectNode *objects;
	char nameCategory[TAM_STRING];
	struct categoryNode *nextCategory;
} CategoryNode;

CategoryNode *cclist = NULL;
CategoryNode *wclist = NULL;

void menuPrincipal();
void limpiarBuffer();
CategoryNode *createCategoryNode();
void validacionString(char nombre[TAM_STRING]);
int newCategory();
int prevCategory();
int nextCategory();
int listCategories();
int deleteCategory();
ObjectNode *createObjectNode();
int newObject();
int listObjects();
int deleteObject();
void exitProgram();

int main(void){
	srand(time(NULL));

	while(1){
		menuPrincipal();
		int opcion;
		if(scanf("%d", &opcion) != 1){
			printf("\n\n> Opción inválida. Ingrese un número.\n");
			limpiarBuffer();
			continue;
		}
		limpiarBuffer();

		switch(opcion){
			case 0: 
				exitProgram();
				printf("\n> Saliendo del programa...\n\n");
				exit(0);

			case 1: {
				int result1 = newCategory();
				if(result1) printf("\n\n> La operación se ha realizado con éxito\n");
				break;
			}

			case 2: {
				int result2 = prevCategory();
				if(result2 == 201){
					printf("\n\n> No hay categorías para realizar esta acción\n");
				}else if(result2 == 202){
					printf("\n\n> No hay categorías suficientes para realizar esta acción\n");
				}
				break;
			}

			case 3: {
				int result3 = nextCategory();
				if(result3 == 201){
					printf("\n\n> No hay categorías para realizar esta acción\n");
				}else if(result3 == 202){
					printf("\n\n> No hay categorías suficientes para realizar esta acción\n");
				}
				break;	
			}

			case 4: {
				int result4 = listCategories();
				if(result4 == 301){
					printf("\n\n> No hay categorías para realizar esta acción.\n");
				}
				break;				
			}

			case 5: {
				int result5 = deleteCategory();
				if(result5 == 401){
					printf("\n\n> No hay categorías para realizar esta acción.\n");
				}else{
					printf("\n\n> La operación se ha realizado con éxito\n");
				}	
				break;	
			}

			case 6: {
				int result6 = newObject();
				if(result6 == 501){
					printf("\n\n> No hay categorías para realizar esta acción.\n");
				}else{
					printf("\n\n> La operación se ha realizado con éxito\n");
				}
				break;
			}

			case 7: {
				int result7 = listObjects();
				if(result7 == 601){
					printf("\n\n> No hay categorías para realizar esta acción.\n");
				}else if(result7 == 602){
					printf("\n\n> No hay objetos para realizar esta acción.\n");
				}
				break;	
			}

			case 8: {
				int result8 = deleteObject();
				if(result8 == 701){
					printf("\n\n> No hay categorías para realizar esta acción.\n");
				}else if(result8 == 702){
					printf("\n\n> No hay objetos para realizar esta acción.\n");
				}else if(result8 == 1){
					printf("\n\n> La operación se ha realizado con éxito\n");
				}
				break;
			}

			default:
				printf("\n\n> Opción fuera de rango (0-8).\n");
				break;
		}	
	}

	return 0;
}

void menuPrincipal(){
	printf("\n\nMENÚ PRINCIPAL.\n");
	printf("1. Crear categoría.\n");
	printf("2. Categoría anterior.\n");
	printf("3. Categoría siguiente.\n");
	printf("4. Listar categorías.\n");
	printf("5. Borrar categoría seleccionada.\n");
	printf("6. Crear objeto.\n");
	printf("7. Listar objetos.\n");
	printf("8. Borrar objeto.\n");
	printf("0. Salir del programa.\n");
	printf("> Seleccione opción: ");
}

void limpiarBuffer(){
	int c;
	while((c = getchar()) != '\n' && c != EOF);
}

CategoryNode *createCategoryNode(){
	CategoryNode *newC = (CategoryNode*)malloc(sizeof(CategoryNode));
	if(newC == NULL){
		printf("\n\n> Heap lleno, no fue posible crear nodo.\n\n");
		exit(0);
	}
	newC->prevCategory = NULL;
	newC->objects = NULL;
	newC->nextCategory = NULL;
	return newC;
}

void validacionString(char nombre[TAM_STRING]){
	while(1){
		if(fgets(nombre, TAM_STRING, stdin) == NULL){
			printf("\n\n> Error de lectura.");
			return;
		}
		
		size_t len = strlen(nombre);
		if(len > 0 && nombre[len-1] != '\n'){
			printf("\n> El nombre ingresado es demasiado grande (máx %d caracteres).\n", TAM_STRING - 1);
			printf("> Pruebe de vuelta por acá: ");
			limpiarBuffer();
			continue;
		}

		nombre[strcspn(nombre, "\n")] = '\0';

		if(strlen(nombre) == 0){
			printf("\n> El nombre no puede estar vacío.\n");
			printf("> Ingrese un nombre válido: ");
			continue;
		}

		break;
	}	
}

int newCategory(){
	CategoryNode *new = createCategoryNode(); 

	printf("\n\n> Ingrese el nombre de la categoría: ");
	validacionString(new->nameCategory);	
	
	if(cclist == NULL){
		new->prevCategory = new;
		new->nextCategory = new;
		cclist = new;
		wclist = new;	// Pasa directamente a ser categoría seleccionada
		return 1;		// Creación de categoría exitosa
	}
	
	new->nextCategory = cclist;		// new = último, se enlaza con el primero
	CategoryNode *temp = cclist;
	while(temp->nextCategory != cclist){
		temp = temp->nextCategory;
	}
	new->prevCategory = temp;
	temp->nextCategory = new;
	cclist->prevCategory = new;
	
	return 1;	// Creación de categoría exitosa
}

int prevCategory(){
	if(wclist == NULL){
		return 201;
	}

	if(wclist->prevCategory == wclist){
		return 202;		
	}

	wclist = wclist->prevCategory;
	printf("\n\n> La categoría seleccionada fue: %s", wclist->nameCategory);
	return 1;
}

int nextCategory(){
	if(wclist == NULL){
		return 201;
	}

	if(wclist->nextCategory == wclist){
		return 202;
	}

	wclist = wclist->nextCategory;
	printf("\n\n> La categoría seleccionada fue: %s", wclist->nameCategory);
	return 1;
}

int listCategories(){
	if(cclist == NULL){
		return 301;
	}
	
	CategoryNode *temp = cclist;
	do{
		if(temp == wclist){
			printf("\n> Seleccionada: %s", temp->nameCategory);
		}else{
			printf("\n> %s", temp->nameCategory);
		}
		temp = temp->nextCategory;
	}while(temp != cclist);

	return 1;
}

int deleteCategory(){
	if(wclist == NULL){
		return 401;
	}

	// Si hay objetos en la categoría, se liberan uno a uno
	if(wclist->objects != NULL){
		wclist->objects->prevObject->nextObject = NULL; // Rompe circularidad para liberar seguro
		ObjectNode *curr = wclist->objects;
		while(curr != NULL){
			ObjectNode *pivote_object = curr;
			curr = curr->nextObject;
			free(pivote_object);
		}
		wclist->objects = NULL;
	}

	// Caso de categoría única
	if(wclist->nextCategory == wclist){
		free(wclist);
		wclist = NULL;
		cclist = NULL;
		return 1;
	}	

	CategoryNode *pivote_wclist = wclist;
	CategoryNode *next_wclist = wclist->nextCategory;
	CategoryNode *prev_wclist = wclist->prevCategory;
	next_wclist->prevCategory = prev_wclist;
	prev_wclist->nextCategory = next_wclist;

	if(wclist == cclist){
	    cclist = next_wclist;
	}
	
	wclist = next_wclist;		
	free(pivote_wclist);

	return 1;
}

ObjectNode *createObjectNode(){
	ObjectNode *newO = (ObjectNode*)malloc(sizeof(ObjectNode));
	if(newO == NULL){
		printf("\n\n> Heap lleno, no fue posible crear nodo.\n\n");
		exit(0);
	}
	newO->prevObject = NULL;
	newO->id = (rand()%2500)+1000;
	newO->nextObject = NULL;
	return newO;
}

int newObject(){
	if(cclist == NULL){
		return 501;
	}

	ObjectNode *new = createObjectNode();
	printf("\n\n> Ingrese el nombre del objeto: ");
	validacionString(new->nameObject);
	
	if(wclist->objects == NULL){
		wclist->objects = new;
		new->prevObject = new;
		new->nextObject = new;
		return 1;
	}

	new->nextObject = wclist->objects;
	ObjectNode *temp = wclist->objects;
	while(temp->nextObject != wclist->objects){
		temp = temp->nextObject;
	}
	new->prevObject = temp;
	temp->nextObject = new;
	wclist->objects->prevObject = new;
	return 1;
}

int listObjects(){
	if(cclist == NULL){
		return 601;
	}

	if(wclist->objects == NULL){
		return 602;
	}

	ObjectNode *temp = wclist->objects;
	do{
		printf("\n\n> %s\n", temp->nameObject);
		printf("ID: %d", temp->id);
		temp = temp->nextObject;
	}while(temp != wclist->objects);

	return 1;
}

int deleteObject(){
	if(cclist == NULL){
		return 701;
	}

	if(wclist->objects == NULL){
		return 702;	
	}

	// En caso de que haya un único objeto se borra sin pedir ID
	if(wclist->objects->prevObject == wclist->objects){
		free(wclist->objects);
		wclist->objects = NULL;
		return 1;
	}

	// Mostrar objetos disponibles para eliminar
	printf("\n\n> Objetos que podrá eliminar, según esta categoría: \n");
	listObjects();
	printf("\n\n> Seleccione el ID de objeto que quiere borrar: ");
	int id_selection;	
	if(scanf("%d", &id_selection) != 1){
		printf("\n\n> ID inválido. Debe ingresar un número entero.\n");
		limpiarBuffer();
		return -1;
	}
	limpiarBuffer();
	
	ObjectNode *temp = wclist->objects;
	do{
		if(temp->id == id_selection){
			ObjectNode *temp_next = temp->nextObject;

			if(temp == wclist->objects){
            	wclist->objects = temp_next;
        	}
			
			temp_next->prevObject = temp->prevObject;
			temp->prevObject->nextObject = temp_next;
			free(temp);
			return 1;
		}
		temp = temp->nextObject;
	}while(temp != wclist->objects);

	printf("\n\n> No se encontró el ID seleccionado.\n\n");
	return -1;
}

void exitProgram(){
	if(cclist == NULL) return;

	// Rompe la circularidad para liberar de forma lineal y segura
	cclist->prevCategory->nextCategory = NULL;

	CategoryNode *temp_category = cclist;
	while(temp_category != NULL){
		if(temp_category->objects != NULL){
			temp_category->objects->prevObject->nextObject = NULL;
			ObjectNode *temp_object = temp_category->objects;
			while(temp_object != NULL){
				ObjectNode *object_pivote = temp_object;
				temp_object = temp_object->nextObject; 
				free(object_pivote);
			}
			temp_category->objects = NULL;
		}

		CategoryNode *category_pivote = temp_category;
		temp_category = temp_category->nextCategory;
		free(category_pivote);
	}

	cclist = NULL;
	wclist = NULL;
}
