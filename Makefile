#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//implementarea benzii, printr-o structura ce contine o lista dublu inlantuita
//next este nodul urmator, in timp ce prev este nodul anterior, iar in val
//se retine caracterul ce va fi scris in banda
typedef struct nod {
    char val;
    struct nod *next;
    struct nod *prev;
}nod;
// am definit 2 noduri, santinela si degetul, care retine adresa celulei care
//indica degetul
typedef struct lista {
    nod *santinela;
    nod *deget;
}lista;
// structura pentru stiva, implementata printr-o lista simpla inlantuita
typedef struct stiva {
    nod *val;
    struct stiva *next;
}celula, *stiva;
//structuri pentru coada
//in variabila comanda se retine numarul comenzii, in valoare caracterul
//care trebuie adaugat in banda, in cazul in care asta prespupune comanda
//respectiva, iar daca nu, valoarea '\0'
typedef struct element {
    int comanda;
    char valoare;
    struct element *next;
}element;
//coada este implementata tot printr-o lista simplu inlantuita si am retinut
//adresele primului si ultimului element din aceasta
typedef struct coada {
    element *primul;
    element *ultimul;
}executie;

//functie pentru eliberarea memoriei alocate pentru banda
void elibereaza_banda(lista *b){
    //cu un pointer auxiliar i de tip nod, pornesc de la santinela si parcurg
    //banda, in timp ce prin intermediul pointerului aux eliberez fiecare
    //celula
    nod *i = b->santinela;
    nod *aux;
    while(i != NULL) {
        aux = i;
        i = i->next;
        free(aux);
    }
}

//functia show
void show(lista *b, FILE *f)
{
    nod *p = b->santinela->next;
    while(p!=NULL){
        if(p == b->deget){
            fprintf(f,"|%c|", p->val);
        }
        else fprintf(f, "%c", p->val);
        p = p->next;
    }
    fprintf(f, "\n");
}
void show_current(lista *b, FILE *f)
{
    fprintf(f, "%c\n", b->deget->val);
}
//operatie de tip update???
void move_right(lista *b)
{
    if(b->deget->next == NULL){
        nod *nou = (nod*)malloc(sizeof(nod));
        nou->prev = b->deget;
        nou->next = NULL;
        nou->val = '#';
        b->deget->next = nou;
        b->deget = nou;
    }
    else {
        b->deget = b->deget->next;
    }
}
void move_left(lista *b)
{
    if(b->deget->prev != b->santinela){
        b->deget = b->deget->prev;
    }
}
void move_right_char(lista *b, char c)
{
    nod *p = b->deget;
    int ok = 0;
    while(p->next != NULL && ok == 0){
        if(p->val != c){
            p = p->next;
        }
        else {
            ok = 1;
            b->deget = p;
        }
    }
    if(ok == 0){
        if(p->val!= c){
            nod *nou = (nod*)malloc(sizeof(nod));
            nou->prev = p;
            nou->next = NULL;
            nou->val = '#';
            p->next = nou;
            b->deget = nou;
        }
        else {
            b->deget = p;
        }
    }
}
void move_left_char(lista *b, char c, int *ok, FILE *f)
{
    nod *p = b->deget;
    while(p != b->santinela && *ok == 0){
        if(p->val != c){
            p = p->prev;
        }
        else {
            *ok = 1;
            b->deget = p;
        }
    }
    if(*ok == 0){
        fprintf(f, "ERROR\n");
    }
}
void write(lista *b, char c)
{
    b->deget->val = c;
}
void insert_left_char(lista *b, char c, FILE *f)
{
    if(b->deget->prev == b->santinela){
        fprintf(f, "ERROR\n");
    }
    else {
        nod *nou = (nod*)malloc(sizeof(nod));
        nou->next = b->deget;
        nou->prev = b->deget->prev;
        b->deget->prev->next = nou;
        b->deget->prev = nou;
        nou->val = c;
        b->deget = nou;
    }
}
void insert_right_char(lista *b, char c)
{
    if(b->deget->next != NULL){
        nod *nou = (nod*)malloc(sizeof(nod));
        nou->prev = b->deget;
        nou->next = b->deget->next;
        b->deget->next->prev = nou;
        b->deget->next = nou;
        nou->val = c;
        b->deget = nou;
    }
    else {
        nod *nou = (nod*)malloc(sizeof(nod));
        nou->prev = b->deget;
        nou->next = NULL;
        b->deget->next = nou;
        nou->val = c;
        b->deget = nou;
    }
}
//!!!!!!!!!!!UPDATE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
void adauga_in_stiva(celula **head, nod *move)
{
    celula *nou;
    nou = (celula *)malloc(sizeof(celula));
    nou->val = move;
    nou->next = *head;
    *head = nou;
}
void afiseaza_stiva(celula *head)
{
    if(head == NULL) {
        printf("STIVA E GOALA!!1\n");
        return;
    }
    celula *aux = head;
    while(aux != NULL) {
        printf(" %p ", aux->val);
        aux = aux->next;
    }
    printf("\n");
}

