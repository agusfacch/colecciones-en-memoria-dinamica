#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct node{
	int data;
	struct node *next;
} Node;

Node *createNode();
void insertNodeFront(Node **h, int data);
void printList(Node *h);
void deleteNodeData(Node **h, int data);
void searchNode(Node *h, int data);
void freeList(Node *h);

int main(void){
	Node *head = NULL;
	insertNodeFront(&head, 2);
	insertNodeFront(&head, 5);
	insertNodeFront(&head, 8);
	
	printf("--- Lista Inicial ---");
	printList(head);

	printf("\n--- Borrando nodo intermedio (5) ---");
	deleteNodeData(&head, 5);
	printList(head);

	printf("\n--- Borrando nodo inicial (8) ---");
	deleteNodeData(&head, 8);
	printList(head);

	printf("\n--- Búsqueda de elemento ---");
	searchNode(head, 2);
	searchNode(head, 99);

	freeList(head);
	head = NULL;

	return 0;
}

Node *createNode(){
	Node *new = (Node*)malloc(sizeof(Node));
	if(new == NULL){
		printf("Error de memoria, no hay más espacio.\n");
		exit(1);
	}
	new->next = NULL;
	return new;
}

void insertNodeFront(Node **h, int data){
	Node *new = createNode();
	new->data = data;
	new->next = *h;
	*h = new;
}

void deleteNodeData(Node **h, int data){
	if(*h == NULL){
		printf("\nNo hay ningún nodo a borrar.\n\n");
		return;
	} 

	Node *temp = *h;
	Node *prev = NULL; 
	while(temp != NULL){
		if(temp->data == data){
			if(prev == NULL){
				*h = temp->next;
				free(temp);
				return;
			}
			
			prev->next = temp->next;
			free(temp);
			return;	
		}

		prev = temp;
		temp = temp->next; 
	}
	printf("\nNo se encontró el nodo a borrar.\n\n");
}

void searchNode(Node *h, int data){
	if(h == NULL){
		printf("\nNo hay elementos en esta lista.\n\n");
		return;
	}

	Node *temp = h;
	while(temp != NULL){
		if(temp->data == data){
			printf("\nEl nodo buscado (%d) SÍ existe en la lista.\n", data);
			return;
		}
		temp = temp->next;
	}	
	printf("\nEl nodo buscado (%d) NO existe en la lista.\n", data);
}

void printList(Node *h){
	if(h != NULL){
		printf("\nNodo con dato -> %d", h->data);
		printList(h->next);
	}else{
		printf("\n");
	}
}

void freeList(Node *h){
	while(h != NULL){
		Node *temp = h;
		h = h->next;
		free(temp);
	}
}