void scoate_din_stiva(celula **head) {
    /* if(*head == NULL) {
       // printf("STIVA E GOALA FRATE!\n");
        return;
    } */
    celula *aux;
    aux = *head;
    *head = (*head)->next;
    free(aux);
}
void goleste_stiva(celula **head)
{
    if(*head == NULL) {
       // printf("STIVA E GOALA FRATE!\n");
        return;
    }
    while(*head != NULL) {
        scoate_din_stiva(head);
    }
}
//OPERATII CU COADA
void adauga_in_coada(executie *c, int comanda, char valoare)
{
    element *nou = (element *)malloc(sizeof(element));
    nou->comanda = comanda;
    nou->valoare = valoare;
    nou->next = NULL;
    if(c->primul == NULL){
        c->primul = nou;
        c->ultimul = nou;
    }
    else {
        c->ultimul->next = nou;
        c->ultimul = nou;
    }
    //printf("AM ADAUGAT %d\n", comanda);
}
void scoate_din_coada(executie *c){
    if(c->primul == NULL){
        printf("Coada e deja goala\n");
        return;
    }
    element *aux;
    aux = c->primul;
    c->primul = c->primul->next;
    free(aux);
}
void afisare_coada(element *c)
{
    while(c!= NULL) {
        printf(" %d ", c->comanda);
        c = c->next;
    }
    printf("\n");
}

int main()
{
    FILE *f = fopen("tema1.in", "r");
    FILE *g = fopen("tema1.out", "w");
    char comanda[100],aux[2];
    char caracter;
    int numar,ok = 0, nr_comenzi, i;
    nod *temp;
    // am declarat banda si am alocat memorie pentru aceasta
    lista *banda = (lista*)malloc(sizeof(lista));
    // am alocat memorie pentru continutul initial al benzii si am legat
    // santinela de deget, initializand lista dublu inlantuita
    banda->santinela = (nod *)malloc(sizeof(nod));
    banda->deget = (nod *)malloc(sizeof(nod));
    banda->santinela->prev = NULL;
    banda->santinela->next = banda->deget;
    banda->deget->prev = banda->santinela;
    banda->deget->next = NULL;
    banda->santinela->val = 's';
    banda->deget->val = '#';
    // am initializat cele 2 stive, una pentru comanda undo si una pentru redo
    // si am alocat memorie pentru acestea
    stiva *undo = (stiva *)malloc(sizeof(stiva));
    stiva *redo = (stiva *)malloc(sizeof(stiva));
    // am initializat primul element din ambele stive cu NULL
    celula *head_redo = NULL;
    celula *head_undo = NULL; 
    // am initializat coada, am alocat memorie pentru aceasta si am
    // initializat atat primul, cat si ultimul element cu NULL
    executie *coada = (executie *)malloc(sizeof(executie));
    coada->primul = NULL;
    coada->ultimul = NULL;
    //am citit numarul de comenzi din fisier
    fscanf(f,"%d", &nr_comenzi);
    fgets(aux,2,f);
    // in acest for, citesc fiecare comanda si decid care sunt pasii ce
    // trebuie urmati in continuare
    for(i=0;i<nr_comenzi;i++){
        ok = 0;
        // variabila caracter va retine caracterul continut de o comanda
        // dar initial acesta este '\0'
        caracter = '\0';
        fgets(comanda, 100, f); 
        // m-am asigurat ca ultima comanda se termina in '\0' si nu in '\n'
        comanda[strlen(comanda)-1] = '\0';
       // fprintf(g, "COMANDA MEA : %s!\n", comanda); 
        //printf("%d", strcmp(comanda, "EXECUTE")); 
        //  intalinrea comenzii EXECUTE    
        if(strcmp(comanda, "EXECUTE") == 0){
            //printf("COMANDA EXECUTE\n");
            // numarul primei comenzi de tip UPDATE din coada
            numar = coada->primul->comanda;
            // inseamna ca s-a intalnit comanda MOVE_RIGHT
            if(numar == 1) {
                //printf("COMANDA MR\n");
                temp = banda->deget;
                move_right(banda);
                // deoarece este o operatie de tip MOVE am adaugat-o in stiva
                adauga_in_stiva(&head_undo,temp);
            }
            // inseamna ca s-a intalnit comanda MOVE_LEFT
            if(numar == 2) {
               // printf("COMANDA ML\n");
                temp = banda->deget;
                move_left(banda);
                // deoarece este o operatie de tip MOVE am adaugat-o in stiva
                adauga_in_stiva(&head_undo,temp);
            }
            // inseamna ca s-a intalnit comanda MOVE_RIGHT_CHAR
            if(numar == 3) {
                //printf("COMANDA MRC\n");
                temp = banda->deget;
                move_right_char(banda, coada->primul->valoare);
                // deoarece este o operatie de tip MOVE am adaugat-o in stiva
                adauga_in_stiva(&head_undo,temp);
            }
            // inseamna ca s-a intalnit comanda MOVE_LEFT_CHAR
            if(numar == 4) {
                //printf("COMANDA MLC\n");
                temp = banda->deget;
                move_left_char(banda, coada->primul->valoare, &ok, g);
                // deoarece este o operatie de tip MOVE am adaugat-o in stiva
                if(ok == 1) {
                    adauga_in_stiva(&head_undo,temp);
                }
            }
            // inseamna ca s-a intalnit comanda INSERT_RIGHT
            if(numar == 5) {
                //printf("COMANDA IR\n");
                insert_right_char(banda, coada->primul->valoare);
            }
            // inseamna ca s-a intalnit comanda INSERT_LEFT
            if(numar == 6) {
               // printf("COMANDA IL\n");
                insert_left_char(banda, coada->primul->valoare, g);
            }
            // inseamna ca s-a intalnit comanda WRITE
            if(numar == 7) {
               // printf("COMANDA WRITE\n");
                write(banda, coada->primul->valoare);
                // dupa fiecare operatie de WRITE executata, am golit stivele
                goleste_stiva(&head_undo);
                goleste_stiva(&head_redo);
            }
            //am scos din coada operatia executata
            scoate_din_coada(coada);
        }
        // cazul in care comanda intalnita este UNDO
        if(strcmp(comanda, "UNDO")==0){
            //printf("COMANDA UNDO\n");
            //am adaugat pointerul al pozitia curenta a degetului in varful
            //stivei pentru REDO
            //am modificat pozitia degetului pentru a indica pointerul extras
            // am extras apoi pointerul din varful stivei UNDO
            adauga_in_stiva(&head_redo, banda->deget);
            banda->deget = head_undo->val;
            //printf("DEGETUL!!!!\n");
            //show_current(banda);
            scoate_din_stiva(&head_undo);
        }
        // cazul in care comanda intalnita este REDO
        if(strcmp(comanda, "REDO")==0){
            //am adaugat pointerul al pozitia curenta a degetului in varful
            //stivei pentru UNDO
            //am modificat pozitia degetului pentru a indica pointerul extras
            // am extras apoi pointerul din varful stivei REDO
           // printf("COMANDA REDO\n");
            adauga_in_stiva(&head_undo, banda->deget);
            banda->deget = head_redo->val;
            scoate_din_stiva(&head_redo);
        }
        // cazul in care comanda intalnita este SHOW
        if(strcmp(comanda, "SHOW")==0){
           // printf("COMANDA SHOW\n");
            show(banda, g);
        }
        // cazul in care comanda intalnita este SHOW_CURENT
        if(strcmp(comanda, "SHOW_CURRENT")==0){
           // printf("COMANDA SC\n");
            show_current(banda, g);
        }
        //am verificat daca prima litera a comenzii este M, I sau W, intrucat
        //doar aceste comenzi trebuie adaugate in coada, restul putand fi
        //executate direct atunci cand sunt intalnite
        if(comanda[0] == 'M' || comanda[0] == 'I' || comanda[0] == 'W') {
            //printf("%c\n", comanda[strlen(comanda)-2]);
            if(comanda[strlen(comanda)-2] == ' ') {
                //printf("E DUBLA\n");
                caracter = comanda[strlen(comanda) - 1];
                comanda[strlen(comanda)-2] = '\0';
            }
            //printf("comanda:%s\n", comanda);
            if(strcmp(comanda, "MOVE_RIGHT") == 0){
                adauga_in_coada(coada,1,caracter);
            }
            if(strcmp(comanda, "MOVE_LEFT") == 0){
                adauga_in_coada(coada,2,caracter);
            }
            if(strcmp(comanda, "MOVE_RIGHT_CHAR") == 0){
                adauga_in_coada(coada,3,caracter);
            }
            if(strcmp(comanda, "MOVE_LEFT_CHAR") == 0){
                adauga_in_coada(coada,4,caracter);
            }
            if(strcmp(comanda, "INSERT_RIGHT") == 0){
                adauga_in_coada(coada,5,caracter);
            }
            if(strcmp(comanda, "INSERT_LEFT") == 0){
                adauga_in_coada(coada,6,caracter);
            }
            if(strcmp(comanda, "WRITE") == 0){
                adauga_in_coada(coada,7,caracter);
            }
        }  
        //show(banda); 
    }
    // fprintf(g, "ERROR\n");
    goleste_stiva(&head_undo);
    goleste_stiva(&head_redo);
    elibereaza_banda(banda);
    free(coada);
    free(undo);
    free(redo);
    free(banda);
    fclose(f);
    fclose(g);
    return 0;
}